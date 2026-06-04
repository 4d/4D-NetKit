# GoogleNotificationHandler Class

## Overview

Shared singleton HTTP handler for incoming Google push notifications.
Registered as a 4D HTTP handler at `/4dnk-google-notification`; routes Calendar
webhook requests and Gmail Pub/Sub push messages to the appropriate active
`GoogleNotification` monitors via `Storage.googleNotifications`.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleNotificationHandler.new()](#csnetkitgooglenotificationhandlernew)

### Functions

* [GoogleNotificationHandler.getResponse()](#googlenotificationhandlergetresponse)

## **cs.NetKit.GoogleNotificationHandler.new()**

**cs.NetKit.GoogleNotificationHandler.new**() : cs.NetKit.GoogleNotificationHandler

### GoogleNotificationHandler.getResponse()

**GoogleNotificationHandler.getResponse**( *$request* : 4D.IncomingMessage ) : 4D.OutgoingMessage

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $request | 4D.IncomingMessage | -> | Incoming HTTP request from Google |
| Result | 4D.OutgoingMessage | <- | HTTP 200 response on success; HTTP 400 when `$request` is `Null` |

#### Description

Handles two types of incoming push notifications:
- Calendar webhook: identified by `X-Goog-Channel-Token` header; routes
to `_processCalendarNotification`
- Gmail Pub/Sub: JSON body with `message.data` (base64 encoded); routes
to `_processGmailNotification`
See inline documentation for the expected payload formats

