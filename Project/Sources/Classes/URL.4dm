property scheme : Text:=""
property username : Text:=""
property password : Text:=""
property host : Text:=""
property _port : Integer:=0
property _path : Text:=""
property queryParams : Collection:=[]
property ref : Text:=""

Class constructor($inParam : Variant)
    
    Case of 
        : (Value type($inParam)=Is text)  // URL string
            This.parse($inParam)
            
        : (Value type($inParam)=Is object)  // URL object
            This.fromJSON($inParam)
    End case 
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _init()
    
    This.scheme:=""
    This.username:=""
    This.password:=""
    This.host:=""
    This._port:=0
    This._path:=""
    This.queryParams:=[]
    This.ref:=""
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function parse($inURL : Text)
    
    // Parse the URL into its components
    // Example: https://username:password@www.example.com:8080/path/to/resource?query=param#ref
    // Result:
    // scheme: https
    // username: username
    // password: password
    // host: www.example.com
    // host: www.example.com
    // port: 8080
    // path: /path/to/resource
    // query: query=param
    // ref: ref
    // queryParams: [{name: "query"; value: "param"}]
    
    This._init()
    
    If (Length($inURL)>0)
        
        // See: https://www.rfc-editor.org/rfc/rfc3986#appendix-B
        
        // Group1= "https:" 
        // Group2= "https"
        // Group3= "//username:password@www.example.com:8080"
        // Group4= "username:password@www.example.com:8080"
        // Group5= "/path/to/resource"
        // Group6= "?query=param"
        // Group7= "query=param"
        // Group8= "#ref"
        // Group9= "ref"
        
        ARRAY LONGINT($foundPos; 0)
        ARRAY LONGINT($foundLen; 0)
        
        var $pattern : Text:="^(([^:\\/?#]+):)?(\\/\\/([^\\/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"
        var $userInfoIndex : Integer:=0
        var $portIndex : Integer:=0
        var $pathIndex : Integer:=0
        var $queryIndex : Integer:=0
        var $hashIndex : Integer:=0
        var $userInfo : Text
        var $URLComponents : Collection
        
        If (Try(Match regex($pattern; $inURL; 1; $foundPos; $foundLen)))
            If (Size of array($foundPos)>8)
                
                // Extract scheme
                If ($foundPos{2}>0)
                    This.scheme:=Substring($inURL; $foundPos{2}; $foundLen{2})
                End if 
                
                // Extract host
                If ($foundPos{4}>0)
                    var $host : Text:=Substring($inURL; $foundPos{4}; $foundLen{4})
                    $userInfoIndex:=Position("@"; $host)
                    If ($userInfoIndex>0)
                        $userInfo:=Substring($host; 1; $userInfoIndex-1)
                        $host:=Substring($host; $userInfoIndex+1)
                        $URLComponents:=Split string($userInfo; ":"; sk ignore empty strings)
                        If ($URLComponents.length>0)
                            This.username:=$URLComponents[0]
                            If ($URLComponents.length>1)
                                This.password:=$URLComponents[1]
                            End if 
                        End if 
                    End if 
                    $URLComponents:=Split string($host; ":"; sk ignore empty strings)
                    If ($URLComponents.length>0)
                        This.host:=$URLComponents[0]
                        If ($URLComponents.length>1)
                            This._port:=Num($URLComponents[1])
                        End if 
                    Else 
                        This.host:=$host
                    End if 
                End if 
                
                // Extract path
                If ($foundPos{5}>0)
                    This._path:=Substring($inURL; $foundPos{5}; $foundLen{5})
                End if 
                
                // Extract query
                If ($foundPos{7}>0)
                    This.query:=Substring($inURL; $foundPos{7}; $foundLen{7})
                End if 
                
                // Extract ref
                If ($foundPos{9}>0)
                    This.ref:=Substring($inURL; $foundPos{9}; $foundLen{9})
                End if 
            End if 
            
        End if 
    End if 
    
    
    // ----------------------------------------------------
    
    
Function parseQuery($inQueryString : Text)
    
    // Example: ?query=param&anotherQuery=anotherParam
    // Result:
    // query: query=param&anotherQuery=anotherParam
    // queryParams: [{name: "query"; value: "param"}, {name: "abotherQuery"; value: "anotherParam"}]
    
    var $queryString : Text:=$inQueryString
    
    This.queryParams:=[]
    If (Position("?"; $queryString)=1)
        $queryString:=Substring($queryString; 2)
    End if 
    If (Length($queryString)>0)
        var $queryParams : Collection:=Split string($queryString; "&"; sk ignore empty strings)
        var $param; $name; $value : Text
        For each ($param; $queryParams)
            $name:=Substring($param; 1; Position("="; $param)-1)
            $value:=Substring($param; Position("="; $param)+1)
            This.queryParams.push({name: $name; value: $value})
        End for each 
    End if 
    
    
    // ----------------------------------------------------
    
    
Function toString() : Text
    
    // Convert the URL object to a string representation
    var $URL : Text:=""
    If (Length(This.host)>0)
        If (Length(This.scheme)>0)
            $URL+=This.scheme+"://"
        End if 
        If (Length(This.username)>0)
            $URL+=This.username
            If (Length(This.password)>0)
                $URL+=":"+This.password
            End if 
            $URL+="@"
        End if 
        $URL+=This.host
    End if 
    If (This._port>0)
        $URL+=":"+String(This._port)
    End if 
    If (Length(This._path)>0)
        $URL+=This._path
    End if 
    If (Length(This.query)>0)
        $URL+="?"+This.query
    End if 
    If (Length(This.ref)>0)
        $URL+="#"+This.ref
    End if 
    
    return $URL
    
    
    // ----------------------------------------------------
    
    
Function toJSON() : Object
    
    // Convert the URL object to a JSON representation
    var $json : Object:={}
    $json.scheme:=This.scheme
    $json.username:=This.username
    $json.password:=This.password
    $json.host:=This.host
    $json.port:=This.port
    $json.path:=This.path
    $json.query:=This.query
    $json.ref:=This.ref
    $json.queryParams:=This.queryParams
    return $json
    
    
    // ----------------------------------------------------
    
    
Function fromJSON($inURL : Object)
    
    // Convert a JSON representation to a URL object
    // Example: {scheme: "http"; host: "www.example.com"; port: 8080; path: "/path/to/resource"; query: "query=param"; ref: "hash"}
    // Result:
    // scheme: http
    // host: www.example.com
    // port: 8080
    This.scheme:=(Value type($inURL.scheme)=Is text) ? $inURL.scheme : ""
    This.username:=(Value type($inURL.username)=Is text) ? $inURL.username : ""
    This.password:=(Value type($inURL.password)=Is text) ? $inURL.password : ""
    This.host:=(Value type($inURL.host)=Is text) ? $inURL.host : ""
    This._port:=(Value type($inURL.port)#Is undefined) ? Num($inURL.port) : 0
    This._path:=(Value type($inURL.path)=Is text) ? $inURL.path : ""
    This.queryParams:=(Value type($inURL.queryParams)=Is collection) ? $inURL.queryParams : []
    This.ref:=(Value type($inURL.ref)=Is text) ? $inURL.ref : ""
    
    
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
            If (Value type($1)=Is text) && (Value type($2)=Is text)  // name string and value string
                This.queryParams.push({name: $1; value: $2})
            End if 
    End case 
    
    
    // ----------------------------------------------------
    
    
Function getDefaultPort() : Integer
    
    // Get default port based on scheme
    var $port : Integer:=0
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
    
    return $port
    
    
    // Mark: - Getters/Setters
    // ----------------------------------------------------
    
    
Function get query() : Text
    
    // Get the query string
    var $query : Text:=""
    If (This.queryParams.length>0)
        var $param : Object
        For each ($param; This.queryParams)
            $query+=$param.name+"="+$param.value+"&"
        End for each 
        $query:=Substring($query; 1; Length($query)-1)
    End if 
    return $query
    
    
    // ----------------------------------------------------
    
    
Function set query($inQueryString : Text)
    
    // Set the query string
    This.queryParams:=[]
    This.parseQuery($inQueryString)
    
    
    // ----------------------------------------------------
    
    
Function get port() : Integer
    
    // Get the port number
    If (This._port=0)
        return This.getDefaultPort()
    End if 
    
    return This._port
    
    
    // ----------------------------------------------------
    
    
Function set port($inPort : Integer)
    
    // Set the port number
    This._port:=$inPort
    
    
    // ----------------------------------------------------
    
    
Function get path() : Text
    
    // Get the path
    return This._path
    
    
    // ----------------------------------------------------
    
    
Function set path($inPath : Text)
    
    // Set the path 
    If ((Length($inPath)=0) || (Position("/"; $inPath)=1))
        This._path:=$inPath
    Else 
        This._path:="/"+$inPath
    End if 
