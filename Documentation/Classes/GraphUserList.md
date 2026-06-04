# GraphUserList Class

## Overview

Pageable list of Azure AD users returned by a Graph API query.
The `users` getter returns the list as a `Collection` of plain objects.

## Table of Contents

### Initialization

* [cs.NetKit.GraphUserList.new()](#csnetkitgraphuserlistnew)

## **cs.NetKit.GraphUserList.new()**

**cs.NetKit.GraphUserList.new**( *$inProvider* : cs.OAuth2Provider ; *$inURL* : Text ; *$inHeaders* : Object ) : cs.NetKit.GraphUserList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inURL | Text | -> | Initial Graph API URL |
| $inHeaders | Object | -> | Additional HTTP headers |
| Result | cs.NetKit.GraphUserList | <- | Object of the GraphUserList class |

