# GraphMessageList Class

## Overview

Pageable list of Outlook messages returned by a Graph API query.
The `mails` getter returns the current page as a `Collection` of `GraphMessage` instances.
Each item is wrapped lazily on first access and cached.

## Properties

A `GraphMessageList` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| mails | Collection | (read-only) Current page as a `Collection` of `GraphMessage` instances; computed once and cached until the next page is loaded |

## See also

* [GraphMessage](./GraphMessage.md)
* [Office365Mail](./Office365Mail.md)
