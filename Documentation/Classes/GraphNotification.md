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

### Functions

* [.start()](#start)
* [.stop()](#stop)

## Properties

A `GraphNotification` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | (read-only) Webhook URL configured at construction (`""` in pull mode) |
| expiration | Text | (read-only) ISO 8601 expiration date/time of the current Graph subscription; empty string in pull mode or before `start()` is called |
| isStarted | Boolean | (read-only) `True` when monitoring is active |
| timer | Integer | (read-only) Pull polling interval in seconds (default 30; pull mode only) |

## Functions

### .start()

**.start**() : Object

#### Description

Starts change notifications.
- **Push mode** (`endPoint` set): creates a Graph subscription via
`POST /subscriptions`; starts a background worker monitoring loop
- **Pull mode** (no `endPoint`): immediately starts the polling worker loop

No-op when already started. See inline comment for full mode description.

### .stop()

**.stop**() : Object

#### Description

Stops change notifications:
- **Push mode**: deletes the Graph subscription via `DELETE /subscriptions/{id}`;
kills the monitor worker; cleans up Storage
- **Pull mode**: signals the polling worker to stop; kills it; cleans up Storage

No-op when not started. See inline comment for details.

## See also

* [GraphNotificationHandler](./GraphNotificationHandler.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365Mail](./Office365Mail.md)
