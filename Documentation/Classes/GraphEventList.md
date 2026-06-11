# GraphEventList Class

## Overview

Pageable list of calendar events returned by a Graph API query.
The `events` getter returns the current page as a `Collection` of `GraphEvent` instances.
Each item is wrapped lazily on first access and cached.

## Properties

A `GraphEventList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| calendarId | Text |  |
| events | Collection | (read-only) Current page as a `Collection` of `GraphEvent` instances; computed once and cached until the next page is loaded |

## See also

* [GraphEvent](./GraphEvent.md)
* [Office365Calendar](./Office365Calendar.md)
