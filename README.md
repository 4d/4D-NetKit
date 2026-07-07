# 4D NetKit

**Version: 21 R4**

4D NetKit is a built-in 4D component that lets you connect your applications to third-party web services and consume their REST APIs directly from 4D code. It handles the OAuth 2.0 authentication flows for you and provides high-level, object-oriented clients for the most common [Microsoft Graph](https://docs.microsoft.com/en-us/graph/overview) and [Google Workspace](https://developers.google.com/workspace) services.

## Overview

With 4D NetKit you can:

* **Authenticate** to Microsoft and Google identity platforms using OAuth 2.0, in both `signedIn` (Authorization Code, interactive) and `service` (Client Credentials / JWT Bearer, unattended) modes — including PKCE, refresh tokens, and certificate-based client assertions.
* **Send and manage emails**: send, reply, append, move, copy, update, and delete messages; manage folders and labels; read messages in MIME, JMAP (4D mail object), or native Microsoft format.
* **Manage calendars and events**: list calendars, and create, read, update, and delete events, including attachments and attendees.
* **Read user profiles**: query individual users or paginated user directories.
* **Organize items**: read Outlook master categories (Microsoft).
* **Receive change notifications**: monitor mailbox and calendar changes through push/pull notifiers.

**Warning:** Shared objects are not supported by the 4D NetKit API.

## Getting started

Authentication is always the first step. You create an [`OAuth2Provider`](Documentation/Classes/OAuth2Provider.md) object that holds your credentials and retrieves access tokens, then pass it to a service client (`Office365` or `Google`).

```4d
// 1. Create an OAuth2 provider
var $oauth2 : cs.NetKit.OAuth2Provider
$oauth2:=New OAuth2 provider({\
  name: "Microsoft"; \
  permission: "signedIn"; \
  clientId: "your-client-id"; \
  redirectURI: "http://127.0.0.1:50993/authorize/"; \
  scope: "https://graph.microsoft.com/.default"})

// 2. Create a service client and use it
var $office365 : cs.NetKit.Office365
$office365:=New Office365 provider($oauth2)

$office365.mail.send($mail)
```

For a complete walkthrough, see the [Tutorial: Authenticate to the Microsoft Graph API in service mode](Documentation/Tutorial.md).

## Documentation

### Authentication

| Page | Description |
|------|-------------|
| [New OAuth2 provider](Documentation/Methods/New%20OAuth2%20provider.md) | Method that instantiates an `OAuth2Provider` object. |
| [OAuth2Provider](Documentation/Classes/OAuth2Provider.md) | Core OAuth 2.0 client: token acquisition, refresh, PKCE, and JWT generation. |
| [JWT](Documentation/Classes/JWT.md) | Create, sign, and verify JSON Web Tokens. |

### Microsoft 365 (Microsoft Graph)

| Page | Description |
|------|-------------|
| [New Office365 provider](Documentation/Methods/New%20Office365%20provider.md) | Method that instantiates an `Office365` object. |
| [Office365](Documentation/Classes/Office365.md) | Entry-point facade exposing the `mail`, `calendar`, `user`, and `category` clients. |
| [Office365Mail](Documentation/Classes/Office365Mail.md) | Send, read, move, copy, reply, update, and delete messages; manage folders. |
| [Office365Calendar](Documentation/Classes/Office365Calendar.md) | Manage calendars and events. |
| [Office365User](Documentation/Classes/Office365User.md) | Read Azure AD user profiles. |
| [Office365Category](Documentation/Classes/Office365Category.md) | Read Outlook master categories. |

### Google Workspace

| Page | Description |
|------|-------------|
| [Google](Documentation/Classes/Google.md) | Entry-point facade exposing the `mail`, `calendar`, and `user` clients. |
| [GoogleMail](Documentation/Classes/GoogleMail.md) | Send, read, and manage Gmail messages and labels. |
| [GoogleCalendar](Documentation/Classes/GoogleCalendar.md) | Manage Google calendars and events. |
| [GoogleUser](Documentation/Classes/GoogleUser.md) | Read Google user profiles (People API). |

### Notifications

| Page | Description |
|------|-------------|
| [GraphNotification](Documentation/Classes/GraphNotification.md) / [GraphNotificationHandler](Documentation/Classes/GraphNotificationHandler.md) | Microsoft Graph change notifications for mail and calendar. |
| [GoogleNotification](Documentation/Classes/GoogleNotification.md) / [GoogleNotificationHandler](Documentation/Classes/GoogleNotificationHandler.md) | Google change notifications for mail and calendar. |


---

(c) Microsoft, Microsoft Office, Microsoft 365, Microsoft Graph are trademarks of the Microsoft group of companies.

(c) Google, Gmail are trademarks of the Alphabet, Inc.
