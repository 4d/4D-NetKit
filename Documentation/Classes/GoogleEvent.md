# GoogleEvent Class

## Overview

Represents a Google Calendar event. All top-level properties from the
Calendar API event resource are mapped directly onto `This`; the `attachments`
array is converted to a collection of `GoogleEventAttachment` instances.

## Properties

A `GoogleEvent` object exposes the following properties:

| Property | Type | Description |
|---|---|---|
| id | Text |  |
| attachments | Collection |  |

## See also

* [GoogleEventList](./GoogleEventList.md)
* [GoogleEventAttachment](./GoogleEventAttachment.md)
* [GoogleCalendar](./GoogleCalendar.md)
