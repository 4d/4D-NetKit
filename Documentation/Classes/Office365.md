# Office365 class

## Overview

The `Office365` class is the entry point for calling the [Microsoft Graph API](https://docs.microsoft.com/en-us/graph/overview#data-and-services-powering-the-microsoft-365-platform) in 4D NetKit. It is a facade that exposes four lazily-instantiated API clients:

* [`user`](./Office365User.md) — read Azure AD user profiles
* [`mail`](./Office365Mail.md) — create, move, send, and manage emails and folders
* [`calendar`](./Office365Calendar.md) — manage calendars and events
* [`category`](./Office365Category.md) — read Outlook master categories

Each client is instantiated on first access and reused for subsequent calls.

These operations can be performed after a valid token request (see [OAuth2Provider](./OAuth2Provider.md#oauth2provider-class)).

The `Office365` class can be instantiated in two ways:
* by calling the [`New Office365 provider`](../Methods/New%20Office365%20provider.md) method
* by calling the `cs.NetKit.Office365.new()` function

**Warning:** Shared objects are not supported by the 4D NetKit API.


## Table of Contents

- [Initialization](#new-office365-provider)
- [Returned object](#returned-object)
- [See also](#see-also)


## **New Office365 provider**

The `Office365` class can be instantiated using the `New Office365 provider` method.

See [New Office365 provider](../Methods/New%20Office365%20provider.md) for the complete method documentation.

### Returned object

The returned `Office365` object exposes the following properties, each giving access to a dedicated API client:

|Property|Type|Description|
|----|---|------|
|user|[Office365User](./Office365User.md)|Microsoft Graph user client: read Azure AD user profiles.|
|mail|[Office365Mail](./Office365Mail.md)|Microsoft Graph mail client: read, send, move, copy, reply, update, and delete messages and folders.|
|calendar|[Office365Calendar](./Office365Calendar.md)|Microsoft Graph calendar client: manage calendars and events.|
|category|[Office365Category](./Office365Category.md)|Microsoft Graph category client: read Outlook master categories.|


## See also

[Office365User](./Office365User.md)<br/>
[Office365Mail](./Office365Mail.md)<br/>
[Office365Calendar](./Office365Calendar.md)<br/>
[Office365Category](./Office365Category.md)<br/>
[OAuth2Provider](./OAuth2Provider.md#oauth2provider-class)<br/>
