# GoogleEventList Class

## Overview

`GoogleEventList` is a paginated list of Google Calendar events returned by [`.getEvents()`](./GoogleCalendar.md#getevents). Each raw event object is wrapped into a [GoogleEvent](./GoogleEvent.md) instance on first access via the `events` property. Use `next()` / `previous()` to navigate between pages.

## Properties

A `GoogleEventList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| events | Collection | Collection of [GoogleEvent](./GoogleEvent.md) instances for the current page. Lazily wrapped on first access and cached until the page changes. |
| kind | Text | Type of collection (e.g., `"calendar#events"`). |
| etag | Text | ETag of the collection. |
| summary | Text | Title of the calendar (read-only). |
| calendarId | Text | Calendar identifier, same as the `calendarId` passed in the request parameter. |
| description | Text | Description of the calendar (read-only). |
| updated | Text | Last modification time of the calendar (ISO 8601 UTC). |
| timeZone | Text | Time zone of the calendar (IANA format, e.g., `"Europe/Zurich"`). |
| accessRole | Text | User's access role for the calendar (read-only). Possible values: `"none"`, `"freeBusyReader"`, `"reader"`, `"writer"`, `"owner"`. |
| defaultReminders | Collection | Default reminders for the authenticated user. Each item has a `method` (Text: `"email"` or `"popup"`) and `minutes` (Integer). |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 250 (configurable via the `top` option in `.getEvents()`). |
| next() | 4D.Function | Loads the next page of events and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of events and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Google server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [GoogleEvent](./GoogleEvent.md)
* [GoogleCalendar](./GoogleCalendar.md)
* [Google](./Google.md)
