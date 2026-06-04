# GraphEvent Class

## Overview

Represents a single Microsoft Graph calendar event.
Extends `_GraphAPI` and is hydrated from a Graph API response via `_loadFromObject`.
Provides lazy-loaded `attachments` via a Graph API call on first access
(only when `hasAttachments` is `True`).

## Table of Contents

### Initialization

* [cs.NetKit.GraphEvent.new()](#csnetkitgrapheventnew)

## **cs.NetKit.GraphEvent.new()**

**cs.NetKit.GraphEvent.new**( *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ; *$inObject* : Object ) : cs.NetKit.GraphEvent

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inParameters | Object | -> | Context options: - `userId` {Text} — Graph user ID or UPN (used when fetching attachments) - `calendarId` {Text} — Calendar ID (used when building the attachment URL) |
| $inObject | Object | -> | Raw Graph API event object to hydrate from |
| Result | cs.NetKit.GraphEvent | <- | Object of the GraphEvent class |

### Properties

The returned `GraphEvent` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text |  |
| hasAttachments | Boolean |  |

