/**
 * @class _URL
 * @description Parses and manages URL components according to RFC 3986
 * @example
 *   var $url := cs._URL.new("https://user:pass@example.com:8080/path?key=value#hash")
 *   $url.host  // "example.com"
 *   $url.port  // 8080
 *   $url.addQueryParameter("page"; "1")
 */

property scheme : Text:=""
property username : Text:=""
property password : Text:=""
property host : Text:=""
property _port : Integer:=0
property _path : Text:=""
property queryParams : Collection:=[]
property ref : Text:=""

Class constructor($inParam : Variant)
/**
 * @constructor
 * @param {Variant} $inParam - URL string or object to parse
 */
    
    Case of 
        : (Value type($inParam)=Is text)  // URL string
            This.parse($inParam)
            
        : (Value type($inParam)=Is object)  // URL object
            This.fromJSON($inParam)
    End case 
    
    
    // Mark: - [Private]
	// ----------------------------------------------------


Function _init()
/**
 * @function _init
 * @private
 * @description Resets all URL components to default values
 */
    
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
/**
 * @function parse
 * @param {Text} $inURL - URL string to parse (RFC 3986)
 * @description Parses a URL string into its components
 * @example
 *   var $url := cs._URL.new()
 *   $url.parse("https://user:pass@example.com:8080/path?key=value#hash")
 * @see https://www.rfc-editor.org/rfc/rfc3986#appendix-B
 */
    
    This._init()
    
    If (Length($inURL)=0)
        return 
    End if 
    
    // See: https://www.rfc-editor.org/rfc/rfc3986#appendix-B
    // Regex groups:
    // Group 1: "https:" (scheme with colon)
    // Group 2: "https" (scheme only)
    // Group 3: "//username:password@www.example.com:8080" (authority)
    // Group 4: "username:password@www.example.com:8080" (authority without //)
    // Group 5: "/path/to/resource" (path)
    // Group 6: "?query=param" (query with ?)
    // Group 7: "query=param" (query without ?)
    // Group 8: "#ref" (fragment with #)
    // Group 9: "ref" (fragment without #)
    
    ARRAY LONGINT($foundPos; 0)
    ARRAY LONGINT($foundLen; 0)
    
    var $pattern : Text:="^(([^:\\/?#]+):)?(\\/\\/([^\\/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?$"
    var $userInfoIndex : Integer:=0
    var $portIndex : Integer:=0
    var $userInfo : Text
    var $URLComponents : Collection
    
    If (Try(Match regex($pattern; $inURL; 1; $foundPos; $foundLen)))
        If (Size of array($foundPos)>8)
            
            // Extract scheme
            If ($foundPos{2}>0)
                This.scheme:=Lowercase(Substring($inURL; $foundPos{2}; $foundLen{2}))
            End if 
            
            // Extract host
            If ($foundPos{4}>0)
                var $host : Text:=Substring($inURL; $foundPos{4}; $foundLen{4})
                $userInfoIndex:=Position("@"; $host)
                If ($userInfoIndex>0)
                    $userInfo:=Substring($host; 1; $userInfoIndex-1)
                    $host:=Substring($host; $userInfoIndex+1)
                    $URLComponents:=Split string($userInfo; ":")
                    If ($URLComponents.length>0)
                        This.username:=$URLComponents[0]
                        If ($URLComponents.length>1)
                            This.password:=$URLComponents[1]
                        End if 
                    End if 
                End if 
                $URLComponents:=[]
                var $posLeftBrackets : Integer:=Position("["; $host)
                var $posRightBrackets : Integer:=Position("]"; $host)
                If (($posLeftBrackets>0) && ($posRightBrackets>0) && ($posLeftBrackets<$posRightBrackets))
                    // IPv6 address
                    This.host:=Substring($host; $posLeftBrackets; $posRightBrackets-$posLeftBrackets+1)
                    $portIndex:=Position(":"; $host; $posRightBrackets+1)
                    If ($portIndex>0)
                        This._port:=Num(Substring($host; $portIndex+1))
                    End if 
                Else 
                    // Regular host
                    $URLComponents:=Split string($host; ":")
                    If ($URLComponents.length>0)
                        This.host:=$URLComponents[0]
                        If ($URLComponents.length>1)
                            This._port:=Num($URLComponents[1])
                        End if 
                    End if 
                End if 
            End if 
            
            // Extract path
            If ($foundPos{5}>0)
                This._path:=Substring($inURL; $foundPos{5}; $foundLen{5})
            End if 
            
            // Extract query
            If ($foundPos{7}>0)
                This.parseQuery(Substring($inURL; $foundPos{7}; $foundLen{7}))
            End if 
            
            // Extract ref
            If ($foundPos{9}>0)
                This.ref:=Substring($inURL; $foundPos{9}; $foundLen{9})
            End if 
        End if 
        
    End if 
    
    
    // -----------------------------------------------------------
    
    
Function parseQuery($inQueryString : Text)
/**
 * @function parseQuery
 * @param {Text} $inQueryString - Query string (with or without leading ?)
 * @description Parses a query string into queryParams collection
 * @example
 *   $url.parseQuery("key=value&page=1")
 *   // queryParams: [{name: "key"; value: "value"}, {name: "page"; value: "1"}]
 */
    
    var $queryString : Text:=$inQueryString
    
    This.queryParams:=[]
    If (Length($queryString)=0)
        return 
    End if 
    
    If (Position("?"; $queryString)=1)
        $queryString:=Substring($queryString; 2)
    End if 
    If (Length($queryString)>0)
        var $queryParams : Collection:=Split string($queryString; "&"; sk ignore empty strings)
        var $param; $name; $value : Text
        For each ($param; $queryParams)
            $param:=Trim($param)
            If (Length($param)>0)
                If (Position("="; $param)>0)
                    $name:=Trim(Substring($param; 1; Position("="; $param)-1))
                    $value:=Substring($param; Position("="; $param)+1)
                    If (Length($name)>0)
                        This.queryParams.push({name: $name; value: $value})
                    End if 
                Else 
                    $name:=Trim($param)
                    If (Length($name)>0)
                        This.queryParams.push({name: $name; value: ""})
                    End if 
                End if 
            End if 
        End for each 
    End if 
    
    
    // -----------------------------------------------------------
    
    
Function toString() : Text
/**
 * @function toString
 * @returns {Text} URL as string
 * @description Reconstructs URL string from components
 * @example
 *   $url.toString()  // "https://user:pass@example.com:8080/path?key=value#hash"
 */
    
    var $URL : Text:=""
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
    If (Length(This.host)>0)
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
    
    
    // -----------------------------------------------------------
    
    
Function toJSON() : Object
/**
 * @function toJSON
 * @returns {Object} URL as JSON object
 * @description Converts URL to JSON representation
 * @example
 *   var $json := $url.toJSON()
 *   // {scheme: "https"; host: "example.com"; port: 8080; ...}
 */
    
    var $json : Object:={}
    $json.scheme:=This.scheme
    $json.username:=This.username
    $json.password:=This.password
    $json.host:=This.host
    $json.port:=This._port
    $json.path:=This._path
    $json.query:=This.query
    $json.ref:=This.ref
    $json.queryParams:=This.queryParams
    return $json
    
    
    // -----------------------------------------------------------


Function fromJSON($inURL : Object)
/**
 * @function fromJSON
 * @param {Object} $inURL - URL object with components
 * @description Loads URL from JSON object representation
 * @example
 *   $url.fromJSON({scheme: "https"; host: "example.com"; port: 443})
 */
    
    This.scheme:=(Value type($inURL.scheme)=Is text) ? $inURL.scheme : ""
    This.username:=(Value type($inURL.username)=Is text) ? $inURL.username : ""
    This.password:=(Value type($inURL.password)=Is text) ? $inURL.password : ""
    This.host:=(Value type($inURL.host)=Is text) ? $inURL.host : ""
    This._port:=(Value type($inURL.port)#Is undefined) ? Num($inURL.port) : 0
    This._path:=(Value type($inURL.path)=Is text) ? $inURL.path : ""
    This.ref:=(Value type($inURL.ref)=Is text) ? $inURL.ref : ""
    
    // Handle query data - prioritize queryParams collection over query string
    This.queryParams:=[]
    
    If (Value type($inURL.queryParams)=Is collection)
        This.queryParams:=$inURL.queryParams
    Else 
        If (Value type($inURL.query)=Is text)
            This.parseQuery($inURL.query)
        End if 
    End if 
    
    
    // -----------------------------------------------------------
    
    
Function addQueryParameter( ...  : Variant)
/**
 * @function addQueryParameter
 * @param {...Variant} - Variable arguments: object, string, or (name; value) pair
 * @description Adds query parameter to URL
 * @example
 *   $url.addQueryParameter("key"; "value")
 *   $url.addQueryParameter({name: "key"; value: "value"})
 *   $url.addQueryParameter("key=value")
 */
    
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
    
    
    // -----------------------------------------------------------


Function getQueryString() : Text
/**
 * @function getQueryString
 * @returns {Text} Query string with leading ? if present
 * @description Gets the full query string with ? prefix
 */
    
    If (Length(This.query)>0)
        return "?"+This.query
    End if 
    return ""
    
    
    // -----------------------------------------------------------


Function getDefaultPort() : Integer
/**
 * @function getDefaultPort
 * @returns {Integer} Default port for the URL scheme (80 for http, 443 for https, etc.)
 * @description Returns default port based on URL scheme
 */
    
    Case of 
        : ((This.scheme="http") || (This.scheme="ws"))
            return 80
        : ((This.scheme="https") || (This.scheme="wss"))
            return 443
    End case 
    
    return 0
    
    
    // Mark: - Getters/Setters
    // -----------------------------------------------------------


Function get query() : Text
/**
 * @function get query
 * @returns {Text} Query string built from queryParams
 * @description Gets query string from query parameters collection
 */
    
    var $query : Text:=""
    If (This.queryParams.length>0)
        var $param : Object
        For each ($param; This.queryParams)
            If ((Value type($param.name)=Is text) && (Value type($param.value)=Is text))
                $query+=$param.name+"="+$param.value+"&"
            End if 
        End for each 
        If (Length($query)>0)
            $query:=Substring($query; 1; Length($query)-1)
        End if 
    End if 
    return $query
    
    
    // -----------------------------------------------------------

    
Function set query($inQueryString : Text)
/**
 * @function set query
 * @param {Text} $inQueryString - Query string to set
 * @description Sets query string and parses it into queryParams
 */
    
    This.queryParams:=[]
    This.parseQuery($inQueryString)
    
    
    // -----------------------------------------------------------

    
Function get port() : Integer
/**
 * @function get port
 * @returns {Integer} Port number (or default port if not set)
 * @description Gets the port number, returns default port if not explicitly set
 */
    
    If (This._port=0)
        return This.getDefaultPort()
    End if 
    
    return This._port
    
    
    // -----------------------------------------------------------

    
Function set port($inPort : Integer)
/**
 * @function set port
 * @param {Integer} $inPort - Port number (0-65535)
 * @description Sets port number with validation
 */
    
    If (($inPort>=0) && ($inPort<=65535))
        This._port:=$inPort
    End if 
    
    
    // -----------------------------------------------------------

    
Function get path() : Text
/**
 * @function get path
 * @returns {Text} URL path component
 * @description Gets the path component
 */
    
    return This._path
    
    
    // -----------------------------------------------------------

    
Function set path($inPath : Text)
/**
 * @function set path
 * @param {Text} $inPath - URL path (automatically adds leading / if missing)
 * @description Sets the path component with automatic normalization
 */
    
    If ((Length($inPath)=0) || (Position("/"; $inPath)=1))
        This._path:=$inPath
    Else 
        This._path:="/"+$inPath
    End if 
    
    
    // Mark: - Utility Methods
    // -----------------------------------------------------------

    
Function isValid() : Boolean
/**
 * @function isValid
 * @returns {Boolean} true if URL has required components (scheme, host)
 * @description Validates that URL has minimum required components
 */
    
    return (Length(This.scheme)>0) && (Length(This.host)>0)
    
    
    // -----------------------------------------------------------

    
Function isAbsolute() : Boolean
/**
 * @function isAbsolute
 * @returns {Boolean} true if URL is absolute (has scheme)
 * @description Checks if URL is absolute (not relative)
 */
    
    return (Length(This.scheme)>0)
    
    
    // -----------------------------------------------------------

    
Function clone() : Object
/**
 * @function clone
 * @returns {Object} Deep copy of this URL object
 * @description Creates a complete copy of the URL object
 */
    
    var $cloned : cs._URL:=cs._URL.new("")
    $cloned.scheme:=This.scheme
    $cloned.username:=This.username
    $cloned.password:=This.password
    $cloned.host:=This.host
    $cloned._port:=This._port
    $cloned._path:=This._path
    $cloned.ref:=This.ref
    $cloned.queryParams:=[]
    
    // Deep copy queryParams
    var $param : Object
    For each ($param; This.queryParams)
        $cloned.queryParams.push({name: $param.name; value: $param.value})
    End for each 
    
    return $cloned
    
    
    // -----------------------------------------------------------

    
Function clear()
/**
 * @function clear
 * @description Resets all URL components to empty values
 */
    
    This._init()
    
    
    // -----------------------------------------------------------

    
Function removeQueryParameter( ... : Variant) : Boolean
/**
 * @function removeQueryParameter
 * @param {Text} $paramName - Name of query parameter to remove
 * @param {Boolean} [$removeAll=False] - When true, removes all matching parameters
 * @returns {Boolean} true if parameter was found and removed
 * @description Removes query parameter(s) by name from queryParams collection
 * @example
 *   $url.removeQueryParameter("page")  // removes page parameter
 *   $url.removeQueryParameter("tag"; True)  // removes all tag parameters
 */
    
    var $paramName : Text:=""
    var $removeAll : Boolean:=False
    var $found : Boolean:=False
    var $param : Object
    var $newQueryParams : Collection:=[]
    
    Case of 
        : ((Count parameters=1) && (Value type($1)=Is text))
            $paramName:=$1
        : ((Count parameters=2) && (Value type($1)=Is text) && (Value type($2)=Is boolean))
            $paramName:=$1
            $removeAll:=$2
        Else 
            return False
    End case 
    
    For each ($param; This.queryParams)
        If ($param.name=$paramName)
            If (($removeAll=False) && $found)
                $newQueryParams.push($param)
            Else 
                $found:=True
            End if 
        Else 
            $newQueryParams.push($param)
        End if 
    End for each 
    
    If ($found)
        This.queryParams:=$newQueryParams
    End if 
    
    return $found
    
    
    // -----------------------------------------------------------
    

Function hasQueryParameter($paramName : Text) : Boolean
/**
 * @function hasQueryParameter
 * @param {Text} $paramName - Name of query parameter to check
 * @returns {Boolean} true if at least one parameter with this name exists
 * @description Checks whether a query parameter exists by name
 */
    
    var $param : Object
    For each ($param; This.queryParams)
        If ($param.name=$paramName)
            return True
        End if 
    End for each 
    
    return False
    
    
    // -----------------------------------------------------------
    
    
Function getQueryParameter($paramName : Text) : Text
/**
 * @function getQueryParameter
 * @param {Text} $paramName - Name of query parameter to retrieve
 * @returns {Text} Value of the parameter, or empty string if not found
 * @description Gets query parameter value by name
 * @example
 *   var $page := $url.getQueryParameter("page")
 */
    
    var $param : Object
    For each ($param; This.queryParams)
        If ($param.name=$paramName)
            return $param.value
        End if 
    End for each 
    
    return ""
