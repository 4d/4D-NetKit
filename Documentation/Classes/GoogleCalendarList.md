# GoogleCalendarList Class

## Overview

Paginated list of Google Calendar entries returned by the
`calendarList.list` endpoint. Exposes the raw calendar objects via the
`calendars` getter; use `next()` / `previous()` inherited from `_BaseList`
to navigate pages.

## Properties

A `GoogleCalendarList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| calendars | Collection | (read-only) Returns the raw calendar objects from the current page as delivered by the API; call `next()` to advance to the following page |

## See also

* [GoogleCalendar](./GoogleCalendar.md)
