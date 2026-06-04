# GraphMessageList Class

## Overview

Pageable list of Outlook messages returned by a Graph API query.
The `mails` getter returns the current page as a `Collection` of `GraphMessage` instances.
Each item is wrapped lazily on first access and cached.

## Table of Contents

### Initialization

* [cs.NetKit.GraphMessageList.new()](#csnetkitgraphmessagelistnew)

## **cs.NetKit.GraphMessageList.new()**

**cs.NetKit.GraphMessageList.new**( *$inMail* : cs.Office365Mail ; *$inProvider* : cs.OAuth2Provider ; *$inURL* : Text ; *$inHeaders* : Object ) : cs.NetKit.GraphMessageList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inMail | cs.Office365Mail | -> | The `Office365Mail` client owning this list (used to resolve `userId` when hydrating `GraphMessage` instances) |
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inURL | Text | -> | Initial Graph API URL |
| $inHeaders | Object | -> | Additional HTTP headers |
| Result | cs.NetKit.GraphMessageList | <- | Object of the GraphMessageList class |

