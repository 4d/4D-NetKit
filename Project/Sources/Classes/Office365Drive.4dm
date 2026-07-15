/**
 * @class Office365Drive
 * @description Microsoft Graph API client for OneDrive and SharePoint Drive operations.
 *   Supports listing drive items, fetching metadata, downloading file content,
 *   and uploading file content.
 */

Class extends _GraphAPI

property userId : Text
property driveId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `userId` {Text} - Graph user ID or UPN; defaults to "" (uses `me` endpoint)
 *   - `driveId` {Text} - Drive ID; defaults to "" (uses default drive)
 */
    
    Super($inProvider)
    
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    This.driveId:=(Length(String($inParameters.driveId))>0) ? String($inParameters.driveId) : ""
    
    
    // Mark: - [Private]
    // ----------------------------------------------------
    
    
Function _getDrivePath() : Text
/**
 * @function _getDrivePath
 * @private
 * @returns {Text} Graph path prefix for the selected user/drive
 */
    
    var $path : Text
    
    If (Length(String(This.userId))>0)
        $path:="users/"+cs._Tools.me.urlEncode(This.userId)
    Else 
        $path:="me"
    End if 
    
    If (Length(String(This.driveId))>0)
        $path+="/drives/"+cs._Tools.me.urlEncode(This.driveId)
    Else 
        $path+="/drive"
    End if 
    
    return $path
    
    
    // ----------------------------------------------------
    
    
Function _sanitizePath($inPath : Text) : Text
/**
 * @function _sanitizePath
 * @private
 * @param {Text} $inPath - Relative path inside the drive
 * @returns {Text} Path normalised with forward slashes and no leading/trailing slash
 */
    
    var $path : Text:=Replace string(String($inPath); "\\"; "/"; *)
    While ((Length($path)>0) && (Substring($path; 1; 1)="/"))
        $path:=Substring($path; 2)
    End while 
    While ((Length($path)>0) && (Substring($path; Length($path); 1)="/"))
        $path:=Substring($path; 1; Length($path)-1)
    End while 
    
    return $path
    
    
    // ----------------------------------------------------
    
    
Function _getItemPath($inParameters : Object; $inFunction : Text) : Text
/**
 * @function _getItemPath
 * @private
 * @param {Object} $inParameters - Item selector (`itemId` or `path`)
 * @param {Text} $inFunction - Caller function name used in error reporting
 * @returns {Text} Graph API item path (without base URL)
 */
    
    If (Length(String($inParameters.itemId))>0)
        return "/items/"+cs._Tools.me.urlEncode($inParameters.itemId)
    End if 
    
    var $path : Text:=This._sanitizePath(String($inParameters.path))
    If (Length($path)>0)
        return "/root:/"+$path+":"
    End if 
    
    This._throwError(9; {which: "\"itemId\" or \"path\""; function: $inFunction})
    return ""
    
    
    // ----------------------------------------------------
    
    
Function _extractUploadBlob($inContent : Variant; $inFunction : Text) : Blob
/**
 * @function _extractUploadBlob
 * @private
 * @param {Variant} $inContent - File content as `Text`, native `Blob`, or `4D.Blob`
 * @param {Text} $inFunction - Caller function name used in error reporting
 * @returns {Blob} Native blob content ready for upload requests
 */
    
    var $blob : Blob
    
    Case of 
        : (Value type($inContent)=Is text)
            CONVERT FROM TEXT(String($inContent); "UTF-8"; $blob)
            
        : (Value type($inContent)=Is BLOB)
            $blob:=$inContent
            
        : (OB Instance of($inContent; 4D.Blob))
            $blob:=$inContent.slice()
            
        Else 
            This._throwError(10; {which: "\"content\""; function: $inFunction})
    End case 
    
    return $blob
    
    
    // ----------------------------------------------------
    
    
Function _buildUploadDestination($inParameters : Object; $inFunction : Text) : Object
/**
 * @function _buildUploadDestination
 * @private
 * @param {Object} $inParameters - Upload destination options
 * @param {Text} $inFunction - Caller function name used in error reporting
 * @returns {Object} Upload target metadata: `{destination; fileName}`
 */
    
    var $destination : Text:=""
    var $fileName : Text:=String($inParameters.fileName)
    
    If (Length(String($inParameters.path))>0)
        var $fullPath : Text:=This._sanitizePath(String($inParameters.path))
        If (Length($fullPath)=0)
            This._throwError(9; {which: "\"path\""; function: $inFunction})
        End if 
        $destination:="/root:/"+$fullPath+":/content"
        $fileName:=$fullPath
        While (Position("/"; $fileName)>0)
            $fileName:=Substring($fileName; Position("/"; $fileName)+1)
        End while 
    Else 
        If (Length($fileName)=0)
            This._throwError(9; {which: "\"path\" or \"fileName\""; function: $inFunction})
        End if 
        
        If (Length(String($inParameters.folderId))>0)
            $destination:="/items/"+cs._Tools.me.urlEncode($inParameters.folderId)+":/"+cs._Tools.me.urlEncode($fileName)+":/content"
        Else 
            var $folderPath : Text:=This._sanitizePath(String($inParameters.folderPath))
            If (Length($folderPath)>0)
                $destination:="/root:/"+$folderPath+"/"+cs._Tools.me.urlEncode($fileName)+":/content"
            Else 
                $destination:="/root:/"+cs._Tools.me.urlEncode($fileName)+":/content"
            End if 
        End if 
    End if 
    
    return {destination: $destination; fileName: $fileName}
    
    
    // ----------------------------------------------------
    
    
Function _makeUploadStatus($inResponse : Object) : Object
/**
 * @function _makeUploadStatus
 * @private
 * @param {Object} $inResponse - Graph drive item response
 * @returns {Object} Status object with mapped uploaded item properties
 */
    
    If (Value type($inResponse)=Is object)
        var $info : Object:={}
        If (Length(String($inResponse.id))>0)
            $info.id:=String($inResponse.id)
        End if 
        If (Length(String($inResponse.name))>0)
            $info.name:=String($inResponse.name)
        End if 
        If (Length(String($inResponse.webUrl))>0)
            $info.webUrl:=String($inResponse.webUrl)
        End if 
        If (Value type($inResponse.size)#Is undefined)
            $info.size:=Num($inResponse.size)
        End if 
        return This._returnStatus($info)
    End if 
    
    return This._returnStatus()
    
    
    // ----------------------------------------------------
    
    
Function _uploadSimple($inDestination : Text; $inConflict : Text; $inUploadBlob : Blob) : Object
/**
 * @function _uploadSimple
 * @private
 * @param {Text} $inDestination - Graph upload destination ending with `/content`
 * @param {Text} $inConflict - Conflict behavior (`replace`, `rename`, `fail`)
 * @param {Blob} $inUploadBlob - Binary file payload
 * @returns {Object} Status object
 */
    
    var $URL : Text:=This._getURL()+This._getDrivePath()+$inDestination
    $URL+="?@microsoft.graph.conflictBehavior="+$inConflict
    
    var $headers : Object:={}
    $headers["Content-Type"]:="application/octet-stream"
    var $response : Variant:=Super._sendRequestAndWaitResponse("PUT"; $URL; $headers; $inUploadBlob)
    
    return This._makeUploadStatus($response)
    
    
    // ----------------------------------------------------
    
    
Function _uploadBySession($inDestination : Text; $inFileName : Text; $inConflict : Text; $inUploadBlob : Blob; $inChunkSize : Integer) : Object
/**
 * @function _uploadBySession
 * @private
 * @param {Text} $inDestination - Graph upload destination ending with `/content`
 * @param {Text} $inFileName - File name used by upload session metadata
 * @param {Text} $inConflict - Conflict behavior (`replace`, `rename`, `fail`)
 * @param {Blob} $inUploadBlob - Binary file payload
 * @param {Integer} $inChunkSize - Chunk size in bytes
 * @returns {Object} Status object
 */
    
    var $totalSize : Integer:=BLOB size($inUploadBlob)
    If ($totalSize<=0)
        This._throwError(9; {which: "\"content\""; function: "office365.drive.uploadFile"})
    End if 
    
    var $sessionPath : Text
    If ((Length($inDestination)>=8) && (Substring($inDestination; Length($inDestination)-7; 8)="/content"))
        $sessionPath:=Substring($inDestination; 1; Length($inDestination)-8)+"/createUploadSession"
    Else 
        This._throwError(13; {function: "office365.drive.uploadFile"; message: "Invalid upload destination."})
    End if 
    
    var $item : Object:={}
    $item["@microsoft.graph.conflictBehavior"]:=$inConflict
    $item.name:=$inFileName
    var $body : Object:={item: $item}
    
    var $response : Object:=Super._sendRequestAndWaitResponse("POST"; This._getURL()+This._getDrivePath()+$sessionPath; Null; $body)
    var $uploadURL : Text:=String($response.uploadUrl)
    If (Length($uploadURL)=0)
        This._throwError(13; {function: "office365.drive.uploadFile"; message: "Unable to create upload session."})
    End if 
    
    var $chunkSize : Integer:=$inChunkSize
    If ($chunkSize<=0)
        $chunkSize:=1638400  // 1.5625 MiB, multiple of 320 KiB as recommended by Microsoft Graph.
    End if 
    
    var $uploadBlob4D : 4D.Blob:=4D.Blob.new($inUploadBlob)
    var $offset : Integer:=0
    var $lastResponse : Object
    While ($offset<$totalSize)
        var $currentChunkSize : Integer:=$chunkSize
        If (($offset+$currentChunkSize)>$totalSize)
            $currentChunkSize:=$totalSize-$offset
        End if 
        
        var $chunkHeaders : Object:={}
        $chunkHeaders["Content-Type"]:="application/octet-stream"
        $chunkHeaders["Content-Range"]:="bytes "+String($offset)+"-"+String($offset+$currentChunkSize-1)+"/"+String($totalSize)
        
        // uploadUrl already contains auth data; do not add Authorization header.
        // Build options object step-by-step (not inline) to preserve Blob binary identity.
        var $chunkOptions : Object:={headers: {}}
        $chunkOptions.headers:=OB Copy($chunkHeaders)
        $chunkOptions.method:="PUT"
        $chunkOptions.body:=$uploadBlob4D.slice($offset; $offset+$currentChunkSize)
        var $putRequest : 4D.HTTPRequest:=Try(4D.HTTPRequest.new($uploadURL; $chunkOptions).wait())
        var $putStatus : Integer:=Num($putRequest.response.status)
        If (Int($putStatus/100)#2)
            var $statusText : Text:=String($putRequest.response.statusText)
            var $message : Text
            If (Value type($putRequest.response.body)=Is text)
                $message:=$putRequest.response.body
            Else 
                If (Value type($putRequest.response.body)=Is object)
                    $message:=Try(JSON Stringify($putRequest.response.body))
                Else 
                    $message:=Try(Convert to text($putRequest.response.body; "UTF-8"))
                End if 
            End if 
            This._throwError(8; {status: $putStatus; explanation: $statusText; message: $message})
        End if 
        
        If (Value type($putRequest.response.body)=Is object)
            $lastResponse:=$putRequest.response.body
        End if 
        $offset+=$currentChunkSize
    End while 
    
    return This._makeUploadStatus($lastResponse)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function list($inParameters : Object) : cs.GraphDriveItemList
/**
 * @function list
 * @param {Object} $inParameters - Query and scope options:
 *   - `itemId` {Text} - Parent folder item ID
 *   - `path` {Text} - Parent folder path relative to the drive root
 *   - `search`, `filter`, `select`, `top`, `orderBy` - OData query parameters
 * @returns {cs.GraphDriveItemList} Pageable list of drive items
 * @description Lists children of the root folder or a selected folder.
 */
    
    Super._clearErrorStack()
    
    var $URL : Text:=This._getURL()+This._getDrivePath()
    
    If (Length(String($inParameters.itemId))>0)
        $URL+="/items/"+cs._Tools.me.urlEncode($inParameters.itemId)+"/children"
    Else 
        var $path : Text:=This._sanitizePath(String($inParameters.path))
        If (Length($path)>0)
            $URL+="/root:/"+$path+":/children"
        Else 
            $URL+="/root/children"
        End if 
    End if 
    
    var $headers : Object
    If (Length(String($inParameters.search))>0)
        $headers:={ConsistencyLevel: "eventual"}
    End if 
    
    $URL+=Super._getURLParamsFromObject($inParameters)
    
    return cs.GraphDriveItemList.new(This._getOAuth2Provider(); $URL; $headers)
    
    
    // ----------------------------------------------------
    
    
Function getItem($inParameters : Object) : Object
/**
 * @function getItem
 * @param {Object} $inParameters - Item selector and options:
 *   - `itemId` {Text} - Drive item ID
 *   - `path` {Text} - Relative path from root (alternative to `itemId`)
 *   - `select` {Text|Collection} - OData `$select`
 * @returns {Object} Cleaned drive item metadata, or `Null` on error
 * @description Fetches drive item metadata.
 */
    
    Super._clearErrorStack()
    
    Try
        var $URL : Text:=This._getURL()+This._getDrivePath()+This._getItemPath($inParameters; "office365.drive.getItem")
        $URL+=Super._getURLParamsFromObject({select: $inParameters.select})
        
        var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL)
        If (Value type($response)=Is object)
            return cs._Tools.me.cleanGraphObject($response)
        End if 
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getFile($inParameters : Object) : 4D.Blob
/**
 * @function getFile
 * @param {Object} $inParameters - Item selector:
 *   - `itemId` {Text} - File item ID
 *   - `path` {Text} - Relative file path from root (alternative to `itemId`)
 * @returns {4D.Blob} Downloaded file content; empty blob on error
 * @description Downloads file bytes from the selected drive item.
 */
    
    Super._clearErrorStack()
    
    var $result : 4D.Blob:=4D.Blob.new()
    
    Try
        var $URL : Text:=This._getURL()+This._getDrivePath()+This._getItemPath($inParameters; "office365.drive.getFile")+"/content"
        var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL)
        
        Case of 
            : (OB Instance of($response; 4D.Blob))
                $result:=$response
                
            : (Value type($response)=Is BLOB)
                $result:=4D.Blob.new($response)
                
            : (Value type($response)=Is text)
                var $blob : Blob
                CONVERT FROM TEXT($response; "UTF-8"; $blob)
                $result:=4D.Blob.new($blob)
        End case 
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return $result
    
    
    // ----------------------------------------------------
    
    
Function uploadFile($inParameters : Object; $inContent : Variant) : Object
/**
 * @function uploadFile
 * @param {Object} $inParameters - Upload destination options:
 *   - `path` {Text} - Destination path including filename (required unless `fileName` is set)
 *   - `fileName` {Text} - File name (used with `folderId` or at root)
 *   - `folderId` {Text} - Parent folder item ID (optional)
 *   - `folderPath` {Text} - Parent folder path from root (optional)
 *   - `conflictBehavior` {Text} - `replace` (default), `rename`, or `fail`
 *   - `useUploadSession` {Boolean} - Force upload-session mode even for small files
 *   - `uploadSessionThreshold` {Integer} - Size threshold in bytes for automatic upload-session mode
 *   - `chunkSize` {Integer} - Chunk size in bytes for upload session (must be a multiple of 320 KiB)
 * @param {Variant} $inContent - File content as `Text`, native `Blob`, or `4D.Blob`
 * @returns {Object} Status object; includes uploaded item info when available
 * @description Uploads file content; switches to Graph upload-session mode for large files.
 */
    
    Super._clearErrorStack()
    
    var $status : Object
    
    Try
        var $uploadBlob : Blob:=This._extractUploadBlob($inContent; "office365.drive.uploadFile")
        var $target : Object:=This._buildUploadDestination($inParameters; "office365.drive.uploadFile")
        var $destination : Text:=String($target.destination)
        var $fileName : Text:=String($target.fileName)
        
        var $conflict : Text:=Lowercase(String($inParameters.conflictBehavior))
        If (($conflict#"rename") && ($conflict#"fail"))
            $conflict:="replace"
        End if 
        
        var $threshold : Integer:=4194304  // 4 MiB
        If (Value type($inParameters.uploadSessionThreshold)#Is undefined)
            $threshold:=Num($inParameters.uploadSessionThreshold)
        End if 
        If ($threshold<=0)
            $threshold:=4194304
        End if 
        
        var $chunkSize : Integer:=1638400  // 1.5625 MiB (5 * 320 KiB)
        If (Value type($inParameters.chunkSize)#Is undefined)
            $chunkSize:=Num($inParameters.chunkSize)
        End if 
        If ($chunkSize<=0)
            $chunkSize:=1638400
        End if 
        
        var $useUploadSession : Boolean:=Bool($inParameters.useUploadSession)
        If (Not($useUploadSession))
            $useUploadSession:=(BLOB size($uploadBlob)>=$threshold)
        End if 
        
        If ($useUploadSession)
            $status:=This._uploadBySession($destination; $fileName; $conflict; $uploadBlob; $chunkSize)
        Else 
            $status:=This._uploadSimple($destination; $conflict; $uploadBlob)
        End if 
    Catch
        $status:=This._returnStatus()
    End try
    
    return $status
    
    
    // ----------------------------------------------------
    
    
Function uploadLargeFile($inParameters : Object; $inContent : Variant) : Object
/**
 * @function uploadLargeFile
 * @param {Object} $inParameters - Upload destination options:
 *   - `path` {Text} - Destination path including filename (required unless `fileName` is set)
 *   - `fileName` {Text} - File name (used with `folderId` or at root)
 *   - `folderId` {Text} - Parent folder item ID (optional)
 *   - `folderPath` {Text} - Parent folder path from root (optional)
 *   - `conflictBehavior` {Text} - `replace` (default), `rename`, or `fail`
 *   - `chunkSize` {Integer} - Chunk size in bytes (should be a multiple of 320 KiB)
 * @param {Variant} $inContent - File content as `Text`, native `Blob`, or `4D.Blob`
 * @returns {Object} Status object; includes uploaded item info when available
 * @description Uploads file content using Graph upload-session mode (chunked PUT requests).
 */
    
    Super._clearErrorStack()
    
    var $status : Object
    
    Try
        var $uploadBlob : Blob:=This._extractUploadBlob($inContent; "office365.drive.uploadLargeFile")
        var $target : Object:=This._buildUploadDestination($inParameters; "office365.drive.uploadLargeFile")
        var $destination : Text:=String($target.destination)
        var $fileName : Text:=String($target.fileName)
        
        var $conflict : Text:=Lowercase(String($inParameters.conflictBehavior))
        If (($conflict#"rename") && ($conflict#"fail"))
            $conflict:="replace"
        End if 
        
        var $chunkSize : Integer:=1638400  // 1.5625 MiB (5 * 320 KiB)
        If (Value type($inParameters.chunkSize)#Is undefined)
            $chunkSize:=Num($inParameters.chunkSize)
        End if 
        If ($chunkSize<=0)
            $chunkSize:=1638400
        End if 
        
        $status:=This._uploadBySession($destination; $fileName; $conflict; $uploadBlob; $chunkSize)
    Catch
        $status:=This._returnStatus()
    End try
    
    return $status
