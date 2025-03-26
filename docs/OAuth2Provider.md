# OAuth2Provider Class

## Overview

The `OAuth2Provider` class allows you to request authentication tokens to third-party web services providers in order to use their APIs in your application. This is done in two steps:

1. Using the `New OAuth2 provider` component method, you instantiate an object of the `OAuth2Provider` class that holds authentication information.
2. You call the `OAuth2ProviderObject.getToken()` class function to retrieve a token from the web service provider.

Here's a diagram of the authorization process:
![authorization-flow](Assets/authorization.png)

This class can be instantiated in two ways:
* by calling the `New OAuth2 provider` method
* by calling the `cs.NetKit.OAuth2Provider.new()` function


**Warning:** OAuth2 authentication in `signedIn` mode requires a browser. Since some servers have restrictions regarding the supported browsers (for example, check this [Google support](https://support.google.com/accounts/answer/7675428?hl=en) page), the functionality may not work properly.

**Warning:** Shared objects are not supported by the 4D NetKit API.


## Table of contents

- [New OAuth2 provider](#new-oauth2-provider)
- [OAuth2ProviderObject.getToken()](#oauth2providerobjectgettoken)




## **New OAuth2 provider**

**New OAuth2 provider**( *paramObj* : Object ) : cs.NetKit.OAuth2Provider

### Parameters

|Parameter|Type||Description|
|---------|--- |:---:|------|
|paramObj|Object|->| Determines the properties of the object to be returned |
|Result|cs.NetKit.OAuth2Provider|<-| Object of the OAuth2Provider class|

### Description

`New OAuth2 provider` instantiates an object of the `OAuth2Provider` class.

In `paramObj`, pass an object that contains authentication information.


The available properties of `paramObj` are:

|Parameter|Type|Description|Optional|
|---------|--- |------|------|
| name | text | Name of the provider. Available values: "Microsoft", "Google" or "" (if "" or undefined/null attribute, the authenticateURI and the tokenURI need to be filled by the 4D developer).|Yes
| permission | text |- "signedIn": Azure AD/Google will sign in the user and ensure they gave their consent for the permissions your app requests (opens a web browser).<br/>- service": the app calls [Microsoft Graph with its own identity](https://docs.microsoft.com/en-us/graph/auth-v2-service)/Google (access without a user).|No
| clientId | text | The client ID assigned to the app by the registration portal.|No
| redirectURI | text | (Not used in service mode) The redirect_uri of your app, the location where the authorization server sends the user once the app has been successfully authorized. When you call the `.getToken()` class function, a web server included in 4D NetKit is started on the port specified in this parameter to intercept the provider's authorization response.|No in signedIn mode, Yes in service mode
| scope | text or collection | Text: A space-separated list of the Microsoft Graph permissions that you want the user to consent to.</br> Collection: Collection of Microsoft Graph permissions. |Yes
| tenant | text | Microsoft: The {tenant} value in the path of the request can be used to control who can sign into the application. The allowed values are: - "common" for both Microsoft accounts and work or school accounts (default value)<br/>- "organizations" for work or school accounts only <br/>- "consumers" for Microsoft accounts only<br/>- tenant identifiers such as tenant ID or domain name.<br/>Google (service mode only): Email address to be considered as the email address of the user for which the application is requesting delegated access. |Yes
| authenticateURI | text | Uri used to do the Authorization request.<br/> Default for Microsoft: "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize".<br/> Default for Google: "https://accounts.google.com/o/oauth2/auth". |Yes
| tokenURI | text | Uri used to request an access token.<br/> Default for Microsoft: "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token".<br/> Default for Google: "https://accounts.google.com/o/oauth2/token".|Yes
|tokenExpiration | text | Timestamp (ISO 8601 UTC) that indicates the expiration time of the token.| Yes
| clientSecret | text | The application secret that you created for your app in the app registration portal. Required for web apps. |Yes
| token | object | If this property exists, the `getToken()` function uses this token object to calculate which request must be sent. It is automatically updated with the token received by the `getToken()` function.   |Yes
| timeout|real| Waiting time in seconds (by default 120s).|Yes
|    prompt   | text |(Optional) A space-delimited, case-sensitive list of prompts to present the user.<br/><br/>Possible values are:<br/>- none: Do not display any authentication or consent screens. Must not be specified with other values.<br/>- consent: Prompt the user for consent.<br/>- select_account: Prompt the user to select an account.<br/>(if you don't specify this parameter, the user will be prompted only the first time your project requests access. )|Yes|
|  loginHint  | text | (Optional) This option can be used to inform the Google Authentication Server which user is attempting to authenticate if your application is aware of this information. By prefilling the email field in the sign-in form or by selecting the appropriate multi-login session, the server uses the hint to simplify the login flow either.<br/> Set the parameter value to a sub-identifier or email address that corresponds to the user's Google ID.                                                                                       |Yes|
|  accessType | text | (Recommended) Indicates whether your application can refresh access tokens when the user is not present at the browser.<br/> Valid parameter values are online (default) and offline.<br/> Set the value to offline if your application needs to update access tokens when the user is not present at the browser. This is how access tokens are refreshed. This value instructs the Google authorization server to return a refresh token and an access token the first time that your application exchanges an authorization code for tokens. |Yes|
| clientEmail | text | (mandatory, Google / service mode only)  email address of the service account used                                                                                                                                                                                                                                                                                                                                                                                                                                                            |No|
| authenticationPage|text or file object|Path of the web page to display in the web browser when the authentication code is received correctly in signed in mode (If not present the default page is used).|Yes
| authenticationErrorPage	|text or file object| Path of the web page to display in the web browser when the authentication server returns an error in signed in mode (If not present the default page is used).|Yes
| PKCEEnabled |boolean| false by default. If true, PKCE is used for OAuth 2.0 authentication and token requests and is only usable for permission=”SignIn”. |Yes
| PKCEMethod |text | "S256" by default. The only supported values for this parameter are "S256" or "plain". |Yes
| thumbprint |text | Certificate thumbprint. Only usable with permission="Service" | Yes (No for certificate based authentication)
| privateKey | text | Certificate private key. Only usable with permission="Service".<br/>(Google / service mode only)  Private key given by Google. Mandatory if .permission="service" and .name="Google" | Yes (No for certificate based authentication)                                                                                                                                                                                                                                                                                                                                                                                                                
| clientAssertionType | text | The format of the assertion as defined by the authorization server. The value is an absolute URI. Default value: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer". Only usable with permission="Service"	|Yes
| browserAutoOpen | boolean | True (default value), the web browser is open automatically. Pass false if you don't want the web browser to open automatically. |Yes

If you want the .getToken() function to use the Assertion Framework described in the RFC 7521 to connect to the server, make sure to pass the `thumbprint` and `privateKey` properties. If `clientSecret`,  `thumbprint` and `privateKey` are present, the `thumbprint` is used by default and the RFC 7521 is used to connect. For more information, please refer to the [OAuth2.0 authentication using a certificate](#https://blog.4d.com/) blog post.

**Note:**  The `authenticationPage` and `authenticationErrorPage` and all the resources associated must be in the same folder.

### Returned object

The OAuth2 provider returned object `cs.NetKit.OAuth2Provider` properties correspond to those of the [`paramObj` object passed as a parameter](#description) and some additional properties:

|Property|Type|Description|
|----|-----|------|
|*paramObj.properties*||< properties passed in parameter [`paramObj`](#description)>|
|authenticateURI|text|Returns the calculated authenticateURI. Can be used in a webbrowser or in a web area to open the connection page.|
|isTokenValid	|Function| `OAuth2Provider.isTokenValid() : boolean` <br/> Verifies the token validity. <br/>- If no token is present, returns false.<br/>- If the current token is not expired, returns true. <br/>- If the token is expired and no refresh token is present, returns false.<br/>- If a refresh token is present, automatically requests a new token and returns true if the token is generated correctly, otherwise false.|

### Example 1

```4d

//authentication into google account and token retrieval

var $File1; $File2 : 4D.File
var $oAuth2 : cs.NetKit.OAuth2Provider
var $param: Object

$File1:=File("/RESOURCES/OK.html")
$File2:=File("/RESOURCES/KO.html")

$param:= New object
$param.name:="Google"
$param.permission:="signedIn"
$param.clientId:="xxxx"
$param.clientSecret:="xxxx"
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:="https://www.googleapis.com/auth/gmail.send"
$param.authenticationPage:=$File1
$param.authenticationErrorPage:=$File2
// Create new OAuth2 object
$oAuth2:=cs.NetKit.OAuth2Provider.new($param)
// Ask for a token
$token:=$oAuth2.getToken()

```
### Example 2

```4d

//Google account authentication using PKCE

var $credential:={}
// google
$credential.name:="Google"
$credential.permission:="signedIn"
$credential.clientId:="499730xxx"
$credential.clientSecret:="fc1kwxxx"
$credential.redirectURI:="http://127.0.0.1:50993/authorize/"
$credential.scope:="https://mail.google.com/"
// PKCE activation
$credential.PKCEEnabled:=True

var $oauth2:=cs.NetKit.OAuth2Provider.new($credential)
var $token:=Try($oauth2.getToken())
if ($token=null)
  ALERT("Error: "+Last errors[0].message)
end if

```

### Example 3

```4d

// Initial authentication with Microsoft OAuth2 and retrieval of token with refresh token

// Define OAuth2 provider details for Microsoft
$provider:=New object()
$provider.name:="Microsoft"
$provider.permission:="signedIn"
$provider.clientId:="xxx-xxx-xxx-xxx-c460fc"
$provider.redirectURI:="http://127.0.0.1:50993/authorize/"
$provider.scope:="https://graph.microsoft.com/.default"

// Use the "offline" parameter to request a refresh token in addition to the regular access token
$provider.accessType:="offline"

// Create new OAuth2 object for Microsoft
$OAuth:= cs.NetKit.OAuth2Provider.new ($provider)

// Request the token, which includes the refresh token
var $myCurrentToken : Object := $OAuth.getToken()

// After receiving the token and refresh token, save it for future token requests
```


```4d
#DECLARE($myCurrentToken : object)
var $provider:=New object()
$provider.name:="Microsoft"
$provider.permission:="signedIn"
$provider.clientId:="xxx-xxx-xxx-xxx-c460fc"
$provider.redirectURI:="http://127.0.0.1:50993/authorize/"
$provider.scope:="https://graph.microsoft.com/.default"

// Include the token from the previous request
$provider.token:=$myCurrentToken

// Re-create OAuth2 object with the stored token
$OAuth:= cs.NetKit.OAuth2Provider.new ($provider)

// getToken() checks if the token has expired
// If the token is still valid, it returns the current token
// If the token has expired, it automatically requests a new one
// If a refresh token is present, the token is automatically renewed without user sign-in
// If no refresh token is available, the user will need to sign in again
$myCurrentToken:=$OAuth.getToken()

```

**Note**: Some servers, like Google, do not always return the refresh token during subsequent token requests. In such cases, you should remember to include the refresh token in the token object before saving it for future use.

## OAuth2ProviderObject.getToken()

**OAuth2ProviderObject.getToken()** : Object

|Parameter|Type||Description|
|---------|--- |------|------|
|Result|Object|<-| Object that holds information on the token retrieved


### Description

`.getToken()` returns an object that contains a `token` property (as defined by the [IETF](https://datatracker.ietf.org/doc/html/rfc6749#section-5.1)), as well as optional additional information returned by the server:

Property|Object properties|Type|Description |
|--- |---------| --- |------|
|token||Object| Token returned |
|| expires_in | Text | How long the access token is valid (in seconds). |
|| access_token |Ttext | The requested access token. |
|| refresh_token | Text | Your app can use this token to acquire additional access tokens after the current access token expires. Refresh tokens are long-lived, and can be used to retain access to resources for extended periods of time. Available only if the value of the `permission` property is "signedIn". |
|| token_type | Text | Indicates the token type value. The only token type that Azure AD supports is "Bearer". |
||scope|Text| A space separated list of the Microsoft Graph permissions that the access_token is valid for.|
|tokenExpiration || Text | Timestamp (ISO 8601 UTC) that indicates the expiration time of the token|

If the value of `token` is empty, the command sends a request for a new token.

If the token has expired:
*   If the token object has the `refresh_token` property, the command sends a new request to refresh the token and returns it.
*   If the token object does not have the `refresh_token` property, the command automatically sends a request for a new token.

When requesting access on behalf of a user ("signedIn" mode) the command opens a web browser to request authorization.

In "signedIn" mode, when `.getToken()` is called, a web server included in 4D NetKit starts automatically on the port specified in the [redirectURI parameter](#description) to intercept the provider's authorization response and display it in the browser.


## See also

[Google Class](./Google.md)
[Office365 Class](./Office365.md)