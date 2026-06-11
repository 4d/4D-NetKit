# GoogleNotification Class

## Overview

Represents a Google notification monitor for Gmail or Calendar changes.
Supports push (Pub/Sub for mail, webhook for calendar) and pull (polling) modes;
call `start()` to begin monitoring and `stop()` to end it.

## Table of Contents

### Functions

* [.start()](#start)
* [.stop()](#stop)

## Properties

A `GoogleNotification` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| endPoint | Text | (read-only) The webhook endpoint URL configured for push mode; empty string when in pull mode or not yet configured |
| expiration | Text | (read-only) Expiration timestamp in milliseconds since epoch (as Text); empty string when not started or when the subscription has no expiration |
| isStarted | Boolean | (read-only) True when the notification monitor is currently active |
| timer | Integer | (read-only) Polling interval in seconds used in pull mode |

## Functions

### .start()

**.start**() : Object

#### Description

Starts change notifications for Gmail or Google Calendar in either
push or pull mode; see inline documentation for mode-specific details

### .stop()

**.stop**() : Object

#### Description

Stops the notification monitor, cleans up all internal state;
in push mode also stops the Gmail watch or Calendar channel on the Google API

## See also

* [GoogleNotificationHandler](./GoogleNotificationHandler.md)
* [GoogleCalendar](./GoogleCalendar.md)
* [GoogleMail](./GoogleMail.md)
