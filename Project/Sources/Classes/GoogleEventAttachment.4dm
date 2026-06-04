/**
 * @class GoogleEventAttachment
 * @description Represents a file attachment on a Google Calendar event.
 *   Exposes metadata from the API response and provides lazy, cached download
 *   of the attachment binary via `getContent()`.
 */

property fileUrl : Text
property title : Text
property mimeType : Text
property iconLink : Text
property contentBytes : 4D.Blob:=Null

/**
 * @constructor
 * @param {Object} $inAttachment - Raw attachment object from the Calendar API event response;
 *   expected properties: `fileUrl`, `title`, `mimeType`, `iconLink`
 */
Class constructor($inAttachment : Object)
    
    This.fileUrl:=String($inAttachment.fileUrl)
    This.title:=String($inAttachment.title)
    This.mimeType:=String($inAttachment.mimeType)
    This.iconLink:=String($inAttachment.iconLink)
    
    
    // Mark: - [Public]
    // ----------------------------------------------------
    
    
/**
 * @function getContent
 * @returns {4D.Blob} The attachment binary; `Null` if the download fails
 * @description Downloads the attachment from `fileUrl` on first call and caches the
 *   result in `contentBytes`; subsequent calls return the cached blob without
 *   making a new HTTP request
 */
Function getContent() : 4D.Blob
    
    If (This.contentBytes=Null)
        var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new(This.fileUrl; {dataType: "blob"}).wait())
        If ($request#Null)
            This.contentBytes:=4D.Blob.new($request.response.body)
        End if 
    End if 
    
    return This.contentBytes
    
    
    // ----------------------------------------------------


/**
 * @function getIcon
 * @returns {Picture} The attachment icon as a 4D Picture; `Null` if the download fails
 * @description Downloads the icon image from `iconLink` and converts the blob to a
 *   4D Picture via `BLOB TO PICTURE`; not cached — a new HTTP request is made on each call
 */
Function getIcon() : Picture
    
    var $icon : Picture:=Null
    var $request : 4D.HTTPRequest:=Try(4D.HTTPRequest.new(This.iconLink; {dataType: "blob"}).wait())
    If ($request#Null)
        var $blob : 4D.Blob:=Null
        $blob:=4D.Blob.new($request.response.body)
        BLOB TO PICTURE($blob; $icon)
    End if 
    
    return $icon
