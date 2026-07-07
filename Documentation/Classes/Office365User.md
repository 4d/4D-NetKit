# Office365User Class

## Overview

`Office365User` is the Microsoft Graph API client for querying Azure AD users. It wraps the `/users` and `/me` endpoints and lets you retrieve user profiles either individually or as a paginated list.

An `Office365User` object is accessed via the `user` property of an [Office365](./Office365.md) object: `$office365.user`.

## Table of Contents

### Functions

* [.get()](#get)
* [.getCurrent()](#getcurrent)
* [.list()](#list)

## Functions

### .get()

**.get**( *id* : Text { ; *select* : Text } ) : Object<br/>
**.get**( *userPrincipalName* : Text { ; *select* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| id | Text | -> | Unique identifier of the user to search for. |
| userPrincipalName | Text | -> | User principal name (UPN) of the user to search for. |
| select | Text | -> | Comma-separated set of properties to return (optional). |
| Result | Object | <- | Object holding information on the user, or `Null` if not found or on error. |

#### Description

`.get()` returns information on the user whose ID matches *id*, or whose User Principal Name matches *userPrincipalName*.

> The UPN is an Internet-style login name based on RFC 822. By convention, it corresponds to the user's email name.

If the ID or UPN is not found or the connection fails, the function returns `Null` and throws an error.

In *select*, pass a comma-separated string of property names to retrieve. If omitted, the function returns a default set of properties (see below).

> The full list of available properties is on [Microsoft's documentation website](https://docs.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0).

#### Returned object

By default, when *select* is omitted, the returned object contains the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text | Unique identifier for the user. |
| businessPhones | Collection | The user's phone numbers. |
| displayName | Text | Name displayed in the address book for the user. |
| givenName | Text | The user's first name. |
| jobTitle | Text | The user's job title. |
| mail | Text | The user's email address. |
| mobilePhone | Text | The user's cellphone number. |
| officeLocation | Text | The user's physical office location. |
| preferredLanguage | Text | The user's language of preference. |
| surname | Text | The user's last name. |
| userPrincipalName | Text | The user's principal name. |

Otherwise, the object contains only the properties specified in *select*.

### .getCurrent()

**.getCurrent**( { *select* : Text } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| select | Text | -> | Comma-separated set of properties to return (optional). |
| Result | Object | <- | Current authenticated user's properties, or `Null` on failure. |

#### Description

`.getCurrent()` returns information on the currently signed-in user.

This function requires a [signed-in user](https://docs.microsoft.com/en-us/graph/auth-v2-user) (delegated permission). It returns `Null` if the session is not a sign-in session.

In *select*, pass a comma-separated string of property names to retrieve. If omitted, returns the [default set of properties](#returned-object).

#### Example

```4d
var $userInfo; $params : Object
var $oAuth2 : cs.NetKit.OAuth2Provider
var $Office365 : cs.NetKit.Office365

// Set up parameters:
$params:=New object
$params.name:="Microsoft"
$params.permission:="signedIn"
$params.clientId:="your-client-id" // Replace with your Microsoft identity platform client ID
$params.redirectURI:="http://127.0.0.1:50993/authorize/"
$params.scope:="https://graph.microsoft.com/.default"

$oAuth2:=New OAuth2 provider($params) // Creates an OAuth2Provider Object
$Office365:=New Office365 provider($oAuth2) // Creates an Office365 object

// Return specified properties for the current user
$userInfo:=$Office365.user.getCurrent("id,userPrincipalName,displayName,givenName,mail")
```

### .list()

**.list**( { *param* : Object } ) : [cs.NetKit.GraphUserList](./GraphUserList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Additional options for the search (optional). |
| Result | [cs.NetKit.GraphUserList](./GraphUserList.md) | <- | Paginated list of Azure AD users. Use `next()` / `previous()` to navigate pages. |

#### Description

`.list()` returns a list of Office 365 users.

In *param*, you can pass the following optional properties:

| Property | Type | Description |
|---|---|---|
| search | Text | Restricts results to match a search criterion. The syntax rules are available on [Microsoft's documentation website](https://docs.microsoft.com/en-us/graph/search-query-parameter#using-search-on-directory-object-collections). |
| filter | Text | Allows retrieving a subset of users. See [Microsoft's documentation on filter parameter](https://docs.microsoft.com/en-us/graph/query-parameters#filter-parameter). |
| select | Text | Comma-separated set of properties to retrieve. By default, user objects include the [default set of properties](#returned-object). |
| top | Integer | Page size. Maximum value is 999. Default is 100. Use `next()` to navigate multi-page results. |
| orderBy | Text | Sort order. Syntax: `"fieldname asc"` or `"fieldname desc"`. |

#### Returned object

The returned [GraphUserList](./GraphUserList.md) object holds a collection of users and status/navigation properties:

| Property | Type | Description |
|---|---|---|
| users | Collection | Collection of user objects. By default each user has the [default set of properties](#returned-object). |
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the server, or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |
| isLastPage | Boolean | `true` if the last page is reached. |
| page | Integer | Current page number. Starts at 1. |
| next() | Function | Loads the next page into `users`. Returns `true` on success, `false` if there is no next page. |
| previous() | Function | Loads the previous page into `users`. Returns `true` on success, `false` if there is no previous page. |

#### Example

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $Office365 : cs.NetKit.Office365
var $userList1; $userList2; $userList3; $userList4; $params : Object
var $col : Collection

// Set up parameters:
$params:=New object
$params.name:="Microsoft"
$params.permission:="signedIn"
$params.clientId:="your-client-id" // Replace with your Microsoft identity platform client ID
$params.redirectURI:="http://127.0.0.1:50993/authorize/"
$params.scope:="https://graph.microsoft.com/.default"

$oAuth2:=New OAuth2 provider($params) // Creates an OAuth2Provider Object
$Office365:=New Office365 provider($oAuth2) // Creates an Office365 object

// Return a list with the first 100 users
$userList1:=$Office365.user.list()

// Return a list of users whose displayName starts with "Jean"
$userList2:=$Office365.user.list(New object("filter"; "startswith(displayName,'Jean')"))

// Return a list of users whose display names contain "F", sorted descending
$userList3:=$Office365.user.list(New object("search"; "\"displayName:F\""; "orderBy"; "displayName desc"; "select"; "displayName"))

// Collect all userPrincipalNames across all pages
$userList4:=$Office365.user.list(New object("select"; "userPrincipalName"))
$col:=New collection
Repeat
    $col.combine($userList4.users)
Until (Not($userList4.next()))
```

## See also

* [GraphUserList](./GraphUserList.md)
* [Office365](./Office365.md)
