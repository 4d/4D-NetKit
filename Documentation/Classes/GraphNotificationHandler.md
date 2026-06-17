# GraphNotificationHandler Class

## Overview

`GraphNotificationHandler` is a shared singleton HTTP handler for incoming Microsoft Graph change notifications. It is registered at the `/4dnk-graph-notification` route and handles both validation requests and notification payloads, routing them to the appropriate active [GraphNotification](./GraphNotification.md) monitors.

To use push mode with the host web server, add the following entry to `Project/Sources/HTTPHandlers.json`:

```json
[
  {
    "class": "NetKit.GraphNotificationHandler",
    "method": "getResponse",
    "regexPattern": "/4dnk-graph-notification",
    "verbs": "post"
  }
]
```

> **Notes:**
> - The 4D Web Server must be [launched in TLS 1.2](https://developer.4d.com/docs/commands/set-database-parameter#min-tls-version-105) to comply with the Microsoft Graph server requirements.
> - If the OAuth 2.0 connection uses an HTTPS redirect URI, the port in the `endPoint` must match exactly.
> - If both a `calendar.notifier` and a `mail.notifier` are declared, they must use the same port.

## Table of Contents

### Functions

* [.getResponse()](#getresponse)

## Functions

### .getResponse()

**.getResponse**( *request* : 4D.IncomingMessage ) : 4D.OutgoingMessage

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| request | 4D.IncomingMessage | -> | Incoming HTTP request from Microsoft Graph. |
| Result | 4D.OutgoingMessage | <- | HTTP 200 + `validationToken` for validation requests; HTTP 202 for notification payloads; HTTP 400 when `request` is `Null`. |

#### Description

`.getResponse()` handles two types of incoming requests from Microsoft Graph:

1. **Validation** — `POST ?validationToken=<token>`: Microsoft sends this to verify the endpoint. The response must echo the token as plain text with status 200.
2. **Notification** — `POST` with JSON body containing `{value: [...]}` array: routes each item to the matching [GraphNotification](./GraphNotification.md) monitor via `Storage.graphNotifications`.

## See also

* [GraphNotification](./GraphNotification.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
