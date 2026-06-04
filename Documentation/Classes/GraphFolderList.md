# GraphFolderList Class

## Overview

Pageable list of Outlook mail folders returned by a Graph API query.
The `folders` getter returns the list as a `Collection` of plain objects.

## Table of Contents

### Initialization

* [cs.NetKit.GraphFolderList.new()](#csnetkitgraphfolderlistnew)

## **cs.NetKit.GraphFolderList.new()**

**cs.NetKit.GraphFolderList.new**( *$inProvider* : cs.OAuth2Provider ; *$inURL* : Text ; *$inHeaders* : Object ) : cs.NetKit.GraphFolderList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inURL | Text | -> | Initial Graph API URL |
| $inHeaders | Object | -> | Additional HTTP headers |
| Result | cs.NetKit.GraphFolderList | <- | Object of the GraphFolderList class |

