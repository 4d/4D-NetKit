# OAuth2Token Class

## Overview

Wraps an OAuth2 access token and its expiration timestamp.
Can be constructed from a parameter object, a raw JSON response string,
or a URL-encoded response string.

## Table of Contents

### Initialization

* [cs.NetKit.OAuth2Token.new()](#csnetkitoauth2tokennew)

## **cs.NetKit.OAuth2Token.new()**

**cs.NetKit.OAuth2Token.new**( *$inParams* : Object ) : cs.NetKit.OAuth2Token

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $inParams | Object | -> | Optional initial token data: - `token` {Object} — Token object (e.g. `{access_token; refresh_token; expires_in}`) - `tokenExpiration` {Text} — ISO 8601 expiration timestamp; computed from `expires_in` when absent |
| Result | cs.NetKit.OAuth2Token | <- | Object of the OAuth2Token class |

### Properties

The returned `OAuth2Token` object contains the following properties:

| Property | Type | Description |
|---|---|---|
| token | Object |  |
| tokenExpiration | Text |  |


## See also

* [OAuth2Provider](./OAuth2Provider.md)
