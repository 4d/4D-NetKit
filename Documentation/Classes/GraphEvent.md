# GraphEvent Class

## Overview

Represents a single Microsoft Graph calendar event.
Extends `_GraphAPI` and is hydrated from a Graph API response via `_loadFromObject`.
Provides lazy-loaded `attachments` via a Graph API call on first access
(only when `hasAttachments` is `True`).

## Properties

A `GraphEvent` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text:="" |  |
| hasAttachments | Boolean:=False |  |
| attachments | Collection | (read-only) Collection of `GraphAttachment` instances for this event; fetched on first access (lazy) and cached. Only fetched when `hasAttachments` is `True`. See inline comment for the supported Graph endpoint variants. |

## See also

* [GraphEventList](./GraphEventList.md)
* [GraphAttachment](./GraphAttachment.md)
* [Office365Calendar](./Office365Calendar.md)
