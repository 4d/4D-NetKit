# GoogleDriveFileList Class

## Overview

`GoogleDriveFileList` is a paginated list of Google Drive files returned by [`.list()`](./GoogleDrive.md#list). It exposes the file objects through the `files` property, and provides `next()` / `previous()` functions to navigate between pages.

## Properties

A `GoogleDriveFileList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| files | Collection | Collection of [`GoogleDriveItem`](./GoogleDriveItem.md) objects on the current page. Each item exposes `.getContent()` to download file bytes. |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. |
| next() | 4D.Function | Loads the next page and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Google server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [GoogleDrive](./GoogleDrive.md)
* [GoogleDriveItem](./GoogleDriveItem.md)
* [Google](./Google.md)