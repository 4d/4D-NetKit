# GoogleUser Class

## Overview

Google People API client; provides read access to user profiles
(names, email addresses, and other person fields) via the
`people.get`, `people.getBatchGet`, and `people.listDirectoryPeople` endpoints.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleUser.new()](#csnetkitgoogleusernew)

### Mails

* [GoogleUser.getCurrent()](#googleusergetcurrent)
* [GoogleUser.get()](#googleuserget)
* [GoogleUser.list()](#googleuserlist)

## **cs.NetKit.GoogleUser.new()**

**cs.NetKit.GoogleUser.new**( *$inProvider* : cs.OAuth2Provider ) : cs.NetKit.GoogleUser

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider used for token retrieval |
| Result | cs.NetKit.GoogleUser | <- | Object of the GoogleUser class |

### Description

Initialises the client with the People API base URL
(`https://people.googleapis.com/v1/`) and sets the default person fields
to `["names", "emailAddresses"]`

## Mails

### GoogleUser.getCurrent()

**GoogleUser.getCurrent**( *$inPersonFields* : Variant ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inPersonFields | Variant | -> | Fields to return (Collection, comma-separated Text, or omitted to use `defaultPersonFields`) |
| Result | Object | <- | People API person resource for the authenticated user |

#### Description

Fetches the profile of the currently authenticated user
by calling `_get("me", $inPersonFields)`

### GoogleUser.get()

**GoogleUser.get**( *$inResourceName* : Text ; *$inPersonFields* : Variant ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inResourceName | Text | -> | Person resource name (e.g. `"people/c123456"`) |
| $inPersonFields | Variant | -> | Fields to return (Collection, comma-separated Text, or omitted to use `defaultPersonFields`) |
| Result | Object | <- | People API person resource object, or `Null` on error |

#### Description

Fetches a single user profile by resource name

### GoogleUser.list()

**GoogleUser.list**( *$inParameters* : Object ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options forwarded to `_getURLParamsFromObject` (`select`, `sources`, `mergeSources`, `top`, `pageToken`) |
| Result | Object | <- | Paginated list of directory people |

#### Description

Builds the `people:listDirectoryPeople` URL and returns a
`GoogleUserList` instance for the first page; use `next()` / `previous()`
on the returned object to navigate subsequent pages

