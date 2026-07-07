# Google Class

## Overview

The `Google` class is the entry point for accessing Google APIs in 4D NetKit. It is a facade that exposes three lazily-instantiated API clients:

* [`mail`](./GoogleMail.md) — send, read, and manage Gmail messages and labels
* [`user`](./GoogleUser.md) — read Google user profiles (People API)
* [`calendar`](./GoogleCalendar.md) — manage Google calendars and events

Each client is instantiated on first access and reused for subsequent calls.

These operations can be performed after a valid token request (see [OAuth2Provider](./OAuth2Provider.md#oauth2provider-class)).

The `Google` class is instantiated by calling the [`cs.NetKit.Google.new()`](#csnetkitgooglenew) function.

**Warning:** Shared objects are not supported by the 4D NetKit API.


## Table of Contents

- [cs.NetKit.Google.new()](#csnetkitgooglenew)
- [Returned object](#returned-object)
- [See also](#see-also)


## **cs.NetKit.Google.new()**

**cs.NetKit.Google.new**( *oAuth2* : cs.NetKit.OAuth2Provider { ; *param* : Object } ) : cs.NetKit.Google

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|oAuth2|cs.NetKit.OAuth2Provider|->| Object of the OAuth2Provider class  |
|param|Object|->| Additional options |
|Result|cs.NetKit.Google|<-| Object of the Google class|

### Description

`cs.NetKit.Google.new()` instantiates an object of the `Google` class.

In `oAuth2`, pass an [OAuth2Provider object](./OAuth2Provider.md#oauth2provider-class).

In `param`, you can pass an object that specifies the following options:

|Property|Type|Description|
|---------|---|------|
|mailType|Text|Mail type used to send and receive emails. Possible values are: <br/>- "JMAP" (default)<br/>- "MIME"|
|userId|Text|User identifier, used to identify the user in Service mode. Can be the `id` or the `userPrincipalName`. Defaults to `"me"`.|

### Returned object

The returned `Google` object exposes the following properties, each giving access to a dedicated API client:

|Property|Type|Description|
|----|---|------|
|mail|[GoogleMail](./GoogleMail.md)|Gmail API client: send, read, delete, and manage messages and labels.|
|user|[GoogleUser](./GoogleUser.md)|Google People API client: read user profiles.|
|calendar|[GoogleCalendar](./GoogleCalendar.md)|Google Calendar API client: manage calendars and events.|

### Example

To create the OAuth2 connection object and a Google object:

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $google : cs.NetKit.Google

$oAuth2:=New OAuth2 provider($param)
$google:=cs.NetKit.Google.new($oAuth2; {mailType: "MIME"})
```


## See also

[GoogleMail](./GoogleMail.md)<br/>
[GoogleUser](./GoogleUser.md)<br/>
[GoogleCalendar](./GoogleCalendar.md)<br/>
[OAuth2Provider](./OAuth2Provider.md#oauth2provider-class)<br/>
