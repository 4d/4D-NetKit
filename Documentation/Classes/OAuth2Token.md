# OAuth2Token Class

## Overview

An `OAuth2Token` object wraps an OAuth2 access token and its expiration timestamp. It is returned by [`OAuth2ProviderObject.getToken()`](./OAuth2Provider.md#oauth2providerobjectgettoken) and can be stored and reused to avoid prompting the user to authenticate on every API call.

When passed back to a provider via its `token` property, `getToken()` uses the existing token to determine which request to send — refreshing silently if a `refresh_token` is present, or opening a new authentication flow if not.

## Properties

An `OAuth2Token` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| token | Object | Token returned by the server. Contains the sub-properties listed below. |
| tokenExpiration | Text | Timestamp (ISO 8601 UTC) indicating when the access token expires. |

### token sub-properties

| Property | Type | Description |
|---|---|---|
| access_token | Text | The requested access token. Use this value in the `Authorization: Bearer` header when calling protected APIs. |
| expires_in | Text | How long the access token is valid, in seconds. |
| refresh_token | Text | Token that can be used to acquire a new access token without user interaction after the current one expires. Only returned when `permission` is `"signedIn"` and `accessType` is `"offline"`. |
| token_type | Text | Token type. Azure AD always returns `"Bearer"`. |
| scope | Text | Space-separated list of permissions the `access_token` is valid for. |
| id_token | Text | Identity token for OpenID Connect requests. Present only when the `openid` scope was requested. Can be decoded using the [JWT class](./JWT.md). |

## Usage

The token object is designed to be persisted and reused across sessions. Pass it back to the provider via the `token` property before calling `getToken()` to skip unnecessary authentication flows:

```4d
// Persist token after first authentication
$user.token:=$oauth2.getToken()
$user.save()

// On subsequent calls, reuse the stored token
var $provider:={}
$provider.name:="Microsoft"
$provider.permission:="signedIn"
$provider.clientId:="your-client-id"
$provider.redirectURI:="http://127.0.0.1:50993/authorize/"
$provider.scope:="https://graph.microsoft.com/.default"
$provider.accessType:="offline"
$provider.token:=$user.token  // reuse stored token

var $oauth2:=cs.NetKit.OAuth2Provider.new($provider)

// isTokenValid() will refresh silently if a refresh_token is present
If (Not($oauth2.isTokenValid()))
  var $token:=$oauth2.getToken()
  If ($token#Null)
    $user.token:=$token
    $user.save()
  End if
End if
```

> **Note:** Some providers (e.g. Google) do not always return a new `refresh_token` on subsequent token requests. Make sure to preserve the original `refresh_token` when updating the stored token object.

## See also

* [OAuth2Provider](./OAuth2Provider.md)
* [JWT](./JWT.md)

