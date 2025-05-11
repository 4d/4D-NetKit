property URL : Text
property scheme : Text
property host : Text
property port : Integer
property path : Text
property queryParams : Collection
property hash : Text

Class constructor($inURL : Text)
    
    This.parse(cs.Tools.me.urlDecode($inURL))
    
    
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
    
    var $urlComponents : Collection
    var $urlWithoutScheme : Text
    var $portIndex : Integer
    var $pathIndex : Integer
    var $queryIndex : Integer
    var $hashIndex : Integer
    
    // Initialize properties
    This.scheme:="https"
    This.host:=""
    This.port:=0
    This.path:=""
    This.queryParams:=[]
    This.hash:=""
    
    // Extract scheme
    $urlComponents:=Split string($inURL; "://"; sk ignore empty strings)
    If ($urlComponents.length>1)
        This.scheme:=$urlComponents[0]
        $urlWithoutScheme:=$urlComponents[1]
    Else 
        $urlWithoutScheme:=$inURL
    End if 
    
    // Extract host and port
    $portIndex:=Position(":"; $urlWithoutScheme)
    $pathIndex:=Position("/"; $urlWithoutScheme)
    If (($portIndex>0) && (($pathIndex=0) || ($portIndex<$pathIndex)))
        This.host:=Substring($urlWithoutScheme; 1; $portIndex-1)
        $urlWithoutScheme:=Substring($urlWithoutScheme; $portIndex+1)
        If ($pathIndex>0)
            This.port:=Num(Substring($urlWithoutScheme; 1; $pathIndex-$portIndex-1))
            $urlWithoutScheme:=Substring($urlWithoutScheme; $pathIndex-$portIndex)
        Else 
            This.port:=Num($urlWithoutScheme)
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
    $queryIndex:=Position("?"; $urlWithoutScheme)
    $hashIndex:=Position("#"; $urlWithoutScheme)
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
    var $url : Text
    $url:=This.scheme+"://"+This.host
    If (This.port>0)
        $url+=":"+String(This.port)
    End if 
    If (Length(This.path)>0)
        $url+=This.path
    End if 
    If (Length(This.query)>0)
        $url+="?"+This.query
    End if 
    If (Length(This.hash)>0)
        $url+="#"+This.hash
    End if 
    return $url
    
    
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