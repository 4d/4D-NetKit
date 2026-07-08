# EmailAddress Class

## Overview

The `EmailAddress` class parses, validates, and formats email addresses with an optional display name.

It supports both address forms:
- `email@domain.com`
- `Display Name <email@domain.com>`

This class is instantiated by calling `cs.EmailAddress.new()`.

**Note:** Shared objects are not supported by the 4D NetKit API.

## Table of contents

* [cs.EmailAddress.new()](#csemailaddressnew)
* [EmailAddress.fromString()](#emailaddressfromstring)
* [EmailAddress.toString()](#emailaddresstostring)
* [EmailAddress.toJSON()](#emailaddresstojson)
* [EmailAddress.toGraphJSON()](#emailaddresstographjson)
* [EmailAddress.isValid()](#emailaddressisvalid)
* [EmailAddress properties](#emailaddress-properties)

## cs.EmailAddress.new()

**cs.EmailAddress.new** ( *nameOrValue* : Text { ; *address* : Text } ) : `cs.EmailAddress`

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| nameOrValue | Text | -> | Full address (`"Name <email@domain>"`) or display name. |
| address | Text | -> | Optional. Email address for two-parameter form. |
| Result | cs.EmailAddress | <- | An `EmailAddress` instance. |

### Example

```4d
var $email1 : cs.EmailAddress:=cs.EmailAddress.new("John Doe <john@example.com>")
var $email2 : cs.EmailAddress:=cs.EmailAddress.new("John Doe"; "john@example.com")
```

## .fromString()

**.fromString** ( *value* : Text )

### Description

Parses a text address and sets `name` and `email`.

## .toString()

**.toString**() : Text

### Description

Returns `"Name <email@domain>"` when a display name exists, otherwise `"email@domain"`.

## .toJSON()

**.toJSON**() : Object

### Description

Returns a simple object: `{name; email}`.

## .toGraphJSON()

**.toGraphJSON**() : Object

### Description

Returns Microsoft Graph recipient format: `{address; name}`.

### Example

```4d
var $recipient : cs.EmailAddress:=cs.EmailAddress.new("jane@example.com")
var $graphRecipient : Object:=$recipient.toGraphJSON()
```

## .isValid()

**.isValid**() : Boolean

### Description

Returns `True` when `email` contains a valid address.

## EmailAddress properties

| Property | Type | Description |
|---|---|---|
| name | Text | Display name. |
| email | Text | Email address. |

## See also

* [GraphRecipient](./GraphRecipient.md)
* [GoogleMail](./GoogleMail.md)
* [Office365Mail](./Office365Mail.md)
