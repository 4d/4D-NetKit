# GraphEvent Class

## Overview

`GraphEvent` represents a single Microsoft Graph calendar event. All top-level properties from the [Graph API event resource](https://learn.microsoft.com/en-us/graph/api/resources/event?view=graph-rest-1.0) are mapped directly onto the object. The `attachments` collection is loaded lazily via a Graph API call on first access.

For the full list of event properties, refer to the [official Microsoft documentation](https://learn.microsoft.com/en-us/graph/api/resources/event?view=graph-rest-1.0).

## Properties

A `GraphEvent` object exposes the following main properties:

| Property | | Type | Description | Updatable |
|---|---|---|---|---|
| id | | Text | ID of the event (case-sensitive, read-only). | |
| calendarId | | Text | Calendar ID. If not provided, the user's primary calendar is used. | |
| hasAttachments | | Boolean | `true` if the event has at least one attachment. | |
| attachments | | Collection | Collection of [GraphAttachment](./GraphAttachment.md) instances. Fetched lazily on first access when `hasAttachments` is `true`, then cached. | |
| attendees | | Collection | List of attendees. | Yes |
| | emailAddress | Text | **Required.** Attendee's email address. | |
| | type | Text | Attendee role: `"required"`, `"optional"`, or `"resource"`. | |
| body | | Object | Body of the message associated with the event. | Yes |
| | content | Text | Content of the body. | |
| | contentType | Text | Type of content: `"text"` or `"html"`. | |
| categories | | Collection | List of categories. Must match the `displayName` of categories returned by [`Office365.category.list()`](./Office365Category.md#list). | Yes |
| start | | Object | Start time of the event. | Yes |
| | date | Date | Start date. | |
| | time | Time | Start time (omitted for all-day events). | |
| | dateTime | Text | Combined start date and time (`"yyyy-mm-ddThh:mm:ss"` format). Overrides `date` and `time`. | |
| | timeZone | Text | Time zone (IANA format, e.g., `"Europe/Zurich"`). Defaults to UTC. | |
| end | | Object | End time of the event. | Yes |
| | date | Date | End date. | |
| | time | Time | End time (omitted for all-day events). | |
| | dateTime | Text | Combined end date and time (`"yyyy-mm-ddThh:mm:ss"` format). Overrides `date` and `time`. | |
| | timeZone | Text | Time zone (IANA format, e.g., `"Europe/Zurich"`). Defaults to UTC. | |
| isAllDay | | Boolean | (Default: `false`) Set to `true` for all-day events. | Yes |
| isCancelled | | Boolean | (Default: `false`) Whether the event is canceled. | |
| isDraft | | Boolean | (Default: `false`) `true` if changes have been made but not yet sent to attendees. | |
| isOnlineMeeting | | Boolean | (Default: `false`) Set to `true` to create an online meeting. | Yes |
| isReminderOn | | Boolean | (Default: `false`) Whether a reminder is set. | Yes |
| location | | Object | Event [location object](https://learn.microsoft.com/en-us/graph/api/resources/location?view=graph-rest-1.0). | Yes |
| onlineMeetingProvider | | Text | Online meeting provider: `"teamsForBusiness"`, `"skypeForBusiness"`, `"skypeForConsumer"`, etc. | Yes |
| recurrence | | Object | [Recurrence pattern](https://learn.microsoft.com/en-us/graph/api/resources/recurrencepattern?view=graph-rest-1.0) (e.g., daily, weekly). | Yes |
| reminderMinutesBeforeStart | | Integer | Time in minutes before start to trigger the reminder. | Yes |
| responseRequested | | Boolean | Whether a response is requested from attendees. Default is `true`. | Yes |
| sensitivity | | Text | Event sensitivity: `"normal"`, `"personal"`, `"private"`, `"confidential"`. | Yes |
| seriesMasterId | | Text | ID of the recurring series master event, if part of a recurring series. | |
| showAs | | Text | Availability status: `"busy"`, `"free"`, etc. | Yes |
| subject | | Text | Event title or subject line. | Yes |
| importance | | Text | Event importance: `"low"`, `"normal"`, or `"high"`. | Yes |
| allowNewTimeProposals | | Boolean | (Default: `true`) Whether attendees can propose a new time. | |
| hideAttendees | | Boolean | (Default: `false`) If `true`, attendees only see themselves. | Yes |

## See also

* [GraphEventList](./GraphEventList.md)
* [GraphAttachment](./GraphAttachment.md)
* [Office365Calendar](./Office365Calendar.md)
* [Office365](./Office365.md)
