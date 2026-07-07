# GraphUserList Class

## Overview

`GraphUserList` is a paginated list of Azure AD users returned by [`.list()`](./Office365User.md#list) or [`.count()`](./Office365User.md#count). It exposes the user objects via the `users` property, and provides `next()` / `previous()` functions to navigate between pages.

## Properties

A `GraphUserList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| users | Collection | Collection of user objects on the current page. By default, each user object contains: `id`, `businessPhones`, `displayName`, `givenName`, `jobTitle`, `mail`, `mobilePhone`, `officeLocation`, `preferredLanguage`, `surname`, `userPrincipalName`. |
| isLastPage | Boolean | `true` if the last page of results has been reached. |
| page | Integer | Current page number. Starts at `1`. Default page size is 100 (configurable via the `top` option in `.list()`). |
| next() | 4D.Function | Loads the next page of users and increments `page` by 1. Returns `true` if successful, `false` if no additional pages are available. |
| previous() | 4D.Function | Loads the previous page of users and decrements `page` by 1. Returns `true` if successful, `false` if no previous pages are available. |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or the last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (if any): `errcode`, `message`, `componentSignature`. |

## See also

* [Office365User](./Office365User.md)
* [Office365](./Office365.md)
