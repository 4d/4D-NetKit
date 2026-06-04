# GraphNotification Class

## Overview

Manages Microsoft Graph change notifications for mail messages or calendar events.
Supports two modes:
- **Push** (webhook): creates a Graph subscription and receives real-time notifications;
automatically renews the subscription before expiration
- **Pull** (delta query): polls the delta endpoint at a configurable interval

Mail pull mode uses three per-changeType delta streams; calendar/event pull mode uses
one delta stream with a `knownIds` cache to classify changes.

## Table of Contents

### Initialization

* [cs.NetKit.GraphNotification.new()](#csnetkitgraphnotificationnew)

### Properties

* [endPoint](#endpoint)
* [expiration](#expiration)
* [isStarted](#isstarted)
* [timer](#timer)

### Functions

* [GraphNotification.start()](#graphnotificationstart)
* [GraphNotification.stop()](#graphnotificationstop)

## **cs.NetKit.GraphNotification.new()**

**cs.NetKit.GraphNotification.new**( *$inType* : Text ; *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ; *$inResource* : Text ; *$inUserId* : Text ; *$inOwner* : Object ) : cs.NetKit.GraphNotification

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inType | Text | -> | Resource type: `"mail"` or `"event"`; used to build callback event type names (e.g. `"mailCreated"`, `"eventModified"`) |
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inParameters | Object | -> | Notification options: - `onCreate` {4D.Function} — Callback when an item is created - `onDelete` {4D.Function} — Callback when an item is deleted - `onModify` {4D.Function} — Callback when an item is modified - `endPoint` {Text} — Webhook URL (push mode); omit for pull mode - `pullInterval` {Integer} — Polling interval in seconds (pull mode; default 30) |
| $inResource | Text | -> | Graph resource path (e.g. `"me/mailFolders/inbox/messages"`) |
| $inUserId | Text | -> | Graph user ID or UPN (forwarded to the owner client) |
| $inOwner | Object | -> | The `Office365Mail` or `Office365Calendar` client that created this notification; forwarded to callbacks |
| Result | cs.NetKit.GraphNotification | <- | Object of the GraphNotification class |

### Properties

The returned `GraphNotification` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint *(read-only)* | Text | Webhook URL configured at construction (`""` in pull mode) |
| expiration *(read-only)* | Text | ISO 8601 expiration date/time of the current Graph subscription; empty string in pull mode or before `start()` is called |
| isStarted *(read-only)* | Boolean | `True` when monitoring is active |
| timer *(read-only)* | Integer | Pull polling interval in seconds (default 30; pull mode only) |

### GraphNotification.start()

**GraphNotification.start**() : Object

#### Description

Starts change notifications.
- **Push mode** (`endPoint` set): creates a Graph subscription via
`POST /subscriptions`; starts a background worker monitoring loop
- **Pull mode** (no `endPoint`): immediately starts the polling worker loop

No-op when already started. See inline comment for full mode description.

### GraphNotification.stop()

**GraphNotification.stop**() : Object

#### Description

Stops change notifications:
- **Push mode**: deletes the Graph subscription via `DELETE /subscriptions/{id}`;
kills the monitor worker; cleans up Storage
- **Pull mode**: signals the polling worker to stop; kills it; cleans up Storage

No-op when not started. See inline comment for details.

