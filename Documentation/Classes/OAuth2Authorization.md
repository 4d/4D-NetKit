# OAuth2Authorization Class

## Overview

Shared singleton HTTP handler for the OAuth2 authorization redirect callback.
Registered as a 4D HTTP handler; receives the redirect from the authorization server
(code or error), resolves the pending `_getAuthorizationCode()` call in Storage,
and returns an HTML response or 302 redirect to the browser.

## Table of Contents

### Functions

* [.getResponse()](#getresponse)

## Functions

### .getResponse()

**.getResponse**( *$request* : 4D.IncomingMessage ) : 4D.OutgoingMessage

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $request | 4D.IncomingMessage | -> | Incoming HTTP request from the browser (redirect from the authorization server with `?code=` or `?error=` query params) |
| Result | 4D.OutgoingMessage | <- | HTML page or 302 redirect on success; 403 when `_authorize` returns `False`; 500 when `$request` is `Null` |

#### Description

Extracts `state` from the URL, calls `_authorize()` to store the
authorization code in `Storage.requests`, and sends the configured
`authenticationPage` or a default HTML response to the browser.

## See also

* [OAuth2Provider](./OAuth2Provider.md)
