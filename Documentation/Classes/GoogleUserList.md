# GoogleUserList Class

## Overview

Paginated list of Google People API contacts returned by the
`people.connections.list` endpoint. Exposes the raw person objects via the
`users` getter; use `next()` / `previous()` inherited from `_BaseList`
to navigate pages.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleUserList.new()](#csnetkitgoogleuserlistnew)

## **cs.NetKit.GoogleUserList.new()**

**cs.NetKit.GoogleUserList.new**( *$inProvider* : cs.OAuth2Provider ; *$inURL* : Text ; *$inHeaders* : Object ) : cs.NetKit.GoogleUserList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider used for token retrieval |
| $inURL | Text | -> | Full URL of the People API list endpoint (including query parameters such as `personFields`, `pageSize`, etc.) |
| $inHeaders | Object | -> | Additional HTTP headers to include in each request (e.g. `{"X-Goog-Request-Reason": "..."}`) |
| Result | cs.NetKit.GoogleUserList | <- | Object of the GoogleUserList class |

