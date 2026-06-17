# GraphEventList Class

## Overview

`GraphEventList` is a paginated list of Microsoft Graph calendar events returned by [`.getEvents()`](./Office365Calendar.md#getevents). Each raw event object is wrapped into a [GraphEvent](./GraphEvent.md) instance on first access. Use `next()` / `previous()` to navigate between pages.

## Properties

A `GraphEventList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| events | Collection | Collection of [GraphEvent](./GraphEvent.md) instances for the current page. Lazily wrapped on first access and cached until the page changes. |
| calendarId | Text | Calendar identifier, same as the `calendarId` provided in the request parameters (if present). |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 10 (configurable via the `top` option in `.getEvents()`). |
| next() | 4D.Function | Loads the next page of events and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of events and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [GraphEvent](./GraphEvent.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365](./Office365.md)
