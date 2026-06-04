# GraphEventList Class

## Overview

Pageable list of calendar events returned by a Graph API query.
The `events` getter returns the current page as a `Collection` of `GraphEvent` instances.
Each item is wrapped lazily on first access and cached.

## Table of Contents

### Initialization

* [cs.NetKit.GraphEventList.new()](#csnetkitgrapheventlistnew)

## **cs.NetKit.GraphEventList.new()**

**cs.NetKit.GraphEventList.new**( *$inCalendar* : cs.Office365Calendar ; *$inURL* : Text ; *$inHeaders* : Object ) : cs.NetKit.GraphEventList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inCalendar | cs.Office365Calendar | -> | The `Office365Calendar` client owning this list (used to resolve `userId` and `calendarId` when hydrating `GraphEvent` instances) |
| $inURL | Text | -> | Initial Graph API URL |
| $inHeaders | Object | -> | Additional HTTP headers |
| Result | cs.NetKit.GraphEventList | <- | Object of the GraphEventList class |

### Properties

The returned `GraphEventList` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| calendarId | Text |  |

