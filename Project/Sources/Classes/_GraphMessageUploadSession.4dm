Class extends _GraphAPI

Class constructor($inProvider : cs:C1710.OAuth2Provider; $params : Object)
	
	Super:C1705($inProvider)
	
	This:C1470._internals._uploadUrl:=Null:C1517
	This:C1470._internals._expirationDateTime:=Null:C1517
	This:C1470._internals._nextExpectedRanges:=Null:C1517
	This:C1470._internals._chunkSize:=3145728  // nk Upload Session min size
	This:C1470._internals._mailId:=String:C10($params.mailId)
	This:C1470._internals._userId:=String:C10($params.userId)
	
	Case of 
		: (OB Is defined:C1231($params; "filePath"))
			This:C1470._internals._file:=File:C1566($params.filePath; fk platform path:K87:2)
			
		: (OB Is defined:C1231($params; "attachment"))
			This:C1470._internals._attachment:=$params.attachment
			
	End case 
	
	If (This:C1470._create())
		If (This:C1470._internals._file#Null:C1517)
			This:C1470._uploadFile()
		Else 
			This:C1470._uploadData()
		End if 
	End if 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _create() : Boolean
	
/*
See: https://learn.microsoft.com/en-us/graph/outlook-large-attachments?tabs=http
for Attachement larger than 3 145 728 and smaller than 157 286 400 bytes 
	
POST https://graph.microsoft.com/v1.0/me/messages/AAMkADI5MAAIT3drCAAA=/attachments/createUploadSession
Content-type: application/json
	
{
  "AttachmentItem": {
    "attachmentType": "file",
    "name": "flower",
    "size": 3483322
  }
}
*/
	
	If (Length:C16(String:C10(This:C1470._internals._mailId))>0)
		
		var $urlParams; $URL : Text
		var $response; $attachment : Object
		
		If (Length:C16(String:C10(This:C1470._internals._userId))>0)
			$urlParams:="users/"+This:C1470._internals._userId
		Else 
			$urlParams:="me"
		End if 
		$urlParams+="/messages/"+String:C10(This:C1470._internals._mailId)+\
			"/attachments/createUploadSession"
		
		var $size : Integer
		var $name : Text
		
		If (This:C1470._internals._file#Null:C1517)
			$name:=This:C1470._internals._file.name
			$size:=This:C1470._internals._file.size
		Else 
			$name:=String:C10(This:C1470._internals._attachment.name)
			$size:=Num:C11(This:C1470._internals._attachment.contentBytes)
		End if 
		
		$URL:=Super:C1706._getURL()+$urlParams
		$attachment:=New object:C1471("AttachmentItem"; \
			New object:C1471("attachmentType"; "file"; \
			"name"; $name; \
			"size"; $size)\
			)
		$response:=Super:C1706._sendRequestAndWaitResponse("POST"; $URL; \
			New object:C1471("Content-type"; "application/json"); \
			JSON Stringify:C1217($attachment))
		
		If ($response#Null:C1517)
			This:C1470._internals._uploadUrl:=String:C10($response["uploadUrl"])
			This:C1470._internals._expirationDateTime:=String:C10($response["expirationDateTime"])
			This:C1470._internals._nextExpectedRanges:=String:C10($response["nextExpectedRanges"])
			
			return True:C214
		End if 
		
	Else 
		Super:C1706._throwError((Length:C16(String:C10(This:C1470._internals._mailId))=0) ? 9 : 10; \
			New object:C1471("which"; "\"mailId\""; "function"; "_GraphMessageUploadSession._create"))
	End if 
	
	return False:C215
	
	
	// ----------------------------------------------------
	
	
Function _sendChunk($inTotalSize : Integer; $inLastOffset : Integer; $inBlob : 4D:C1709.Blob) : Boolean
	
/*
PUT https://outlook.office.com/api/v2.0/Users('a8e8e219-4931-95c1-b73d-62626fd79c32@72aa88bf-76f0-494f-91ab-2d7cd730db47')/Messages('AAMkADI5MAAIT3drCAAA=')/AttachmentSessions('AAMkADI5MAAIT3k0tAAA=')?authtoken=eyJhbGciOiJSUzI1NiIsImtpZCI6IktmYUNIUlN6bllHMmNI
Content-Type: application/octet-stream
Content-Length: 2097152
Content-Range: bytes 0-2097151/3483322
	
{
  <bytes 0-2097151 of the file to be attached, in binary format>
}
*/
	
	var $header : Object
	var $firstByte; $lastByte : Integer
	
	$firstByte:=$inLastOffset-1
	$lastByte:=Num:C11($firstByte+$inBlob.size)
	$header:=New object:C1471("Content-Type"; "application/octet-stream"; \
		"Content-Length"; String:C10($inBlob.size); \
		"Content-Range"; "bytes "+String:C10($firstByte)+"-"+String:C10($lastByte)+"/"+String:C10($inTotalSize))
	
	var $response : Variant
	$response:=Super:C1706._sendRequestAndWaitResponse("PUT"; \
		This:C1470._internals._uploadUrl; \
		$header; \
		$inBlob)
	
	If ($response#Null:C1517)
		Case of 
			: (This:C1470._internals._status=200)  // Accepted
				This:C1470._internals._uploadUrl:=String:C10($response["uploadUrl"])
				This:C1470._internals._expirationDateTime:=String:C10($response["expirationDateTime"])
				This:C1470._internals._nextExpectedRanges:=String:C10($response["nextExpectedRanges"])
				
			: (This:C1470._internals._status=201)  // Created
/*
Location should look like:
https://outlook.office.com/api/v2.0/Users('xxx')/Messages('yyyy')/Attachments('zzz')
*/
				This:C1470._internals._location:=String:C10($response["location"])
				
		End case 
		
		return True:C214
	End if 
	
	return False:C215
	
	
	// ----------------------------------------------------
	
	
Function _uploadFile() : Boolean
	
	If (Not:C34(This:C1470._internals._file.exists))
		Super:C1706._throwError(12; New object:C1471("attachment"; "\"+"+\
			This:C1470._internals._file.name+\
			"\""; "function"; "_GraphMessageUploadSession._uploadFile"))
		return False:C215
	End if 
	
	If (Length:C16(String:C10(This:C1470._internals._uploadUrl))=0)
		Super:C1706._throwError((Length:C16(String:C10(This:C1470._internals._uploadUrl))=0) ? 9 : 10; \
			New object:C1471("which"; "\"uploadUrl\""; "function"; "_GraphMessageUploadSession._uploadFile"))
		return False:C215
	End if 
	
	var $fileHandle : 4D:C1709.FileHandle
	var $bIsOK : Boolean
	var $filesize; $lastOffset; $chunkSize : Integer
	
	$fileHandle:=This:C1470._internals._file.open("read")
	$fileSize:=This:C1470._internals._file.size
	
	While (Not:C34($fileHandle.eof))
		
		var $blob : 4D:C1709.Blob
		
		$lastOffset:=$fileHandle.offset
		$chunkSize:=(($fileSize-$lastOffset)>This:C1470._internals._chunkSize) ? \
			This:C1470._internals._chunkSize : \
			($fileSize-$lastOffset)
		$blob:=$fileHandle.readBlob($chunkSize)
		
		$bIsOK:=This:C1470._sendChunk($fileSize; $lastOffset; $blob)
		
		If (Not:C34($bIsOK))
			break
		End if 
		IDLE:C311
		
	End while 
	
	return $bIsOK
	
	
	// ----------------------------------------------------
	
	
Function _uploadData() : Boolean
	
	If (This:C1470._internals._attachment=Null:C1517)
		Super:C1706._throwError(10; New object:C1471("which"; "\"attachment\""; "function"; "_GraphMessageUploadSession._uploadData"))
		return False:C215
	End if 
	
	If (Length:C16(String:C10(This:C1470._internals._uploadUrl))=0)
		Super:C1706._throwError((Length:C16(String:C10(This:C1470._internals._uploadUrl))=0) ? 9 : 10; \
			New object:C1471("which"; "\"uploadUrl\""; "function"; "_GraphMessageUploadSession._uploadFile"))
		return False:C215
	End if 
	
	var $bIsOK : Boolean
	var $blob : 4D:C1709.Blob
	var $dataSize; $lastOffset; $chunkSize : Integer
	
	BASE64 DECODE:C896(This:C1470._internals._attachment.contentBytes; $blob)
	$dataSize:=$blob.size
	$lastOffset:=0
	
	While ($lastOffset<=$dataSize)
		
		var $chunk : 4D:C1709.Blob
		
		$chunkSize:=(($dataSize-$lastOffset)>This:C1470._internals._chunkSize) ? \
			This:C1470._internals._chunkSize : \
			($dataSize-$lastOffset)
		$chunk:=$blob.slice($chunkSize)
		
		$bIsOK:=This:C1470._sendChunk($dataSize; $lastOffset; $chunk)
		$lastOffset+=$chunk.size
		
		If (Not:C34($bIsOK))
			break
		End if 
		IDLE:C311
		
	End while 
	
	return $bIsOK
	