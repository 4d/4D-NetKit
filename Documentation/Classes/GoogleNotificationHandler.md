# GoogleNotificationHandler Class

## Overview

`GoogleNotificationHandler` is a shared singleton HTTP handler for incoming Google push notifications. It is registered as a 4D HTTP handler at the `/4dnk-google-notification` route, and routes incoming webhook requests to the appropriate active [GoogleNotification](./GoogleNotification.md) monitor.

To use push mode with the host web server, add the following entry to `Project/Sources/HTTPHandlers.json`:

```json
[
  {
    "class": "NetKit.GoogleNotificationHandler",
    "method": "getResponse",
    "regexPattern": "/4dnk-google-notification",
    "verbs": "post"
  }
]
```

> If the OAuth 2.0 connection uses an HTTPS redirect URI, the port in the `endPoint` must match exactly. If both a `calendar.notifier` and a `mail.notifier` are declared, they must use the same port.

## Table of Contents

### Functions

* [.getResponse()](#getresponse)

## Functions

### .getResponse()

**.getResponse**( *request* : 4D.IncomingMessage ) : 4D.OutgoingMessage

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| request | 4D.IncomingMessage | -> | Incoming HTTP request from Google. |
| Result | 4D.OutgoingMessage | <- | HTTP 200 response on success; HTTP 400 when `request` is `Null`. |

#### Description

`.getResponse()` handles two types of incoming push notifications:

- **Calendar webhook**: identified by the `X-Goog-Channel-Token` header; routed to the calendar notification processor.
- **Gmail Pub/Sub**: JSON body with `message.data` (base64 encoded); routed to the Gmail notification processor.

The handler dispatches the corresponding callbacks (`onCreate`, `onDelete`, `onModify`) defined in the active [GoogleNotification](./GoogleNotification.md) monitors via `Storage.googleNotifications`.

## See also

* [GoogleNotification](./GoogleNotification.md)
* [GoogleCalendar](./GoogleCalendar.md)
* [GoogleMail](./GoogleMail.md)
* [Google](./Google.md)
