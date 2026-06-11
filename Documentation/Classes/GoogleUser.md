# GoogleUser Class

## Overview

Google People API client; provides read access to user profiles
(names, email addresses, and other person fields) via the
`people.get`, `people.getBatchGet`, and `people.listDirectoryPeople` endpoints.

## Table of Contents

### Mails

* [.get()](#get)
* [.getCurrent()](#getcurrent)
* [.list()](#list)

## Mails

### .get()

**.get**( *$inResourceName* : Text { ; *$inPersonFields* : Variant } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inResourceName | Text | -> | Person resource name (e.g. `"people/c123456"`) |
| $inPersonFields | Variant | -> | Fields to return (Collection, comma-separated Text, or omitted to use `defaultPersonFields`) |
| Result | Object | <- | People API person resource object, or `Null` on error |

#### Description

Fetches a single user profile by resource name

### .getCurrent()

**.getCurrent**( { *$inPersonFields* : Variant } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inPersonFields | Variant | -> | Fields to return (Collection, comma-separated Text, or omitted to use `defaultPersonFields`) |
| Result | Object | <- | People API person resource for the authenticated user |

#### Description

Fetches the profile of the currently authenticated user
by calling `_get("me", $inPersonFields)`

### .list()

**.list**( *$inParameters* : Object ) : [cs.NetKit.GoogleUserList](./GoogleUserList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options forwarded to `_getURLParamsFromObject` (`select`, `sources`, `mergeSources`, `top`, `pageToken`) |
| Result | [cs.NetKit.GoogleUserList](./GoogleUserList.md) | <- | Paginated list of directory people |

#### Description

Builds the `people:listDirectoryPeople` URL and returns a
`GoogleUserList` instance for the first page; use `next()` / `previous()`
on the returned object to navigate subsequent pages

## See also

* [GoogleUserList](./GoogleUserList.md)
* [Google](./Google.md)
