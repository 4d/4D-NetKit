# GraphMessageList Class

## Overview

`GraphMessageList` is a paginated list of Outlook mail messages returned by [`.getMails()`](./Office365Mail.md#getmails). Each raw message object is wrapped into a [GraphMessage](./GraphMessage.md) instance on first access. Use `next()` / `previous()` to navigate between pages.

## Properties

A `GraphMessageList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| mails | Collection | Collection of [GraphMessage](./GraphMessage.md) instances for the current page. Lazily wrapped on first access and cached until the page changes. |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 10 (configurable via the `top` option in `.getMails()`). |
| next() | 4D.Function | Loads the next page of messages and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of messages and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [GraphMessage](./GraphMessage.md)
* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
