# GoogleEventList Class

## Overview

Paginated list of Google Calendar events returned by the
`events.list` endpoint. Wraps each raw event object into a `GoogleEvent`
instance on first access via the `events` getter (lazy, cached);
use `next()` / `previous()` inherited from `_BaseList` to navigate pages.

## Properties

A `GoogleEventList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| kind | Text |  |
| etag | Text |  |
| summary | Text |  |
| calendarId | Text |  |
| description | Text |  |
| updated | Text |  |
| timeZone | Text |  |
| accessRole | Text |  |
| defaultReminders | Collection |  |
| events | Collection | (read-only) Lazily wraps each raw event object from `_internals._list` into a `GoogleEvent` instance on first access; the result is cached and invalidated when `next()` / `previous()` loads a new page |

## See also

* [GoogleEvent](./GoogleEvent.md)
* [GoogleCalendar](./GoogleCalendar.md)
