# JWT Class

## Overview

The `JWT` class allows you to generate, decode, and validate JSON Web Tokens (JWTs) to authenticate users and secure API calls. JWTs are widely used in modern web authentication systems, including OAuth2 and OpenID Connect.

This class is typically used in three scenarios:

* **Token generation**: Create a signed JWT when a user logs in.
* **Token decoding**: Read and inspect a JWT received from an authentication provider.
* **Token validation**: Verify the JWT’s signature and expiration before granting access to protected resources.

This class is instantiated using the `cs.NetKit.JWT.new()` function.

**Note:** Shared objects are not supported by the 4D NetKit API.

## Table of contents

* [cs.NetKit.JWT.new()](#csnetkitjwtnew)
* [JWT.decode()](#jwtdecode)
* [JWT.generate()](#jwtgenerate)
* [JWT.validate()](#jwtvalidate)


## cs.NetKit.JWT.new()

**cs.NetKit.JWT.new()** : `cs.NetKit.JWT`

Creates a new instance of the JWT class.

### Example

```4d
var $jwt := cs.NetKit.JWT.new()
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
|signature| Object |Ensures the integrity of the token and verifies the sender’s authenticity|

### Example

```4d

var $result := cs.NetKit.JWT.new().decode($token)

```

## JWT.generate()

**JWT.generate** ( *params* : Object ; *privateKey* : Text ) : Text

### Parameters

| Parameter | Type | | Description |
|------------|--------|:--:|--------------------------------------------------------------|
| params | Object | ->| Options for the JWT content|
| privateKey | Text | ->| Private key used to sign the JWT |
| Result | Text | <-| The generated JWT token |

### Description

Generates a signed JWT based on the provided parameters and private key.

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

**JWT.validate** ( *token* : Text ; *key* : Text ) : Boolean

### Parameters

| Parameter | Type | | Description |
|-----------|------|--:|-------------------------------------------------------------|
| token | Text | ->| JWT token to validate |
| key | Text | ->| Public key or shared secret used to verify the signature |
| Result | Boolean | <-| `True` if the token is valid, `False` otherwise |

### Description

Validates a JWT token using the provided public key or shared secret.

### Example

```4d

var $isValid:= cs.NetKit.JWT.new().validate($token; $key)

```
## See also

* [OAuth2Provider Class](./OAuth2Provider.md)
* [Google Class](./Google.md)
* [Office365 Class](./Office365.md)
* [Interactive JWT Debugger](https://jwt.io/)


