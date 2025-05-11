property scheme : Text
property host : Text
property _port : Integer
property path : Text
property queryParams : Collection
property hash : Text

Class constructor($inURL : Text; $inDecodeURL : Boolean)
    
    var $URL : Text:=Bool($inDecodeURL) ? cs.Tools.me.urlDecode($inURL) : $inURL
    
    This.parse($URL)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function parse($inURL : Text)
    
    // Parse the URL into its components
    // Example: https://www.example.com:8080/path/to/resource?query=param#hash
    // Result:
    // scheme: https
    // host: www.example.com
    // port: 8080
    // path: /path/to/resource
    // query: query=param
    // hash: hash
    // queryParams: [{name: "query"; value: "param"}]
    
    var $urlWithoutScheme : Text
    
    // Initialize properties
    This.scheme:="https"
    This.host:=""
    This.path:=""
    This.queryParams:=[]
    This.hash:=""
    This._port:=0
    
    // Extract scheme
    var $urlComponents : Collection:=Split string($inURL; "://"; sk ignore empty strings)
    If ($urlComponents.length>1)
        This.scheme:=$urlComponents[0]
        $urlWithoutScheme:=$urlComponents[1]
    Else 
        $urlWithoutScheme:=$inURL
    End if 
    
    // Extract host and port
    var $portIndex : Integer:=Position(":"; $urlWithoutScheme)
    var $pathIndex : Integer:=Position("/"; $urlWithoutScheme)
    If (($portIndex>0) && (($pathIndex=0) || ($portIndex<$pathIndex)))
        This.host:=Substring($urlWithoutScheme; 1; $portIndex-1)
        $urlWithoutScheme:=Substring($urlWithoutScheme; $portIndex+1)
        If ($pathIndex>0)
            This._port:=Num(Substring($urlWithoutScheme; 1; $pathIndex-$portIndex-1))
            $urlWithoutScheme:=Substring($urlWithoutScheme; $pathIndex-$portIndex)
        Else 
            This._port:=Num($urlWithoutScheme)
            $urlWithoutScheme:=""
        End if 
    Else 
        If ($pathIndex>0)
            This.host:=Substring($urlWithoutScheme; 1; $pathIndex-1)
            $urlWithoutScheme:=Substring($urlWithoutScheme; $pathIndex)
        Else 
            This.host:=$urlWithoutScheme
            $urlWithoutScheme:=""
        End if 
    End if 
    
    // Extract path
    var $queryIndex : Integer:=Position("?"; $urlWithoutScheme)
    var $hashIndex : Integer:=Position("#"; $urlWithoutScheme)
    If ($queryIndex>0)
        This.path:=Substring($urlWithoutScheme; 1; $queryIndex-1)
        $urlWithoutScheme:=Substring($urlWithoutScheme; $queryIndex)
    Else 
        If ($hashIndex>0)
            This.path:=Substring($urlWithoutScheme; 1; $hashIndex-1)
            $urlWithoutScheme:=Substring($urlWithoutScheme; $hashIndex)
        Else 
            This.path:=$urlWithoutScheme
            $urlWithoutScheme:=""
        End if 
    End if 
    
    // Extract query
    If (Position("?"; $urlWithoutScheme)>0)
        var $query : Text
        $hashIndex:=Position("#"; $urlWithoutScheme)
        If ($hashIndex>0)
            $query:=Substring($urlWithoutScheme; 2; $hashIndex-2)
            $urlWithoutScheme:=Substring($urlWithoutScheme; $hashIndex)
        Else 
            $query:=Substring($urlWithoutScheme; 2)
            $urlWithoutScheme:=""
        End if 
        If (Length($query)>0)
            var $queryParams : Collection:=Split string($query; "&"; sk ignore empty strings)
            var $param; $name; $value : Text
            For each ($param; $queryParams)
                $name:=Substring($param; 1; Position("="; $param)-1)
                $value:=Substring($param; Position("="; $param)+1)
                This.queryParams.push({name: $name; value: $value})
            End for each 
        End if 
    End if 
    
    // Extract hash
    If (Position("#"; $urlWithoutScheme)>0)
        This.hash:=Substring($urlWithoutScheme; 2)
    End if 
    
    
    // ----------------------------------------------------
    
    
Function toString() : Text
    
    // Convert the URL object to a string representation
    var $URL : Text:=This.scheme+"://"+This.host
    If (This._port>0)
        $URL+=":"+String(This._port)
    End if 
    If (Length(This.path)>0)
        $URL+=This.path
    End if 
    If (Length(This.query)>0)
        $URL+="?"+This.query
    End if 
    If (Length(This.hash)>0)
        $URL+="#"+This.hash
    End if 
    return $URL
    
    
    // ----------------------------------------------------
    
    
Function addQueryParameter( ...  : Variant)
    
    Case of 
        : (Count parameters=1)
            Case of 
                : (Value type($1)=Is object)  // {name: "name"; value: "value"} object
                    If ((Value type($1.name)=Is text) && (Value type($1.value)=Is text))
                        This.queryParams.push({name: $1.name; value: $1.value})
                    End if 
                    
                : (Value type($1)=Is text)  // name=value string
                    If (Position("="; $1)>1)
                        var $name : Text:=Substring($1; 1; Position("="; $1)-1)
                        var $value : Text:=Substring($1; Position("="; $1)+1)
                        This.queryParams.push({name: $name; value: $value})
                    End if 
            End case 
            
        : (Count parameters=2)
            If (Value type($1)=Is text) && (Value type($2)=Is text)  // timestamp string and timezone string
                This.queryParams.push({name: $1; value: $2})
            End if 
    End case 
    
    
    // Mark: - Getters
    // ----------------------------------------------------
    
    
Function get query() : Text
    
    // Get the query string
    var $query : Text:=""
    If (This.queryParams.length>0)
        var $param : Object
        For each ($param; This.queryParams)
            $query+=$param.name+"="+cs.Tools.me.urlEncode($param.value)+"&"
        End for each 
        $query:=Substring($query; 1; Length($query)-1)
    End if 
    return $query
    // ----------------------------------------------------
    
    
Function get port() : Integer
    
    // Get the port number
    var $port : Integer:=This._port
    If ($port=0)
        // Set default port based on scheme
        Case of 
            : (This.scheme="ftp")
                $port:=21
            : (This.scheme="sftp")
                $port:=22
            : (This.scheme="smtp")
                $port:=25
            : (This.scheme="pop3")
                $port:=110
            : (This.scheme="imap")
                $port:=143
            : (This.scheme="ldap")
                $port:=389
            : (This.scheme="ldaps")
                $port:=636
            : ((This.scheme="http") || (This.scheme="ws"))
                $port:=80
            : ((This.scheme="https") || (This.scheme="wss"))
                $port:=443
        End case 
    End if 
    return $port
