# GoogleCalendar Class

## Overview

`GoogleCalendar` is the Google Calendar API client within 4D NetKit. It provides CRUD operations on calendars and events, and exposes a `notifier()` factory for push/pull change monitoring.

A `GoogleCalendar` object is accessed via the `calendar` property of a [Google](./Google.md) object: `$google.calendar`.

## Table of Contents

### Calendars

* [.getCalendar()](#getcalendar)
* [.getCalendars()](#getcalendars)

### Events

* [.createEvent()](#createevent)
* [.deleteEvent()](#deleteevent)
* [.getEvent()](#getevent)
* [.getEvents()](#getevents)
* [.updateEvent()](#updateevent)

### Notifications

* [.notifier()](#notifier)

## Properties

A `GoogleCalendar` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text | User identifier used to identify the user in Service mode. Can be the `id` or the `userPrincipalName`. |

## Calendars

### .getCalendar()

**.getCalendar**( { *id* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| id | Text | -> | ID of the calendar to retrieve. To retrieve calendar IDs, call `.getCalendars()`. If `id` is null, empty, or missing, returns the primary calendar of the currently logged-in user. |
| Result | Object | <- | Object containing the details of the specified calendar. For more details, see the [Google Calendar API resource](https://developers.google.com/calendar/api/v3/reference/calendarList#resource), or `Null` on error. |

#### Description

`.getCalendar()` retrieves a specific calendar from the authenticated user's calendar list using an `id` to identify the calendar, and returns an object containing details about the requested calendar.

#### Example

```4d
var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param; $Calendars; $myCalendar : Object

$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id"
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

### .getCalendars()

**.getCalendars**( { *param* : Object } ) : [cs.NetKit.GoogleCalendarList](./GoogleCalendarList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Set of options to filter or refine the calendar list request (optional). |
| Result | [cs.NetKit.GoogleCalendarList](./GoogleCalendarList.md) | <- | Paginated list of calendar entries; use `next()` / `previous()` to navigate pages. |

#### Description

`.getCalendars()` retrieves a list of calendars that the authenticated user can access. The filtering and paging options passed in `param` are reflected in the returned object.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| maxResults | Integer | Maximum number of calendar entries returned per page. Default is 100. Maximum is 250. |
| minAccessRole | Text | Minimum access role for the user in the returned calendars. Acceptable values: `"freeBusyReader"`, `"owner"`, `"reader"`, `"writer"`. |
| showDeleted | Boolean | Whether to include deleted calendar list entries in the result. Default is `false`. |
| showHidden | Boolean | Whether to show hidden entries. Default is `false`. |

#### Example

```4d
var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param; $Calendars : Object

$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id"
$param.clientSecret:="xxxxxxxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:=[]
$param.scope.push("https://mail.google.com/")
$param.scope.push("https://www.googleapis.com/auth/calendar")

$oauth2:=New OAuth2 provider($param)
$google:=cs.NetKit.Google.new($oauth2)

$Calendars:=$google.calendar.getCalendars()
```

## Events

### .createEvent()

**.createEvent**( *event* : Object { ; *param* : Object } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| event | Object | -> | [Event object](./GoogleEvent.md) to create. Only `start` and `end` properties are required. The `id` field is stripped automatically. |
| param | Object | -> | Object containing additional creation options (optional). |
| Result | Object | <- | [Status object](#status-object) with an additional `event` property containing the created [GoogleEvent](./GoogleEvent.md) on success. |

#### Description

`.createEvent()` creates a new calendar event.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| calendarId | Text | Target calendar ID. Defaults to `"primary"`. |
| sendUpdates | Text | Defines who receives email notifications. Acceptable values: `"all"`, `"externalOnly"`, `"none"`. |
| supportsAttachments | Boolean | `true` to allow creation or modification of the `attachments` property. Defaults to `false`. |

#### Returned object

The method returns a [status object](#status-object) with an additional `event` property:

| Property | Type | Description |
|---|---|---|
| event | Object | [Event object](./GoogleEvent.md) returned by the server. |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Example

```4d
var $Google:=cs.NetKit.Google.new($Oauth)
var $event; $result : Object

$event:={}
$event.summary:="Team Meeting"
$event.start:={date: Current date; time: Current time}
$event.end:={date: Current date; time: Current time+3600}
$event.attendees:=[{email: "first.lastname@gmail.com"}]
$event.description:="Description of the event"

$result:=$Google.calendar.createEvent($event)
If (Not($result.success))
  ALERT($result.statusText)
End if
```

### .deleteEvent()

**.deleteEvent**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Object containing the details of the event to delete. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.deleteEvent()` deletes an event from a specified calendar.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| eventId | Text | **Required.** ID of the event to delete. |
| calendarId | Text | Calendar ID. If not provided or null, uses the user's primary calendar. To retrieve calendar IDs, call `.getCalendars()`. |
| sendUpdates | Text | Controls which attendees receive notifications about the deletion. Acceptable values: `"all"`, `"externalOnly"`, `"none"`. |

#### Returned object

The method returns a standard [status object](#status-object).

#### Example

```4d
var $Google:=cs.NetKit.Google.new($Oauth)

$status:=$Google.calendar.deleteEvent({eventId: $event.id})
If ($status.success)
  ALERT("Calendar event correctly deleted")
Else
  ALERT($status.statusText)
End if
```

### .getEvent()

**.getEvent**( *param* : Object ) : [cs.NetKit.GoogleEvent](./GoogleEvent.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Object containing the necessary details to retrieve a specific event. |
| Result | [cs.NetKit.GoogleEvent](./GoogleEvent.md) | <- | The requested event, or `Null` on error or missing required parameters. |

#### Description

`.getEvent()` retrieves a specific event from a Google Calendar using its unique `eventId`.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| eventId | Text | **Required.** The unique identifier of the event to retrieve. |
| calendarId | Text | Calendar identifier. If not provided, the user's primary calendar is used. |
| maxAttendees | Integer | Maximum number of attendees to include in the response. |
| timeZone | Text | Time zone for the response, formatted as an IANA name (e.g., `"Europe/Zurich"`). Defaults to UTC. |

### .getEvents()

**.getEvents**( { *param* : Object } ) : [cs.NetKit.GoogleEventList](./GoogleEventList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Object containing filters and options for retrieving calendar events (optional). |
| Result | [cs.NetKit.GoogleEventList](./GoogleEventList.md) | <- | Paginated list of [GoogleEvent](./GoogleEvent.md) instances; use `next()` / `previous()` to navigate pages. |

#### Description

`.getEvents()` retrieves events on the specified calendar. If *param* is not provided, it returns all events from the user's primary calendar.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| calendarId | Text | Calendar identifier. If not provided, the user's primary calendar is used. |
| eventTypes | Text | Specifies the types of events to return. Acceptable values: `"birthday"`, `"default"`, `"focusTime"`, `"fromGmail"`, `"outOfOffice"`, `"workingLocation"`. |
| iCalUID | Text | Searches for an event by its iCalendar ID. |
| maxAttendees | Integer | Limits the number of attendees returned per event. |
| top | Integer | Maximum number of events per page. Default is 250, maximum is 2500. |
| orderBy | Text | Sort order. Acceptable values: `"startTime"` (ascending, only when `singleEvents=true`), `"updated"`. |
| search | Text | Free-text search query across event fields. |
| showDeleted | Boolean | Whether to include deleted events (`status="cancelled"`). Defaults to `false`. |
| showHiddenInvitations | Boolean | Whether to include hidden invitations. Defaults to `false`. |
| singleEvents | Boolean | Whether to expand recurring events into single instances. Defaults to `false`. |
| startDateTime | Text \| Object | Filters events by start time. If set, `endDateTime` must also be provided. |
| endDateTime | Text \| Object | Filters events by end time. If set, `startDateTime` must also be provided. |
| timeZone | Text | Time zone for the response, formatted as an IANA name (e.g., `"Europe/Zurich"`). Defaults to UTC. |
| updatedMin | Text | Filters events based on last modification time (ISO 8601 UTC). |

#### Example

```4d
// Get all calendars, then retrieve events from the first one
var $calendars:=$google.calendar.getCalendars()
var $myCalendar:=$calendars.calendars[0]

var $events:=$google.calendar.getEvents({calendarId: $myCalendar.id; top: 10})
```

### .updateEvent()

**.updateEvent**( *event* : Object { ; *param* : Object } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| event | Object | -> | [Event object](./GoogleEvent.md) with updated fields. `id`, `start`, and `end` are required. |
| param | Object | -> | Object containing additional update options (optional). |
| Result | Object | <- | [Status object](#status-object) with an additional `event` property containing the updated [GoogleEvent](./GoogleEvent.md) on success. |

#### Description

`.updateEvent()` updates an existing calendar event.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| calendarId | Text | Calendar ID. Defaults to `"primary"`. |
| sendUpdates | Text | Defines who receives email notifications about the update. Acceptable values: `"all"`, `"externalOnly"`, `"none"`. |
| supportsAttachments | Boolean | `true` to allow modification of the `attachments` property. Defaults to `false`. |
| fullUpdate | Boolean | If `true`, the full event is replaced (PUT). If `false` (default), only specified fields are updated (PATCH). |

#### Returned object

The method returns a [status object](#status-object) with an additional `event` property:

| Property | Type | Description |
|---|---|---|
| event | Object | Updated [event object](./GoogleEvent.md) returned by the server. |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Example

```4d
#DECLARE($eventId : Text)
var $Google:=cs.NetKit.Google.new($Oauth)
var $event; $result : Object

$event:={}
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

## Notifications

### .notifier()

**.notifier**( *param* : Object { ; *calendarId* : Text } ) : [cs.NetKit.GoogleNotification](./GoogleNotification.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Callback and mode definitions (see below). |
| calendarId | Text | -> | *(optional)* Subscribe to changes in that specific calendar. If omitted, subscribe to the default (primary) calendar. |
| Result | [cs.NetKit.GoogleNotification](./GoogleNotification.md) | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted`. Call `start()` to begin monitoring. |

#### Description

`.notifier()` creates and returns a [GoogleNotification](./GoogleNotification.md) object allowing you to configure, start, and stop subscriptions to calendar event change notifications.

Two modes are available:

- **Push** (webhook): Real-time notifications via HTTP callbacks. Requires a publicly accessible HTTPS endpoint. The webhook URL is derived as `{endPoint}/4dnk-google-notification?state={uuid}`.
- **Pull** (polling): Periodic polling of change APIs. No external endpoint needed. Polls the delta query API at the configured interval.

When a resource changes, user-defined callbacks are dispatched in the 4D worker where the notifier's `start()` function was originally called.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Webhook URL for **push** mode. If omitted, uses **pull** mode. Must be a publicly accessible HTTPS endpoint. |
| onCreate | 4D.Function | Callback for a calendar event creation *(optional)*. |
| onDelete | 4D.Function | Callback for a calendar event deletion *(optional)*. |
| onModify | 4D.Function | Callback for a calendar event modification *(optional)*. |
| timer | Integer | Polling interval in seconds for pull mode (default: 30) *(optional)*. |

Callback functions receive two parameters:

| Parameter | Type | Description |
|---|---|---|
| google | cs.NetKit.Google | The current [Google](./Google.md) object. |
| event | Object | Object with `type` (Text: `"eventCreated"`, `"eventDeleted"`, or `"eventModified"`) and `ids` (Collection of affected event IDs). |

#### Returned object

The returned [GoogleNotification](./GoogleNotification.md) object contains the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Publicly accessible HTTPS endpoint that receives notifications. |
| expiration | Text | Expiration date and time (timestamp). Read-only. |
| isStarted | Boolean | `true` when notifications are active, `false` when stopped. Read-only. |
| start() | 4D.Function | Starts the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| stop() | 4D.Function | Stops the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| timer | Integer | Interval in seconds between delta query checks (pull mode). |

#### Example

Calendar notifications via delta polling every 60 seconds (pull mode):

```4d
var $provider:=SignedInProvider()
var $google:=cs.NetKit.Google.new($provider)
var $notification:={}

$notification.onCreate:=Formula(ALERT("You have a new event!"))
$google.calendar.notifier($notification; "primary").start()
```

## Status object

Several `GoogleCalendar` functions return a `status` object containing the following properties:

| Property | Type | Description |
|---|---|---|
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Google server or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |

## See also

* [GoogleCalendarList](./GoogleCalendarList.md)
* [GoogleEvent](./GoogleEvent.md)
* [GoogleNotification](./GoogleNotification.md)
* [Google](./Google.md)
