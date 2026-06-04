# Office365User Class

## Overview

Microsoft Graph API client for querying Azure AD users.
Wraps the `/users` and `/me` endpoints.

## Table of Contents

### Initialization

* [cs.NetKit.Office365User.new()](#csnetkitoffice365usernew)

### Functions

* [Office365User.getCurrent()](#office365usergetcurrent)
* [Office365User.get()](#office365userget)
* [Office365User.list()](#office365userlist)
* [Office365User.count()](#office365usercount)

## **cs.NetKit.Office365User.new()**

**cs.NetKit.Office365User.new**( *$inProvider* : cs.OAuth2Provider ) : cs.NetKit.Office365User

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| Result | cs.NetKit.Office365User | <- | Object of the Office365User class |

### Office365User.getCurrent()

**Office365User.getCurrent**( *$inSelect* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inSelect | Text | -> | Comma-separated list of properties to return (OData `$select`) |
| Result | Object | <- | Current authenticated user's properties, or `Null` on failure |

#### Description

Fetches the currently authenticated user via `GET /me`

### Office365User.get()

**Office365User.get**( *$inID* : Text ; *$inSelect* : Text ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inID | Text | -> | Azure AD user ID or user principal name |
| $inSelect | Text | -> | Comma-separated list of properties to return (OData `$select`) |
| Result | Object | <- | User properties object, or `Null` when not found or on error |

#### Description

Fetches a specific user via `GET /users/{id}`;
throws error 9 when `$inID` is empty

### Office365User.list()

**Office365User.list**( *$inParameters* : Object ) : [cs.NetKit.GraphUserList](./GraphUserList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options: - `search` {Text} — OData `$search` expression; automatically sets `ConsistencyLevel: eventual` - `filter` {Text} — OData `$filter` expression - `select` {Text} — Comma-separated property names (`$select`) - `top` {Text|Integer} — Maximum number of results per page (`$top`) - `orderBy` {Text} — Sort expression (`$orderBy`) |
| Result | [cs.NetKit.GraphUserList](./GraphUserList.md) | <- | Pageable list of Azure AD users |

#### Description

Lists Azure AD users via `GET /users` with optional OData query parameters

### Office365User.count()

**Office365User.count**( *$inParameters* : Object ) : [cs.NetKit.GraphUserList](./GraphUserList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParameters | Object | -> | Query options (same as `list`); `$count=true` and `ConsistencyLevel: eventual` are added automatically: - `search` {Text} — OData `$search` expression - `filter` {Text} — OData `$filter` expression - `select` {Text} — OData `$select` - `top` {Text|Integer} — OData `$top` - `orderBy` {Text} — OData `$orderBy` |
| Result | [cs.NetKit.GraphUserList](./GraphUserList.md) | <- | Pageable list with total count included in the response |

#### Description

Lists Azure AD users with `$count=true` via `GET /users`;
requires `ConsistencyLevel: eventual` (set automatically)


## See also

* [GraphUserList](./GraphUserList.md)
* [Office365](./Office365.md)
