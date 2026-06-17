# GraphRecipient Class

## Overview

`GraphRecipient` represents a Microsoft Graph email recipient in the `{emailAddress: {address; name}}` format used by mail messages and calendar events. The email address is validated on construction; an error (code 2) is thrown when the address is invalid.

## Properties

A `GraphRecipient` object exposes the following properties:

| Property | | Type | Description |
|---|---|---|---|
| emailAddress | | Object | The recipient's email address object. |
| | address | Text | **Required.** The email address of the person or entity. |
| | name | Text | The display name of the person or entity *(optional)*. |

## Example

Recipient objects are used in mail properties such as `toRecipients`, `ccRecipients`, `bccRecipients`, `from`, `sender`, and `replyTo`:

```4d
$email:=New object()
$email.from:=New object("emailAddress"; New object("address"; "sender@example.com"))
$email.toRecipients:=New collection(
    New object("emailAddress"; New object("address"; "recipient@example.com"; "name"; "Jane Doe"))
)
```

## See also

* [GraphMessage](./GraphMessage.md)
* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
