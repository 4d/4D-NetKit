# GraphNotificationHandler Class

## Overview

Shared singleton HTTP handler for incoming Microsoft Graph change notifications.
Registered at `/4dnk-graph-notification`; handles both validation requests
(responds with `validationToken`) and notification payloads (routes to monitors via
`Storage.graphNotifications`).

## Table of Contents

### Functions

* [.getResponse()](#getresponse)

## Functions

### .getResponse()

**.getResponse**( *$request* : 4D.IncomingMessage ) : 4D.OutgoingMessage

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $request | 4D.IncomingMessage | -> | Incoming HTTP request from Microsoft Graph |
| Result | 4D.OutgoingMessage | <- | HTTP 200 + `validationToken` for validation requests; HTTP 202 for notification payloads; HTTP 400 when `$request` is `Null` |

#### Description

Two types of requests are handled:
1. **Validation** — `POST ?validationToken=<token>`; response must echo the token as
plain text with status 200
2. **Notification** — `POST` with JSON body containing `{value: [...]}` array;
routes each item to the matching monitor via `_processNotificationBody`

See inline comment for the Graph webhook protocol reference.

## See also

* [GraphNotification](./GraphNotification.md)
