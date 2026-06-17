# GraphNotification Class

## Overview

`GraphNotification` manages Microsoft Graph change notifications for mail messages or calendar events. It supports two modes:

- **Push** (webhook): Creates a [Microsoft Graph subscription](https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions) and receives real-time notifications. Automatically renews the subscription before expiration. The webhook URL is derived as `{endPoint}/4dnk-graph-notification?state={uuid}`.
- **Pull** (delta query): Polls the [delta endpoint](https://learn.microsoft.com/en-us/graph/delta-query-messages) at a configurable interval. No external endpoint needed.

A `GraphNotification` object is obtained by calling [`.notifier()`](./Office365Calendar.md#notifier) on an `Office365Calendar` object, or [`.notifier()`](./Office365Mail.md#notifier) on an `Office365Mail` object. Call `start()` to begin monitoring and `stop()` to end it.

Callbacks (`onCreate`, `onDelete`, `onModify`) are dispatched in the 4D worker where `.start()` was originally called. The subscription is automatically closed when the notifier object is destroyed.

## Table of Contents

### Functions

* [.start()](#start)
* [.stop()](#stop)

## Properties

A `GraphNotification` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | (read-only) Webhook URL configured at construction. Empty string in pull mode. |
| expiration | Text | (read-only) ISO 8601 expiration date/time of the current Graph subscription. Empty string in pull mode or before `start()` is called. |
| isStarted | Boolean | (read-only) `true` when monitoring is active. |
| timer | Integer | (read-only) Pull polling interval in seconds (default: 30; pull mode only). |

## Functions

### .start()

**.start**() : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Object | <- | Status object with `success` (Boolean), `statusText` (Text), and `errors` (Collection). |

#### Description

`.start()` activates change notifications.

- **Push mode** (`endPoint` set): creates a Graph subscription via `POST /subscriptions`; starts a background worker monitoring loop that renews the subscription before expiration.
- **Pull mode** (no `endPoint`): immediately starts the polling worker loop using delta queries.

No-op when already started.

### .stop()

**.stop**() : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Object | <- | Status object with `success` (Boolean), `statusText` (Text), and `errors` (Collection). |

#### Description

`.stop()` stops change notifications.

- **Push mode**: deletes the Graph subscription via `DELETE /subscriptions/{id}`; kills the monitor worker; cleans up Storage.
- **Pull mode**: signals the polling worker to stop; kills it; cleans up Storage.

No-op when not started.

#### Example

Calendar notifications via delta polling every 60 seconds (pull mode):

```4d
$calNotif:=$office365.calendar.notifier({ \
    timer: 60; \
    onCreate: Formula(handleNewEvent($1; $2)); \
    onModify: Formula(handleEventUpdate($1; $2)) \
})
$status:=$calNotif.start()

// Stop monitoring
$status:=$calNotif.stop()
```

Mail notifications via webhook (push mode):

```4d
var $notif:=$office365.mail.notifier({ \
    endPoint: "https://myserver.com"; \
    onCreate: Formula(ALERT("New mail: "+String($2.ids))); \
    onDelete: Formula(ALERT("Mail deleted: "+String($2.ids))) \
})
$status:=$notif.start()
```

## See also

* [GraphNotificationHandler](./GraphNotificationHandler.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
