# GoogleUserList Class

## Overview

`GoogleUserList` is a paginated list of Google People API contacts returned by [`.list()`](./GoogleUser.md#list). It exposes the person objects via the `users` property, and provides `next()` / `previous()` functions to navigate between pages.

## Properties

A `GoogleUserList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| users | Collection | Collection of [user objects](https://developers.google.com/people/api/rest/v1/people#Person) on the current page, each containing detailed information about individual users. |
| isLastPage | Boolean | `true` if the current page is the last one. |
| page | Integer | Current page number. Starts at `1`. Default page size is 100 (configurable via the `top` option in `.list()`). |
| next() | 4D.Function | Loads the next page of users and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of users and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Google server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [GoogleUser](./GoogleUser.md)
* [Google](./Google.md)
