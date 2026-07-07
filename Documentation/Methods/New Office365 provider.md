# New Office365 provider

**New Office365 provider**( *paramObj* : Object { ; *param* : Object } ) : cs.NetKit.Office365

## Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|paramObj|cs.NetKit.OAuth2Provider|->| Object of the OAuth2Provider class  |
|param|Object|->| Additional options |
|Result|cs.NetKit.Office365|<-| Object of the Office365 class|

## Description

`New Office365 provider` instantiates an object of the [`Office365`](../Classes/Office365.md) class.

In *paramObj*, pass an [OAuth2Provider object](../Classes/OAuth2Provider.md#oauth2provider-class).

In *param*, you can pass an object that specifies the following options:

|Property|Type|Description|
|---------|---|------|
|mailType|Text|Indicates the Mail type to use to send and receive emails. Possible types are: <br/>- "MIME"<br/>- "JMAP"<br/>- "Microsoft" (default)|

## Returned object

The returned `Office365` object contains the following properties:

|Property||Type|Description|
|----|-----|---|------|
|mail||Object|Email handling object|
||send()|Function|Sends the emails|
||type|Text|(read-only) Mail type used to send and receive emails. Default is "Microsoft", can bet set using the `mailType` option|
||userId|Text|User identifier, used to identify the user in Service mode. Can be the `id` or the `userPrincipalName`|


## Example 1

To create the OAuth2 connection object and an Office365 object:

```4d
var $oAuth2: cs.NetKit.OAuth2Provider
var $office365 : cs.NetKit.Office365

$oAuth2:=New OAuth2 provider($param)
$office365:=New Office365 provider($oAuth2;New object("mailType"; "Microsoft"))
```

## Example 2

Refer to [this tutorial](../Tutorial.md#authenticate-to-the-microsoft-graph-api-in-service-mode) for an example of connection in Service mode.

## See also

[Office365 class](../Classes/Office365.md)<br/>
[New OAuth2 provider](./New%20OAuth2%20provider.md)
