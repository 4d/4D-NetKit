# GraphMessage Class

## Overview

Represents a single Microsoft Graph mail message.
Extends `_GraphAPI` and is hydrated from a Graph API response via `_loadFromObject`.
Provides lazy-loaded `attachments` via a Graph API call on first access.

## Properties

A `GraphMessage` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text |  |
| attachments | Collection | (read-only) Collection of `GraphAttachment` instances for this message; fetched on first access (lazy) and cached. Note: `hasAttachments` is unreliable for inline-only attachments — the Graph API is always queried regardless (see inline comment for Microsoft docs link). |

## See also

* [GraphMessageList](./GraphMessageList.md)
* [GraphAttachment](./GraphAttachment.md)
* [Office365Mail](./Office365Mail.md)
