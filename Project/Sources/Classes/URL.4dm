property scheme : Text
property username : Text
property password : Text
property host : Text
property _port : Integer
property _path : Text
property queryParams : Collection
property ref : Text

Class constructor($inParam : Variant)
    
    Case of 
        : (Value type($inParam)=Is text)  // URL string
            This.parse($inParam)
            
        : (Value type($inParam)=Is object)  // URL object
            This.fromJSON($inParam)
    End case 
    
    
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
    
    var $urlWithoutScheme : Text
    
    // Initialize properties
    This.scheme:=""
    This.username:=""
    This.password:=""
    This.host:=""
    This._path:=""
    This.queryParams:=[]
    This.ref:=""
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
    var $userInfoIndex : Integer:=Position("@"; $urlWithoutScheme)
    var $portIndex : Integer:=Position(":"; $urlWithoutScheme; $userInfoIndex)
    var $pathIndex : Integer:=Position("/"; $urlWithoutScheme)
    var $queryIndex : Integer:=Position("?"; $urlWithoutScheme)
    var $hashIndex : Integer:=Position("#"; $urlWithoutScheme)
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
            If ($queryIndex>0)
                This.host:=Substring($urlWithoutScheme; 1; $queryIndex-1)
                $urlWithoutScheme:=Substring($urlWithoutScheme; $queryIndex)
            Else 
                If (hashIndex>0)
                    This.host:=Substring($urlWithoutScheme; 1; $hashIndex-1)
                    $urlWithoutScheme:=Substring($urlWithoutScheme; $hashIndex)
                Else 
                    // No port, path, or query/hash
                    // Set host to the entire URL without scheme
                    This.host:=$urlWithoutScheme
                    $urlWithoutScheme:=""
                End if 
            End if 
        End if 
    End if 
    
    // Extract username and password
    $userInfoIndex:=Position("@"; This.host)
    If ($userInfoIndex>0)
        var $userInfo : Text:=Substring(This.host; 1; $userInfoIndex-1)
        This.host:=Substring(This.host; $userInfoIndex+1)
        var $userInfoComponents : Collection:=Split string($userInfo; ":"; sk ignore empty strings)
        If ($userInfoComponents.length>0)
            This.username:=$userInfoComponents[0]
            If ($userInfoComponents.length>1)
                This.password:=$userInfoComponents[1]
            End if 
        End if 
    End if 
    
    // Extract path
    $queryIndex:=Position("?"; $urlWithoutScheme)
    $hashIndex:=Position("#"; $urlWithoutScheme)
    If ($queryIndex>0)
        This._path:=Substring($urlWithoutScheme; 1; $queryIndex-1)
        $urlWithoutScheme:=Substring($urlWithoutScheme; $queryIndex)
    Else 
        If ($hashIndex>0)
            This._path:=Substring($urlWithoutScheme; 1; $hashIndex-1)
            $urlWithoutScheme:=Substring($urlWithoutScheme; $hashIndex)
        Else 
            This._path:=$urlWithoutScheme
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
            This.parseQuery($query)
        End if 
    End if 
    
    // Extract hash
    If (Position("#"; $urlWithoutScheme)>0)
        This.ref:=Substring($urlWithoutScheme; 2)
    End if 
    
    
    // ----------------------------------------------------
    
    
Function parseQuery($inQueryString : Text)
    
    // Example: ?query=param&anotherQuery=anotherParam
    // Result:
    // query: query=param&anotherQuery=anotherParam
    // queryParams: [{name: "query"; value: "param"}, {name: "abotherQuery"; value: "anotherParam"}]
    
    var $queryString : Text:=$inQueryString
    
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
    This._port:=(Value type($inURL.port)#Is undefined) ? $inURL.port : 0
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
    If (Position("/"; $inPath)=1)
        This._path:=$inPath
    Else 
        This._path:="/"+$inPath
    End if 
