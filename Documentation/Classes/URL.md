# URL Class

## Overview

The `URL` class parses and manipulates URL strings according to RFC 3986.

It can read URL components, manage query parameters, and serialize values back to string or object.

This class is instantiated by calling `cs.URL.new()`.

**Note:** Shared objects are not supported by the 4D NetKit API.

## Table of contents

* [cs.URL.new()](#csurlnew)
* [URL.parse()](#urlparse)
* [URL.parseQuery()](#urlparsequery)
* [URL.addQueryParameter()](#urladdqueryparameter)
* [URL.removeQueryParameter()](#urlremovequeryparameter)
* [URL.toString()](#urltostring)
* [URL.toJSON()](#urltojson)
* [URL.fromJSON()](#urlfromjson)
* [URL.isValid()](#urlisvalid)
* [URL.isAbsolute()](#urlisabsolute)
* [URL properties](#url-properties)

## cs.URL.new()

**cs.URL.new** ( *inParam* : Variant ) : `cs.URL`

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| inParam | Variant | -> | URL as text, or object representation. |
| Result | cs.URL | <- | A `URL` instance. |

### Example

```4d
var $url : cs.URL:=cs.URL.new("https://user:pass@example.com:8080/path?page=1#section")
```

## .parse()

**.parse** ( *inURL* : Text )

### Description

Parses a full URL string and populates URL properties.

## .parseQuery()

**.parseQuery** ( *inQueryString* : Text )

### Description

Parses a query string and updates `queryParams`.

## .addQueryParameter()

**.addQueryParameter** ( ... : Variant )

### Description

Adds a query parameter using one of these forms:
- object `{name; value}`
- text `"name=value"`
- pair `("name"; "value")`

### Example

```4d
var $url : cs.URL:=cs.URL.new("https://api.example.com/users")
$url.addQueryParameter("top"; "50")
$url.addQueryParameter("search"; "john")
```

## .removeQueryParameter()

**.removeQueryParameter** ( *paramName* : Text { ; *removeAll* : Boolean } ) : Boolean

### Description

Removes one or all matching parameters by name.

## .toString()

**.toString**() : Text

### Description

Rebuilds the full URL string from object properties.

### Example

```4d
var $url : cs.URL:=cs.URL.new("https://example.com/calendar/events?page=2")
$url.removeQueryParameter("page")
$url.addQueryParameter("page"; "3")

var $result : Text:=$url.toString()
```

## .toJSON()

**.toJSON**() : Object

### Description

Returns an object representation of the current URL.

## .fromJSON()

**.fromJSON** ( *inURL* : Object )

### Description

Loads URL properties from an object representation.

## .isValid()

**.isValid**() : Boolean

### Description

Returns `True` when URL has a valid scheme and host.

## .isAbsolute()

**.isAbsolute**() : Boolean

### Description

Returns `True` when URL has a scheme.

## URL properties

| Property | Type | Description |
|---|---|---|
| scheme | Text | Protocol (`http`, `https`, ...). |
| username | Text | User info username. |
| password | Text | User info password. |
| host | Text | Hostname or IP. |
| port | Integer | Explicit or default port for scheme. |
| path | Text | URL path. |
| query | Text | Query string built from `queryParams`. |
| queryParams | Collection | Collection of `{name; value}` query entries. |
| ref | Text | Fragment (`#...`). |

## See also

* [OAuth2Provider](./OAuth2Provider.md)
* [GoogleCalendar](./GoogleCalendar.md)
* [Office365Calendar](./Office365Calendar.md)

