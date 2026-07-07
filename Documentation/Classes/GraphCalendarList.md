# GraphCalendarList Class

## Overview

`GraphCalendarList` is a paginated list of Outlook calendars returned by [`.getCalendars()`](./Office365Calendar.md#getcalendars). It exposes the calendar objects via the `calendars` property, and provides `next()` / `previous()` functions to navigate between pages.

## Properties

A `GraphCalendarList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| calendars | Collection | Collection of calendar objects on the current page. Each object contains properties such as `id`, `name`, and `owner`. |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 10 (configurable via the `top` option in `.getCalendars()`). |
| next() | 4D.Function | Loads the next page of calendars and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of calendars and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [Office365Calendar](./Office365Calendar.md)
* [Office365](./Office365.md)
