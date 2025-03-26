# Google Class

## Overview

The `Google` class allows you to send emails through the [Google REST API](https://developers.google.com/gmail/api/reference/rest/v1/users.messages).

This can be done after a valid token request, (see [OAuth2Provider object](#oauth2provider)).

The `Google` class is instantiated by calling the `cs.NetKit.Google.new()` function.

**Warning:** Shared objects are not supported by the 4D NetKit API.


## Table of contents

- [cs.NetKit.Google.new()](#csnetkitgooglenew)
- [Google.mail.append()](#googlemailappend)
- [Google.mail.createLabel()](#googlemailcreatelabel)
- [Google.mail.delete()](#googlemaildelete)
- [Google.mail.deleteLabel()](#googlemaildeletelabel)
- [Google.mail.getLabel()](#googlemailgetlabel)
- [Google.mail.getLabelList()](#googlemailgetlabellist)
- [Google.mail.getMail()](#googlemailgetmail)
- [Google.mail.getMailIds()](#googlemailgetmailids)
- [Google.mail.getMails()](#googlemailgetmails)
- [Google.mail.send()](#googlemailsend)
- [Google.mail.untrash()](#googlemailuntrash)
- [Google.mail.update()](#googlemailupdate)
- [Google.mail.updateLabel()](#googlemailupdatelabel)
- [Google.user.get()](#googleuserget)
- [Google.user.getCurrent()](#googleusergetcurrent)
- [Google.user.list()](#googleuserlist)
- [labelInfo object](#labelinfo-object)
- [Status object (Google Class)](#status-object-google-class)


## **cs.NetKit.Google.new()**

**cs.NetKit.Google.new**( *oAuth2* : cs.NetKit.OAuth2Provider { ; *options* : Object } ) : cs.NetKit.Google

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|oAuth2|cs.NetKit.OAuth2Provider|->| Object of the OAuth2Provider class  |
|options|Object|->| Additional options |
|Result|cs.NetKit.Google|<-| Object of the Google class|

### Description

`cs.NetKit.Google.new()` instantiates an object of the `Google` class.

In `oAuth2`, pass an [OAuth2Provider object](#oauth2provider).

In `options`, you can pass an object that specifies the following options:

|Property|Type|Description|
|---------|---|------|
|mailType|Text|Indicates the Mail type to use to send and receive emails. Possible types are: <br/>- "MIME"<br/>- "JMAP"|

### Returned object

The returned `Google` object contains the following properties:

|Property||Type|Description|
|----|-----|---|------|
|mail||Object|Email handling object|
||[send()](#googlemailsend)|Function|Sends the emails|
||type|Text|(read-only) Mail type used to send and receive emails. Can be set using the `mailType` option|
||userId|Text|User identifier, used to identify the user in Service mode. Can be the `id` or the `userPrincipalName`|

### Example

To create the OAuth2 connection object and a Google object:

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $google : cs.NetKit.Google

$oAuth2:=New OAuth2 provider($param)
$google:=cs.NetKit.Google.new($oAuth2;New object("mailType"; "MIME"))
```
## Google.mail.append()

**Google.mail.append**( *mail* : Text { ; *labelIds* : Collection } ) : Object <br/>
**Google.mail.append**( *mail* : Blob { ; *labelIds* : Collection } ) : Object <br/>
**Google.mail.append**( *mail* : Object { ; *labelIds* : Collection } ) : Object <br/>

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mail|Text &#124; Blob &#124; Object|->|Email to be append |
|labelIds|Collection|->|Collection of label IDs to add to messages. By default the DRAFT label is applied|
|Result|Object|<-|[Status object](#status-object-google-class)|


### Description

`Google.mail.append()` appends *mail* to the user's mailbox as a DRAFT or with designated *labelIds*.

>If the *labelIds* parameter is passed and the mail has a "from" or "sender" header, the Gmail server automatically adds the SENT label.

### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "id" property:

|Property|Type|Description|
|---------|--- |------|
|id|Text|id of the email created on the server|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

### Example

To append an email :

```4d
$status:=$google.mail.append($mail)
```

By default, the mail is created with a DRAFT label. To change the designated label, pass a second parameter:

```4d
$status:=$google.mail.append($mail;["INBOX"])
```

## Google.mail.createLabel()

**Google.mail.createLabel**( *labelInfo* : Object ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|[labelInfo](#labelinfo-object)|Object|->|Label information.|
|Result|Object|<-|[Status object](#status-object-google-class)|

### Description

`Google.mail.createLabel()` creates a new label.

### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "label" property:

|Property|Type|Description|
|---------|--- |------|
|label|Object|contains a newly created instance of Label (see [labelInfo](#labelinfo-object))|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

### Example

To create a label named 'Backup':

```4d
$status:=$google.mail.createLabel({name: "Backup"})
$labelId:=$status.label.id
```

## Google.mail.delete()

**Google.mail.delete**( *mailID* : Text { ; *permanently* : Boolean } ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailID|Text|->|ID of the mail to delete |
|permanently|Boolean|->|if permanently is true, deletes a message permanently. Otherwise, moves the specified message to the trash |
|Result|Object|<-|[Status object](#status-object-google-class)|


### Description

`Google.mail.delete()` deletes the specified message from the user's mailbox.

### Returned object

The method returns a standard [**status object**](#status-object-google-class).

### Permissions

This method requires one of the following OAuth scopes:

```
https://mail.google.com/
https://www.googleapis.com/auth/gmail.modify
```

### Example

To delete an email permanently:

```4d
$status:=$google.mail.delete($mailId; True)
```

## Google.mail.deleteLabel()

**Google.mail.deleteLabel**( *labelId* : Text ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|labelId|Text|->|The ID of the label|
|Result|Object|<-|[Status object](#status-object-google-class)|

### Description

`Google.mail.deleteLabel()` immediately and permanently deletes the specified label and removes it from any messages and threads that it is applied to. 
> This method is only available for labels with type="user".


### Returned object

The method returns a standard [**status object**](#status-object-google-class).

### Example

To delete a label:

```4d
$status:=$google.mail.deleteLabel($labelId)

```

## Google.mail.getLabel()

**Google.mail.getLabel**( *labelId* : Text ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|labelId|Text|->|The ID of the label|
|Result|Object|<-|[labelInfo](#labelinfo-object)|

### Description

`Google.mail.getLabel()` returns the information of a label as a [labelInfo](#labelinfo-object) object.

### Returned object

The returned [**labelInfo**](#labelinfo-object) object contains the following additional properties:


|Property|Type|Description|
|---------|---|------|
|messagesTotal|Integer|The total number of messages with the label.|
|messagesUnread|Integer|The number of unread messages with the label.|
|threadsTotal|Integer|The total number of threads with the label.|
|threadsUnread|Integer|The number of unread threads with the label.|

### Example

To retrieve the label name, total message count, and unread messages:

```4d
$info:=$google.mail.getLabel($labelId)
$name:=$info.name
$emailNumber:=$info.messagesTotal
$unread:=$info.messagesUnread
```

## Google.mail.getLabelList()

**Google.mail.getLabelList**() : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|Result|Object|<-| Status object |

### Description

`Google.mail.getLabelList()` returns an object containing the collection of all labels in the user's mailbox.


### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "labels" property:

|Property|Type|Description|
|---------|--- |------|
|labels|Collection|Collection of [`mailLabel` objects](#maillabel-objects)|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|


### mailLabel object

A `mailLabel` object contains the following properties (note that additional information can be returned by the server):

|Property|Type|Description|
|---------|--- |------|
|name|Text|Display name of the label.|
|id|Text|Immutable ID of the label.|
|messageListVisibility|Text|Visibility of messages with this label in the message list in the Gmail web interface. Can be "show" or "hide"|
|labelListVisibility|Text|Visibility of the label in the label list in the Gmail web interface. Can be:<br/>- "labelShow": Show the label in the label list.<br/>- "labelShowIfUnread": Show the label if there are any unread messages with that label<br/>- "labelHide": Do not show the label in the label list.|
|type|Text| Owner type for the label:<br/>- "user": User labels are created by the user and can be modified and deleted by the user and can be applied to any message or thread.<br/>- "system": System labels are internally created and cannot be added, modified, or deleted. System labels may be able to be applied to or removed from messages and threads under some circumstances but this is not guaranteed. For example, users can apply and remove the INBOX and UNREAD labels from messages and threads, but cannot apply or remove the DRAFTS or SENT labels from messages or threads.|


## Google.mail.getMail()

**Google.mail.getMail**( *mailID* : Text { ; *options* : Object } ) : Object<br/>**Google.mail.getMail**( *mailID* : Text { ; *options* : Object } ) : Blob<br/>

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailID|Text|->|ID of the message to retrieve |
|options|Object|->|Options |
|Result|Object &#124; Blob|<-| Downloaded mail|


### Description

`Google.mail.getMail()` gets the specified message from the user's mailbox.

In *options*, you can pass several properties:

|Property|Type|Description|
|---------|--- |------|
|format|Text| The format to return the message in. Can be: <br/>- "minimal": Returns only email message ID and labels; does not return the email headers, body, or payload. Returns a jmap object. <br/>- "raw": Returns the full email message (default)<br/>- "metadata": Returns only email message ID, labels, and email headers. Returns a jmap object.|
|headers|Collection|Collection of strings containing the email headers to be returned. When given and format is "metadata", only include headers specified.|
|mailType|Text|Only available if format is "raw". By default, the same as the *mailType* property of the mail (see [cs.NetKit.Google.new()](#csnetkitgooglenew)). If format="raw", the format can be: <br/>- "MIME"<br/>- "JMAP"|



### Returned object

The method returns a mail in one of the following formats, depending on the `mailType`:

|Format|Type|Comment|
|---|---|---|
|MIME|Blob||
|JMAP|Object|Contains an `id` attribute|



## Google.mail.getMailIds()

**Google.mail.getMailIds**( { *options* : Object } ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|options|Object|->|Options for messages to get |
|Result|Object|<-| Status object |

### Description

`Google.mail.getMailIds()` returns an object containing a collection of message ids in the user's mailbox.

In *options*, you can pass several properties:

|Property|Type|Description|
|---------|--- |------|
|top|Integer|Maximum number of messages to return (default is 100). The maximum allowed value for this field is 500.|
|search|Text| Only return messages matching the specified query. Supports the same query format as the Gmail search box. For example, "from:someuser@example.com rfc822msgid:somemsgid@example.com is:unread". See	also [https://support.google.com/mail/answer/7190](https://support.google.com/mail/answer/7190).|
|labelIds|Collection| Only return messages with labels that match all of the specified label IDs. Messages in a thread might have labels that other messages in the same thread don't have. To learn more, see [Manage labels on messages and threads](https://developers.google.com/gmail/api/guides/labels) in Google documentation.	|
|includeSpamTrash|Boolean|Include messages from SPAM and TRASH in the results. False by default.	|



### Returned object

The method returns a [**status object**](status-object-google-class) with additional properties:

|Property|Type|Description|
|---------|--- |------|
|isLastPage|Boolean|True if the last page is reached|
|page|Integer|Mail information page number. Starts at 1. By default, each page holds 10 results. Page size limit can be set in the `top` *option*.|
|next()|`4D.Function` object|Function that updates the mail collection with the next mail information page and increases the `page` property by 1. Returns a boolean value:<br/>- If a next page is successfully loaded, returns True<br/>- If no next page is returned, the mail collection is not updated and False is returned.|
|previous()|`4D.Function` object|Function that updates the mail collection with the previous mail information page and decreases the `page` property by 1. Returns a boolean value:<br/>- If a previous page is successfully loaded, returns True<br/>- If no previous page is returned, the mail collection is not updated and False is returned.|
|mailIds|Collection| Collection of objects, where each object contains:<br/>- *id* : Text : The id of the email<br/>- *threadId* : Text : The id of the thread to which this Email belongs<br/>- If no mail is returned, the collection is empty.|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|


### Permissions

This method requires one of the following OAuth scopes:

```
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/gmail.readonly
https://www.googleapis.com/auth/gmail.metadata
```

## Google.mail.getMails()

**Google.mail.getMails**( *mailIDs* : Collection { ; *options* : Object } ) : Collection

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailIDs|Collection|->|Collection of strings (mail IDs), or a collection of objects (each object contains an ID property)|
|options|Object|->|Options|
|Result|Collection|<-|Collection of mails in format depending on *mailType*: JMAP (collection of objects) or MIME (collection of blobs)</br>If no mail is returned, the collection is empty|


### Description

`Google.mail.getMails()` gets a collection of emails based on the specified *mailIDs* collection.

> The maximum number of IDs supported is 100. In order to get more than 100 mails, it's necessary to call the function multiple times; otherwise, the `Google.mail.getMails()` function returns null and throws an error.

In *options*, you can pass several properties:

|Property|Type|Description|
|---------|--- |------|
|format|Text| The format to return the message in. Can be: <br/>- "minimal": Returns only email message ID and labels; does not return the email headers, body, or payload. Returns a jmap object. <br/>- "raw": Returns the full email message (default)<br/>- "metadata": Returns only email message ID, labels, and email headers. Returns a jmap object.|
|headers|Collection|Collection of strings containing the email headers to be returned. When given and format is "metadata", only include headers specified.|
|mailType|Text|Only available if format is "raw". By default, the same as the *mailType* property of the mail (see [cs.NetKit.Google.new()](#csnetkitgooglenew)). If format="raw", the format can be: <br/>- "MIME"<br/>- "JMAP"(Default)|



### Returned value

The method returns a collection of mails in one of the following formats, depending on the `mailType`:

|Format|Type|Comment|
|---|---|---|
|MIME|Blob||
|JMAP|Object|Contains an `id` attribute|



## Google.mail.send()

**Google.mail.send**( *email* : Text ) : Object<br/>**Google.mail.send**( *email* : Object ) : Object<br/>**Google.mail.send**( *email* : Blob ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|email|Text &#124; Blob &#124; Object|->| Email to be sent|
|Result|Object|<-| [Status object](#status-object-google-class) |

### Description

`Google.mail.send()` sends an email using the MIME or JMAP formats.

In `email`, pass the email to be sent. Possible types:

* Text or Blob: the email is sent using the MIME format
* Object: the email is sent using the JSON format, in accordance with the [4D email object format](https://developer.4d.com/docs/API/EmailObjectClass.html#email-object), which follows the JMAP specification.

The data type passed in `email` must be compatible with the [`Google.mail.type` property](#returned-object-2). In the following example, since the mail type is `JMAP`, `$email` must be an object:

```4d
$Google:=cs.NetKit.Google.new($token;{mailType:"JMAP"})
$status:=$Google.mail.send($email)
```

> To avoid authentication errors, make sure your application has appropriate authorizations to send emails. One of the following OAuth scopes is required: [modify](https://www.googleapis.com/auth/gmail.modify), [compose](https://www.googleapis.com/auth/gmail.compose), or [send](https://www.googleapis.com/auth/gmail.send). For more information, see the [Authorization guide](https://developers.google.com/workspace/guides/configure-oauth-consent).

### Returned object

The method returns a standard [**status object**](#status-object-google-class).

## Google.mail.untrash()

**Google.mail.untrash**( *mailID* : Text ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailID|Text|->|The ID of the message to remove from Trash |
|Result|Object|<-|[Status object](#status-object-google-class)|


### Description

`Google.mail.untrash()` removes the specified message from the trash.

### Returned object

The method returns a standard [**status object**](#status-object-google-class).

### Permissions

This method requires one of the following OAuth scopes:

```
https://mail.google.com/
https://www.googleapis.com/auth/gmail.modify
```


## Google.mail.update()

**Google.mail.update**( *mailIDs* : Collection ; *options* : Object) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailIDs|Collection|->|Collection of strings (mail IDs), or collection of objects (each object contains an ID property)|
|options|Object|->|Options|
|Result|Object|<-| [Status object](#status-object-google-class) |

> There is a limit of 1000 IDs per request.

### Description

`Google.mail.update()` adds or removes labels on the specified messages to help categorizing emails. The label can be a system label (e.g., NBOX, SPAM, TRASH, UNREAD, STARRED, IMPORTANT) or a custom label. Multiple labels could be applied simultaneously.

For more information check out the [label management documentation](https://developers.google.com/gmail/api/guides/labels).

In *options*, you can pass the following two properties:

|Property|Type|Description|
|---------|--- |------|
|addLabelIds|Collection|A collection of label IDs to add to messages.|
|removeLabelIds|Collection|A collection of label IDs to remove from messages.|


### Returned object

The method returns a standard [**status object**](#status-object-google-class).


### Example

To mark a collection of emails as "unread":

```4d
$result:=$google.mail.update($mailIds; {addLabelIds: ["UNREAD"]})
```

## Google.mail.updateLabel()

**Google.mail.updateLabel**( *labelId* : Text ; *labelInfo* : Object ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|labelId|Text|->|The ID of the label|
|[labelInfo](#labelinfo-object)|Object|->|Label information to update|
|Result|Object|<-|[Status object](#status-object-google-class)|

### Description

`Google.mail.updateLabel()` updates the specified label.
> This method is only available for labels with type="user".

### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "label" property:

|Property|Type|Description|
|---------|--- |------|
|label|Object|contains an instance of Label (see [labelInfo](#labelinfo-object))|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

### Example

To update a previously created label  to 'Backup January':

```4d
$status:=$google.mail.updateLabel($labelId; {name:"Backup January"})

```


## Google.user.get()

**Google.user.get**( *id* : Text {; *select* : Text } ) : Object<br/>
**Google.user.get**( *id* : Text {; *select* : Collection } ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|id|Text|->|The *resourceName* of the person to provide information about. Use the *resourceName* field returned by [Google.user.list()](#googleuserlist) to specify the person.|
|select|Text \| Collection|->|Text: A comma-separated list of specific fields that you want to retrieve from each person (e.g., "names, phoneNumbers").  <br/>Collection: Collection of the specific fields.|
|Result|Object|<-|Represents user's details, like names, emails, and phone numbers based on the selected fields.|

### Description

`Google.user.get()` provides information about a [user](https://developers.google.com/people/api/rest/v1/people#Person) based on the *resourceName* provided in `id` and fields optionally specified in `select`.

Supported fields include *addresses*, *ageRanges*, *biographies*, *birthdays*, *calendarUrls*, *clientData*, *coverPhotos*, *emailAddresses*, *events*, *externalIds*, *genders*, *imClients*, *interests*, *locales*, *locations*, *memberships*, *metadata*, *miscKeywords*, *names*, *nicknames*, *occupations*, *organizations*, *phoneNumbers*, *photos*, *relations*, *sipAddresses*, *skills*, *urls*, *userDefined*.


### Returned object

The returned [user object](https://developers.google.com/people/api/rest/v1/people#Person) contains values for the specified field(s). 

If no fields have been specified in `select`, `Google.user.get()` returns *emailAddresses* and *names*. Otherwise, it returns only the specified field(s).

### Permissions

No authorization required to access public data. For private data, one of the following OAuth scopes is required:

https://www.googleapis.com/auth/contacts <br/>
https://www.googleapis.com/auth/contacts.readonly <br/>
https://www.googleapis.com/auth/contacts.other.readonly <br/>
https://www.googleapis.com/auth/directory.readonly <br/>
https://www.googleapis.com/auth/profile.agerange.read <br/>
https://www.googleapis.com/auth/profile.emails.read <br/>
https://www.googleapis.com/auth/profile.language.read <br/>
https://www.googleapis.com/auth/user.addresses.read <br/>
https://www.googleapis.com/auth/user.birthday.read <br/>
https://www.googleapis.com/auth/user.emails.read <br/>
https://www.googleapis.com/auth/user.gender.read <br/>
https://www.googleapis.com/auth/user.organization.read <br/>
https://www.googleapis.com/auth/user.phonenumbers.read <br/>
https://www.googleapis.com/auth/userinfo.email <br/>
https://www.googleapis.com/auth/userinfo.profile <br/>
https://www.googleapis.com/auth/profile.language.read

## Google.user.getCurrent()

**Google.user.getCurrent**( { *select* : Text } ) : Object<br/>
**Google.user.getCurrent**( { *select* : Collection } ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|select|Text \| Collection|->|Text: A comma-separated list of specific fields that you want to retrieve from each person (e.g., "names, phoneNumbers"). <br/>Collection: Collection of the specific fields.|
|Result|Object|<-|Represents user's details, like names, emails, and phone numbers based on the selected fields.|

### Description

`Google.user.getCurrent()` provides information about the authenticated [user](https://developers.google.com/people/api/rest/v1/people#Person) based on fields specified in `select`.

Supported fields include *addresses*, *ageRanges*, *biographies*, *birthdays*, *calendarUrls*, *clientData*, *coverPhotos*, *emailAddresses*, *events*, *externalIds*, *genders*, *imClients*, *interests*, *locales*, *locations*, *memberships*, *metadata*, *miscKeywords*, *names*, *nicknames*, *occupations*, *organizations*, *phoneNumbers*, *photos*, *relations*, *sipAddresses*, *skills*, *urls*, *userDefined*.

### Returned object

The returned [user object](https://developers.google.com/people/api/rest/v1/people#Person) contains values for the specific field(s). 

If no fields have been specified in `select`, `Google.user.getCurrent()` returns *emailAddresses* and *names*. Otherwise, it returns only the specified field(s).

### Permissions

Requires the same OAuth scope package as [Google.user.get()](#permissions-15).

### Example

To retrieve information from the current user:

```4d
var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param : Object

// Set up parameters:
$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id" // Replace with your Google identity platform client ID
$param.clientSecret:="xxxxxxxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:=[]
$param.scope.push("https://mail.google.com/")

$param.scope.push("https://www.googleapis.com/auth/contacts")
$param.scope.push("https://www.googleapis.com/auth/contacts.other.readonly")
$param.scope.push("https://www.googleapis.com/auth/contacts.readonly")
$param.scope.push("https://www.googleapis.com/auth/directory.readonly")
$param.scope.push("https://www.googleapis.com/auth/user.addresses.read")
$param.scope.push("https://www.googleapis.com/auth/user.birthday.read")
$param.scope.push("https://www.googleapis.com/auth/user.emails.read")
$param.scope.push("https://www.googleapis.com/auth/user.gender.read")
$param.scope.push("https://www.googleapis.com/auth/user.organization.read")
$param.scope.push("https://www.googleapis.com/auth/user.phonenumbers.read")
$param.scope.push("https://www.googleapis.com/auth/userinfo.email")
$param.scope.push("https://www.googleapis.com/auth/userinfo.profile")


$oauth2:=New OAuth2 provider($param)

$google:=cs.NetKit.Google.new($oauth2)

var $currentUser1:=$google.user.getCurrent()
//without parameters, returns by default "emailAddresses" and "names" 

var $currentUser2:=$google.user.getCurrent("phoneNumbers")
//returns the field "phoneNumbers" 
```

## Google.user.list()

**Google.user.list**( { *options* : Object } ) : Object

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|options|Object|->|A set of options defining how to retrieve and filter user data|
|Result|Object|<-|An object containing a structured collection of [user](https://developers.google.com/people/api/rest/v1/people#Person) data organized into pages|

### Description

`Google.user.list()` provides a list of domain profiles or domain contacts in the authenticated user's domain directory. 

> If the contact sharing or the External Directory sharing is not allowed in the Google admin, the returned `users` collection is empty.

In *options*, you can pass the following properties:

|Property|Type|Description|
|---------|--- |------|
|select|Text \| Collection|Text: A comma-separated list of specific fields that you want to retrieve from each person (e.g., "names, phoneNumbers"). <br/>Collection: Collection of the specific fields. <br/>If omitted, defaults to returning emailAddresses and names.|
|sources|Text \| Collection|Specifies the directory source to return. Values: <br/>-  DIRECTORY_SOURCE_TYPE_UNSPECIFIED (Unspecified), <br/>- DIRECTORY_SOURCE_TYPE_DOMAIN_CONTACT (Google Workspace domain  shared contact), <br/>-  DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE (default, Workspace domain  profile).|
|mergeSources|Text \| Collection|Adds related data if linked by verified join keys such as email addresses or phone numbers. <br/>-  DIRECTORY_MERGE_SOURCE_TYPE_UNSPECIFIED (Unspecified), <br/>- DIRECTORY_MERGE_SOURCE_TYPE_CONTACT (User owned contact).|
|top|Integer|Sets the maximum number of people to retrieve per page, between 1 and 1000 (default is 100).|

### Returned object

The returned object holds a collection of [users objects](https://developers.google.com/people/api/rest/v1/people#Person) as well as [**status object**](status-object-google-class) properties and functions that allow you to navigate between different pages of results.

|Property|Type|Description|
|---------|--- |------|
|users|Collection|A collection of [user objects](https://developers.google.com/people/api/rest/v1/people#Person), each containing detailed information about individual users|
|isLastPage|Boolean|Indicates whether the current page is the last one in the collection of user data.|
|page|Integer|Represents the current page number of user information, starting from 1. By default, each page contains 100 results, but the page size limit can be adjusted using the *top* option.|
|next()|Function|A function that retrieves the next page of user information. Returns True if successful; otherwise, returns False if there is no next page and the users collection is not updated.|
|previous()|Function|A function that retrieves the previous page of user information. Returns True if successful; otherwise, returns False if there is no previous page and the users collection is not updated.|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

### Permissions

Requires the same OAuth scope package as [Google.user.get()](#permissions-15).

### Example

To retrieve user data in a structured collection organized into pages with a maximum of `top` users per page: 

```4d
var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param : Object

$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id" // Replace with your Google identity platform client ID
$param.clientSecret:="xxxxxxxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:=[]
$param.scope.push("https://mail.google.com/")

$param.scope.push("https://www.googleapis.com/auth/contacts")
$param.scope.push("https://www.googleapis.com/auth/contacts.other.readonly")
$param.scope.push("https://www.googleapis.com/auth/contacts.readonly")
$param.scope.push("https://www.googleapis.com/auth/directory.readonly")
$param.scope.push("https://www.googleapis.com/auth/user.addresses.read")
$param.scope.push("https://www.googleapis.com/auth/user.birthday.read")
$param.scope.push("https://www.googleapis.com/auth/user.emails.read")
$param.scope.push("https://www.googleapis.com/auth/user.gender.read")
$param.scope.push("https://www.googleapis.com/auth/user.organization.read")
$param.scope.push("https://www.googleapis.com/auth/user.phonenumbers.read")
$param.scope.push("https://www.googleapis.com/auth/userinfo.email")
$param.scope.push("https://www.googleapis.com/auth/userinfo.profile")


$oauth2:=New OAuth2 provider($param)

$google:=cs.NetKit.Google.new($oauth2)

var $userList:=$google.user.list({top:10})
```


## labelInfo object

Several Google.mail label management methods use a `labelInfo` object, containing the following properties:

|Property|Type|Description|
|---------|--- |------|
|id|Text|The ID of the label.|
|name|Text|The display name of the label. (mandatory)|
|messageListVisibility|Text|The visibility of messages with this label in the message list.<br></br> Can be: <br/>- "show": Show the label in the message list. <<br/>- "hide": Do not show the label in the message list. |
|labelListVisibility|Text|The visibility of the label in the label list. <br></br> Can be:<br/>- "labelShow": Show the label in the label list. <br/>- "labelShowIfUnread" : Show the label if there are any unread messages with that label. <br/>- "labelHide": Do not show the label in the label list. |
|[color](https://developers.google.com/gmail/api/reference/rest/v1/users.labels?hl=en#color)|Object|The color to assign to the label (color is only available for labels that have their type set to user). <br></br> The color object has 2 attributes : <br/>-  textColor: text: The text color of the label, represented as hex string. This field is required in order to set the color of a label. <br/>- backgroundColor: text: The background color represented as hex string #RRGGBB (ex for black: #000000). This field is required in order to set the color of a label. </li></ul>|
|type|Text|The owner type for the label. <br></br> Can be: <br/>- "system": Labels created by Gmail.<br/>- "user": Custom labels created by the user or application.<br/>System labels are internally created and cannot be added, modified, or deleted. They're may be able to be applied to or removed from messages and threads under some circumstances but this is not guaranteed. For example, users can apply and remove the INBOX and UNREAD labels from messages and threads, but cannot apply or remove the DRAFTS or SENT labels from messages or threads. </br>User labels are created by the user and can be modified and deleted by the user and can be applied to any message or thread. |


## Status object

Several Google.mail functions return a `status object`, containing the following properties:

|Property|Type|Description|
|---------|--- |------|
|success|Boolean| True if the operation was successful|
|statusText|Text| Status message returned by the Gmail server or last error returned by the 4D error stack|
|errors |  Collection | Collection of 4D error items (not returned if a Gmail server response is received): <br/>- [].errcode is the 4D error code number<br/>- [].message is a description of the 4D error<br/>- [].componentSignature is the signature of the internal component that returned the error|

Basically, you can test the `success` and `statusText` properties of this object to know if the function was correctly executed.

Some functions adds specific properties to the **status object**, properties are described with the functions.



## See also

[Office365 Class](./Office365.md)
[OAuth2Provider Class](./OAuth2Provider.md)