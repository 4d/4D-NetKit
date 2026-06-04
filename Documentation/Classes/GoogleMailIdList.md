# GoogleMailIdList Class

## Overview

Paginated list of Gmail message identifiers returned by the Gmail
`users.messages.list` endpoint. Exposes the raw message-id objects (each with
`id` and `threadId`) via the `mailIds` getter; use `next()` / `previous()`
inherited from `_BaseList` to navigate pages.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleMailIdList.new()](#csnetkitgooglemailidlistnew)

## **cs.NetKit.GoogleMailIdList.new()**

**cs.NetKit.GoogleMailIdList.new**( *$inProvider* : cs.OAuth2Provider ; *$inURL* : Text ) : cs.NetKit.GoogleMailIdList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider used for token retrieval |
| $inURL | Text | -> | Full URL of the Gmail messages list endpoint (including query parameters such as `q`, `maxResults`, etc.) |
| Result | cs.NetKit.GoogleMailIdList | <- | Object of the GoogleMailIdList class |

