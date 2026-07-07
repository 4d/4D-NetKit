# OAuth2Authorization Class

## Overview

`OAuth2Authorization` is the HTTP handler class that intercepts the OAuth2 authorization redirect callback when the host's web server is used as the redirect endpoint.

In [`OAuth2Provider`](./OAuth2Provider.md) `"signedIn"` mode, after the user authenticates in the browser, the authorization server redirects back to the `redirectURI` with a `?code=` (or `?error=`) query parameter. `OAuth2Authorization` handles that incoming request, extracts the authorization code, stores it for the pending `getToken()` call, and returns a confirmation page to the browser.

> This class is only required when the **host's web server** handles the redirect. If you use the 4D NetKit built-in server (e.g. `redirectURI` on port `50993`), no handler registration is needed. See [Web server for redirect URI](./OAuth2Provider.md#web-server-for-redirect-uri) for details on which server is used.

## Table of Contents

### Functions

* [.getResponse()](#getresponse)

## Setup

To register `OAuth2Authorization` as an HTTP handler, add the following entry to `Project/Sources/HTTPHandlers.json` in the host project:

```json
[
  {
    "class": "4D.NetKit.OAuth2Authorization",
    "method": "getResponse",
    "regexPattern": "/authorize",
    "verbs": "get"
  }
]
```

> You can use any `regexPattern` that matches the path in your `redirectURI`. The example above uses `/authorize`. For more information, see [HTTP Handlers](https://developer.4d.com/docs/WebServer/http-request-handler).

The `redirectURI` in your provider configuration must point to the same path:

```4d
$param.redirectURI:="http://127.0.0.1/authorize/"   // uses host web server (default port 80)
$param.redirectURI:="http://127.0.0.1:8080/authorize/"  // uses host web server (port 8080)
```

## Functions

### .getResponse()

**.getResponse**( *$request* : 4D.IncomingMessage ) : 4D.OutgoingMessage

#### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| $request | 4D.IncomingMessage | -> | Incoming HTTP request from the browser, containing the `?code=` or `?error=` query parameters set by the authorization server. |
| Result | 4D.OutgoingMessage | <- | HTML response shown in the browser: the configured `authenticationPage` on success, `authenticationErrorPage` on failure, or built-in default pages if none are configured. Returns HTTP 403 when authorization is rejected, HTTP 500 when `$request` is `Null`. |

#### Description

`.getResponse()` is called automatically by the web server when the authorization server redirects the browser back to the `redirectURI` after user authentication.

The method:
1. Extracts the `state` parameter from the URL query string to identify the pending request.
2. Stores the received authorization code in `Storage` so the waiting `getToken()` call can consume it.
3. Returns the appropriate HTML page to the browser.

You should never call this method directly. Register it as an HTTP handler (see [Setup](#setup)) and let the web server invoke it.

#### Example

After registering the handler, configure the `redirectURI` to point to your host web server:

```4d
var $param:=New object
$param.name:="Microsoft"
$param.permission:="signedIn"
$param.clientId:="your-client-id"
$param.redirectURI:="http://127.0.0.1/authorize/"  // host web server on default port
$param.scope:="https://graph.microsoft.com/.default"

var $oAuth2:=cs.NetKit.OAuth2Provider.new($param)
var $token:=$oAuth2.getToken()  // opens browser; OAuth2Authorization.getResponse() handles the callback
```

## See also

* [OAuth2Provider](./OAuth2Provider.md)
* [OAuth2Token](./OAuth2Token.md)

