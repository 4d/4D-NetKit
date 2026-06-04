# GraphMessage Class

## Overview

Represents a single Microsoft Graph mail message.
Extends `_GraphAPI` and is hydrated from a Graph API response via `_loadFromObject`.
Provides lazy-loaded `attachments` via a Graph API call on first access.

## Table of Contents

### Initialization

* [cs.NetKit.GraphMessage.new()](#csnetkitgraphmessagenew)

### Properties

* [id](#id)

## **cs.NetKit.GraphMessage.new()**

**cs.NetKit.GraphMessage.new**( *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ; *$inObject* : Object ) : cs.NetKit.GraphMessage

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inParameters | Object | -> | Context options: - `mailType` {Text} — `"Microsoft"` (default), `"JMAP"`, or `"MIME"` - `userId` {Text} — Graph user ID or UPN (used when fetching attachments) |
| $inObject | Object | -> | Raw Graph API message object to hydrate from |
| Result | cs.NetKit.GraphMessage | <- | Object of the GraphMessage class |

### Properties

The returned `GraphMessage` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text |  |

