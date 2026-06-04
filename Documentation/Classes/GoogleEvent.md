# GoogleEvent Class

## Overview

Represents a Google Calendar event. All top-level properties from the
Calendar API event resource are mapped directly onto `This`; the `attachments`
array is converted to a collection of `GoogleEventAttachment` instances.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleEvent.new()](#csnetkitgoogleeventnew)

## **cs.NetKit.GoogleEvent.new()**

**cs.NetKit.GoogleEvent.new**( *$inObject* : Object ) : cs.NetKit.GoogleEvent

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inObject | Object | -> | Raw event object from the Calendar API response; all top-level properties except `attachments` are copied as-is onto `This`; `attachments` items are wrapped into `GoogleEventAttachment` instances |
| Result | cs.NetKit.GoogleEvent | <- | Object of the GoogleEvent class |

### Properties

The returned `GoogleEvent` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text |  |
| attachments | Collection |  |


## See also

* [GoogleEventList](./GoogleEventList.md)
* [GoogleEventAttachment](./GoogleEventAttachment.md)
* [GoogleCalendar](./GoogleCalendar.md)
