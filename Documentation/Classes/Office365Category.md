# Office365Category Class

## Overview

`Office365Category` is the Microsoft Graph API client for managing Outlook master categories within 4D NetKit. It wraps the `/outlook/masterCategories` endpoint and allows you to retrieve the list of categories used to group and organize items such as messages and calendar events.

An `Office365Category` object is accessed via the `category` property of an [Office365](./Office365.md) object: `$office365.category`.

## Table of Contents

### Functions

* [.list()](#list)

## Properties

An `Office365Category` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text | User identifier used in Service mode. Can be the `id` or the `userPrincipalName`. |

## Functions

### .list()

**.list**() : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Object | <- | [Status object](#status-object) including a `categories` property. |

#### Description

`.list()` retrieves the list of defined categories used to group and organize items such as messages and calendar events in a Microsoft account.

Each category includes a display name and a color, which can be applied when creating or updating events (the `categories` property of an [event](./GraphEvent.md) must match the `displayName` of categories returned by this function).

#### Returned object

The method returns a [status object](#status-object) with an additional `categories` property:

| Property | | Type | Description |
|---|---|---|---|
| success | | Boolean | See [status object](#status-object). |
| statusText | | Text | See [status object](#status-object). |
| errors | | Collection | See [status object](#status-object). |
| categories | | Collection | Collection of category objects. |
| | id | Text | ID of the category. |
| | displayName | Text | A unique name that identifies the category in the user's mailbox. Once set, this name cannot be changed. |
| | color | Text | A pre-set color constant mapped to one of 25 predefined Outlook colors (e.g., `"Preset0"`, `"Preset12"`). See the list of [color constants](https://learn.microsoft.com/en-us/graph/api/resources/outlookcategory?view=graph-rest-1.0#properties). |

#### Permissions

| Type | Permission |
|---|---|
| Delegated (Work/School) | `MailboxSettings.Read` |
| Delegated (Personal) | `MailboxSettings.Read` |
| Application | `MailboxSettings.Read` |

#### Example

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $Office365 : cs.NetKit.Office365
var $result : Object
var $toDisplay : Collection

$result:=$Office365.category.list()
$toDisplay:=[]

If (Not($result.success))
  ALERT($result.statusText)
Else
  For each ($category; $result.categories)
    $toDisplay.push($category.displayName)
  End for each
End if
```

## Status object

| Property | Type | Description |
|---|---|---|
| success | Boolean | `true` if the operation was successful. |
| statusText | Text | Status message returned by the Microsoft server or last error from the 4D error stack. |
| errors | Collection | Collection of 4D error items (not returned if a server response is received): `errcode`, `message`, `componentSignature`. |

## See also

* [GraphCategoryList](./GraphCategoryList.md)
* [GraphEvent](./GraphEvent.md)
* [Office365](./Office365.md)
