# GoogleCalendarList Class

## Overview

`GoogleCalendarList` is a paginated list of Google Calendar entries returned by [`.getCalendars()`](./GoogleCalendar.md#getcalendars). It exposes the raw calendar objects via the `calendars` property, and provides `next()` / `previous()` functions to navigate between pages.

## Properties

A `GoogleCalendarList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| calendars | Collection | Collection of calendar objects on the current page, as returned by the API. Each calendar object contains details such as `id`, `summary`, and `accessRole`. |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number of results. Starts at `1`. By default, each page holds up to 100 results. |
| next() | 4D.Function | Loads the next page of calendar entries and increments `page` by 1. Returns `true` if the next page is loaded successfully, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of calendar entries and decrements `page` by 1. Returns `true` if the previous page is loaded successfully, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Google server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [GoogleCalendar](./GoogleCalendar.md)
* [Google](./Google.md)
