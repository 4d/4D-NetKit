# GraphMessage Class

## Overview

`GraphMessage` represents a single Microsoft Graph mail message. All top-level properties from the [Graph API message resource](https://learn.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0) are mapped directly onto the object. The `attachments` collection is loaded lazily via a Graph API call on first access.

For the full list of message properties, refer to the [official Microsoft documentation](https://learn.microsoft.com/en-us/graph/api/resources/message?view=graph-rest-1.0#properties).

## Properties

A `GraphMessage` object exposes the following main properties:

| Property | Type | Description |
|---|---|---|
| id | Text | Unique identifier for the message (note that this value may change if a message is moved or altered). |
| attachments | Collection | Collection of [GraphAttachment](./GraphAttachment.md) instances. Fetched lazily on first access and cached. Note: the Graph API is always queried for attachments regardless of `hasAttachments`, since that flag is unreliable for inline-only attachments. |
| bccRecipients | Collection | The Bcc recipients for the message. Each item is a [GraphRecipient](./GraphRecipient.md) object (`{emailAddress: {address; name}}`). |
| body | Object | The body of the message. Contains `content` (Text) and `contentType` (Text: `"text"` or `"html"`). |
| ccRecipients | Collection | The Cc recipients for the message. Each item is a [GraphRecipient](./GraphRecipient.md) object. |
| flag | Object | Followup flag with `flagStatus` (`"notFlagged"`, `"complete"`, or `"flagged"`), `startDateTime`, and `dueDateTime`. |
| from | Object | The mailbox owner and sender of the message. A [GraphRecipient](./GraphRecipient.md) object. |
| importance | Text | Importance of the message: `"low"`, `"normal"`, or `"high"`. |
| internetMessageHeaders | Collection | Collection of message headers defined by RFC 5322. Each item has `name` (Text) and `value` (Text). |
| isDeliveryReceiptRequested | Boolean | `true` if a delivery receipt is requested. |
| isRead | Boolean | `true` if the message has been read. |
| isReadReceiptRequested | Boolean | `true` if a read receipt is requested. |
| replyTo | Collection | Email addresses to use when replying. Collection of [GraphRecipient](./GraphRecipient.md) objects. |
| sender | Object | The account actually used to generate the message. A [GraphRecipient](./GraphRecipient.md) object. |
| subject | Text | The subject of the message. |
| toRecipients | Collection | The To recipients for the message. Collection of [GraphRecipient](./GraphRecipient.md) objects. |

## See also

* [GraphMessageList](./GraphMessageList.md)
* [GraphAttachment](./GraphAttachment.md)
* [GraphRecipient](./GraphRecipient.md)
* [Office365Mail](./Office365Mail.md)
* [Office365](./Office365.md)
