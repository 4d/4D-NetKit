# Tutorials


4D NetKit is a built-in 4D component that allows you to interact with third-party web services and their APIs, such as [Microsoft Graph](https://docs.microsoft.com/en-us/graph/overview).

## Table of contents

* [Authenticate to the Microsoft Graph API in service mode](#authenticate-to-the-microsoft-graph-api-in-service-mode)
* (Archived) [Authenticate to the Microsoft Graph API in signedIn mode (4D NetKit), then send an email (SMTP Transporter class)](#authenticate-to-the-microsoft-graph-api-in-signedin-mode-and-send-an-email-with-smtp)


**Warning:** Shared objects are not supported by the 4D NetKit API.

## Authenticate to the Microsoft Graph API in service mode

### Objectives

Establish a connection to the Microsoft Graph API in service mode.

### Prerequisites

* You have registered an application with the [Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) and obtained your application ID (also called client ID) and client secret.

> Here, the term "application" does not refer to an application built in 4D. It refers to an entry point you create on the Azure portal. You use the generated client ID to tell your 4D application to trust the Microsoft identity platform.

### Steps

Once you have your client ID and client secret, you're ready to establish a connection to your Azure application.

1. Open your 4D application, create a method and insert the following code:

```4d
var $oAuth2 : cs.NetKit.OAuth2Provider
var $office365 : cs.NetKit.Office365

var $credential:={}
$credential.name:="Microsoft"
$credential.permission:="service"

$credential.clientId:="your-client-id" //Replace with your Microsoft identity platform client ID
$credential.clientSecret:="your-client-secret" //Replace with your client secret
$credential.tenant:="your-tenant-id" // Replace with your tenant ID
$credential.scope:="https://graph.microsoft.com/.default"

$oAuth2:=New OAuth2 provider($credential)

$office365:=$cs.NetKit.Office365.new($oAuth2; {mailType: "MIME"})
// In service mode, you need to indicate on behalf of which user you are sending the request:
$office365.mail.userId:="MyUserPrincipalName"
// Get mails of MyUserPrincipalName account
$mailList:=$office365.mail.getMails()

```

2. Execute the method to establish the connection.

## (Archived) Authenticate to the Microsoft Graph API in signedIn mode and send an email with SMTP

> This tutorial has been archived. We recommend using the [Office365.mail.send()](./Office365.md#office365mailsend) method to send emails.

#### Objectives

Establish a connection to the Microsoft Graph API in signedIn mode, and send an email using the [SMTP Transporter class](http://developer.4d.com/docs/fr/API/SMTPTransporterClass.html).

In this example, we get access [on behalf of a user](https://docs.microsoft.com/en-us/graph/auth-v2-user).

#### Prerequisites

* You have registered an application with the [Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app) and obtained your application ID (also called client ID).

> Here, the term "application" does not refer to an application built in 4D. It refers to an entry point you create on the Azure portal. You use the generated client ID to tell your 4D application to trust the Microsoft identity platform.

* You have a Microsoft e-mail account. For example, you signed up for an e-mail account with Microsoft's webmail services designated domains (@hotmail.com, @outlook.com, etc.).

#### Steps

Once you have your client ID, you're ready to establish a connection to your Azure application and send an email:

1. Open your 4D application, create a method and insert the following code:

```4d
var $token; $param; $email : Object
var $oAuth2 : cs.NetKit.OAuth2Provider
var $address : Text

// Configure authentication


$param:=New object
$param.name:="Microsoft"
$param.permission:="signedIn"
$param.clientId:="your-client-id" // Replace with your Microsoft identity platform client ID
$param.redirectURI:="http://127.0.0.1:50993/authorize/"
$param.scope:="https://outlook.office.com/SMTP.Send" // Get consent for sending an smtp email

// Instantiate an object of the OAuth2Provider class
$oAuth2:=New OAuth2 provider($param)

// Request a token using the class function

// Send a token request and start the a web server on the port specified in $param.redirectURI
//to intercept the authorization response
$token:=$oAuth2.getToken()

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

