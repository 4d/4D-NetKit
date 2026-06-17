# GraphFolderList Class

## Overview

`GraphFolderList` is a paginated list of Outlook mail folders returned by [`.getFolderList()`](./Office365Mail.md#getfolderlist). It exposes the folder objects via the `folders` property, and provides `next()` / `previous()` functions to navigate between pages.

## Properties

A `GraphFolderList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| folders | Collection | Collection of `mailFolder` objects on the current page. Each object contains: |
| | id (Text) | The mailFolder's unique identifier. |
| | displayName (Text) | The mailFolder's display name. |
| | parentFolderId (Text) | The unique identifier for the mailFolder's parent mailFolder. |
| | childFolderCount (Integer) | Number of immediate child mailFolders in the current mailFolder. |
| | totalItemCount (Integer) | Number of items in the mailFolder. |
| | unreadItemCount (Integer) | Number of items in the mailFolder marked as unread. |
| | isHidden (Boolean) | Indicates whether the mailFolder is hidden. |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 10 (configurable via the `top` option in `.getFolderList()`). |
| next() | 4D.Function | Loads the next page of folders and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of folders and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
