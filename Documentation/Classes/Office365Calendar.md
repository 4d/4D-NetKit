# Office365Calendar Class

## Overview

Microsoft Graph API client for calendar and event management.
Supports reading, creating, updating, and deleting calendars and events,
with optional `calendarId` and `userId` scoping.
Accepts event date/time as ISO text, `{date; time}` objects, or Graph `{dateTime; timeZone}`
objects — normalised automatically by `_conformEventDateTime`.

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

A `Office365Calendar` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text:="" |  |
| id | Text:="" |  |

## Calendars

### .getCalendar()

**.getCalendar**( { *$inID* : Text ; *$inSelect* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inID | Text | -> | Calendar ID; uses the default calendar when empty |
| $inSelect | Text | -> | Comma-separated list of properties to return (OData `$select`) |
| Result | Object | <- | Cleaned calendar object, or `Null` on failure |

#### Description

Fetches a single calendar via
`GET /me/calendars/{id}` or `GET /me/calendar`

### .getCalendars()

**.getCalendars**( *$inParameters* : Object ) : [cs.NetKit.GraphCalendarList](./GraphCalendarList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options: - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`) - `filter`, `select`, `top`, `orderBy` — standard OData parameters |
| Result | [cs.NetKit.GraphCalendarList](./GraphCalendarList.md) | <- | Pageable list of calendars |

#### Description

Lists calendars via `GET /me/calendars`

## Events

### .createEvent()

**.createEvent**( *$inEvent* : Object { ; *$inParameters* : Object } ) : Object

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

### .deleteEvent()

**.deleteEvent**( { *$inParameters* : Object } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Required parameters: - `eventId` {Text} — ID of the event to delete - `calendarId` {Text} — Calendar ID; uses default calendar when empty |
| Result | Object | <- | Status object |

#### Description

Permanently deletes a calendar event via `DELETE /me/calendar/events/{id}`.
See inline comment for all supported Graph endpoints.

### .getEvent()

**.getEvent**( { *$inParameters* : Object } ) : [cs.NetKit.GraphEvent](./GraphEvent.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Required and optional parameters: - `eventId` {Text} — **Required.** ID of the event to fetch - `startDateTime` {Text|Object} — **Required.** Range start (used as query parameter) - `endDateTime` {Text|Object} — **Required.** Range end (used as query parameter) - `calendarId` {Text} — Calendar ID; uses default calendar when empty - `timeZone` {Text} — Response time zone (`Prefer: outlook.timezone`) - `bodyContentType` {Text} — Body format (`Prefer: outlook.body-content-type`) - `select` {Text} — OData `$select` |
| Result | [cs.NetKit.GraphEvent](./GraphEvent.md) | <- | Event object, or `Null` when not found or on error |

#### Description

Fetches a single event via `GET /me/calendar/events/{id}` or
`GET /me/calendars/{id}/events/{id}`. See inline comment for all supported Graph endpoints.

### .getEvents()

**.getEvents**( { *$inParameters* : Object } ) : [cs.NetKit.GraphEventList](./GraphEventList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Required and optional parameters: - `startDateTime` {Text|Object} — **Required.** Start of the date range - `endDateTime` {Text|Object} — **Required.** End of the date range - `calendarId` {Text} — Calendar ID; uses default calendar when empty - `timeZone` {Text} — Response time zone (`Prefer: outlook.timezone`) - `bodyContentType` {Text} — Body format (`Prefer: outlook.body-content-type`) - `search` {Text} — OData `$search` (sets `ConsistencyLevel: eventual`) - `filter`, `select`, `top`, `orderBy` — standard OData parameters |
| Result | [cs.NetKit.GraphEventList](./GraphEventList.md) | <- | Pageable list of events |

#### Description

Lists events via `GET /me/calendar/calendarView` (when both date bounds are set)
or `GET /me/calendar/events`. See inline comment for all supported endpoints.

### .updateEvent()

**.updateEvent**( *$inEvent* : Object { ; *$inParameters* : Object } ) : Object

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

### .notifier()

**.notifier**( *$inParameters* : Object { ; *$inCalendarId* : Text } ) : cs.GraphNotification

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Notification callbacks and options: - `onCreate` {4D.Function} — Called when an event is created; receives the `eventId` - `onDelete` {4D.Function} — Called when an event is deleted; receives the `eventId` - `onModify` {4D.Function} — Called when an event is modified; receives the `eventId` - `endPoint` {Text} — Webhook URL for push mode; omit to use pull (delta query) mode |
| $inCalendarId | Text | -> | Calendar to subscribe to; defaults to the default calendar |
| Result | cs.GraphNotification | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted` |

#### Description

Creates a `GraphNotification` for calendar event change notifications via the
Microsoft Graph subscription API. See inline comment for full parameter details.

## See also

* [GraphEvent](./GraphEvent.md)
* [GraphEventList](./GraphEventList.md)
* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
