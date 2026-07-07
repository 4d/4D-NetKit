# Office365Calendar Class

## Overview

`Office365Calendar` is the Microsoft Graph API client for calendar and event management within 4D NetKit. It supports reading, creating, updating, and deleting calendars and events, with optional `calendarId` and `userId` scoping.

An `Office365Calendar` object is accessed via the `calendar` property of an [Office365](./Office365.md) object: `$office365.calendar`.

Event date/time values are accepted as ISO text, `{date; time}` objects, or Graph `{dateTime; timeZone}` objects.

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

An `Office365Calendar` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text | User identifier used in Service mode. Can be the `id` or the `userPrincipalName`. |
| id | Text | Calendar identifier. When set, all operations target this specific calendar by default. |

## Calendars

### .getCalendar()

**.getCalendar**( { *id* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| id | Text | -> | ID of the calendar to retrieve. To retrieve calendar IDs, call `.getCalendars()`. If `id` is null, empty, or missing, returns the primary calendar of the currently logged-in user. |
| Result | Object | <- | [Object](https://learn.microsoft.com/en-us/graph/api/resources/calendar?view=graph-rest-1.0#properties) containing the properties and relationships of the specified calendar, or `Null` on failure. |

#### Description

`.getCalendar()` retrieves the properties and relationships of a specific calendar.

#### Example

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $Office365 : cs.NetKit.Office365
var $params; $calendarList; $calendarA : Object

$params:=New object
$params.name:="Microsoft"
$params.permission:="signedIn"
$params.clientId:="your-client-id"
$params.redirectURI:="http://127.0.0.1:50993/authorize/"
$params.scope:="https://graph.microsoft.com/.default"

$oAuth2:=New OAuth2 provider($params)
$Office365:=New Office365 provider($oAuth2)

// Retrieve the entire list of calendars
$calendarList:=$Office365.calendar.getCalendars()

// Retrieve the first calendar in the list using its ID
$calendarA:=$Office365.calendar.getCalendar($calendarList.calendars[0].id)
```

### .getCalendars()

**.getCalendars**( { *param* : Object } ) : [cs.NetKit.GraphCalendarList](./GraphCalendarList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Set of options to filter, order, or select specific calendar properties (optional). |
| Result | [cs.NetKit.GraphCalendarList](./GraphCalendarList.md) | <- | Paginated list of calendar objects. Use `next()` / `previous()` to navigate pages. |

#### Description

`.getCalendars()` retrieves a collection of the user's calendars.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| select | Text | Specifies which calendar properties to retrieve. Comma-separated values. |
| orderby | Text | Specifies the order of the returned results. Syntax: property name followed by `asc` or `desc`. |
| filter | Text | OData filter expression to filter the results. Example: `"name eq 'Work'"`. |

#### Example

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $Office365 : cs.NetKit.Office365
var $params; $calendarList : Object

$params:=New object
$params.name:="Microsoft"
$params.permission:="signedIn"
$params.clientId:="your-client-id"
$params.redirectURI:="http://127.0.0.1:50993/authorize/"
$params.scope:="https://graph.microsoft.com/.default"

$oAuth2:=New OAuth2 provider($params)
$Office365:=New Office365 provider($oAuth2)

$calendarList:=$Office365.calendar.getCalendars()
```

## Events

### .createEvent()

**.createEvent**( *event* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| event | Object | -> | Object containing the details of the calendar [event](./GraphEvent.md) to create. |
| Result | Object | <- | [Status object](#status-object) with an additional `event` property. |

#### Description

`.createEvent()` creates a new calendar event.

In *event*, pass the properties you want to set. See [GraphEvent](./GraphEvent.md) for the full list of available properties. Attachments in `event.attachments` are uploaded separately after event creation.

#### Returned object

The method returns a [status object](#status-object) with an additional `event` property:

| Property | Type | Description |
|---|---|---|
| event | Object | [GraphEvent](./GraphEvent.md) returned by the server. |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Permissions

| Type | Permission |
|---|---|
| Delegated (Work/School) | `Calendars.ReadWrite` |
| Delegated (Personal) | `Calendars.ReadWrite` |
| Application | `Calendars.ReadWrite` |

#### Example

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $Office365 : cs.NetKit.Office365
var $event; $result : Object

$Office365:=New Office365 provider($oAuth2)

$event:={}
$event.subject:="Team Sync"
$event.start:={date: Current date; time: Current time}
$event.end:={date: Current date; time: Current time+3600}
$event.attendees:=[{emailAddress: {address: "colleague@example.com"}}]

$result:=$Office365.calendar.createEvent($event)
If (Not($result.success))
  ALERT($result.statusText)
End if
```

### .deleteEvent()

**.deleteEvent**( *param* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Object containing details for the calendar event to delete. |
| Result | Object | <- | [Status object](#status-object). |

#### Description

`.deleteEvent()` deletes a calendar event.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| eventId | Text | **Required.** ID of the event to delete. |
| calendarId | Text | ID of the calendar. If not provided, the primary calendar of the currently logged-in user is used. |

#### Returned object

The method returns a standard [status object](#status-object).

#### Permissions

| Type | Permission |
|---|---|
| Delegated (Work/School) | `Calendars.ReadWrite` |
| Delegated (Personal) | `Calendars.ReadWrite` |
| Application | `Calendars.ReadWrite` |

#### Example

```4d
$status:=$office365.calendar.deleteEvent({eventId: $event.id})
If ($status.success)
  ALERT("Calendar event correctly deleted")
Else
  ALERT($status.statusText)
End if
```

### .getEvent()

**.getEvent**( *param* : Object ) : [cs.NetKit.GraphEvent](./GraphEvent.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Object containing the necessary details to retrieve a specific event. |
| Result | [cs.NetKit.GraphEvent](./GraphEvent.md) | <- | The requested [GraphEvent](./GraphEvent.md), or `Null` when not found or on error. |

#### Description

`.getEvent()` retrieves details of a specific event, including its properties and relationships. The event is identified by its unique `eventId` within the specified calendar.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| eventId | Text | **Required.** The unique identifier of the event. |
| calendarId | Text | Calendar identifier. If not provided, the user's primary calendar is used. |
| timeZone | Text | Time zone for the response (IANA format). UTC by default. |
| select | Text | OData `$select` — comma-separated list of properties to return. |

### .getEvents()

**.getEvents**( { *param* : Object } ) : [cs.NetKit.GraphEventList](./GraphEventList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Object containing filters and options for retrieving calendar events (optional). |
| Result | [cs.NetKit.GraphEventList](./GraphEventList.md) | <- | Paginated list of [GraphEvent](./GraphEvent.md) instances. Use `next()` / `previous()` to navigate pages. |

#### Description

`.getEvents()` retrieves events from a specified calendar. By default, events are pulled from the user's primary calendar unless another calendar is specified.

**Note:** If no time range is provided, it returns single-instance meetings and series masters. When both `startDateTime` and `endDateTime` are specified, it retrieves all occurrences, exceptions, and single-instance events within the defined time range.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| calendarId | Text | Calendar identifier. If not provided, the user's primary calendar is used. |
| startDateTime | Text, Object | Filters events by start time. If set, `endDateTime` must also be provided. **Text:** ISO 8601 UTC timestamp. **Object:** Must contain `date` (date type) and `time` (time type). |
| endDateTime | Text, Object | Filters events by end time. If set, `startDateTime` must also be provided. |
| timeZone | Text | Time zone for the response (IANA format). UTC by default. |
| select | Text | Specifies which event properties to return (OData `$select`). |
| orderby | Text | Defines sorting order for results (OData `$orderby`). |
| filter | Text | OData filter expression. Example: `"status eq 'confirmed'"`. |
| top | Integer | Maximum number of events per page. Default is 10. Maximum is 999. |

#### Example

```4d
// Get all calendars, then retrieve events from the first one
var $calendars:=$office365.calendar.getCalendars()
var $myCalendar:=$calendars.calendars[0]

var $events:=$office365.calendar.getEvents({calendarId: $myCalendar.id; top: 10})
```

### .updateEvent()

**.updateEvent**( *event* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| event | Object | -> | Object containing the updated [event](./GraphEvent.md) properties. The `id` property is mandatory. |
| Result | Object | <- | [Status object](#status-object) with an additional `event` property. |

#### Description

`.updateEvent()` updates an existing calendar event.

In *event*, pass the event `id` (mandatory) and the properties you want to update. You only need to include the fields you want to change — any property left out will keep its current value. Attachments in `event.attachments` are uploaded separately after the update.

#### Returned object

The method returns a [status object](#status-object) with an additional `event` property:

| Property | Type | Description |
|---|---|---|
| event | Object | Updated [GraphEvent](./GraphEvent.md) returned by the server. |
| success | Boolean | See [status object](#status-object). |
| statusText | Text | See [status object](#status-object). |
| errors | Collection | See [status object](#status-object). |

#### Permissions

| Type | Permission |
|---|---|
| Delegated (Work/School) | `Calendars.ReadWrite` |
| Delegated (Personal) | `Calendars.ReadWrite` |
| Application | `Calendars.ReadWrite` |

#### Example

```4d
#DECLARE($eventId : Text)
var $Office365:=New Office365 provider($oAuth2)
var $event; $result : Object

$event:={}
$event.id:=$eventId
$event.subject:="Updated Meeting Title"
$event.start:={date: Current date; time: Current time}
$event.end:={date: Current date; time: Current time+3600}

$result:=$Office365.calendar.updateEvent($event)
If (Not($result.success))
  ALERT($result.statusText)
End if
```

## Notifications

### .notifier()

**.notifier**( *param* : Object { ; *calendarId* : Text } ) : [cs.NetKit.GraphNotification](./GraphNotification.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Callback and mode definitions (see below). |
| calendarId | Text | -> | *(optional)* Subscribe to changes in that specific calendar. If omitted, subscribe to the default calendar. |
| Result | [cs.NetKit.GraphNotification](./GraphNotification.md) | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted`. Call `start()` to begin monitoring. |

#### Description

`.notifier()` creates and returns a [GraphNotification](./GraphNotification.md) object allowing you to configure, start, and stop subscriptions to calendar event change notifications.

Two modes are available:

- **Push** (webhook): Real-time notifications via HTTP callbacks. Requires a publicly accessible HTTPS endpoint. Creates a [Microsoft Graph subscription](https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions). The webhook URL is derived as `{endPoint}/4dnk-graph-notification?state={uuid}`.
- **Pull** (polling): Periodic polling of the [delta query API](https://learn.microsoft.com/en-us/graph/delta-query-messages). No external endpoint needed.

When a resource changes, user-defined callbacks are dispatched in the 4D worker where the notifier's `start()` function was originally called.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Webhook URL for **push** mode. If omitted, uses **pull** mode. Must be a publicly accessible HTTPS endpoint. See [endPoint management](#endpoint-management). |
| onCreate | 4D.Function | Callback for a calendar event creation *(optional)*. |
| onDelete | 4D.Function | Callback for a calendar event deletion *(optional)*. |
| onModify | 4D.Function | Callback for a calendar event modification *(optional)*. |
| timer | Integer | Polling interval in seconds for pull mode (default: 30) *(optional)*. |

Callback functions receive two parameters:

| Parameter | Type | Description |
|---|---|---|
| office365 | cs.NetKit.Office365 | The current [Office365](./Office365.md) object. |
| event | Object | Object with `type` (Text: `"eventCreated"`, `"eventDeleted"`, or `"eventModified"`) and `ids` (Collection of affected event IDs). |

#### Returned object

The returned [GraphNotification](./GraphNotification.md) object contains the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | Publicly accessible HTTPS endpoint that receives notifications. |
| expiration | Text | Expiration date and time (timestamp). Read-only. |
| isStarted | Boolean | `true` when notifications are active, `false` when stopped. Read-only. |
| start() | 4D.Function | Starts the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| stop() | 4D.Function | Stops the subscription. Returns a status object (`success`, `statusText`, `errors`). |
| timer | Integer | Interval in seconds between delta query checks (pull mode). |

### `endPoint` management

Using an `endPoint`, you let Microsoft call your application whenever a change occurs:

```4d
$parameter.endPoint:="https://mydomain.com/notifications"
```

- The 4D Web Server must be [launched in TLS 1.2](https://developer.4d.com/docs/commands/set-database-parameter#min-tls-version-105) to comply with Microsoft Graph requirements.
- If the `endPoint` port is the same as the host port, the host web server is used automatically.
- If no port is specified, standard ports (80 for HTTP, 443 for HTTPS) are used.
- In any other case, the 4D NetKit component web server is used.

When the `endPoint` uses the host web server, add the following entry to `Project/Sources/HTTPHandlers.json`:

```json
[
  {
    "class": "NetKit.GraphNotificationHandler",
    "method": "getResponse",
    "regexPattern": "/4dnk-graph-notification",
    "verbs": "post"
  }
]
```

> If both a `calendar.notifier` and a `mail.notifier` are declared, they must use the same port.

#### Example

Calendar notifications via delta polling every 60 seconds (pull mode):

```4d
$calNotif:=$office365.calendar.notifier({ \
    timer: 60; \
    onCreate: Formula(handleNewEvent($1; $2)); \
    onModify: Formula(handleEventUpdate($1; $2)) \
})
$status:=$calNotif.start()

// Stop monitoring
$status:=$calNotif.stop()
```

## Status object

Several `Office365Calendar` functions return a `status` object containing the following properties:

| Property | Type | Description |
|---|---|---|
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |

## See also

* [GraphEvent](./GraphEvent.md)
* [GraphEventList](./GraphEventList.md)
* [GraphNotification](./GraphNotification.md)
* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
