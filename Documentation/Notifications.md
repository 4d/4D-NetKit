# Change Notifications

## Overview

The notification system allows subscribing to change notifications on **mails** and **calendar events** for both **Office 365** (Microsoft Graph) and **Google** (Gmail / Google Calendar).

Two modes are available:
- **Push** (webhook): Real-time notifications via HTTP callbacks. Requires a publicly accessible endpoint.
- **Pull** (polling): Periodic polling of change APIs. No external endpoint needed.

When a resource changes, user-defined callbacks are dispatched in the 4D worker where `start()` was originally called.

---

## Office 365 (Microsoft Graph)

### API

#### `Office365.mail.notifier(param{; folderId}) → notificationObj`

Creates a notification object for **mail** change notifications.

| Parameter | Type | Description |
|---|---|---|
| `param` | Object | Callback and mode definitions (see below) |
| `folderId` | Text | *(optional)* Subscribe only to changes in that mail folder. If omitted, subscribe to all folders. |

#### `Office365.calendar.notifier(param{; calendarId}) → notificationObj`

Creates a notification object for **calendar event** change notifications.

| Parameter | Type | Description |
|---|---|---|
| `param` | Object | Callback and mode definitions (see below) |
| `calendarId` | Text | *(optional)* Subscribe to changes in that specific calendar. If omitted, subscribe to the default calendar. |

#### `param` attributes (Office 365)

| Attribute | Type | Description |
|---|---|---|
| `onCreate` | `4D.Function` | Called when a resource is **created**. *(optional)* |
| `onDelete` | `4D.Function` | Called when a resource is **deleted**. *(optional)* |
| `onModify` | `4D.Function` | Called when a resource is **modified**. *(optional)* |
| `endPoint` | Text | Webhook URL for **push** mode. If omitted, uses **pull** mode (delta queries). *(optional)* |
| `timer` | Integer | Polling interval in seconds for pull mode (default: 30). *(optional)* |

### Modes

- **Push**: If `endPoint` is provided, creates a [Microsoft Graph subscription](https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions). The webhook URL is derived as `{endPoint}/$4dk-graph-notification?state={uuid}`.
- **Pull**: If no `endPoint`, polls the [delta query API](https://learn.microsoft.com/en-us/graph/delta-query-messages) at the configured interval.

### Data Flow (Push mode)

```
┌──────────────┐     POST /subscriptions      ┌─────────────────────┐
│   4D App     │ ──────────────────────────►  │  Microsoft Graph    │
│              │                              │                     │
│  start()     │     Webhook POST             │  Detects changes    │
│              │ ◄──────────────────────────  │  on resource        │
│              │                              └─────────────────────┘
│              │
│  ┌───────────────────────────────────────────────────────┐
│  │  _GraphNotificationHandler (shared singleton)         │
│  │  - Validates webhook (validationToken → 200)          │
│  │  - Receives notifications → Storage.notifications     │
│  └───────────────────┬───────────────────────────────────┘
│                      │  writes to Storage.notifications[state].pending
│                      ▼
│  ┌───────────────────────────────────────────────────────┐
│  │  4DNK_Monitor_{state} (background worker)             │
│  │  - Drains pending items from Storage (2s interval)    │
│  │  - Dispatches via CALL WORKER to original worker      │
│  │  - Auto-renews subscription before expiration         │
│  └───────────────────┬───────────────────────────────────┘
│                      │  CALL WORKER(originalWorker, callbacks)
│                      ▼
│  ┌───────────────────────────────────────────────────────┐
│  │  Original Worker (where start() was called)           │
│  │  - onCreate({eventType; IDs})                         │
│  │  - onModify({eventType; IDs})                         │
│  │  - onDelete({eventType; IDs})                         │
│  └───────────────────────────────────────────────────────┘
└──────────────┘
```

### Usage Examples (Office 365)

```4d
// Push mode — Mail notifications via webhook
$notif:=$office365.mail.notifier({ \
    endPoint: "https://myserver.com"; \
    onCreate: Formula(ALERT("New mail: "+String($1.IDs))); \
    onDelete: Formula(ALERT("Mail deleted: "+String($1.IDs))) \
})
$status:=$notif.start()

// Pull mode — Calendar notifications via delta polling (every 60 seconds)
$calNotif:=$office365.calendar.notifier({ \
    timer: 60; \
    onCreate: Formula(handleNewEvent($1)); \
    onModify: Formula(handleEventUpdate($1)) \
})
$status:=$calNotif.start()

// Stop
$status:=$notif.stop()
```

---

## Google (Gmail / Google Calendar)

### API

#### `Google.mail.notifier(param) → notificationObj`

Creates a notification object for **Gmail** change notifications.

| Parameter | Type | Description |
|---|---|---|
| `param` | Object | Callback and mode definitions (see below) |

#### `Google.calendar.notifier(param{; calendarId}) → notificationObj`

Creates a notification object for **Google Calendar** event change notifications.

| Parameter | Type | Description |
|---|---|---|
| `param` | Object | Callback and mode definitions (see below) |
| `calendarId` | Text | *(optional)* Calendar ID to watch. If omitted, watches the primary calendar. |

#### `param` attributes (Google)

| Attribute | Type | Description |
|---|---|---|
| `onCreate` | `4D.Function` | Called when a resource is **created**. *(optional)* |
| `onDelete` | `4D.Function` | Called when a resource is **deleted**. *(optional)* |
| `onModify` | `4D.Function` | Called when a resource is **modified**. *(optional)* |
| `topicName` | Text | Google Cloud Pub/Sub topic name for **Gmail push** mode. *(optional, mail only)* |
| `labelIds` | Collection | Label IDs to filter Gmail notifications. *(optional, mail only)* |
| `endPoint` | Text | Webhook URL for **Calendar push** mode. *(optional, calendar only)* |
| `timer` | Integer | Polling interval in seconds for pull mode (default: 30). *(optional)* |

### Modes

Google notifications have different push mechanisms depending on the resource type:

| Resource | Push mechanism | Push requirement | Pull mechanism |
|---|---|---|---|
| **Gmail** | [Google Pub/Sub](https://developers.google.com/gmail/api/guides/push) | `topicName` parameter | [History API](https://developers.google.com/gmail/api/reference/rest/v1/users.history/list) |
| **Calendar** | [Watch channel](https://developers.google.com/calendar/api/guides/push) (direct webhook) | `endPoint` parameter | [Incremental sync](https://developers.google.com/calendar/api/guides/sync) with `syncToken` |

#### Gmail Push Setup

For Gmail push notifications, you must:
1. Create a Google Cloud Pub/Sub **topic** with Gmail publish permissions.
2. Create a **push subscription** on that topic pointing to `{serverUrl}/$4dk-google-notification`.
3. Pass the topic name as `topicName` in the notification parameters.

See: [Gmail Push Notifications Guide](https://developers.google.com/gmail/api/guides/push)

#### Calendar Push Setup

For Calendar push notifications, pass the `endPoint` parameter. The webhook URL is derived as `{endPoint}/$4dk-google-notification`. Google sends state identification via the `X-Goog-Channel-Token` HTTP header (not via the URL).

### Data Flow (Google — Push mode)

```
┌──────────────┐     POST /watch or Pub/Sub   ┌─────────────────────┐
│   4D App     │ ──────────────────────────►  │  Google APIs        │
│              │                              │                     │
│  start()     │     Webhook POST or          │  Detects changes    │
│              │     Pub/Sub push             │  on resource        │
│              │ ◄──────────────────────────  │                     │
│              │                              └─────────────────────┘
│              │
│  ┌───────────────────────────────────────────────────────┐
│  │  _GoogleNotificationHandler (shared singleton)        │
│  │  - Calendar: reads X-Goog-Channel-Token header        │
│  │  - Gmail: decodes Pub/Sub message (base64 data)       │
│  │  - Pushes signal → Storage.googleNotifications        │
│  └───────────────────┬───────────────────────────────────┘
│                      │  writes to Storage.googleNotifications[state].pending
│                      ▼
│  ┌───────────────────────────────────────────────────────┐
│  │  4DNK_GMonitor_{state} (background worker)            │
│  │  - Drains pending signals from Storage (2s interval)  │
│  │  - Queries Google API for actual changes              │
│  │    (Gmail: history.list / Calendar: events with sync) │
│  │  - Dispatches via CALL WORKER to original worker      │
│  │  - Auto-renews watch before expiration                │
│  └───────────────────┬───────────────────────────────────┘
│                      │  CALL WORKER(originalWorker, callbacks)
│                      ▼
│  ┌───────────────────────────────────────────────────────┐
│  │  Original Worker (where start() was called)           │
│  │  - onCreate({eventType; IDs})                         │
│  │  - onModify({eventType; IDs})                         │
│  │  - onDelete({eventType; IDs})                         │
│  └───────────────────────────────────────────────────────┘
└──────────────┘
```

> **Note:** Unlike Microsoft Graph (which sends change details directly in the webhook body), Google push notifications are *signals only*. The monitoring worker then queries the API to determine what actually changed.

### Usage Examples (Google)

```4d
// Pull mode — Gmail notifications (polling every 30 seconds, default)
$notif:=$google.mail.notifier({ \
    onCreate: Formula(handleNewMail($1)); \
    onDelete: Formula(handleDeletedMail($1)); \
    onModify: Formula(handleModifiedMail($1)) \
})
$status:=$notif.start()

// Push mode — Gmail notifications via Pub/Sub
$notif:=$google.mail.notifier({ \
    topicName: "projects/my-project/topics/gmail-notifications"; \
    labelIds: ["INBOX"]; \
    onCreate: Formula(handleNewMail($1)) \
})
$status:=$notif.start()

// Pull mode — Calendar notifications (polling every 60 seconds)
$calNotif:=$google.calendar.notifier({ \
    timer: 60; \
    onCreate: Formula(handleNewEvent($1)); \
    onModify: Formula(handleEventUpdate($1)); \
    onDelete: Formula(handleEventDeletion($1)) \
})
$status:=$calNotif.start()

// Push mode — Calendar notifications via webhook
$calNotif:=$google.calendar.notifier({ \
    endPoint: "https://myserver.com"; \
    onCreate: Formula(handleNewEvent($1)) \
}; "primary")
$status:=$calNotif.start()

// Stop
$status:=$notif.stop()
```

---

## Common
