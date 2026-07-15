/**
 * @class GoogleDriveItem
 * @description Represents a Google Drive file item.
 *   Provides `getContent()` to download file bytes lazily.
 */

Class extends _GoogleAPI

property id : Text
property name : Text
property mimeType : Text
property size : Integer
property modifiedTime : Text
property webViewLink : Text
property thumbnailLink : Text


Class constructor($inProvider : cs.OAuth2Provider; $inBaseURL : Text; $inObject : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Text} $inBaseURL - Drive API base URL (e.g. "https://www.googleapis.com/drive/v3/")
 * @param {Object} $inObject - Raw Google Drive file metadata to hydrate from
 */
    
    Super($inProvider; $inBaseURL)
    
    If (($inObject#Null) && (Not(OB Is empty($inObject))))
        var $key : Text
        For each ($key; OB Keys($inObject))
            This[$key]:=$inObject[$key]
        End for each 
    End if 
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function getContent() : 4D.Blob
/**
 * @function getContent
 * @returns {4D.Blob} File content as binary; empty blob on error
 * @description Downloads file bytes via `GET /drive/v3/files/{id}?alt=media`
 */
    
    var $result : 4D.Blob:=4D.Blob.new()
    
    If ((Length(String(This.id))=0) || (String(This.mimeType)="application/vnd.google-apps.@"))
        return $result
    End if 
    
    Try
        var $URL : cs._URL:=cs._URL.new(This._getURL()+"files/"+cs._Tools.me.urlEncode(This.id))
        $URL.addQueryParameter("alt"; "media")
        $URL.addQueryParameter("supportsAllDrives"; "false")
        
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
    
    
Function getThumbnail() : 4D.Blob
/**
 * @function getThumbnail
 * @returns {4D.Blob} Thumbnail image content; empty blob on error
 * @description Downloads the thumbnail image for the drive item.
 *   Uses `thumbnailLink` from the item metadata. If not present, fetches it first
 *   via `GET /drive/v3/files/{id}?fields=thumbnailLink`.
 */
    
    var $result : 4D.Blob:=4D.Blob.new()
    
    If ((Length(String(This.id))=0) || (String(This.mimeType)="application/vnd.google-apps.folder"))
        return $result
    End if 
    
    Try
        var $thumbLink : Text:=String(This.thumbnailLink)
        
        // Fetch thumbnailLink if not in metadata
        If (Length($thumbLink)=0)
            var $URL : cs._URL:=cs._URL.new(This._getURL()+"files/"+cs._Tools.me.urlEncode(This.id))
            $URL.addQueryParameter("fields"; "thumbnailLink")
            $URL.addQueryParameter("supportsAllDrives"; "false")
            var $headers : Object:={Accept: "application/json"}
            var $meta : Object:=Super._sendRequestAndWaitResponse("GET"; $URL.toString(); $headers)
            If (Value type($meta)=Is object)
                $thumbLink:=String($meta.thumbnailLink)
                This.thumbnailLink:=$thumbLink
            End if 
        End if 
        
        If (Length($thumbLink)>0)
            // thumbnailLink is a short-lived authenticated URL — fetch with token
            var $response : Variant:=Super._sendRequestAndWaitResponse("GET"; $thumbLink)
            Case of 
                : (OB Instance of($response; 4D.Blob))
                    $result:=$response
                : (Value type($response)=Is BLOB)
                    $result:=4D.Blob.new($response)
            End case 
        End if 
    Catch
        // Errors are already in _errorStack via _throwError
    End try
    
    return $result
