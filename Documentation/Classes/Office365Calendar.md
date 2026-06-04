# Office365Calendar Class

## Overview

Microsoft Graph API client for calendar and event management.
Supports reading, creating, updating, and deleting calendars and events,
with optional `calendarId` and `userId` scoping.
Accepts event date/time as ISO text, `{date; time}` objects, or Graph `{dateTime; timeZone}`
objects — normalised automatically by `_conformEventDateTime`.

## Table of Contents

### Initialization

* [cs.NetKit.Office365Calendar.new()](#csnetkitoffice365calendarnew)

### Properties

* [userId](#userid)
* [id](#id)

### Calendars

* [Office365Calendar.getCalendar()](#office365calendargetcalendar)
* [Office365Calendar.getCalendars()](#office365calendargetcalendars)

### Events

* [Office365Calendar.getEvent()](#office365calendargetevent)
* [Office365Calendar.getEvents()](#office365calendargetevents)
* [Office365Calendar.createEvent()](#office365calendarcreateevent)
* [Office365Calendar.deleteEvent()](#office365calendardeleteevent)
* [Office365Calendar.updateEvent()](#office365calendarupdateevent)

### Notifications

* [Office365Calendar.notifier()](#office365calendarnotifier)

## **cs.NetKit.Office365Calendar.new()**

**cs.NetKit.Office365Calendar.new**( *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ) : cs.NetKit.Office365Calendar

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inParameters | Object | -> | Configuration object; recognised properties: - `userId` {Text} — Graph user ID or UPN; defaults to `""` (uses `me` endpoint) |
| Result | cs.NetKit.Office365Calendar | <- | Object of the Office365Calendar class |

### Properties

The returned `Office365Calendar` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text |  |
| id | Text |  |

## Calendars

### Office365Calendar.getCalendar()

**Office365Calendar.getCalendar**( *$inID* : Text ; *$inSelect* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inID | Text | -> | Calendar ID; uses the default calendar when empty |
| $inSelect | Text | -> | Comma-separated list of properties to return (OData `$select`) |
| Result | Object | <- | Cleaned calendar object, or `Null` on failure |

#### Description

Fetches a single calendar via
`GET /me/calendars/{id}` or `GET /me/calendar`

### Office365Calendar.getCalendars()

**Office365Calendar.getCalendars**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options: - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`) - `filter`, `select`, `top`, `orderBy` — standard OData parameters |
| Result | Object | <- | Pageable list of calendars |

#### Description

Lists calendars via `GET /me/calendars`

## Events

### Office365Calendar.getEvent()

**Office365Calendar.getEvent**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Required and optional parameters: - `eventId` {Text} — **Required.** ID of the event to fetch - `startDateTime` {Text|Object} — **Required.** Range start (used as query parameter) - `endDateTime` {Text|Object} — **Required.** Range end (used as query parameter) - `calendarId` {Text} — Calendar ID; uses default calendar when empty - `timeZone` {Text} — Response time zone (`Prefer: outlook.timezone`) - `bodyContentType` {Text} — Body format (`Prefer: outlook.body-content-type`) - `select` {Text} — OData `$select` |
| Result | Object | <- | Event object, or `Null` when not found or on error |

#### Description

Fetches a single event via `GET /me/calendar/events/{id}` or
`GET /me/calendars/{id}/events/{id}`. See inline comment for all supported Graph endpoints.

### Office365Calendar.getEvents()

**Office365Calendar.getEvents**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Required and optional parameters: - `startDateTime` {Text|Object} — **Required.** Start of the date range - `endDateTime` {Text|Object} — **Required.** End of the date range - `calendarId` {Text} — Calendar ID; uses default calendar when empty - `timeZone` {Text} — Response time zone (`Prefer: outlook.timezone`) - `bodyContentType` {Text} — Body format (`Prefer: outlook.body-content-type`) - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`) - `filter`, `select`, `top`, `orderBy` — standard OData parameters |
| Result | Object | <- | Pageable list of events |

#### Description

Lists events via `GET /me/calendar/calendarView` (when both date bounds are set)
or `GET /me/calendar/events`. See inline comment for all supported endpoints.

### Office365Calendar.createEvent()

**Office365Calendar.createEvent**( *$inEvent* : Object ; *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inEvent | Object | -> | Event object; `calendarId`, `id`, and `attachments` are handled automatically |
| $inParameters | Object | -> | Optional overrides: - `calendarId` {Text} — Target calendar ID (takes precedence over `$inEvent.calendarId`) |
| Result | Object | <- | Status object; includes `event` with the created event data |

#### Description

Creates a calendar event via `POST /me/calendar/events`.
Attachments in `$inEvent.attachments` are uploaded separately after event creation.
See inline comment for all supported Graph endpoints.

### Office365Calendar.deleteEvent()

**Office365Calendar.deleteEvent**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Required parameters: - `eventId` {Text} — ID of the event to delete - `calendarId` {Text} — Calendar ID; uses default calendar when empty |
| Result | Object | <- | Status object |

#### Description

Permanently deletes a calendar event via `DELETE /me/calendar/events/{id}`.
See inline comment for all supported Graph endpoints.

### Office365Calendar.updateEvent()

**Office365Calendar.updateEvent**( *$inEvent* : Object ; *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inEvent | Object | -> | Event object with updated properties; `calendarId` and `id` are read from `$inEvent` when not in `$inParameters` |
| $inParameters | Object | -> | Optional overrides: - `calendarId` {Text} — Target calendar ID - `id` {Text} — Event ID (takes precedence over `$inEvent.id`) |
| Result | Object | <- | Status object; includes `event` with the updated event data |

#### Description

Updates a calendar event via `PATCH /me/calendar/events/{id}`.
Attachments in `$inEvent.attachments` are uploaded separately after the update.
See inline comment for all supported Graph endpoints.

## Notifications

### Office365Calendar.notifier()

**Office365Calendar.notifier**( *$inParameters* : Object ; *$inCalendarId* : Text ) : cs.GraphNotification

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Notification callbacks and options: - `onCreate` {4D.Function} — Called when an event is created; receives the `eventId` - `onDelete` {4D.Function} — Called when an event is deleted; receives the `eventId` - `onModify` {4D.Function} — Called when an event is modified; receives the `eventId` - `endPoint` {Text} — Webhook URL for push mode; omit to use pull (delta query) mode |
| $inCalendarId | Text | -> | Calendar to subscribe to; defaults to the default calendar |
| Result | cs.GraphNotification | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted` |

#### Description

Creates a `GraphNotification` for calendar event change notifications via the
Microsoft Graph subscription API. See inline comment for full parameter details.

