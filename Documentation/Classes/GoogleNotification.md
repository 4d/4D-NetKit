# GoogleNotification Class

## Overview

Represents a Google notification monitor for Gmail or Calendar changes.
Supports push (Pub/Sub for mail, webhook for calendar) and pull (polling) modes;
call `start()` to begin monitoring and `stop()` to end it.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleNotification.new()](#csnetkitgooglenotificationnew)

### Properties

* [endPoint](#endpoint)
* [expiration](#expiration)
* [isStarted](#isstarted)
* [timer](#timer)

### Functions

* [GoogleNotification.start()](#googlenotificationstart)
* [GoogleNotification.stop()](#googlenotificationstop)

## **cs.NetKit.GoogleNotification.new()**

**cs.NetKit.GoogleNotification.new**( *$inType* : Text ; *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ; *$inResource* : Text ; *$inOwner* : Object ) : cs.NetKit.GoogleNotification

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inType | Text | -> | Notification type: `"mail"` (Gmail) or `"event"` (Google Calendar) |
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for token retrieval; determines the base URL (`gmail.googleapis.com` or `www.googleapis.com/calendar`) |
| $inParameters | Object | -> | Configuration object; recognised properties: - `onCreate`, `onDelete`, `onModify` {4D.Function} — Change-event callbacks - `endPoint` {Text} — Webhook URL for Calendar push mode - `topicName` {Text} — Google Cloud Pub/Sub topic name for Gmail push mode - `labelIds` {Collection} — Gmail label filter for push mode - `timer` {Integer} — Polling interval in seconds for pull mode (default: 30) |
| $inResource | Text | -> | Resource to monitor: Gmail user ID (mail mode) or calendar ID (event mode) |
| $inOwner | Object | -> | Parent `GoogleMail` or `GoogleCalendar` instance; forwarded to callbacks as context |
| Result | cs.NetKit.GoogleNotification | <- | Object of the GoogleNotification class |

### Properties

The returned `GoogleNotification` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint *(read-only)* | Text | The webhook endpoint URL configured for push mode; empty string when in pull mode or not yet configured |
| expiration *(read-only)* | Text | Expiration timestamp in milliseconds since epoch (as Text); empty string when not started or when the subscription has no expiration |
| isStarted *(read-only)* | Boolean | True when the notification monitor is currently active |
| timer *(read-only)* | Integer | Polling interval in seconds used in pull mode |

### GoogleNotification.start()

**GoogleNotification.start**() : Object

#### Description

Starts change notifications for Gmail or Google Calendar in either
push or pull mode; see inline documentation for mode-specific details

### GoogleNotification.stop()

**GoogleNotification.stop**() : Object

#### Description

Stops the notification monitor, cleans up all internal state;
in push mode also stops the Gmail watch or Calendar channel on the Google API

