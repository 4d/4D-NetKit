# Google Class

## Overview

The `Google` class allows you to send emails through the [Google REST API](https://developers.google.com/gmail/api/reference/rest/v1/users.messages).

This can be done after a valid token request, (see [OAuth2Provider object](#oauth2provider)).

The `Google` class is instantiated by calling the `cs.NetKit.Google.new()` function.

**Warning:** Shared objects are not supported by the 4D NetKit API.


## Table of Contents

### [Initialization](#csnetkitgooglenew)

* [cs.NetKit.Google.new()](#csnetkitgooglenew)

### [Calendar](#calendar-1)

* [Google.Calendar.getCalendar()](#googlecalendargetcalendar)
* [Google.Calendar.getCalendars()](#googlecalendargetcalendars)
* [Google.Calendar.getEvent()](#googlecalendargetevent)
* [Google.Calendar.getEvents()](#googlecalendargetevents)
* [Google.Calendar.createEvent()](#googlecalendarcreateevent)
* [Google.Calendar.updateEvent()](#googlecalendarupdateevent)
* [Google.Calendar.deleteEvent()](#googlecalendardeleteevent)
* [Event object](#event-object)

### [Mail](#mail-1)

* [Google.mail.send()](#googlemailsend)
* [Google.mail.append()](#googlemailappend)
* [Google.mail.update()](#googlemailupdate)
* [Google.mail.createLabel()](#googlemailcreatelabel)
* [Google.mail.updateLabel()](#googlemailupdatelabel)
* [Google.mail.deleteLabel()](#googlemaildeletelabel)
* [Google.mail.delete()](#googlemaildelete)
* [Google.mail.getLabel()](#googlemailgetlabel)
* [Google.mail.getLabelList()](#googlemailgetlabellist)
* [Google.mail.getMail()](#googlemailgetmail)
* [Google.mail.getMailIds()](#googlemailgetmailids)
* [Google.mail.getMails()](#googlemailgetmails)
* [Google.mail.untrash()](#googlemailuntrash)
* [labelInfo object](#labelinfo-object)

### [User](#user-1)

* [Google.user.get()](#googleuserget)
* [Google.user.getCurrent()](#googleusergetcurrent)
* [Google.user.list()](#googleuserlist)

### [Status](#status-object)

* [Status object](#status-object)

## **cs.NetKit.Google.new()**

**cs.NetKit.Google.new**( *oAuth2* : cs.NetKit.OAuth2Provider { ; *param* : Object } ) : cs.NetKit.Google

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|oAuth2|cs.NetKit.OAuth2Provider|->| Object of the OAuth2Provider class  |
|param|Object|->| Additional options |
|Result|cs.NetKit.Google|<-| Object of the Google class|

### Description

`cs.NetKit.Google.new()` instantiates an object of the `Google` class.

In `oAuth2`, pass an [OAuth2Provider object](#oauth2provider).

In `param`, you can pass an object that specifies the following options:

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

## Calendar

### Google.Calendar.getCalendar()

**Google.Calendar.getCalendar**( { *id* : Text } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|id|Text|->|ID of the calender to retrieve. |
|calendar|Object|<-| Object containing the details of the specified calendar. For more details, see the [Google Calendar API resource](https://developers.google.com/calendar/api/v3/reference/calendarList#resource).|

> To retrieve calendar IDs call the getCalendars() function. If id is null, empty or missing, returns the primary calendar of the currently logged in user.

#### Description

`Google.Calendar.getCalendar()` retrieves a specific calendar from the authenticated user's calendar list; using an `id` to identify the calendar and returns a `calendar` object containing details about the requested calendar.

#### Example 

```4d

var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param; $Calendars; $myCalendar : Object

$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id" // Replace with your Google identity platform client ID
$param.clientSecret:="xxxxxxxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:=[]
$param.scope.push("https://mail.google.com/")
$param.scope.push("https://www.googleapis.com/auth/calendar")

$oauth2:=New OAuth2 provider($param)

$google:=cs.NetKit.Google.new($oauth2)

// Retrieve the entire list of calendars
$Calendars:=$google.calendar.getCalendars()

// Retrieve the first calendar in the list using its ID
$myCalendar:=$google.calendar.getCalendar($Calendars.calendars[0].id)

```


### Google.Calendar.getCalendars()

**Google.Calendar.getCalendar**( { *param* : Object } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|param|Object|->|Set of options to filter or refine the calendar list request.|
|Result|Object|<-|Object containing the calendar list with the related data.|

#### Description

`Google.Calendar.getCalendars()` retrieves a list of calendars that the authenticated user can access. The passed filtering and paging options in `param` are returned in the `result` object.

In *param*, you can pass the following optional properties:

|Property|Type|Description|
|---------|--- |------|
| maxResults | Integer | Maximum number of calendar entries returned per page. Default is 100. Maximum is 250.|
| minAccessRole | String  | Minimum access role for the user in the returned calendars. Default is no restriction. Acceptable values:|
| | |- "freeBusyReader": User can read free/busy information.             |                                                                                                                                                                    
| | |- "owner":  User can read, modify events, and control access. |
| | |- "reader": User can read non-private events.  |
| | |- "writer": User can read and modify events.                         |         
| showDeleted | Boolean | Whether to include deleted calendar list entries in the result. Optional. The default is False.|
| showHidden | Boolean | Whether to show hidden entries. Optional. The default is False.|

#### Returned object

The function returns a Collection of details about the user's calendar list in the following properties:

| **Property**         | **Type**          | **Description**                                                                                                                                                             |
|----------------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `calendars`          | Collection        | Collection of calendar objects present in the user's calendar list. Each calendar object contains details such as `id`, `summary`, and `accessRole`.                                                             |
| `isLastPage`         | Boolean           | `True` if the last page of results has been reached.                                                                                                                       |
| `page`               | Integer           | Current page number of results. Starts at `1`. By default, each page holds 100 results.                                                                                   |
| `next()`             | Function          | Loads the next page of calendar entries and increments the `page` property by 1. Returns:                                                                                  |
|                      |                   | - `True` if the next page is loaded successfully.                                                                                                                         |
|                      |                   | - `False` if no additional pages are available (the collection is not updated).                                                                                           |
| `previous()`         | Function          | Loads the previous page of calendar entries and decrements the `page` property by 1. Returns:                                                                              |
|                      |                   | - `True` if the previous page is loaded successfully.                                                                                                                     |
|                      |                   | - `False` if no previous pages are available (the collection is not updated).                                                                                             |
| `statusText`         | Text              | Status message returned by the Google server or the last error message from the 4D error stack.                                                                            |
| `success`            | Boolean           | `True` if the operation is successful, `False` otherwise.                                                                                                                 |
| `errors`             | Collection        | Collection of 4D error items (if any):                                                                                                                                     |
|                      |                   | - `.errcode`: 4D error code number.                                                                                                                                         |
|                      |                   | - `.message`: Error description.                                                                                                                                           |
|                      |                   | - `.componentSignature`: Signature of the component that returned the error.                                                                                              |


#### Example 

```4d

var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param; $Calendars : Object

$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id" // Replace with your Google identity platform client ID
$param.clientSecret:="xxxxxxxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:=[]
$param.scope.push("https://mail.google.com/")
$param.scope.push("https://www.googleapis.com/auth/calendar")

$oauth2:=New OAuth2 provider($param)

$google:=cs.NetKit.Google.new($oauth2)

// Retrieve the entire list of calendars

$Calendars:=$google.calendar.getCalendars()

```
### Google.Calendar.getEvent()

**Google.Calendar.getEvent**( *param* : Object ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|param|Object|->|Object containing the necessary details to retrieve a specific event|
|Result|Object|<-|Object containing the retrieved event|

#### Description

`Google.Calendar.getEvent()` retrieves a specific event from a Google Calendar using its unique `eventId`.

In *param*, you can pass the following properties:

|Property|Type|Description|
|---------|--- |------|
| eventId | String | (Required) The unique identifier of the event to retrieve |
| calendarId | String | Calendar identifier. To retrieve calendar IDs, call calendarList.list(). If not provided, the user's primary (currently logged-in) calendar is used |
| maxAttendees | Integer | Max number of attendees to be returned for the event|
| timeZone | String | Time zone used in the response (formatted as an IANA Time Zone Database name, e.g., "Europe/Zurich"). Defaults to UTC |

#### Returned object 

The function returns a Google [`event`](https://developers.google.com/calendar/api/v3/reference/events) object.

### Google.Calendar.getEvents()

**Google.Calendar.getEvents**( { *param* : Object } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|param|Object|->|Object containing filters and options for retrieving calendar events|
|Result|Object|<-|Object containing the retrieved events|

#### Description

`Google.Calendar.getEvents()` retrieves events on the specified calendar. If *param* is not provided, it returns all events from the user's primary calendar.

In *param*, you can pass the following optional properties:

|Property|Type|Description|
|---------|--- |------|
| calendarId | String | Calendar identifier. To retrieve calendar IDs, call `Google.Calendar.getCalendars()`. If not provided, the user's primary calendar is used. |
| eventTypes | String | Specifies the types of events to return. Can be repeated multiple times to retrieve multiple event types. If not set, all event types are returned. Acceptable values: "birthday" (special all-day events with annual recurrence), "default" (regular events), "focusTime" (focus time events), "fromGmail" (events from Gmail), "outOfOffice" (out-of-office events), "workingLocation" (working location events). |
| iCalUID | String | Searches for an event by its iCalendar ID. **Note:** `icalUID` and `id` are not identical. In recurring events, all occurrences have unique `id`s but share the same `icalUID`. |
| maxAttendees | Integer | Limits the number of attendees to be returned per event|
| top | Integer | Mximum number of events per page. Default is `250`, maximum is `2500`. |
| orderBy | String | Specifies how events should be ordered in the response. Default is an **unspecified but stable order**. Acceptable values: "startTime" (ascending, only when `singleEvents=True`), "updated" (ascending order of last modification time). |
| privateExtendedProperty | Collection | Returns events that match these properties specified as propertyName=value |
| search | String | Searches for events using free text in multiple fields, including summary, description, location, attendee names/emails, organizer names/emails, and working location properties. Also matches predefined keywords for out-of-office, focus-time, and working-location events. |
| sharedExtendedProperty | Collection | Returns events that match these properties specified as propertyName=value. The returned events match **all** specified constraints |
| showDeleted | Boolean | Whether to include deleted events (`status="cancelled"`) in the result. Defaults to `False`. Behavior depends on the `singleEvents` setting |
| showHiddenInvitations | Boolean | Whether to include hidden invitations in the result. Defaults to `False` |
| singleEvents | Boolean | Whether to expand recurring events into instances and return only individual events and instances, **excluding** the underlying recurring event. Defaults to `False` |
| startDateTime | Text, Object | Filters events by start time. If set, `endDateTime` must also be provided. **Text:** ISO 8601 UTC timestamp. **Object:** Must contain `date` (date type) and `time` (time type), formatted according to system settings |
| endDateTime | Text, Object | Filters events by end time. If set, `startDateTime` must also be provided. **Text:** ISO 8601 UTC timestamp. **Object:** Must contain `date` (date type) and `time` (time type), formatted according to system settings |
| timeZone | String | Time zone for the response, formatted as an IANA Time Zone Database name (e.g., "Europe/Zurich"). Defaults to UTC |
| updatedMin | Text | Filters events based on last modification time (`ISO 8601 UTC`). When set, deleted events since this time are always included, regardless of `showDeleted` |

#### Returned object

The method returns a [**status object**](#status-object-google-class) in addition to the following properties:

| Property |  Type | Description |
|---| ---|---|
| isLastPage | Boolean | True if the last page is reached. |
| page | Integer | Page number of the user information. Defaults to 1, with a page size of 100 (configurable via top). |
| next() | Function | Fetches the next page of users, increments page by 1. Returns True if successful, False otherwise. |
| previous() | Function | Fetches the previous page of users, decrements page by 1. Returns True if successful, False otherwise. |
| kind | String | Type of collection ("calendar#events"). |
| etag | String | ETag of the collection. |
| summary | String | Title of the calendar (read-only). |
| calendarId | String | Calendar identifier, same as the calendarId passed in the parameter if present. |
| description | String | Description of the calendar (read-only). |
| updated | Text | Last modification time of the calendar (ISO 8601 UTC). |
| timeZone | String | Time zone of the calendar (formatted as an IANA Time Zone Database name, e.g., "Europe/Zurich"). |
| accessRole | String | User’s access role for the calendar (read-only). Possible values: "none", "freeBusyReader", "reader", "writer", "owner". |
| defaultReminders | Collection | Default reminders for the authenticated user. Applies to events that do not explicitly override them. |
| defaultReminders[].method | String | Method used for the reminder ("email" or "popup"). |
| defaultReminders[].minutes | Integer | Minutes before the event when the reminder triggers. |
| events | Collection | List of events on the calendar. If some events have attachments, an "attachments" attribute is added, containing a collection of attachments. |

#### Example

```4d

// Gets all the calendars 
var $calendars:=$google.calendar.getCalendars()
// For the rest of the example, we'll use the first calendar in the list
var $myCalendar:=$calendars.calendars[0]

// Gets all the event of the selected calendars
var $events:=$google.calendar.getEvents({calendarId: $myCalendar.id; top: 10})

```

### Google.calendar.createEvent()

**Google.calendar.createEvent**(*event*: Object{; *param*: Object}) : Object

#### Parameters

| Parameter | Type   |  | Description|                                                                                                                                                                 
| -------- | ------ | --- |--------------------------- |
|event | Object | ->|Object containing details of the calendar [event](#event-object) to create |
|param | Object | -> | Object containing additional creation options | 
|Result|Object|<-|[Status object](#status-object-google-class)|

#### Description

`Google.calendar.createEvent()` creates a new calendar event.

In *event*, pass an [event](#event-object) object to create. Only `start` and `end` properties are required.

In *param*, you can pass the following additional optional properties:

|Property|Type|Description|
|---------|--- |------|
|sendUpdates|String|Defines who should receive email notifications about the event. Acceptable values:<br>• `"all"` – Notify all attendees.<br>• `"externalOnly"` – Notify only non-Google users.<br>• `"none"` – No notifications sent.| 
|supportsAttachments|Boolean| `true` to allow creation or modification of the [`attachments`](#attachment-object-google) property. Defaults to `false`  |

#### Returned Object

The method returns a [**status object**](status-object-google-class) with an additional "event" property:

|Property|Type|Description|
|---------|--- |------|
|event|Object|[Event object](#event-object) returned by the server|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

#### Example

Create an event in the Google calendar:

```4d
var $Google:=cs.NetKit.Google.new($Oauth)
var $event; $result : Object

$event:={}
$event.summary:="Team Meeting"
$event.start:={date: Current date; time: Current time}
$event.end:={date: Current date; time: Current time+3600}
$event.attendees:=[{email: "first.lastname@gmail.com"}]
$event.description:="description of the event"

$result:=$Google.calendar.createEvent($event)
If (Not($result.success))
  ALERT($result.statusText)
End if
```

### Google.calendar.updateEvent()

**Google.calendar.updateEvent**(*event*: Object{; *param*: Object}) : Object

#### Parameters

| Parameter | Type   | | Description|                                                                          
| -------- | ----- | -------- | --------------- |
|event |Object|->| Object containing details of the calendar [event](#event-object) to update. |
|param |Object|->| Object containing additional update options. | 
|Result | Object | <-| [Status object](#status-object-google-class) |

#### Description

`Google.calendar.updateEvent()` updates an existing event.

In *event*, pass an [event](#event-object) object to create. `start`, `end` and `id` properties are required.

And in *param*, you can pass the following additional optional properties:

| Property | Type    | Description |
|------------|---------|-------------|
| sendUpdates | String  | Defines who should receive email notifications about the update. Acceptable values:<br>• `"all"` – Notify all attendees.<br>• `"externalOnly"` – Notify only non-Google users.<br>• `"none"` – No notifications sent. |
| supportsAttachments | Boolean | `true` to allow creation or modification of the [`attachments`](#attachment-object-google) property. Defaults to `false`. |
| fullUpdate | Boolean | If `true`, the full event is replaced. If `false` (default), only specified fields are updated. | 

#### Returned Object

The method returns a [**status object**](status-object-google-class) with an additional "event" property:

|Property|Type|Description|
|---------|--- |------|
|event|Object|Updated [event object](#event-object) returned by the server|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

#### Example

Update an already existing event:

```4d
#DECLARE($eventId:Text)  
var $Google:=cs.NetKit.Google.new($Oauth)
var $result : Object

$event.id:=$eventId
$event.summary:="Updated Event Title"
$event.description:="Updated Event description"
$event.start:={date: Current date; time: Current time}
$event.end:={date: Current date; time: Current time+3600}

$result:=$Google.calendar.updateEvent($event)
If (Not($result.success))
  ALERT($result.statusText)
End if
```


### Google.calendar.deleteEvent()

**Google.calendar.deleteEvent**(*param*: Object) : Object

#### Parameters

| Parameter | Type   | | Description                                                                                                                                                                                                                                                                   |
| -------- | ----- | --- | -------------------- |
| param | Object | -> | Object containing details of the calendar [event](#event-object) to delete | 
|Result|Object|<-|[Status object](#status-object-google-class)|

#### Description

`Google.calendar.deleteEvent()` deletes an event from a specified calendar. 

In *param*, you can pass the following properties:

|Property|Type|Description|
|---------|--- |------|
| eventId | String | **Required.** ID of the event to delete|
| calendarId | String |**Optional.** Calendar ID. If not provided or null, uses the user's primary calendar. To retrieve calendar IDs, call `Google.calendar.getCalendars()`|
| sendUpdates | String |**Optional.** Controls which  attendees of the event receive notifications about the deletion. Acceptable values:<br>• `"all"` – Notify all attendees of the event (Google or non-Google users) <br>• `"externalOnly"` – Notify only non-Google users <br>• `"none"` – No notifications sent|

#### Returned Object

The method returns a standard [**status object**](#status-object-google-class).

#### Example

Delete a calendar event:

```4d
var $Google:=cs.NetKit.Google.new($Oauth)

$status:=$google.calendar.deleteEvent({eventId: $event.id})
If ($result.success)
  ALERT("Calendar event correctly deleted")
Else
  ALERT($result.statusText)
End if
```

### Event object

The `event` object used with Google Calendar methods includes the following main properties. For the full list, refer to the [official Google Calendar API documentation](https://developers.google.com/calendar/api/v3/reference/events#resource).

| Property | | Type | Description|                                                                                                                                                           
| ------ |---| -------- | ------------------- |
|id 	||	Text 	| ID for the event.|
| calendarId | | Text | Calendar ID. If not provided, the user's primary calendar is used. Use `Google.calendar.getCalendars()` to retrieve IDs.|                                       
| attachments | | Collection | File [attachments](#attachment-object-google) (max 25). To use this, `supportsAttachments` must be set to `true` in the request.| 
| attendees| | Collection | List of attendees.  |
| | email | String | Required. Email address of the attendee. |
| | displayName | String | Name of the attendee. |
| | comment| String | The attendee’s response comment. |
| | optional| Boolean  | (Default: false) Whether the attendee is optional.|
| | resource| Boolean  | (Default: false) Set to `true` when the attendee is a resource (e.g., room or equipment). Can only be set when the attendee is first added. Ignored in later updates. |
| | additionalGuests| Integer  | (Default: `0`) Allowed number of additional guests of the attendee.  |
| description | | Text       | Description of the event (HTML allowed).|  
| start | | Object     | Start time. Use `dateTime` with optional `timeZone`, or `date` for all-day events.|
| | date | Date, Text | Start date of the event. If provided as text, use the format `"yyyy-mm-dd"`. |
| | time | Time |Start time of the event (not present if all-day event)| 
| | dateTime | Text | Combined start date and time in RFC3339 format. A time zone offset is required unless `timeZone` is specified. IOverrides `date` and `time`.(not used for all-day events). |
| | timeZone | String | Time zone for the `dateTime`, using IANA format (e.g., `"Europe/Zurich"`). Defaults to UTC if not provided.   |  
| end | | Object     | End time. Use `dateTime` with optional `timeZone`, or `date` for all-day events.|
| | date | Date, Text | End date of the event. If provided as text, use the format `"yyyy-mm-dd"`. |
| | time | Time |End time of the event (not present if all-day event)|
| | dateTime | Text |Combined date and time in RFC3339 format. A time zone offset is required unless `timeZone` is specified. Overrides `date` and `time`.(not used for all-day events). |
| | timeZone | String | Time zone for the `dateTime`, using IANA format (e.g., `"Europe/Zurich"`). Defaults to UTC if not provided. |
| eventType | | Text       | Specific type of the event (Cannot be changed after creation). <br> Possible values: `"default"`, `"birthday"`, `"focusTime"`, `"outOfOffice"`, etc.|
| extendedProperties.private | | Object     | [Custom key-value pairs](https://developers.google.com/calendar/api/v3/reference/events#extendedProperties)  only visible to the event owner to store additional information (e.g; `"internalNote": "Discuss Q3 targets"`)|
| extendedProperties.shared | | Object     | [Custom key-value pairs](https://developers.google.com/calendar/api/v3/reference/events#extendedProperties) shared with all attendees to share additional notes or tags (e.g., `"projectCode": "XYZ123"`).|                                                                                                                         
| focusTimeProperties| | Object     | [Focus Time event-specific settings](https://developers.google.com/calendar/api/v3/reference/events#focustimeproperties). Used when `eventType` is `"focusTime"`.|
| guestsCanInviteOthers | | Boolean    | (Default: true) If attendees can invite guests. |
| guestsCanModify  | | Boolean    | (Default: false) If attendees can edit the event. |  
| guestsCanSeeOtherGuests| | Boolean    | (Default: true) If attendees can see each other.| 
| location | | Text       | Event location.|                                                                                                                                              
| recurrence\[] | | Collection       | List of rules for repeating events using [RFC5545](https://www.rfc-editor.org/rfc/rfc5545) format (RRULE/EXRULE/RDATE/EXDATE (e.g., FREQ=WEEKLY;BYDAY=MO)). Does not include start/end times, use the `start` and `end` for that. Omit this field for one-time events. |                                                                       
| reminders.overrides\[] | | Collection       | Custom reminders.|
| | method | String  | **Required**. Method of the reminder: "email" or "popup"|
| | minutes | Integer  | **Required**. Time before event (in minutes) when reminder should trigger. Between 0 and 40320.|
| reminders.useDefault | | Boolean    | Whether to use the calendar’s default reminders for the event.| 
| source.title | | Text       | Title of the source linked to the event, such as a web page or email subject.|  
| source.url | | Text       | URL of the source linked to the event (must use `http` or `https`).| 
| status | | Text       |Describes the event's current state. <br> Possible values: `"confirmed"` (default) `"tentative"`, or `"cancelled"`.| 
| summary | | Text  | Title of the event.| 
| transparency | | Text       | Whether the event blocks time on the calendar. Values: `"opaque"` (busy) or `"transparent"` (available).|
| visibility | | Text       | Visibility level: `"default"`, `"public"`, `"private"`, or `"confidential"`.|                                                                                           

## Mail

### Google.mail.append()

**Google.mail.append**( *mail* : Text { ; *labelIds* : Collection } ) : Object <br/>
**Google.mail.append**( *mail* : Blob { ; *labelIds* : Collection } ) : Object <br/>
**Google.mail.append**( *mail* : Object { ; *labelIds* : Collection } ) : Object <br/>

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mail|Text &#124; Blob &#124; Object|->|Email to be append |
|labelIds|Collection|->|Collection of label IDs to add to messages. By default the DRAFT label is applied|
|Result|Object|<-|[Status object](#status-object-google-class)|


#### Description

`Google.mail.append()` appends *mail* to the user's mailbox as a DRAFT or with designated *labelIds*.

>If the *labelIds* parameter is passed and the mail has a "from" or "sender" header, the Gmail server automatically adds the SENT label.

#### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "id" property:

|Property|Type|Description|
|---------|--- |------|
|id|Text|id of the email created on the server|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

#### Example

To append an email :

```4d
$status:=$google.mail.append($mail)
```

By default, the mail is created with a DRAFT label. To change the designated label, pass a second parameter:

```4d
$status:=$google.mail.append($mail;["INBOX"])
```

### Google.mail.createLabel()

**Google.mail.createLabel**( *labelInfo* : Object ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|[labelInfo](#labelinfo-object)|Object|->|Label information.|
|Result|Object|<-|[Status object](#status-object-google-class)|

#### Description

`Google.mail.createLabel()` creates a new label.

#### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "label" property:

|Property|Type|Description|
|---------|--- |------|
|label|Object|contains a newly created instance of Label (see [labelInfo](#labelinfo-object))|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

#### Example

To create a label named 'Backup':

```4d
$status:=$google.mail.createLabel({name: "Backup"})
$labelId:=$status.label.id
```

### Google.mail.delete()

**Google.mail.delete**( *mailID* : Text { ; *permanently* : Boolean } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailID|Text|->|ID of the mail to delete |
|permanently|Boolean|->|if permanently is true, deletes a message permanently. Otherwise, moves the specified message to the trash |
|Result|Object|<-|[Status object](#status-object-google-class)|


#### Description

`Google.mail.delete()` deletes the specified message from the user's mailbox.

#### Returned object

The method returns a standard [**status object**](#status-object-google-class).

#### Permissions

This method requires one of the following OAuth scopes:

```
https://mail.google.com/
https://www.googleapis.com/auth/gmail.modify
```

#### Example

To delete an email permanently:

```4d
$status:=$google.mail.delete($mailId; True)
```

### Google.mail.deleteLabel()

**Google.mail.deleteLabel**( *labelId* : Text ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|labelId|Text|->|The ID of the label|
|Result|Object|<-|[Status object](#status-object-google-class)|

#### Description

`Google.mail.deleteLabel()` immediately and permanently deletes the specified label and removes it from any messages and threads that it is applied to. 
> This method is only available for labels with type="user".


#### Returned object

The method returns a standard [**status object**](#status-object-google-class).

#### Example

To delete a label:

```4d
$status:=$google.mail.deleteLabel($labelId)

```

### Google.mail.getLabel()

**Google.mail.getLabel**( *labelId* : Text ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|labelId|Text|->|The ID of the label|
|Result|Object|<-|[labelInfo](#labelinfo-object)|

#### Description

`Google.mail.getLabel()` returns the information of a label as a [labelInfo](#labelinfo-object) object.

#### Returned object

The returned [**labelInfo**](#labelinfo-object) object contains the following additional properties:


|Property|Type|Description|
|---------|---|------|
|messagesTotal|Integer|The total number of messages with the label.|
|messagesUnread|Integer|The number of unread messages with the label.|
|threadsTotal|Integer|The total number of threads with the label.|
|threadsUnread|Integer|The number of unread threads with the label.|

#### Example

To retrieve the label name, total message count, and unread messages:

```4d
$info:=$google.mail.getLabel($labelId)
$name:=$info.name
$emailNumber:=$info.messagesTotal
$unread:=$info.messagesUnread
```

### Google.mail.getLabelList()

**Google.mail.getLabelList**() : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|Result|Object|<-| Status object |

#### Description

`Google.mail.getLabelList()` returns an object containing the collection of all labels in the user's mailbox.


#### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "labels" property:

|Property|Type|Description|
|---------|--- |------|
|labels|Collection|Collection of [`mailLabel` objects](#maillabel-objects)|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|


#### mailLabel object

A `mailLabel` object contains the following properties (note that additional information can be returned by the server):

|Property|Type|Description|
|---------|--- |------|
|name|Text|Display name of the label.|
|id|Text|Immutable ID of the label.|
|messageListVisibility|Text|Visibility of messages with this label in the message list in the Gmail web interface. Can be "show" or "hide"|
|labelListVisibility|Text|Visibility of the label in the label list in the Gmail web interface. Can be:<br/>- "labelShow": Show the label in the label list.<br/>- "labelShowIfUnread": Show the label if there are any unread messages with that label<br/>- "labelHide": Do not show the label in the label list.|
|type|Text| Owner type for the label:<br/>- "user": User labels are created by the user and can be modified and deleted by the user and can be applied to any message or thread.<br/>- "system": System labels are internally created and cannot be added, modified, or deleted. System labels may be able to be applied to or removed from messages and threads under some circumstances but this is not guaranteed. For example, users can apply and remove the INBOX and UNREAD labels from messages and threads, but cannot apply or remove the DRAFTS or SENT labels from messages or threads.|


### Google.mail.getMail()

**Google.mail.getMail**( *mailID* : Text { ; *param* : Object } ) : Object<br/>**Google.mail.getMail**( *mailID* : Text { ; *param* : Object } ) : Blob<br/>

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailID|Text|->|ID of the message to retrieve |
|param|Object|->|Options for the message to retrieve|
|Result|Object &#124; Blob|<-| Downloaded mail|


#### Description

`Google.mail.getMail()` gets the specified message from the user's mailbox.

In *param*, you can pass several properties:

|Property|Type|Description|
|---------|--- |------|
|format|Text| The format to return the message in. Can be: <br/>- "minimal": Returns only email message ID and labels; does not return the email headers, body, or payload. Returns a jmap object. <br/>- "raw": Returns the full email message (default)<br/>- "metadata": Returns only email message ID, labels, and email headers. Returns a jmap object.|
|headers|Collection|Collection of strings containing the email headers to be returned. When given and format is "metadata", only include headers specified.|
|mailType|Text|Only available if format is "raw". By default, the same as the *mailType* property of the mail (see [cs.NetKit.Google.new()](#csnetkitgooglenew)). If format="raw", the format can be: <br/>- "MIME"<br/>- "JMAP"|



#### Returned object

The method returns a mail in one of the following formats, depending on the `mailType`:

|Format|Type|Comment|
|---|---|---|
|MIME|Blob||
|JMAP|Object|Contains an `id` attribute|



### Google.mail.getMailIds()

**Google.mail.getMailIds**( { *param* : Object } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|param|Object|->|Options for messages to get |
|Result|Object|<-| Status object |

#### Description

`Google.mail.getMailIds()` returns an object containing a collection of message ids in the user's mailbox.

In *param*, you can pass several properties:

|Property|Type|Description|
|---------|--- |------|
|top|Integer|Maximum number of messages to return (default is 100). The maximum allowed value for this field is 500.|
|search|Text| Only return messages matching the specified query. Supports the same query format as the Gmail search box. For example, "from:someuser@example.com rfc822msgid:somemsgid@example.com is:unread". See	also [https://support.google.com/mail/answer/7190](https://support.google.com/mail/answer/7190).|
|labelIds|Collection| Only return messages with labels that match all of the specified label IDs. Messages in a thread might have labels that other messages in the same thread don't have. To learn more, see [Manage labels on messages and threads](https://developers.google.com/gmail/api/guides/labels) in Google documentation.	|
|includeSpamTrash|Boolean|Include messages from SPAM and TRASH in the results. False by default.	|



#### Returned object

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


#### Permissions

This method requires one of the following OAuth scopes:

```
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/gmail.readonly
https://www.googleapis.com/auth/gmail.metadata
```

### Google.mail.getMails()

**Google.mail.getMails**( *mailIDs* : Collection { ; *param* : Object } ) : Collection

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailIDs|Collection|->|Collection of strings (mail IDs), or a collection of objects (each object contains an ID property)|
|param|Object|->|Options|
|Result|Collection|<-|Collection of mails in format depending on *mailType*: JMAP (collection of objects) or MIME (collection of blobs)</br>If no mail is returned, the collection is empty|


#### Description

`Google.mail.getMails()` gets a collection of emails based on the specified *mailIDs* collection.

> The maximum number of IDs supported is 100. In order to get more than 100 mails, it's necessary to call the function multiple times; otherwise, the `Google.mail.getMails()` function returns null and throws an error.

In *param*, you can pass several properties:

|Property|Type|Description|
|---------|--- |------|
|format|Text| The format to return the message in. Can be: <br/>- "minimal": Returns only email message ID and labels; does not return the email headers, body, or payload. Returns a jmap object. <br/>- "raw": Returns the full email message (default)<br/>- "metadata": Returns only email message ID, labels, and email headers. Returns a jmap object.|
|headers|Collection|Collection of strings containing the email headers to be returned. When given and format is "metadata", only include headers specified.|
|mailType|Text|Only available if format is "raw". By default, the same as the *mailType* property of the mail (see [cs.NetKit.Google.new()](#csnetkitgooglenew)). If format="raw", the format can be: <br/>- "MIME"<br/>- "JMAP"(Default)|



#### Returned value

The method returns a collection of mails in one of the following formats, depending on the `mailType`:

|Format|Type|Comment|
|---|---|---|
|MIME|Blob||
|JMAP|Object|Contains an `id` attribute|



### Google.mail.send()

**Google.mail.send**( *email* : Text ) : Object<br/>**Google.mail.send**( *email* : Object ) : Object<br/>**Google.mail.send**( *email* : Blob ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|email|Text &#124; Blob &#124; Object|->| Email to be sent|
|Result|Object|<-| [Status object](#status-object-google-class) |

#### Description

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

#### Returned object

The method returns a standard [**status object**](#status-object-google-class).

### Google.mail.untrash()

**Google.mail.untrash**( *mailID* : Text ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailID|Text|->|The ID of the message to remove from Trash |
|Result|Object|<-|[Status object](#status-object-google-class)|


#### Description

`Google.mail.untrash()` removes the specified message from the trash.

#### Returned object

The method returns a standard [**status object**](#status-object-google-class).

#### Permissions

This method requires one of the following OAuth scopes:

```
https://mail.google.com/
https://www.googleapis.com/auth/gmail.modify
```

### Google.mail.update()

**Google.mail.update**( *mailIDs* : Collection ; *param* : Object) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|mailIDs|Collection|->|Collection of strings (mail IDs), or collection of objects (each object contains an ID property)|
|param|Object|->|Options|
|Result|Object|<-| [Status object](#status-object-google-class) |

> There is a limit of 1000 IDs per request.

#### Description

`Google.mail.update()` adds or removes labels on the specified messages to help categorizing emails. The label can be a system label (e.g., NBOX, SPAM, TRASH, UNREAD, STARRED, IMPORTANT) or a custom label. Multiple labels could be applied simultaneously.

For more information check out the [label management documentation](https://developers.google.com/gmail/api/guides/labels).

In *param*, you can pass the following two properties:

|Property|Type|Description|
|---------|--- |------|
|addLabelIds|Collection|A collection of label IDs to add to messages.|
|removeLabelIds|Collection|A collection of label IDs to remove from messages.|


#### Returned object

The method returns a standard [**status object**](#status-object-google-class).


#### Example

To mark a collection of emails as "unread":

```4d
$result:=$google.mail.update($mailIds; {addLabelIds: ["UNREAD"]})
```

### Google.mail.updateLabel()

**Google.mail.updateLabel**( *labelId* : Text ; *labelInfo* : Object ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|labelId|Text|->|The ID of the label|
|[labelInfo](#labelinfo-object)|Object|->|Label information to update|
|Result|Object|<-|[Status object](#status-object-google-class)|

#### Description

`Google.mail.updateLabel()` updates the specified label.
> This method is only available for labels with type="user".

#### Returned object

The method returns a [**status object**](status-object-google-class) with an additional "label" property:

|Property|Type|Description|
|---------|--- |------|
|label|Object|contains an instance of Label (see [labelInfo](#labelinfo-object))|
|success|Boolean| [see Status object](#status-object-google-class)|
|statusText|Text| [see Status object](#status-object-google-class)|
|errors|Collection| [see Status object](#status-object-google-class)|

#### Example

To update a previously created label  to 'Backup January':

```4d
$status:=$google.mail.updateLabel($labelId; {name:"Backup January"})

```

### "Google" mail object properties

When you send an email with the "Google" mail type, you must pass an object to `Google.mail.send()`. For a comprehensive list of properties supported by Gmail message objects, refer to the [Gmail API documentation](https://developers.google.com/gmail/api/reference/rest/v1/users.messages). The most common properties are listed below:

| Property | Type | Description |
|----------|------|-------------|
| attachments | attachment collection | The attachments for the email. |
| bccRecipients | recipient collection | The Bcc: recipients for the message. |
| ccRecipients | recipient collection | The Cc: recipients for the message. |
| from | recipient object | The sender's email address. Must match the authenticated Gmail user. |
| id | Text | Unique identifier for the message. |
| important | Boolean | If true, marks the message as important (Gmail only). |
| labelIds | Collection | List of label IDs to apply to the message. |
| replyTo | recipient collection | Email addresses to use when replying. |
| sender | recipient object | The account that generates the message. Same as `from` in most cases. |
| subject | Text | The subject line of the message. |
| toRecipients | recipient collection | The To: recipients for the message. |
| threadId | Text | The ID of the thread to which the message belongs. |


#### Attachment object (Google)

| Property | Type | Description |
|----------|------|-------------|
| filename | Text | The name of the attached file. |
| mailType | Text | Indicates the Mail type to use to send and receive email's attechement. |
| content | Text | The base64-encoded content of the file. |
| size | Number | The size of the file in bytes. |
| isInline | Boolean | Set to true if the attachment is inline (e.g., embedded image). |
| contentId | Text | Content ID for referencing the attachment inline via CID. |


#### recipient object

| Property | Type | Description |
|----------|------|-------------|
| emailAddress | Object | Contains the address and display name. |
| emailAddress.address | Text | The email address of the recipient. |
| emailAddress.name | Text | Display name of the recipient. |

#### Example: Send an email with a file attachment (Google)

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $token; $param; $email; $status : Object

// Set up authentication
$param:=New object()
$param.name:="Google"
$param.permission:="signedIn"
$param.clientId:="your-client-id" // Replace with your client ID
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:="https://www.googleapis.com/auth/gmail.send"

$oAuth2:=New OAuth2 provider($param)
$token:=$oAuth2.getToken()

// Create the email, specify the sender and the recipient
$email:=New object()
$email.from:=New object("emailAddress"; New object("address"; "sender@gmail.com"))
$email.toRecipients:=New collection(New object("emailAddress"; New object("address"; "recipient@gmail.com")))
$email.subject:="Hello from NetKit"
$email.body:=New object("content"; "Hello, World!"; "contentType"; "html")

// Create an attachment
var $attachment : Object
var $text : Text
$text:="Simple text file"
BASE64 ENCODE($text)
$attachment:=New object
$attachment.filename:="note.txt"
$attachment.mimeType:="text/plain"
$attachment.content:=$text
$email.attachments:=New collection($attachment)

// Send the email
var $Google : Object
$Google:=New Google($token)
$status:=$Google.mail.send($email)
```



### labelInfo object

Several Google.mail label management methods use a `labelInfo` object, containing the following properties:

|Property|Type|Description|
|---------|--- |------|
|id|Text|The ID of the label.|
|name|Text|The display name of the label. (mandatory)|
|messageListVisibility|Text|The visibility of messages with this label in the message list.<br></br> Can be: <br/>- "show": Show the label in the message list. <<br/>- "hide": Do not show the label in the message list. |
|labelListVisibility|Text|The visibility of the label in the label list. <br></br> Can be:<br/>- "labelShow": Show the label in the label list. <br/>- "labelShowIfUnread" : Show the label if there are any unread messages with that label. <br/>- "labelHide": Do not show the label in the label list. |
|[color](https://developers.google.com/gmail/api/reference/rest/v1/users.labels?hl=en#color)|Object|The color to assign to the label (color is only available for labels that have their type set to user). <br></br> The color object has 2 attributes : <br/>-  textColor: text: The text color of the label, represented as hex string. This field is required in order to set the color of a label. <br/>- backgroundColor: text: The background color represented as hex string #RRGGBB (ex for black: #000000). This field is required in order to set the color of a label. </li></ul>|
|type|Text|The owner type for the label. <br></br> Can be: <br/>- "system": Labels created by Gmail.<br/>- "user": Custom labels created by the user or application.<br/>System labels are internally created and cannot be added, modified, or deleted. They're may be able to be applied to or removed from messages and threads under some circumstances but this is not guaranteed. For example, users can apply and remove the INBOX and UNREAD labels from messages and threads, but cannot apply or remove the DRAFTS or SENT labels from messages or threads. </br>User labels are created by the user and can be modified and deleted by the user and can be applied to any message or thread. |

## User
 
### Google.user.get()

**Google.user.get**( *id* : Text {; *select* : Text } ) : Object<br/>
**Google.user.get**( *id* : Text {; *select* : Collection } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|id|Text|->|The *resourceName* of the person to provide information about. Use the *resourceName* field returned by [Google.user.list()](#googleuserlist) to specify the person.|
|select|Text \| Collection|->|Text: A comma-separated list of specific fields that you want to retrieve from each person (e.g., "names, phoneNumbers").  <br/>Collection: Collection of the specific fields.|
|Result|Object|<-|Represents user's details, like names, emails, and phone numbers based on the selected fields.|

#### Description

`Google.user.get()` provides information about a [user](https://developers.google.com/people/api/rest/v1/people#Person) based on the *resourceName* provided in `id` and fields optionally specified in `select`.

Supported fields include *addresses*, *ageRanges*, *biographies*, *birthdays*, *calendarUrls*, *clientData*, *coverPhotos*, *emailAddresses*, *events*, *externalIds*, *genders*, *imClients*, *interests*, *locales*, *locations*, *memberships*, *metadata*, *miscKeywords*, *names*, *nicknames*, *occupations*, *organizations*, *phoneNumbers*, *photos*, *relations*, *sipAddresses*, *skills*, *urls*, *userDefined*.


#### Returned object

The returned [user object](https://developers.google.com/people/api/rest/v1/people#Person) contains values for the specified field(s). 

If no fields have been specified in `select`, `Google.user.get()` returns *emailAddresses* and *names*. Otherwise, it returns only the specified field(s).

#### Permissions

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

### Google.user.getCurrent()

**Google.user.getCurrent**( { *select* : Text } ) : Object<br/>
**Google.user.getCurrent**( { *select* : Collection } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|select|Text \| Collection|->|Text: A comma-separated list of specific fields that you want to retrieve from each person (e.g., "names, phoneNumbers"). <br/>Collection: Collection of the specific fields.|
|Result|Object|<-|Represents user's details, like names, emails, and phone numbers based on the selected fields.|

#### Description

`Google.user.getCurrent()` provides information about the authenticated [user](https://developers.google.com/people/api/rest/v1/people#Person) based on fields specified in `select`.

Supported fields include *addresses*, *ageRanges*, *biographies*, *birthdays*, *calendarUrls*, *clientData*, *coverPhotos*, *emailAddresses*, *events*, *externalIds*, *genders*, *imClients*, *interests*, *locales*, *locations*, *memberships*, *metadata*, *miscKeywords*, *names*, *nicknames*, *occupations*, *organizations*, *phoneNumbers*, *photos*, *relations*, *sipAddresses*, *skills*, *urls*, *userDefined*.

#### Returned object

The returned [user object](https://developers.google.com/people/api/rest/v1/people#Person) contains values for the specific field(s). 

If no fields have been specified in `select`, `Google.user.getCurrent()` returns *emailAddresses* and *names*. Otherwise, it returns only the specified field(s).

#### Permissions

Requires the same OAuth scope package as [Google.user.get()](#permissions-15).

#### Example

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

### Google.user.list()

**Google.user.list**( { *param* : Object } ) : Object

#### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|param|Object|->|A set of options defining how to retrieve and filter user data|
|Result|Object|<-|An object containing a structured collection of [user](https://developers.google.com/people/api/rest/v1/people#Person) data organized into pages|

#### Description

`Google.user.list()` provides a list of domain profiles or domain contacts in the authenticated user's domain directory. 

> If the contact sharing or the External Directory sharing is not allowed in the Google admin, the returned `users` collection is empty.

In *param*, you can pass the following properties:

|Property|Type|Description|
|---------|--- |------|
|select|Text \| Collection|Text: A comma-separated list of specific fields that you want to retrieve from each person (e.g., "names, phoneNumbers"). <br/>Collection: Collection of the specific fields. <br/>If omitted, defaults to returning emailAddresses and names.|
|sources|Text \| Collection|Specifies the directory source to return. Values: <br/>-  DIRECTORY_SOURCE_TYPE_UNSPECIFIED (Unspecified), <br/>- DIRECTORY_SOURCE_TYPE_DOMAIN_CONTACT (Google Workspace domain  shared contact), <br/>-  DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE (default, Workspace domain  profile).|
|mergeSources|Text \| Collection|Adds related data if linked by verified join keys such as email addresses or phone numbers. <br/>-  DIRECTORY_MERGE_SOURCE_TYPE_UNSPECIFIED (Unspecified), <br/>- DIRECTORY_MERGE_SOURCE_TYPE_CONTACT (User owned contact).|
|top|Integer|Sets the maximum number of people to retrieve per page, between 1 and 1000 (default is 100).|

#### Returned object

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

#### Permissions

Requires the same OAuth scope package as [Google.user.get()](#permissions-15).

#### Example

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

[Office365 Class](./Office365.md)<br/>
[OAuth2Provider Class](./OAuth2Provider.md)
