# GoogleMailIdList Class

## Overview

Paginated list of Gmail message identifiers returned by the Gmail
`users.messages.list` endpoint. Exposes the raw message-id objects (each with
`id` and `threadId`) via the `mailIds` getter; use `next()` / `previous()`
inherited from `_BaseList` to navigate pages.

## Properties

A `GoogleMailIdList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| mailIds | Collection | (read-only) Returns the raw list items from the current page as delivered by the API; call `next()` to advance to the following page |

## See also

* [GoogleMail](./GoogleMail.md)
