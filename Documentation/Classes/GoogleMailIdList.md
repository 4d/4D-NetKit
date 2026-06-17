# GoogleMailIdList Class

## Overview

`GoogleMailIdList` is a paginated list of Gmail message identifiers returned by [`.getMailIds()`](./GoogleMail.md#getmailids). It exposes the raw message-id objects (each with `id` and `threadId`) via the `mailIds` property, and provides `next()` / `previous()` functions to navigate between pages.

## Properties

A `GoogleMailIdList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| mailIds | Collection | Collection of objects on the current page. Each object contains: `id` (Text, the mail ID) and `threadId` (Text, the thread ID). Empty if no mail is returned. |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 10 (configurable via the `top` option in `.getMailIds()`). |
| next() | 4D.Function | Loads the next page of mail IDs and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of mail IDs and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Gmail server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [GoogleMail](./GoogleMail.md)
* [Google](./Google.md)
