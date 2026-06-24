/**
 * @class _Tools
 * @singleton
 * @description Utility singleton providing shared helpers for string manipulation,
 *   URL and email parsing, web server management, and error building
 */

property webServer : 4D.WebServer
property isDebug : Boolean
property trace : Boolean
property webLicenseAvailable : Boolean
property notificationMode : Boolean


singleton Class constructor()
/**
 * @constructor
 * @description Initializes the singleton with default property values
 */
	
	This.webServer:=WEB Server(Web server database)
	This.isDebug:=False
	This.trace:=False
	This.webLicenseAvailable:=False
	This.notificationMode:=False
	
	
Function init()
/**
 * @function init
 * @description Detects and stores web license availability based on the current application type
 */
	
	If (Application type=4D Remote mode)
		cs._Tools.me.webLicenseAvailable:=Is license available(4D Client Web license)
	Else 
		cs._Tools.me.webLicenseAvailable:=(Is license available(4D Web license) | Is license available(4D Web local license) | Is license available(4D Web one connection license))
	End if 
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function base64UrlSafeDecode($inBase64Encoded : Text) : Text
/**
 * @function base64UrlSafeDecode
 * @param {Text} $inBase64Encoded - URL-safe Base64 encoded string
 * @returns {Text} Decoded plain text
 * @description Decodes a URL-safe Base64 string, converting _ to / and - to + before decoding,
 *   and adding = padding as needed
 * @example base64UrlSafeDecode("SGVsbG8gV29ybGQ") // → "Hello World"
 */
	
/*
    Largely inspired by UTL_base64UrlSafeDecode.4dm 
    From blegay's acme_component here: https://github.com/blegay/acme_component
    
    MIT License
    
    Copyright (c) 2020 blegay
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/
	
	var $outDecodedString : Text
	
	If (Asserted(Count parameters>0; "requires 1 parameter"))
		
		// replace the "\r" and "/n" we may find...
		$inBase64Encoded:=Replace string($inBase64Encoded; "\r"; ""; *)
		$inBase64Encoded:=Replace string($inBase64Encoded; "\n"; ""; *)
		
		$inBase64Encoded:=Replace string($inBase64Encoded; "_"; "/"; *)  // convert "_" to "/"
		$inBase64Encoded:=Replace string($inBase64Encoded; "-"; "+"; *)  // convert "-" to "+"
		
		// if the base64 encoded does not contain the padding characters ("="), lets add them
		// base64 encoded data should have a length multiple of 4
		var $padModulo : Integer:=Mod(Length($inBase64Encoded); 4)
		If ($padModulo>0)
			$inBase64Encoded:=$inBase64Encoded+((4-$padModulo)*"=")
		End if 
		
		BASE64 DECODE($inBase64Encoded; $outDecodedString)  // decode to plain text
		
	End if 
	
	return $outDecodedString
	
	
	// ----------------------------------------------------
	
	
Function camelCase($inString : Text) : Text
/**
 * @function camelCase
 * @param {Text} $inString - Input string
 * @returns {Text} camelCase version of the string
 * @description Converts a string to camelCase using spaces and common punctuation as word separators
 * @example camelCase("hello world") // → "helloWorld"
 * @example camelCase("Content-Type") // → "contentType"
 */
	
	var $result : Text:=""
	var $string : Text:=Lowercase($inString; *)
	var $wordSep : Text:=" ,;:=?./\\±_@#&(!)*+=%\t\r\n"
	var $uppercase : Boolean:=False
	var $length : Integer:=Length($string)
	var $i : Integer
	
	For ($i; 1; $length)
		
		var $char : Text:=Substring($string; $i; 1)
		
		Case of 
			: (Position($char; $wordSep; *)>0)
				$uppercase:=True
				
			Else 
				If ($uppercase)
					$result:=$result+Uppercase($char)
				Else 
					$result:=$result+$char
				End if 
				$uppercase:=False
		End case 
	End for 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function convertToGraphAttachment($inObject : cs.GraphAttachment) : Object
/**
 * @function convertToGraphAttachment
 * @param {cs.GraphAttachment} $inObject - GraphAttachment instance to convert
 * @returns {Object} microsoft.graph.fileAttachment object, or Null if $inObject is not a GraphAttachment
 */
	
	var $result : Object:=Null
	
	// converts cs.GraphAttachment into microsoft.graph.fileAttachment
	If (OB Instance of($inObject; cs.GraphAttachment))
		
		//%W-550.26
		$result:={}
		$result["@odata.type"]:=(Length(String($inObject["@odata.type"]))>0) ? \
			$inObject["@odata.type"] : "#microsoft.graph.fileAttachment"
		If (Length(String($inObject.cid))>0)
			$result.contentId:=String($inObject.cid)
		End if 
		If (String($inObject.disposition)="inline")
			$result.isInline:=True
		End if 
		If (Length(String($inObject.name))>0)
			$result.name:=String($inObject.name)
		End if 
		If (Length(String($inObject.type))>0)
			$result.contentType:=String($inObject.type)
		End if 
		If (Not(OB Is defined($inObject; "contentBytes")))
			// Calling .getContent() will populate the contentBytes property, so we need to call it at least once to ensure contentBytes is available for the GraphAttachment
			$inObject.getContent()
		End if 
		$result.contentBytes:=$inObject.contentBytes
		$result.size:=$inObject.size
		//%W+550.26
		
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function cleanGraphObject($inObject : Object) : Object
/**
 * @function cleanGraphObject
 * @param {Object} $inObject - Object to clean
 * @returns {Object} Copy of $inObject with all @odata keys and Null values removed
 */
	
	var $cleanObject : Object:=OB Copy($inObject)
	var $keys : Collection:=OB Keys($cleanObject)
	var $key : Text
	For each ($key; $keys)
		If ((Position("@"; $key)=1) || ($cleanObject[$key]=Null))
			OB REMOVE($cleanObject; $key)
		End if 
	End for each 
	
	return $cleanObject
	
	
	// ----------------------------------------------------
	
	
Function getHeaderValueParameter($headerValue : Text; $paramName : Text; $defaultValue : Text) : Text
/**
 * @function getHeaderValueParameter
 * @param {Text} $headerValue - Full header value string
 * @param {Text} $paramName - Parameter name to look up
 * @param {Text} $defaultValue - Value to return if the parameter is not found
 * @returns {Text} Parameter value, or $defaultValue if not found
 * @example getHeaderValueParameter("text/html; charset=utf-8"; "charset"; "utf-8") // → "utf-8"
 */
	
	var $result : Text:=This.getParameterValue($headerValue; $paramName)
	If (Length($result)=0)
		$result:=$defaultValue
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function getParameterValue($headerValue : Text; $paramName : Text) : Text
/**
 * @function getParameterValue
 * @param {Text} $headerValue - Full header value string
 * @param {Text} $paramName - Parameter name to look up
 * @returns {Text} Parameter value (quoted or unquoted), or "" if not found
 * @example getParameterValue("attachment; filename=\"report.pdf\""; "filename") // → "report.pdf"
 * @example getParameterValue("text/html; charset=utf-8"; "charset") // → "utf-8"
 */
	
	var $search : Text:=$paramName+"="
	var $pos : Integer:=Position($search; $headerValue)
	
	If ($pos>0)
		var $valueStart : Integer:=$pos+Length($search)
		var $firstChar : Text:=Substring($headerValue; $valueStart; 1)
		
		If ($firstChar="\"")
			// Quoted value: extract between the two double-quotes
			$valueStart+=1
			var $closeQuote : Integer:=Position("\""; $headerValue; $valueStart)
			If ($closeQuote>0)
				return Substring($headerValue; $valueStart; $closeQuote-$valueStart)
			End if 
		Else 
			// Unquoted value: ends at ';' or end of string
			var $end : Integer:=Position(";"; $headerValue; $valueStart)
			If ($end=0)
				$end:=Length($headerValue)+1
			End if 
			return Trim(Substring($headerValue; $valueStart; $end-$valueStart))
		End if 
	End if 
	
	return ""
	
	
	// ----------------------------------------------------
	
	
Function getJMAPAttribute($inKey : Text) : Text
/**
 * @function getJMAPAttribute
 * @param {Text} $inKey - Raw email header or Gmail API key
 * @returns {Text} Corresponding JMAP attribute name, or "" if no mapping exists
 * @example getJMAPAttribute("Subject") // → "subject"
 * @example getJMAPAttribute("From") // → "from"
 */
	
	var $mapping : Object:={id: "id"; threadId: "threadId"; sizeEstimate: "size"; snippet: "preview"; Date: "receivedAt"; Subject: "subject"; labelIds: "mailboxIds"; MessageId: "messageId"; From: "from"; Sender: "sender"; To: "to"; Cc: "cc"; ReplyTo: "replyTo"; InReplyTo: "inReplyTo"; Keywords: "keywords"}
	var $key : Text:=Replace string($inKey; "-"; "")
	return OB Is defined($mapping; $key) ? String($mapping[$key]) : ""
	
	
	// ----------------------------------------------------
	
	
Function getDomainFromURL($inURL : Text) : Text
/**
 * @function getDomainFromURL
 * @param {Text} $inURL - Full URL string
 * @returns {Text} Host (domain) component of the URL
 * @example getDomainFromURL("https://www.example.com/path") // → "www.example.com"
 */
	
	var $URL : cs._URL:=cs._URL.new($inURL)
	
	return $URL.host
	
	
	// ----------------------------------------------------
	
	
Function getPathFromURL($inURL : Text) : Text
/**
 * @function getPathFromURL
 * @param {Text} $inURL - Full URL string
 * @returns {Text} Path component of the URL
 * @example getPathFromURL("https://www.example.com/path/to/resource") // → "/path/to/resource"
 */
	
	var $URL : cs._URL:=cs._URL.new($inURL)
	
	return $URL.path
	
	
	// ----------------------------------------------------
	
	
Function getPortFromURL($inURL : Text) : Integer
/**
 * @function getPortFromURL
 * @param {Text} $inURL - Full URL string
 * @returns {Integer} Port number, or scheme default port if not explicitly set
 * @example getPortFromURL("https://www.example.com:8443/path") // → 8443
 * @example getPortFromURL("https://www.example.com/path") // → 443
 */
	
	var $URL : cs._URL:=cs._URL.new($inURL)
	
	return $URL.port
	
	
	// ----------------------------------------------------
	
	
Function getURLParameterValue($inURL : Text; $inParamName : Text) : Text
/**
 * @function getURLParameterValue
 * @param {Text} $inURL - Full URL string
 * @param {Text} $inParamName - Query parameter name to look up
 * @returns {Text} Query parameter value, or "" if not found
 * @example getURLParameterValue("https://example.com?code=abc123"; "code") // → "abc123"
 */
	
	var $result : Text:=""
	var $URL : cs._URL:=cs._URL.new($inURL)
	var $foundParam : Object:=$URL.queryParams.find(Formula($1.value.name=$2); $inParamName)
	
	If ((Value type($foundParam)=Is object) && (OB Is defined($foundParam; "value")))
		$result:=$foundParam.value
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function isEmailAddressHeader($inKey : Text) : Boolean
/**
 * @function isEmailAddressHeader
 * @param {Text} $inKey - Email header field name
 * @returns {Boolean} True if the header carries email addresses (From, To, Cc, Bcc, etc.)
 * @example isEmailAddressHeader("To") // → True
 * @example isEmailAddressHeader("Subject") // → False
 */
	
	var $emailHeaders : Collection:=["From"; "Sender"; "Reply-To"; "To"; "Cc"; "Bcc"; "Resent-From"; "Resent-Sender"; "Resent-Reply-To"; "Resent-To"; "Resent-Cc"; "Resent-Bcc"]
	return $emailHeaders.some("$1 = :1"; $inKey)
	
	
	// ----------------------------------------------------
	
	
Function isLocalIP($inIPAddress : Text) : Boolean
/**
 * @function isLocalIP
 * @param {Text} $inIPAddress - IP address or hostname to check
 * @returns {Boolean} True if the address is a loopback address or matches a local network interface
 * @example isLocalIP("127.0.0.1") // → True
 * @example isLocalIP("8.8.8.8") // → False
 */

	var $sysInfo : Object:=System info
	var $networkInterface : Object

	If (Length($inIPAddress)=0)
		return False
	End if
	If (($inIPAddress="127.0.0.1") || ($inIPAddress="::1") || ($inIPAddress="localhost"))
		return True
	End if

	For each ($networkInterface; $sysInfo.networkInterfaces)
		If ($networkInterface.ipAddresses.query("ip == :1"; $inIPAddress).length > 0)
			return True
		End if
	End for each

	return False
	
	
	// ----------------------------------------------------
	
	
Function isValidEmail($inEmail : Text) : Boolean
/**
 * @function isValidEmail
 * @param {Text} $inEmail - Email address string to validate
 * @returns {Boolean} True if the string is a valid email address (RFC 5321 pattern)
 * @example isValidEmail("jane.doe@example.com") // → True
 * @example isValidEmail("invalid") // → False
 */
	
	var $pattern : Text:="(?i)^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$"
	return Match regex($pattern; $inEmail; 1)
	
	
	// ----------------------------------------------------
	
	
Function isValidURL($inURL : Text) : Boolean
/**
 * @function isValidURL
 * @param {Text} $inURL - URL string to validate
 * @returns {Boolean} True if the URL has an http/https scheme and a non-empty host
 * @example isValidURL("https://www.example.com") // → True
 * @example isValidURL("ftp://files.example.com") // → False
 * @example isValidURL("/relative/path") // → False
 */
	
	var $URL : cs._URL:=cs._URL.new($inURL)
	
	return (((Length($URL.scheme)>0) && ($URL.scheme="http@")) && (Length($URL.host)>0))
	
	
	// ----------------------------------------------------
	
	
Function quoteString($inString : Text) : Text
/**
 * @function quoteString
 * @param {Text} $inString - String to quote
 * @returns {Text} String surrounded by double-quotes; adds missing opening or closing quote
 * @example quoteString("hello") // → "\"hello\""
 * @example quoteString("\"already quoted\"") // → "\"already quoted\""
 */
	
	var $result : Text:=$inString
	var $length : Integer:=Length($result)
	
	If ($length>0)
		If ($result[[1]]#"\"")
			$result:="\""+$result
		End if 
		If ($result[[$length]]#"\"")
			$result+="\""
		End if 
	End if 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function retainFileObject($inParameter : Variant) : 4D.File
/**
 * @function retainFileObject
 * @param {Variant} $inParameter - A 4D.File instance or a platform path string
 * @returns {4D.File} The file if it exists, or Null if the parameter is invalid or the file does not exist
 */
	
	If (Value type($inParameter)#Is undefined)
		
		var $platformPath : Text
		If ((Value type($inParameter)=Is object) && (OB Instance of($inParameter; 4D.File)))
			$platformPath:=$inParameter.platformPath
		Else 
			$platformPath:=String($inParameter)
		End if 
		If (Length($platformPath)>0)
			var $file : 4D.File:=File($platformPath; fk platform path)
			If ($file.exists)
				return $file
			End if 
		End if 
	End if 
	
	return Null
	
	
	// ----------------------------------------------------
	
	
Function startWebServer($inParameters : Object) : Object
/**
 * @function startWebServer
 * @param {Object} $inParameters - Settings object
 * @param {Integer} [$inParameters.port=50993] - HTTPS port when useTLS=True, HTTP port when useTLS=False
 * @param {Integer} [$inParameters.httpPort=80] - HTTP port when useTLS=True (both HTTP and HTTPS are enabled simultaneously)
 * @param {Boolean} [$inParameters.useTLS=False] - Enable TLS (HTTPS)
 * @param {Boolean} [$inParameters.enableDebugLog] - Enable web debug log
 * @param {4D.Folder|Text} [$inParameters.certificateFolder] - Folder containing cert.pem and key.pem
 * @param {4D.Folder|Text} [$inParameters.webFolder] - Web root folder
 * @returns {Object} {success: Boolean; error: Object|Null}
 * @description Starts the web server; stops and restarts it if settings have changed.
 *   When useTLS=True, both HTTP (httpPort) and HTTPS (port) are enabled simultaneously.
 *   If the server is already running in notification mode with the same settings, the call
 *   succeeds immediately without restarting. If settings have changed, error 17 is returned
 *   to avoid disrupting active notification handlers.
 */
	
	var $port : Integer:=(Num($inParameters.port)>0) ? Num($inParameters.port) : 50993
	var $httpPort : Integer:=(Num($inParameters.httpPort)>0) ? Num($inParameters.httpPort) : 80
	var $bIsSSL : Boolean:=(Value type($inParameters.useTLS)#Is undefined) ? Bool($inParameters.useTLS) : False
	var $debugLog : Integer:=Bool($inParameters.enableDebugLog) ? wdl enable with all body parts : wdl disable web log
	var $status : Object:={success: False; error: Null}
	
	If (This.webServer.isRunning)
		If (Not(This.webServer.HTTPEnabled) \
			|| ($bIsSSL && (Not(This.webServer.HTTPSEnabled) || (This.webServer.HTTPSPort#$port) || (This.webServer.HTTPPort#$httpPort))) \
			|| (Not($bIsSSL) && (This.webServer.HTTPSEnabled || (This.webServer.HTTPPort#$port))) \
			|| (This.webServer.debugLog#$debugLog))
			If (This.notificationMode)
				$status.error:=cs._Tools.me.makeError(17; Null)
				return $status
			End if 
			This.webServer.stop()
			DELAY PROCESS(Current process; 20)
		End if 
	End if 
	
	If (Not(This.webServer.isRunning))
		var $settings : Object:={}
		$settings.HTTPEnabled:=True
		$settings.HTTPSEnabled:=$bIsSSL
		If ($bIsSSL)
			$settings.HTTPSPort:=$port
			$settings.HTTPPort:=$httpPort
			// Force TLSv1.2 as minimum: observed that Microsoft Graph webhook callbacks fail to connect over TLSv1.3 only
			$settings.minTLSVersion:=TLSv1_2
			If (Not(OB Is defined($inParameters; "certificateFolder")))
				// Check component's own PACKAGE folder first
				var $componentFolder : 4D.Folder:=Folder("/PACKAGE/")
				If ($componentFolder.file("cert.pem").exists && $componentFolder.file("key.pem").exists)
					$settings.certificateFolder:=$componentFolder
				Else 
					// Fall back to host database's PACKAGE folder
					var $hostFolder : 4D.Folder:=Folder("/PACKAGE/"; *)
					If ($hostFolder.file("cert.pem").exists && $hostFolder.file("key.pem").exists)
						$settings.certificateFolder:=$hostFolder
					Else 
						// Default to component folder (original behavior)
						$settings.certificateFolder:=$componentFolder
					End if 
				End if 
			Else 
				If (OB Instance of($inParameters.certificateFolder; 4D.Folder))
					$settings.certificateFolder:=$inParameters.certificateFolder
				Else 
					$settings.certificateFolder:=Folder($inParameters.certificateFolder; fk platform path)
				End if 
			End if 
		Else 
			$settings.HTTPPort:=$port
		End if 
		$settings.debugLog:=$debugLog
		$settings.scalableSession:=False
		$settings.keepSession:=False
		
		If (OB Is defined($inParameters; "webFolder"))
			If (OB Instance of($inParameters.webFolder; 4D.Folder))
				$settings.rootFolder:=$inParameters.webFolder
			Else 
				$settings.rootFolder:=Folder($inParameters.webFolder; fk platform path)
			End if 
		Else 
			$settings.rootFolder:=Folder(fk web root folder; *)
		End if 
		
		var $startStatus : Object:=This.webServer.start($settings)
		If (($startStatus#Null) && (Value type($startStatus)=Is object))
			If (OB Is defined($startStatus; "error"))
				$status.error:=$startStatus.error
			Else 
				$status.error:=$startStatus
			End if 
		End if 
		
	End if 
	
	$status.success:=This.webServer.isRunning
	If ((Not($status.success)) && ($status.error=Null))
		$status.error:=cs._Tools.me.makeError(7; {port: $port})
	End if 
	return $status
	
	
	// ----------------------------------------------------
	
	
Function stopWebServer() : Boolean
/**
 * @function stopWebServer
 * @returns {Boolean} True if the server is still running after the stop attempt, False if successfully stopped
 */
	
	If (This.webServer.isRunning)
		This.webServer.stop()
	End if 
	
	return This.webServer.isRunning
	
	
	// ----------------------------------------------------
	
	
Function trimSpaces($inText : Text) : Text
/**
 * @function trimSpaces
 * @param {Text} $inText - String to trim
 * @returns {Text} String with leading and trailing spaces removed
 * @example trimSpaces("  hello  ") // → "hello"
 */
	
	var $startPos : Integer:=1
	var $endPos : Integer:=Length($inText)
	
	While (($startPos<=$endPos) && ($inText[[$startPos]]=" "))
		$startPos+=1
	End while 
	
	While (($endPos>=$startPos) && ($inText[[$endPos]]=" "))
		$endPos-=1
	End while 
	
	return Substring($inText; $startPos; $endPos-$startPos+1)
	
	
	// ----------------------------------------------------
	
	
Function urlDecode($inURL : Text) : Text
/**
 * @function urlDecode
 * @param {Text} $inURL - Percent-encoded URL string
 * @returns {Text} Decoded plain text
 * @example urlDecode("Hello%20World") // → "Hello World"
 */
	
/*
    Largely inspired from url_decode.4dm by Vincent de Lachaux
    See: https://github.com/4d/4D-SVG project
*/
	var $i : Integer
	var $hexValues : Text:="123456789ABCDEF"
	var $urlLength : Integer:=Length($inURL)
	var $result : Text:=""
	
	For ($i; 1; $urlLength; 1)
		
		If ($inURL[[$i]]="%")
			
			var $c : Integer:=(Position(Substring($inURL; $i+1; 1); $hexValues)*16)+(Position(Substring($inURL; $i+2; 1); $hexValues))
			$result+=Char($c)
			$i+=2
			
		Else 
			
			$result+=$inURL[[$i]]
			
		End if 
	End for 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function urlEncode($value : Text) : Text
/**
 * @function urlEncode
 * @param {Text} $value - Plain text string to encode
 * @returns {Text} Percent-encoded string safe for use in a URL
 * @example urlEncode("Hello World") // → "Hello%20World"
 * @example urlEncode("a=1&b=2") // → "a%3D1%26b%3D2"
 */
	
	var $i; $j : Integer
	var $length : Integer:=Length($value)
	var $result : Text:=""
	
	For ($i; 1; $length)
		
		var $char : Text:=Substring($value; $i; 1)
		var $code : Integer:=Character code($char)
		var $shouldEscape : Boolean:=False
		
		Case of 
			: ($code=45)
			: ($code=46)
			: ($code>47) && ($code<58)
			: ($code>63) && ($code<91)
			: ($code=95)
			: ($code>96) && ($code<123)
			: ($code=126)
			Else 
				$shouldEscape:=True
		End case 
		
		If ($shouldEscape)
			var $data : Blob
			CONVERT FROM TEXT($char; "utf-8"; $data)
			For ($j; 0; BLOB size($data)-1)
				var $hex : Text:=String($data{$j}; "&x")
				$result:=$result+"%"+Substring($hex; Length($hex)-1)
			End for 
		Else 
			$result:=$result+$char
		End if 
	End for 
	
	return $result
	
	
	// ----------------------------------------------------
	
	
Function makeError($inCode : Integer; $inParameters : Object) : Object
/**
 * @function makeError
 * @param {Integer} $inCode - Error code (used to look up the localized message "ERR_4DNK_{code}")
 * @param {Object} $inParameters - Key/value pairs substituted into the localized message template
 * @returns {Object} {errCode: Integer; componentSignature: "4DNK"; message: Text}
 * @example makeError(7; {port: 50993}) // → {errCode: 7; componentSignature: "4DNK"; message: "..."}
 */
	
	var $description : Text:=Localized string("ERR_4DNK_"+String($inCode))
	
	If (Not(OB Is empty($inParameters)))
		var $key : Text
		For each ($key; $inParameters)
			$description:=Replace string($description; "{"+$key+"}"; String($inParameters[$key]))
		End for each 
	End if 
	
	var $error : Object:={errCode: $inCode; componentSignature: "4DNK"; message: $description}
	
	return $error
	
	
	// ----------------------------------------------------
	
	
Function buildPageFromTemplate($inTitle : Text; $inMessage : Text; $inDetails : Text; $inSuccess : Boolean) : Text
/**
 * @function buildPageFromTemplate
 * @param {Text} $inTitle - Page title
 * @param {Text} $inMessage - Main message to display
 * @param {Text} $inDetails - Additional details to display
 * @param {Boolean} $inSuccess - True for a success page, False for an error page
 * @returns {Text} HTML response page built from the responseTemplate.html resource file
 */
	var $responseTemplateFile : 4D.File:=Folder(fk resources folder).file("responseTemplate.html")
	var $responseTemplateContent : Text:=$responseTemplateFile.getText()
	var $responseBody : Text:=""
	var $status : Text:=(Value type($inSuccess)=Is boolean) ? (Choose($inSuccess=True; "success"; "error")) : "success"
	
	PROCESS 4D TAGS($responseTemplateContent; $responseBody; $inTitle; $inMessage; $inDetails; $status)
	
	return $responseBody
