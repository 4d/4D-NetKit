# GoogleEventList Class

## Overview

Paginated list of Google Calendar events returned by the
`events.list` endpoint. Wraps each raw event object into a `GoogleEvent`
instance on first access via the `events` getter (lazy, cached);
use `next()` / `previous()` inherited from `_BaseList` to navigate pages.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleEventList.new()](#csnetkitgoogleeventlistnew)

## **cs.NetKit.GoogleEventList.new()**

**cs.NetKit.GoogleEventList.new**( *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ) : cs.NetKit.GoogleEventList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider used for token retrieval |
| $inParameters | Object | -> | `_GoogleBaseList` parameters object; pass at minimum `{url: Text}` pointing to the `events.list` endpoint. Top-level response properties (`kind`, `etag`, `summary`, etc.) are forwarded automatically when listed in `$inParameters.attributes`. |
| Result | cs.NetKit.GoogleEventList | <- | Object of the GoogleEventList class |

### Properties

The returned `GoogleEventList` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| kind | Text |  |
| etag | Text |  |
| summary | Text |  |
| calendarId | Text |  |
| description | Text |  |
| updated | Text |  |
| timeZone | Text |  |
| accessRole | Text |  |
| defaultReminders | Collection |  |

