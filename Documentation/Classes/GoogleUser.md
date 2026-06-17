# GoogleUser Class

## Overview

`GoogleUser` is the Google People API client within 4D NetKit. It provides read access to user profiles (names, email addresses, and other person fields) via the `people.get`, `people.getBatchGet`, and `people.listDirectoryPeople` endpoints.

A `GoogleUser` object is accessed via the `user` property of a [Google](./Google.md) object: `$google.user`.

## Table of Contents

### Functions

* [.get()](#get)
* [.getCurrent()](#getcurrent)
* [.list()](#list)

## Functions

### .get()

**.get**( *id* : Text { ; *select* : Text } ) : Object<br/>
**.get**( *id* : Text { ; *select* : Collection } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| id | Text | -> | The `resourceName` of the person to retrieve information about (e.g., `"people/c123456"`). Use the `resourceName` field returned by [`.list()`](#list). |
| select | Text \| Collection | -> | Comma-separated list or collection of specific fields to retrieve (e.g., `"names, phoneNumbers"`). If omitted, returns `emailAddresses` and `names`. |
| Result | Object | <- | [People API person resource](https://developers.google.com/people/api/rest/v1/people#Person) object, or `Null` on error. |

#### Description

`.get()` provides information about a user based on the `resourceName` provided in `id` and the fields optionally specified in `select`.

Supported fields include: *addresses*, *ageRanges*, *biographies*, *birthdays*, *calendarUrls*, *clientData*, *coverPhotos*, *emailAddresses*, *events*, *externalIds*, *genders*, *imClients*, *interests*, *locales*, *locations*, *memberships*, *metadata*, *miscKeywords*, *names*, *nicknames*, *occupations*, *organizations*, *phoneNumbers*, *photos*, *relations*, *sipAddresses*, *skills*, *urls*, *userDefined*.

#### Permissions

No authorization required to access public data. For private data, one of the following OAuth scopes is required:

```
https://www.googleapis.com/auth/contacts
https://www.googleapis.com/auth/contacts.readonly
https://www.googleapis.com/auth/contacts.other.readonly
https://www.googleapis.com/auth/directory.readonly
https://www.googleapis.com/auth/profile.agerange.read
https://www.googleapis.com/auth/profile.emails.read
https://www.googleapis.com/auth/profile.language.read
https://www.googleapis.com/auth/user.addresses.read
https://www.googleapis.com/auth/user.birthday.read
https://www.googleapis.com/auth/user.emails.read
https://www.googleapis.com/auth/user.gender.read
https://www.googleapis.com/auth/user.organization.read
https://www.googleapis.com/auth/user.phonenumbers.read
https://www.googleapis.com/auth/userinfo.email
https://www.googleapis.com/auth/userinfo.profile
```

### .getCurrent()

**.getCurrent**( { *select* : Text } ) : Object<br/>
**.getCurrent**( { *select* : Collection } ) : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| select | Text \| Collection | -> | Comma-separated list or collection of specific fields to retrieve (e.g., `"names, phoneNumbers"`). If omitted, returns `emailAddresses` and `names`. |
| Result | Object | <- | [People API person resource](https://developers.google.com/people/api/rest/v1/people#Person) for the authenticated user. |

#### Description

`.getCurrent()` provides information about the currently authenticated user, based on the fields optionally specified in `select`.

Supported fields are the same as [`.get()`](#get).

#### Permissions

Requires the same OAuth scopes as [`.get()`](#permissions).

#### Example

```4d
var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param : Object

$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id"
$param.clientSecret:="xxxxxxxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:=[]
$param.scope.push("https://www.googleapis.com/auth/contacts")
$param.scope.push("https://www.googleapis.com/auth/userinfo.email")
$param.scope.push("https://www.googleapis.com/auth/userinfo.profile")

$oauth2:=New OAuth2 provider($param)
$google:=cs.NetKit.Google.new($oauth2)

// Returns emailAddresses and names by default
var $currentUser1:=$google.user.getCurrent()

// Returns only phoneNumbers
var $currentUser2:=$google.user.getCurrent("phoneNumbers")
```

### .list()

**.list**( { *param* : Object } ) : [cs.NetKit.GoogleUserList](./GoogleUserList.md)

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| param | Object | -> | Options defining how to retrieve and filter user data (optional). |
| Result | [cs.NetKit.GoogleUserList](./GoogleUserList.md) | <- | Paginated list of [user objects](https://developers.google.com/people/api/rest/v1/people#Person). Use `next()` / `previous()` to navigate pages. |

#### Description

`.list()` provides a list of domain profiles or domain contacts in the authenticated user's domain directory.

> If contact sharing or External Directory sharing is not allowed in the Google admin console, the returned `users` collection will be empty.

In *param*, you can pass the following properties:

| Property | Type | Description |
|---|---|---|
| select | Text \| Collection | Comma-separated list or collection of fields to retrieve (e.g., `"names, phoneNumbers"`). Defaults to `emailAddresses` and `names`. |
| sources | Text \| Collection | Directory source to return. Values: `"DIRECTORY_SOURCE_TYPE_UNSPECIFIED"`, `"DIRECTORY_SOURCE_TYPE_DOMAIN_CONTACT"`, `"DIRECTORY_SOURCE_TYPE_DOMAIN_PROFILE"` (default). |
| mergeSources | Text \| Collection | Adds related data if linked by verified join keys (e.g., email, phone). Values: `"DIRECTORY_MERGE_SOURCE_TYPE_UNSPECIFIED"`, `"DIRECTORY_MERGE_SOURCE_TYPE_CONTACT"`. |
| top | Integer | Maximum number of people per page (1–1000). Default is 100. |

#### Permissions

Requires the same OAuth scopes as [`.get()`](#permissions).

#### Example

```4d
var $google : cs.NetKit.Google
var $oauth2 : cs.NetKit.OAuth2Provider
var $param : Object

$param:={}
$param.name:="google"
$param.permission:="signedIn"
$param.clientId:="your-client-id"
$param.clientSecret:="xxxxxxxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:=[]
$param.scope.push("https://www.googleapis.com/auth/contacts")
$param.scope.push("https://www.googleapis.com/auth/directory.readonly")
$param.scope.push("https://www.googleapis.com/auth/userinfo.email")
$param.scope.push("https://www.googleapis.com/auth/userinfo.profile")

$oauth2:=New OAuth2 provider($param)
$google:=cs.NetKit.Google.new($oauth2)

var $userList:=$google.user.list({top: 10})
```

## See also

* [GoogleUserList](./GoogleUserList.md)
* [Google](./Google.md)
