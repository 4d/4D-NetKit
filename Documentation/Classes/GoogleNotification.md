# GoogleNotification Class

## Overview

`GoogleNotification` represents a change notification monitor for Gmail or Google Calendar. It supports two modes:

- **Push** (webhook): Real-time notifications via HTTP callbacks. Requires a publicly accessible HTTPS endpoint.
- **Pull** (polling): Periodic polling of change APIs. No external endpoint needed.

A `GoogleNotification` object is obtained by calling [`.notifier()`](./GoogleCalendar.md#notifier) on a `GoogleCalendar` object, or [`.notifier()`](./GoogleMail.md#notifier) on a `GoogleMail` object. Call `start()` to begin monitoring and `stop()` to end it.

## Table of Contents

### Functions

* [.start()](#start)
* [.stop()](#stop)

## Properties

A `GoogleNotification` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | (read-only) The webhook endpoint URL configured for push mode. Empty string when in pull mode or not yet configured. |
| expiration | Text | (read-only) Expiration timestamp of the current subscription. Empty string when not started or when the subscription has no expiration. |
| isStarted | Boolean | (read-only) `true` when the notification monitor is currently active. |
| timer | Integer | (read-only) Polling interval in seconds used in pull mode. |

## Functions

### .start()

**.start**() : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Object | <- | Status object with `success` (Boolean), `statusText` (Text), and `errors` (Collection). |

#### Description

`.start()` activates change notifications for Gmail or Google Calendar in either push or pull mode, and fills the `expiration` property.

- In **push mode**, registers a webhook subscription with Google.
- In **pull mode**, begins polling the Google API at the configured `timer` interval.

Callbacks (`onCreate`, `onDelete`, `onModify`) are dispatched in the 4D worker where `.start()` was originally called.

### .stop()

**.stop**() : Object

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| Result | Object | <- | Status object with `success` (Boolean), `statusText` (Text), and `errors` (Collection). |

#### Description

`.stop()` stops the notification monitor, cleans up all internal state, and clears the `expiration` property. In push mode, it also cancels the Gmail watch or Calendar channel subscription on the Google API.

## See also

* [GoogleNotificationHandler](./GoogleNotificationHandler.md)
* [GoogleCalendar](./GoogleCalendar.md)
* [GoogleMail](./GoogleMail.md)
* [Google](./Google.md)
