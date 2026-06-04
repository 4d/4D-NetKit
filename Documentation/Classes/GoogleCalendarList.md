# GoogleCalendarList Class

## Overview

Paginated list of Google Calendar entries returned by the
`calendarList.list` endpoint. Exposes the raw calendar objects via the
`calendars` getter; use `next()` / `previous()` inherited from `_BaseList`
to navigate pages.

## Table of Contents

### Initialization

* [cs.NetKit.GoogleCalendarList.new()](#csnetkitgooglecalendarlistnew)

## **cs.NetKit.GoogleCalendarList.new()**

**cs.NetKit.GoogleCalendarList.new**( *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ) : cs.NetKit.GoogleCalendarList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider used for token retrieval |
| $inParameters | Object | -> | `_GoogleBaseList` parameters object; pass at minimum `{url: Text}` pointing to the `calendarList.list` endpoint |
| Result | cs.NetKit.GoogleCalendarList | <- | Object of the GoogleCalendarList class |


## See also

* [GoogleCalendar](./GoogleCalendar.md)
