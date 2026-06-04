# Office365Category Class

## Overview

Microsoft Graph API client for managing Outlook master categories.
Wraps the `/outlook/masterCategories` endpoint.

## Table of Contents

### Initialization

* [cs.NetKit.Office365Category.new()](#csnetkitoffice365categorynew)

## **cs.NetKit.Office365Category.new()**

**cs.NetKit.Office365Category.new**( *$inProvider* : cs.OAuth2Provider ; *$inParameters* : Object ) : cs.NetKit.Office365Category

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inProvider | cs.OAuth2Provider | -> | OAuth2 provider for authenticating requests |
| $inParameters | Object | -> | Configuration object; recognised properties: - `userId` {Text} — Graph user ID or UPN; defaults to `""` (uses `me` endpoint) |
| Result | cs.NetKit.Office365Category | <- | Object of the Office365Category class |

### Properties

The returned `Office365Category` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| userId | Text |  |

