/**
 * @class GraphDriveItem
 * @description Represents a Microsoft Graph Drive item (file or folder).
 *   Provides `getContent()` to download file bytes lazily.
 */

Class extends _GraphAPI

property id : Text
property name : Text
property size : Integer
property webUrl : Text

Class constructor($inProvider : cs.OAuth2Provider; $inDrivePath : Text; $inObject : Object)
/**
 * @constructor
 * @param {cs.OAuth2Provider} $inProvider - OAuth2 provider for authenticating requests
 * @param {Text} $inDrivePath - Drive path prefix (e.g. "me/drive")
 * @param {Object} $inObject - Raw Graph API drive item object to hydrate from
 */
    
    Super($inProvider)
    
    This._internals._drivePath:=$inDrivePath
    Super._loadFromObject($inObject)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
Function getContent() : 4D.Blob
/**
 * @function getContent
 * @returns {4D.Blob} File content as binary; empty blob for folders or on error
 * @description Downloads file bytes via `GET /drive/items/{id}/content`
 */
    
    var $result : 4D.Blob:=4D.Blob.new()
    
    If ((Length(String(This.id))=0) || (OB Is defined(This; "folder")))
        return $result
    End if 
    
    Try
        var $URL : Text:=This._getURL()+This._internals._drivePath+"/items/"+This.id+"/content"
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
