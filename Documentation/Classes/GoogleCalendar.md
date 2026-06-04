# GoogleCalendar Class

## Overview

Google Calendar API client; provides CRUD operations on calendars
and events, and exposes a `notifier()` factory for push/pull change monitoring.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleCalendar.new()](#csnetkitgooglecalendarnew)

### Calendars

* [GoogleCalendar.getCalendar()](#googlecalendargetcalendar)
* [GoogleCalendar.getCalendars()](#googlecalendargetcalendars)

### Events

* [GoogleCalendar.getEvent()](#googlecalendargetevent)
* [GoogleCalendar.getEvents()](#googlecalendargetevents)
* [GoogleCalendar.createEvent()](#googlecalendarcreateevent)
* [GoogleCalendar.deleteEvent()](#googlecalendardeleteevent)
* [GoogleCalendar.updateEvent()](#googlecalendarupdateevent)

### Notifications

* [GoogleCalendar.notifier()](#googlecalendarnotifier)

## **cs.NetKit.GoogleCalendar.new()**

**cs.NetKit.GoogleCalendar.new**( *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ) : cs.NetKit.GoogleCalendar

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider used for token retrieval |
| $inParameters | Object | -> | Configuration object; recognised properties: - `userId` {Text} — Google account identifier (defaults to empty, meaning the authenticated user) |
| Result | cs.NetKit.GoogleCalendar | <- | Object of the GoogleCalendar class |

### Properties

The returned `GoogleCalendar` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text |  |

## Calendars

### GoogleCalendar.getCalendar()

**GoogleCalendar.getCalendar**( *$inID* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inID | Text | -> | Calendar ID to fetch; defaults to `"primary"` when empty |
| Result | Object | <- | Google Calendar `calendarListEntry` resource, or `Null` on error |

#### Description

Fetches a single entry from the user's calendar list via
`GET users/me/calendarList/{calendarId}`; pushes error 10 when `$inID` is not a Text

### GoogleCalendar.getCalendars()

**GoogleCalendar.getCalendars**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options; recognised properties: - `top` {Integer|Text} — Maximum results per page (`maxResults`) - `minAccessRole` {Text} — Minimum access role filter - `pageToken` {Text} — Page token for pagination - `showHidden` {Boolean} — Include hidden calendars - `showDeleted` {Boolean} — Include deleted calendars |
| Result | Object | <- | Paginated list of calendar entries; use `next()` / `previous()` to navigate pages |

#### Description

Fetches the user's calendar list via `GET users/me/calendarList`
and returns a `GoogleCalendarList` for the first page

## Events

### GoogleCalendar.getEvent()

**GoogleCalendar.getEvent**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options; required properties: - `eventId` {Text} — ID of the event to fetch Optional properties: - `calendarId` {Text} — Calendar ID (defaults to `"primary"`) - `timeZone` {Text} — Timezone for the response (defaults to `"UTC"`) - `maxAttendees` {Integer|Text} — Maximum number of attendees to include |
| Result | Object | <- | The requested event wrapped in a `GoogleEvent` instance, or `Null` on error or missing required parameters |

#### Description

Fetches a single event via `GET calendars/{calendarId}/events/{eventId}`;
pushes error 10 when `eventId` is not a Text, error 9 when `startDateTime` / `endDateTime`
is missing from a paired requirement

### GoogleCalendar.getEvents()

**GoogleCalendar.getEvents**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options; recognised properties: - `calendarId` {Text} — Calendar ID (defaults to `"primary"`) - `startDateTime` {Text|Object} — Lower bound for event start time; defaults to now - `endDateTime` {Text|Object} — Upper bound for event start time - `timeZone` {Text} — Timezone for the response (defaults to `"UTC"`) - `top` {Integer|Text} — Maximum results per page (`maxResults`) - `orderBy` {Text} — Sort order: `"startTime"` or `"updated"` - `search` {Text} — Free-text search query (`q`) - `eventTypes` {Text} — Event type filter - `iCalUID` {Text} — Filter by iCalendar UID - `maxAttendees` {Integer|Text} — Maximum attendees to include - `showDeleted` / `showHiddenInvitations` / `singleEvents` {Boolean} - `updatedMin` / `privateExtendedProperty` / `sharedExtendedProperty` {Text} |
| Result | Object | <- | Paginated list of `GoogleEvent` instances; top-level metadata (`kind`, `etag`, `summary`, etc.) is forwarded onto the list object |

#### Description

Fetches events via `GET calendars/{calendarId}/events` and returns a
`GoogleEventList` for the first page; use `next()` / `previous()` to navigate pages

### GoogleCalendar.createEvent()

**GoogleCalendar.createEvent**( *$inEvent* : Object ; *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inEvent | Object | -> | Event object to create; `start` / `end` are normalised via `_conformEvent` (flexible date/time input accepted); `id` is stripped automatically |
| $inParameters | Object | -> | Request options; recognised properties: - `calendarId` {Text} — Target calendar ID (defaults to `"primary"`) - `conferenceDataVersion` {Integer|Text} — Conference data version - `maxAttendees` {Integer|Text} — Maximum attendees in the response - `sendNotifications` {Boolean} — Whether to send notifications to attendees - `sendUpdates` {Text} — `"all"`, `"externalOnly"`, or `"none"` - `supportsAttachments` {Boolean} — Whether attachments are supported |
| Result | Object | <- | Status object `{success; statusText; ?event}` where `event` is the created `GoogleEvent` instance on success |

#### Description

Creates a new event via `POST calendars/{calendarId}/events`

### GoogleCalendar.deleteEvent()

**GoogleCalendar.deleteEvent**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Request options; recognised properties: - `calendarId` {Text} — Calendar ID (defaults to `"primary"`) - `eventId` {Text} — ID of the event to delete - `sendNotifications` {Boolean} — Whether to send cancellation notifications - `sendUpdates` {Text} — `"all"`, `"externalOnly"`, or `"none"` |
| Result | Object | <- | Status object `{success; statusText}` |

#### Description

Permanently deletes an event via
`DELETE calendars/{calendarId}/events/{eventId}`

### GoogleCalendar.updateEvent()

**GoogleCalendar.updateEvent**( *$inEvent* : Object ; *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inEvent | Object | -> | Event object with updated fields; `id` is used to identify the event then stripped from the request body; `start` / `end` are normalised via `_conformEvent` |
| $inParameters | Object | -> | Request options; recognised properties: - `calendarId` {Text} — Calendar ID (defaults to `"primary"`) - `fullUpdate` {Boolean} — Use `PUT` (full replace) when True, `PATCH` (partial) otherwise - `conferenceDataVersion` {Integer|Text} — Conference data version - `maxAttendees` {Integer|Text} — Maximum attendees in the response - `sendNotifications` {Boolean} — Whether to send update notifications - `sendUpdates` {Text} — `"all"`, `"externalOnly"`, or `"none"` - `supportsAttachments` {Boolean} |
| Result | Object | <- | Status object `{success; statusText; ?event}` where `event` is the updated `GoogleEvent` instance on success |

#### Description

Updates an event via `PATCH` (default) or `PUT` (when `fullUpdate` is True)

## Notifications

### GoogleCalendar.notifier()

**GoogleCalendar.notifier**( *$inParameters* : Object ; *$inCalendarId* : Text ) : cs.GoogleNotification

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Notification options (see inline documentation): `onCreate`, `onDelete`, `onModify` callbacks; optional `endPoint` for push mode; optional `timer` (seconds) for pull mode |
| $inCalendarId | Text | -> | Calendar ID to watch (defaults to `"primary"`) |
| Result | cs.GoogleNotification | <- | Notification object with `start()`, `stop()`, `expiration`, and `isStarted`; call `start()` to begin monitoring |

#### Description

Factory that creates a `GoogleNotification` for calendar event change
monitoring. Push mode (webhook) requires `endPoint`; pull mode polls the Calendar
events API with sync tokens at a configurable interval.

