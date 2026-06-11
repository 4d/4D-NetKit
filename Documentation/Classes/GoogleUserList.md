# GoogleUserList Class

## Overview

Paginated list of Google People API contacts returned by the
`people.connections.list` endpoint. Exposes the raw person objects via the
`users` getter; use `next()` / `previous()` inherited from `_BaseList`
to navigate pages.

## Properties

A `GoogleUserList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| users | Collection | (read-only) Returns the person objects from the current page as delivered by the API; call `next()` to advance to the following page |

## See also

* [GoogleUser](./GoogleUser.md)
