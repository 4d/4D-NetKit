# 4D NetKit

## Overview
4D NetKit is a built-in 4D component that allows you to interact with third-party web services and their APIs, such as [Microsoft Graph](https://docs.microsoft.com/en-us/graph/overview).

## Table of contents

* [OAuth2Provider](#OAuth2Provider-class)
* [Tutorial : Authenticate to the Microsoft Graph API with 4D Netkit, and send an email using the SMTP Transporter class](#tutorial--authenticate-to-the-microsoft-graph-api-with-4d-netkit-and-send-an-email-using-the-smtp-transporter-class)

## OAuth2Provider

Inside the 4D NetKit component, the `New OAuth2 provider` method returns an object which is an instance of the `OAuth2Provider` [class](https://developer.4d.com/docs/en/Concepts/classes.html). 

The `OAuth2Provider` class allows you to request authentication tokens to third-party web services providers in order to use their APIs in your application. This is done in two steps:

1. Using the `New OAuth2 provider` component method, you instantiate an object of the `OAuth2Provider` class that holds authentication information.
2. You call the `OAuth2ProviderObject.getToken()` class function to retrieve a token from the web service provider.

Here's a diagram of the authorization process:
![authorization-flow](Documentation/Assets/authorization.png)

### **New OAuth2 provider**

**New OAuth2 provider**( *paramObj* : Object ) : Object

#### Parameters 
|Parameter|Type||Description|
|---------|--- |:---:|------|
|paramObj|Object|->| determines the properties of the object to be returned |
|Result|Object|<-| object of the OAuth2Provider class

#### Description
`New OAuth2 provider` instantiates an object of the `OAuth2Provider` class.

In `paramObj`, pass an object that contains authentication information.

The returned object's properties correspond to those of the `paramObj` object passed as a parameter. 

The available properties of `paramObj` are:

|Parameter|Type|Description|Can be Null or undefined|
|---------|--- |------|------|
| name | text | Name of the provider. Currently, the only provider available is "Microsoft". |No
| permission | text | <ul><li> "signedIn": Azure AD will sign in the user and ensure they gave their consent for the permissions your app requests (opens a web browser).</li><li>"service": the app calls Microsoft Graph [with its own identity](https://docs.microsoft.com/en-us/graph/auth-v2-service) (access without a user).</li></ul>|No
| clientId | text | The client ID assigned to the app by the registration portal.|No
| redirectURI | text | (Not used in service mode) The redirect_uri of your app, the location where the authorization server sends the user once the app has been successfully authorized. When you call the `.getToken()` class function, a web server included in 4D NetKit is started on the port specified in this parameter to intercept the provider's authorization response.|No in signedIn mode, Yes in service mode
| scope | text or collection | text: A space-separated list of the Microsoft Graph permissions that you want the user to consent to.</br> collection: Collection of Microsoft Graph permissions. |No
| tenant | text | The {tenant} value in the path of the request can be used to control who can sign into the application. The allowed values are: <ul><li>"common" for both Microsoft accounts and work or school accounts </li><li>"organizations" for work or school accounts only </li><li>"consumers" for Microsoft accounts only</li><li>tenant identifiers such as tenant ID or domain name.</li></ul> Default is "common". |Yes
| authenticateURI | text | Uri used to do the Authorization request. By default: "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/authorize". |Yes
| tokenURI | text | Uri used to request an access token. By default: "https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token". |Yes
| clientSecret | text | The application secret that you created for your app in the app registration portal. Required for web apps. |Yes
| token | object | If this property exists, the `getToken()` function uses this token object to calculate which request must be sent. It is automatically updated with the token received by the `getToken()` function.   |Yes
| timeout|real| Waiting time in seconds (by default 120s).|Yes

### OAuth2ProviderObject.getToken()

**OAuth2ProviderObject.getToken()** : Object

|Parameter|Type||Description|
|---------|--- |------|------|
|Result|Object|<-| Object that holds information on the token retrieved


#### Description 

`.getToken()` returns an object that contains a `token` property (as defined by the [IETF](https://datatracker.ietf.org/doc/html/rfc6749#section-5.1)), as well as optional additional information returned by the server:

Property|Object properties|Type|Description |
|--- |---------| --- |------|
|token||object| Token returned |
|| expires_in | text | How long the access token is valid (in seconds). |
|| access_token | text | The requested access token. |
|| refresh_token | text | Your app can use this token to acquire additional access tokens after the current access token expires. Refresh tokens are long-lived, and can be used to retain access to resources for extended periods of time. Available only if the value of the `permission` property is "signedIn". |
|| token_type | text | Indicates the token type value. The only token type that Azure AD supports is "Bearer". |
||scope|text| A space separated list of the Microsoft Graph permissions that the access_token is valid for.|
|tokenExpiration || text | Timestamp (ISO 8601 UTC) that indicates the expiration time of the token|

If the value of `token` is empty, the command sends a request for a new token.

If the token has expired: 
*   If the token object has the `refresh_token` property, the command sends a new request to refresh the token and returns it.
*   If the token object does not have the `refresh_token` property, the command automatically sends a request for a new token. 

When requesting access on behalf of a user ("signedIn" mode) the command opens a web browser to request authorization.

In "signedIn" mode, when `.getToken()` is called, a web server included in 4D NetKit starts automatically on the port specified in the [redirectURI parameter](#description) to intercept the provider's authorization response and display in the browser.

# Tutorials

## Authenticate to the Microsoft Graph API with 4D Netkit in service mode

### Objectives
Establish a connection to the Microsoft Graph API in service mode

### Prerequisites

* You have registered an application with the [Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) and obtained your application ID (also called client ID) and client secret.

> Here, the term "application" does not refer to an application built in 4D. It refers to an entry point you create on the Azure portal. You use the generated client ID to tell your 4D application to trust the Microsoft identity platform.

### Steps

Once you have your client ID and client secret, you're ready to establish a connection to your Azure application.

1. Open your 4D application, create a method and insert the following code:

```4d
var $oAuth2 : Object
var $token : Object

$param:=New object()
$param.name:="Microsoft"
$param.permission:="service"

$param.clientId:="your-client-id" // Replace with the client ID you obtained on the Microsoft identity platform
$param.clientSecret:="your-client-secret" // Replace with your client secret
$param.tenant:="your-tenant-id" // Replace with your tenant ID
$param.tokenURI:="https://login.microsoftonline.com/your-tenant-id/oauth2/v2.0/token/" // Replace the tenant ID
$param.scope:="https://graph.microsoft.com/.default"

$oAuth2:=New OAuth2 provider($param)

$token:=$oAuth2.getToken()
```

2. Execute the method to establish the connection.

## Authenticate to the Microsoft Graph API in signedIn mode and send an email with SMTP

### Objectives 

Establish a connection to the Microsoft Graph API in signedIn mode, and send an email using the [SMTP Transporter class](http://developer.4d.com/docs/fr/API/SMTPTransporterClass.html).

In this example, we get access [on behalf of a user](https://docs.microsoft.com/en-us/graph/auth-v2-user).

### Prerequisites

* You have registered an application with the [Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) and obtained your application ID (also called client ID).

> Here, the term "application" does not refer to an application built in 4D. It refers to an entry point you create on the Azure portal. You use the generated client ID to tell your 4D application to trust the Microsoft identity platform.

* You have a Microsoft e-mail account. For example, you signed up for an e-mail account with Microsoft's webmail services designated domains (@hotmail.com, @outlook.com, etc.).

### Steps

Once you have your client ID, you're ready to establish a connection to your Azure application and send an email:

1. Open your 4D application, create a method and insert the following code:

```4d

var $oAuth2; $token; $param; $email : Object
var $address : Text

// Configure authentication

$param:=New object
$param.name:="Microsoft"
$param.permission:="signedIn"
$param.clientId:="your-client-id" // Replace with the client id you obtained on the Microsoft identity platform 
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:="https://outlook.office.com/SMTP.Send" // Get consent for sending an smtp email

// Instantiate an object of the OAuth2Provider class

$oAuth2:=New OAuth2 provider($param)

// Request a token using the class function

$token:=$oAuth2.getToken() // Sends a token request and starts the a web server on the port specified in $param.redirectURI to intercept the authorization response

// Set the email address for SMTP configuration 

$address:= "email-sender-address@outlook.fr" // Replace with your Microsoft email account address

// Set the email's content and metadata

$email:=New object
$email.subject:="My first mail"
$email.from:=$address
$email.to:="email-recipient-address@outlook.fr" // Replace with the recipient's email address
$email.textBody:="Test mail \r\n This is just a test e-mail \r\n Please ignore it"

// Configure the SMTP connection

$parameters:=New object
$parameters.accessTokenOAuth2:=$token
$parameters.authenticationMode:=SMTP authentication OAUTH2
$parameters.host:="smtp.office365.com"
$parameters.user:=$address

// Send the email 

$smtp:=SMTP New transporter($parameters)
$statusSend:=$smtp.send($email)

```

2. Execute the method. Your browser opens a page that allows you to authenticate.

3. Log in to your Microsoft Outlook account and check that you've received the email.
