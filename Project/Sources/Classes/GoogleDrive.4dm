/**
 * @class GoogleDrive
 * @extends _GoogleAPI
 * @description Google Drive API client for basic file operations:
 *   list files, read metadata, download content, and upload content.
 */

Class extends _GoogleAPI

property userId : Text

Class constructor($inProvider : cs.OAuth2Provider; $inParameters : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider used for token retrieval
 * @param {Object} $inParameters - Configuration object; recognised properties:
 *   - `userId` {Text} - Reserved for compatibility with other Google clients
 */
    
    Super($inProvider; "https://www.googleapis.com/drive/v3/")
    This.userId:=(Length(String($inParameters.userId))>0) ? String($inParameters.userId) : ""
    
    
    // Mark: - [Private]
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
    
    
Function _isValidGoogleFileId($inFileId : Text) : Boolean
/**
 * @function _isValidGoogleFileId
 * @private
 * @param {Text} $inFileId - Google Drive file ID
 * @returns {Boolean} `True` if the file ID is a non-empty text
 */
    
    return ((Value type($inFileId)=Is text) && (Length(String($inFileId))>0))
    
    
    // ----------------------------------------------------
    
    
Function _buildFileMetadata($inParameters : Object; $inFunction : Text) : Object
/**
 * @function _buildFileMetadata
 * @private
 * @param {Object} $inParameters - Upload options
 * @param {Text} $inFunction - Caller function name used in error reporting
 * @returns {Object} Metadata object ready for Drive API
 */
    
    var $metadata : Object:={}
    
    If (Length(String($inParameters.name))>0)
        $metadata.name:=String($inParameters.name)
    End if 
    If (Length(String($inParameters.mimeType))>0)
        $metadata.mimeType:=String($inParameters.mimeType)
    End if 
    
    If (Value type($inParameters.parents)=Is collection)
        $metadata.parents:=$inParameters.parents
    Else 
        If (Length(String($inParameters.folderId))>0)
            $metadata.parents:=[String($inParameters.folderId)]
        End if 
    End if 
    
    If ((Not(This._isValidGoogleFileId(String($inParameters.fileId)))) && (Length(String($metadata.name))=0))
        This._throwError(9; {which: "\"name\""; function: $inFunction})
    End if 
    
    return $metadata
    
    
    // ----------------------------------------------------
    
    
Function _makeUploadStatus($inResponse : Variant; $inAdditional : Object) : Object
/**
 * @function _makeUploadStatus
 * @private
 * @param {Variant} $inResponse - Drive API response
 * @param {Object} $inAdditional - Additional status data
 * @returns {Object} Status object with mapped file properties
 */
    
    var $info : Object:=($inAdditional#Null) ? OB Copy($inAdditional) : {}
    
    If (Value type($inResponse)=Is object)
        If (Length(String($inResponse.id))>0)
            $info.id:=String($inResponse.id)
        End if 
        If (Length(String($inResponse.name))>0)
            $info.name:=String($inResponse.name)
        End if 
        If (Length(String($inResponse.mimeType))>0)
            $info.mimeType:=String($inResponse.mimeType)
        End if 
        If (Length(String($inResponse.webViewLink))>0)
            $info.webViewLink:=String($inResponse.webViewLink)
        End if 
        If (Value type($inResponse.size)#Is undefined)
            $info.size:=Num($inResponse.size)
        End if 
    End if 
    
    return This._returnStatus($info)
    
    
    // ----------------------------------------------------
    
    
Function _uploadContentToFile($inFileId : Text; $inUploadBlob : Blob; $inParameters : Object) : Variant
/**
 * @function _uploadContentToFile
 * @private
 * @param {Text} $inFileId - Target file ID
 * @param {Blob} $inUploadBlob - Binary payload
 * @param {Object} $inParameters - Upload options
 * @returns {Variant} Drive API response
 */
    
    var $URL : cs._URL:=cs._URL.new("https://www.googleapis.com/upload/drive/v3/files/"+cs._Tools.me.urlEncode($inFileId))
    $URL.addQueryParameter("uploadType"; "media")
    $URL.addQueryParameter("supportsAllDrives"; "true")
    
    var $fields : Text:=(Length(String($inParameters.fields))>0) ? String($inParameters.fields) : "id,name,mimeType,webViewLink,size"
    $URL.addQueryParameter("fields"; $fields)
    
    var $headers : Object:={}
    $headers["Content-Type"]:=(Length(String($inParameters.mimeType))>0) ? String($inParameters.mimeType) : "application/octet-stream"
    
    return Super._sendRequestAndWaitResponse("PATCH"; $URL.toString(); $headers; $inUploadBlob)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function list($inParameters : Object) : cs.GoogleDriveFileList
/**
 * @function list
 * @param {Object} $inParameters - List options; recognised properties:
 *   - `search` {Text} - Drive query (`q`)
 *   - `top` {Integer|Text} - Page size (`pageSize`)
 *   - `orderBy` {Text} - Sort expression
 *   - `spaces` {Text} - Spaces to query (`drive`, `appDataFolder`, ...)
 *   - `fields` {Text} - Response projection
 *   - `pageToken` {Text} - Page token
 *   - `supportsAllDrives` {Boolean} - Include shared drives support
 *   - `includeItemsFromAllDrives` {Boolean} - Include items from all drives
 * @returns {cs.GoogleDriveFileList} Paginated list of Google Drive files
 */
    
    Super._clearErrorStack()
    
    var $URL : cs._URL:=cs._URL.new(This._getURL()+"files")
    If (Length(String($inParameters.search))>0)
        $URL.addQueryParameter("q"; String($inParameters.search))
    End if 
    If (Value type($inParameters.top)#Is undefined)
        $URL.addQueryParameter("pageSize"; String($inParameters.top))
    End if 
    If (Length(String($inParameters.orderBy))>0)
        $URL.addQueryParameter("orderBy"; String($inParameters.orderBy))
    End if 
    If (Length(String($inParameters.spaces))>0)
        $URL.addQueryParameter("spaces"; String($inParameters.spaces))
    End if 
    If (Length(String($inParameters.pageToken))>0)
        $URL.addQueryParameter("pageToken"; String($inParameters.pageToken))
    End if 
    $URL.addQueryParameter("supportsAllDrives"; Bool($inParameters.supportsAllDrives) ? "true" : "false")
    If (Value type($inParameters.includeItemsFromAllDrives)=Is boolean)
        $URL.addQueryParameter("includeItemsFromAllDrives"; Bool($inParameters.includeItemsFromAllDrives) ? "true" : "false")
    End if 
    var $fields : Text:=(Length(String($inParameters.fields))>0) ? String($inParameters.fields) : "nextPageToken,files(id,name,mimeType,size,modifiedTime,parents,webViewLink)"
    $URL.addQueryParameter("fields"; $fields)
    
    var $headers : Object:={Accept: "application/json"}
    return cs.GoogleDriveFileList.new(This._getOAuth2Provider(); {url: $URL.toString(); elements: "files"; headers: $headers})
    
    
    // ----------------------------------------------------
    
    
Function getItem($inParameters : Object) : Object
/**
 * @function getItem
 * @param {Object} $inParameters - File selector/options:
 *   - `itemId` {Text} - File ID (required)
 *   - `fields` {Text} - Response projection
 *   - `supportsAllDrives` {Boolean} - Include shared drives support
 * @returns {Object} Drive file metadata, or `Null` on error
 */
    
    Super._clearErrorStack()
    
    Try
        If (Not(This._isValidGoogleFileId(String($inParameters.itemId))))
            This._throwError(9; {which: "\"itemId\""; function: "google.drive.getItem"})
        End if 
        
        var $URL : cs._URL:=cs._URL.new(This._getURL()+"files/"+cs._Tools.me.urlEncode($inParameters.itemId))
        $URL.addQueryParameter("supportsAllDrives"; Bool($inParameters.supportsAllDrives) ? "true" : "false")
        var $fields : Text:=(Length(String($inParameters.fields))>0) ? String($inParameters.fields) : "id,name,mimeType,size,modifiedTime,parents,webViewLink"
        $URL.addQueryParameter("fields"; $fields)
        
        var $headers : Object:={Accept: "application/json"}
        return Super._sendRequestAndWaitResponse("GET"; $URL.toString(); $headers)
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return Null
    
    
    // ----------------------------------------------------
    
    
Function getFile($inParameters : Object) : 4D.Blob
/**
 * @function getFile
 * @param {Object} $inParameters - File selector/options:
 *   - `itemId` {Text} - File ID (required)
 *   - `supportsAllDrives` {Boolean} - Include shared drives support
 * @returns {4D.Blob} Downloaded file content; empty blob on error
 */
    
    Super._clearErrorStack()
    
    var $result : 4D.Blob:=4D.Blob.new()
    
    Try
        If (Not(This._isValidGoogleFileId(String($inParameters.itemId))))
            This._throwError(9; {which: "\"itemId\""; function: "google.drive.getFile"})
        End if 
        
        var $URL : cs._URL:=cs._URL.new(This._getURL()+"files/"+cs._Tools.me.urlEncode($inParameters.itemId))
        $URL.addQueryParameter("alt"; "media")
        $URL.addQueryParameter("supportsAllDrives"; Bool($inParameters.supportsAllDrives) ? "true" : "false")
        
        var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $URL.toString())
        
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
 * @param {Object} $inParameters - Upload options:
 *   - `fileId` {Text} - Existing file ID to update (optional)
 *   - `name` {Text} - File name (required when creating)
 *   - `mimeType` {Text} - MIME type
 *   - `parents` {Collection} - Parent folder IDs
 *   - `folderId` {Text} - Parent folder ID (shortcut when `parents` is omitted)
 *   - `fields` {Text} - Response projection
 *   - `supportsAllDrives` {Boolean} - Include shared drives support
 * @param {Variant} $inContent - File content as `Text`, native `Blob`, or `4D.Blob`
 * @returns {Object} Status object; includes uploaded file info when available
 * @description Creates a file metadata resource when needed, then uploads content using
 *   Drive media upload (`PATCH ...?uploadType=media`).
 */
    
    Super._clearErrorStack()
    
    var $status : Object
    
    Try
        var $uploadBlob : Blob:=This._extractUploadBlob($inContent; "google.drive.uploadFile")
        var $fileId : Text:=String($inParameters.fileId)
        var $metadata : Object:=This._buildFileMetadata($inParameters; "google.drive.uploadFile")
        var $supportsAllDrives : Text:=Bool($inParameters.supportsAllDrives) ? "true" : "false"
        var $createResponse : Variant:=Null
        
        If (Not(This._isValidGoogleFileId($fileId)))
            var $createURL : cs._URL:=cs._URL.new(This._getURL()+"files")
            $createURL.addQueryParameter("supportsAllDrives"; $supportsAllDrives)
            $createURL.addQueryParameter("fields"; "id,name,mimeType,webViewLink,size")
            var $createHeaders : Object:={}
            $createHeaders["Content-Type"]:="application/json"
            $createResponse:=Super._sendRequestAndWaitResponse("POST"; $createURL.toString(); $createHeaders; JSON Stringify($metadata))
            $fileId:=String($createResponse.id)
            If (Length($fileId)=0)
                This._throwError(13; {function: "google.drive.uploadFile"; message: "Unable to create Google Drive file metadata."})
            End if 
        Else 
            If (Not(OB Is empty($metadata)))
                var $updateURL : cs._URL:=cs._URL.new(This._getURL()+"files/"+cs._Tools.me.urlEncode($fileId))
                $updateURL.addQueryParameter("supportsAllDrives"; $supportsAllDrives)
                $updateURL.addQueryParameter("fields"; "id,name,mimeType,webViewLink,size")
                var $updateHeaders : Object:={}
                $updateHeaders["Content-Type"]:="application/json"
                Super._sendRequestAndWaitResponse("PATCH"; $updateURL.toString(); $updateHeaders; JSON Stringify($metadata))
            End if 
        End if 
        
        var $uploadResponse : Variant:=This._uploadContentToFile($fileId; $uploadBlob; $inParameters)
        $status:=This._makeUploadStatus($uploadResponse; {id: $fileId})
    Catch
        $status:=This._returnStatus()
    End try
    
    return $status