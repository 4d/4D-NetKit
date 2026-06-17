# JWT Class

## Overview

The `JWT` class allows you to generate, decode, and validate JSON Web Tokens (JWTs) to authenticate users and secure API calls. JWTs are widely used in modern web authentication systems, including OAuth2 and OpenID Connect.

This class is typically used in three scenarios:

* **Token generation**: Create a signed JWT when a user logs in.
* **Token decoding**: Read and inspect a JWT received from an authentication provider.
* **Token validation**: Verify the JWT's signature and expiration before granting access to protected resources.

This class is instantiated using the `cs.NetKit.JWT.new()` function.

**Note:** Shared objects are not supported by the 4D NetKit API.

## Table of contents

* [cs.NetKit.JWT.new()](#csnetkitjwtnew)
* [JWT.decode()](#jwtdecode)
* [JWT.generate()](#jwtgenerate)
* [JWT.validate()](#jwtvalidate)


## cs.NetKit.JWT.new()

**cs.NetKit.JWT.new** ( *key* : Text or Object ) : `cs.NetKit.JWT`

Creates a new instance of the JWT class.

### Parameters

| Parameter | Type         | Description |
|-----------|--------------|-------------|
| key       | Text/Object  | *Optional.* If text â†’ Key in PEM format.<br>- If object â†’ Must be an object returned by `4D.CryptoKey`.<br>If it's a private key, the public key will be inferred. |

### Example

```4d
var $jwt := cs.NetKit.JWT.new($key)

```

## JWT.decode()

**JWT.decode** ( *token* : Text ) : Object

### Parameters

| Parameter | Type |  | Description         |
|-----------|----- |:---:|----------------- |
| token     | Text |->| JWT string to decode |
| Result    | Object |<-|The decoded content of the JWT |

### Description

Decodes a JWT string and returns its components (header, payload, signature).

### Returned object

The function returns an object containing the following properties:

| Property | Type | Description |
|---|---|---|
|header| Object |Metadata about the token type and the signing algorithm |
|payload| Object |The information (claims) of the token like the user's name, role, user ID, or expiration date.|                                                                          
|signature| Object |Ensures the integrity of the token and verifies the sender's authenticity|

### Example

```4d

var $result := cs.NetKit.JWT.new().decode($token)

```

## JWT.generate()

**JWT.generate** ( *params* : Object { ; *privateKey* : Text or Object } ) : Text

### Parameters

| Parameter | Type | | Description |
|------------|--------|:--:|--------------------------------------------------------------|
| params | Object | ->| Options for the JWT content|
| privateKey | Text/Object | ->| *Optional.* If text â†’ Private key in PEM format.<br>- If object â†’ Must be returned by `4D.CryptoKey`.<br>If omitted, the key passed to `JWT.new()` will be used. |
| Result | Text | <-| The generated JWT token |

### Description

Generates a signed JWT based on the provided parameters and optional private key.

In *params*, you can pass several properties:

| Property |  | Type | Description |
|----------|--|------|-------------|
| header | |Object | *(optional)* Metadata about the token |
| | header.alg |Text |Signing algorithm. Defaults to `"RS256"` if not specified |
| | header.typ |Text | Token type. Defaults to `"JWT"` if not specified|
| payload | | Object | The claims/information you want to include in the token|                                                                                                                    

### Example

```4d

var $params:={header: {alg: "HS256"; typ: "JWT"}}
$params.payload:={sub: "123456789"; name: "John"; exp : 50}

var $token := cs.NetKit.JWT.new().generate($params; $privateKey)

```

## JWT.validate()

**JWT.validate** ( *token* : Text { ; *key* : Text or Object } ) : Boolean

### Parameters

| Parameter | Type | | Description |
|-----------|------|--:|-------------------------------------------------------------|
| token | Text | ->| JWT token to validate |
| key | Text | ->| *Optional.* If text â†’ Private or public key in PEM format.<br>- If object â†’ Must be returned by `4D.CryptoKey`.<br>If omitted, the key passed to `JWT.new()` will be used. |
| Result | Boolean | <-| `True` if the token is valid, `False` otherwise |

### Description

Validates a JWT token using the provided public key or the key passed to the constructor.

The function returns `True` if:
- The token signature is valid.
- The token is not expired (`exp` claim is in the future).

The function returns `False` if:
- The token's signature cannot be verified with the provided key.
- The token has expired.
- The token is malformed.

### Example

```4d

var $isValid:= cs.NetKit.JWT.new().validate($token; $key)

```

## OpenID Connect use case

When using an OAuth2 provider with the `openid` scope, the access token response includes an `id_token` (a JWT). You can use `JWT.decode()` and `JWT.validate()` to inspect and verify the identity information it contains:

```4d
var $provider:={}
$provider.name:="Microsoft"
$provider.permission:="signedIn"
$provider.clientId:="your-client-id"
$provider.redirectURI:="http://127.0.0.1:80/authorize/"
$provider.scope:="openid profile email"
$provider.nonce:="randomNonce456"  // optional custom nonce

var $oauth:=cs.NetKit.OAuth2Provider.new($provider)
var $token:=$oauth.getToken()

// Access the id_token returned with the OpenID response
If ($token.token.id_token#Null)

  // Decode the JWT — header, payload, and signature
  var $openID:=cs.NetKit.JWT.new().decode($token.token.id_token)

  // Verify the nonce to prevent replay attacks
  If ($openID.payload.nonce=$provider.nonce)
    ALERT("Hello "+$openID.payload.name)
  End if

End if
```

## See also

* [OAuth2Provider Class](./OAuth2Provider.md)
* [Google Class](./Google.md)
* [Office365 Class](./Office365.md)


