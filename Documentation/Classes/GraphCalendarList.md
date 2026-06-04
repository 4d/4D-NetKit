# GraphCalendarList Class

## Overview

Pageable list of Outlook calendars returned by a Graph API query.
The `calendars` getter returns the list as a `Collection` of plain objects.

## Table of Contents

### Initialization

* [cs.NetKit.GraphCalendarList.new()](#csnetkitgraphcalendarlistnew)

## **cs.NetKit.GraphCalendarList.new()**

**cs.NetKit.GraphCalendarList.new**( *$inProvider* : cs.OAuth2Provider ; *$inURL* : Text ; *$inHeaders* : Object ) : cs.NetKit.GraphCalendarList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inURL | Text | -> | Initial Graph API URL |
| $inHeaders | Object | -> | Additional HTTP headers |
| Result | cs.NetKit.GraphCalendarList | <- | Object of the GraphCalendarList class |

