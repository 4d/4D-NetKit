# GoogleEvent Class

## Overview

`GoogleEvent` represents a Google Calendar event. All top-level properties from the [Calendar API event resource](https://developers.google.com/calendar/api/v3/reference/events#resource) are mapped directly onto the object. The `attachments` array is converted to a collection of [GoogleEventAttachment](./GoogleEventAttachment.md) instances.

For the full list of event properties, refer to the [official Google Calendar API documentation](https://developers.google.com/calendar/api/v3/reference/events#resource).

## Properties

A `GoogleEvent` object exposes the following main properties:

| Property | | Type | Description |
|---|---|---|---|
| id | | Text | ID of the event. |
| calendarId | | Text | Calendar ID. Use `Google.calendar.getCalendars()` to retrieve IDs. |
| attachments | | Collection | Collection of [GoogleEventAttachment](./GoogleEventAttachment.md) instances (max 25). Requires `supportsAttachments: true` in the request. |
| attendees | | Collection | List of attendees. |
| | email | Text | **Required.** Email address of the attendee. |
| | displayName | Text | Name of the attendee. |
| | comment | Text | The attendee's response comment. |
| | optional | Boolean | (Default: `false`) Whether the attendee is optional. |
| | additionalGuests | Integer | (Default: `0`) Allowed number of additional guests. |
| description | | Text | Description of the event (HTML allowed). |
| start | | Object | Start time. Use `dateTime` with optional `timeZone`, or `date` for all-day events. |
| | date | Date, Text | Start date. If Text, use format `"yyyy-mm-dd"`. |
| | time | Time | Start time (omitted for all-day events). |
| | dateTime | Text | Combined start date and time in RFC 3339 format. Overrides `date` and `time`. |
| | timeZone | Text | Time zone for `dateTime` (IANA format, e.g., `"Europe/Zurich"`). Defaults to UTC. |
| end | | Object | End time. Use `dateTime` with optional `timeZone`, or `date` for all-day events. |
| | date | Date, Text | End date. If Text, use format `"yyyy-mm-dd"`. |
| | time | Time | End time (omitted for all-day events). |
| | dateTime | Text | Combined end date and time in RFC 3339 format. Overrides `date` and `time`. |
| | timeZone | Text | Time zone for `dateTime` (IANA format, e.g., `"Europe/Zurich"`). Defaults to UTC. |
| eventType | | Text | Specific type of the event (cannot be changed after creation). Possible values: `"default"`, `"birthday"`, `"focusTime"`, `"outOfOffice"`, `"workingLocation"`, etc. |
| extendedProperties.private | | Object | Custom key-value pairs only visible to the event owner. |
| extendedProperties.shared | | Object | Custom key-value pairs shared with all attendees. |
| guestsCanInviteOthers | | Boolean | (Default: `true`) Whether attendees can invite other guests. |
| guestsCanModify | | Boolean | (Default: `false`) Whether attendees can edit the event. |
| guestsCanSeeOtherGuests | | Boolean | (Default: `true`) Whether attendees can see each other. |
| location | | Text | Event location. |
| recurrence[] | | Collection | List of recurrence rules in [RFC 5545](https://www.rfc-editor.org/rfc/rfc5545) format (RRULE/EXRULE/RDATE/EXDATE). |
| reminders.overrides[] | | Collection | Custom reminder overrides. |
| | method | Text | **Required.** Reminder method: `"email"` or `"popup"`. |
| | minutes | Integer | **Required.** Minutes before the event when the reminder triggers (0–40320). |
| reminders.useDefault | | Boolean | Whether to use the calendar's default reminders. |
| source.title | | Text | Title of the source linked to the event. |
| source.url | | Text | URL of the source linked to the event (must use `http` or `https`). |
| status | | Text | Current state of the event. Possible values: `"confirmed"` (default), `"tentative"`, `"cancelled"`. |
| summary | | Text | Title of the event. |
| transparency | | Text | Whether the event blocks time on the calendar. Values: `"opaque"` (busy) or `"transparent"` (available). |
| visibility | | Text | Visibility level: `"default"`, `"public"`, `"private"`, or `"confidential"`. |

## See also

* [GoogleEventList](./GoogleEventList.md)
* [GoogleEventAttachment](./GoogleEventAttachment.md)
* [GoogleCalendar](./GoogleCalendar.md)
* [Google](./Google.md)
