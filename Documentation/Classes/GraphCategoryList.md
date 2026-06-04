# GraphCategoryList Class

## Overview

Pageable list of Outlook master categories returned by a Graph API query.
The `categories` getter returns the list as a `Collection` of plain objects.

## Table of Contents

### Initialization

* [cs.NetKit.GraphCategoryList.new()](#csnetkitgraphcategorylistnew)

## **cs.NetKit.GraphCategoryList.new()**

**cs.NetKit.GraphCategoryList.new**( *$inProvider* : cs.OAuth2Provider ; *$inURL* : Text ; *$inHeaders* : Object ) : cs.NetKit.GraphCategoryList

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inURL | Text | -> | Initial Graph API URL |
| $inHeaders | Object | -> | Additional HTTP headers |
| Result | cs.NetKit.GraphCategoryList | <- | Object of the GraphCategoryList class |


## See also

* [Office365Category](./Office365Category.md)
