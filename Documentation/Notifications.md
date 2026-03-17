# Office 365 Change Notifications

## Overview

The notification system allows subscribing to real-time change notifications on **mails** and **calendar events** via the [Microsoft Graph subscriptions API](https://learn.microsoft.com/en-us/graph/api/subscription-post-subscriptions). When a resource changes on Microsoft's side, a webhook is called, and user-defined callbacks are dispatched in the 4D worker where `start()` was originally called.

---

## API

### `Office365.mail.notification(param{; folderId}) → notificationObj`

Creates a notification object for **mail** change notifications.

| Parameter | Type | Description |
|---|---|---|
| `param` | Object | Callback definitions (see below) |
| `folderId` | Text | *(optional)* If provided, subscribe only to changes in that mail folder. If omitted, subscribe to all folders. |

### `Office365.calendar.notification(param{; calendarId}) → notificationObj`

Creates a notification object for **calendar event** change notifications.

| Parameter | Type | Description |
|---|---|---|
| `param` | Object | Callback definitions (see below) |
| `calendarId` | Text | *(optional)* If provided, subscribe to changes in that specific calendar. If omitted, subscribe to the default calendar. |

### `param` attributes

| Attribute | Type | Description |
|---|---|---|
| `onCreate` | `4D.Function` | Called when a resource is **created**. Receives the resource ID (mailId or eventId) as first parameter. *(optional)* |
| `onDelete` | `4D.Function` | Called when a resource is **deleted**. Receives the resource ID as first parameter. *(optional)* |
| `onModify` | `4D.Function` | Called when a resource is **modified**. Receives the resource ID as first parameter. *(optional)* |

### `notificationObj` — The returned notification object

| Property / Method | Type | Description |
|---|---|---|
| `expiration` | Text | Expiration date/time of the subscription (ISO 8601 timestamp). Read only. |
| `isStarted` | Boolean | `True` if the notification is currently active. Read only. |
| `start()` | Function → Object | Starts the subscription. Returns `{success: Boolean; statusText: Text; errors: Collection}`. |
| `stop()` | Function → Object | Stops the subscription and cleans up. Returns `{success: Boolean; statusText: Text; errors: Collection}`. |

---

## Internal Architecture

### Class Hierarchy

```
_BaseClass
  └─ _BaseAPI
       └─ _GraphAPI
            ├─ GraphNotification       (NEW — notification lifecycle)
            ├─ Office365Mail           (MODIFIED — added notification())
            └─ Office365Calendar       (MODIFIED — added notification())

_GraphNotificationHandler              (NEW — shared singleton, webhook handler)
```

### Data Flow

```
┌──────────────┐     POST /subscriptions     ┌─────────────────────┐
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
│  │  - Polls Storage.notifications[state].pending (2s)    │
│  │  - Drains pending items                               │
│  │  - Dispatches via CALL WORKER to original worker      │
│  │  - Auto-renews subscription before expiration         │
│  └───────────────────┬───────────────────────────────────┘
│                      │  CALL WORKER(originalWorker, callbacks)
│                      ▼
│  ┌───────────────────────────────────────────────────────┐
│  │  Original Worker (where start() was called)           │
│  │  - onCreate(resourceId)                               │
│  │  - onModify(resourceId)                               │
│  │  - onDelete(resourceId)                               │
│  └───────────────────────────────────────────────────────┘
└──────────────┘
```

### Storage Model

All inter-process communication uses `Storage` (shared objects), following the same pattern as `Storage.requests` used by OAuth2:

```
Storage.notifications : Shared Object
    └─ [state] : Shared Object          // keyed by UUID generated at start()
         ├─ subscriptionId : Text       // Microsoft Graph subscription ID
         ├─ isStarted : Boolean         // flag to stop the monitor loop
         └─ pending : Shared Collection // queue of incoming notifications
              └─ { changeType: Text; resourceId: Text }
```

### Key Design Decisions

1. **Webhook URL**: Derived automatically from the OAuth2 provider's `redirectURI` — same host/port, path `/$4dk-notification?state=<uuid>`.

2. **Dual web server support**:
   - **Modern model** (`4D.HTTPServer` / `HTTPRequestHandler`): Handled by `_GraphNotificationHandler.getResponse()` (shared singleton with `4D.IncomingMessage` / `4D.OutgoingMessage`).
   - **Legacy model** (`On Web Connection`): Handled by `_onWebConnection.4dm` which routes `/$4dk-notification@` requests.

3. **Callback dispatch**: Callbacks are always executed in the worker where `start()` was called, via `CALL WORKER`. This ensures the user code runs in the expected execution context.

4. **Auto-renewal**: The monitoring worker automatically renews the subscription 1 hour before expiration (subscriptions have a max lifetime of ~4230 minutes for mail/events). Renewal is done via `PATCH /subscriptions/{id}`.

5. **Cleanup**: Calling `stop()` deletes the Graph subscription, signals the monitor to stop, and cleans up `Storage.notifications`.

---

## Files Modified / Created

### New Files

| File | Description |
|---|---|
| `Project/Sources/Classes/GraphNotification.4dm` | Core notification class. Manages the full lifecycle: `start()` creates the subscription + launches the monitor worker; `stop()` deletes the subscription and kills the worker. Handles auto-renewal and callback dispatch. |
| `Project/Sources/Classes/_GraphNotificationHandler.4dm` | Shared singleton that handles incoming webhook HTTP requests (validation + notification body parsing → `Storage`). Follows the same pattern as `OAuth2Authorization`. |

### Modified Files

| File | Change |
|---|---|
| `Project/Sources/Classes/Office365Mail.4dm` | Added `notification($inParameters; $inFolderId)` function returning `cs.GraphNotification`. |
| `Project/Sources/Classes/Office365Calendar.4dm` | Added `notification($inParameters; $inCalendarId)` function returning `cs.GraphNotification`. |
| `Project/Sources/Methods/_onWebConnection.4dm` | Added routing for `/$4dk-notification@` (webhook handling for the legacy web server model). |

---

## HTTP Handler Configuration

When the **host database's web server** is used (i.e. the `endPoint` port matches the host web server port), you must register an HTTP handler so the webhook requests reach the notification handler.

Add the following entry in the `Project/Sources/HTTPHandlers.json` file of the **host project**:

```json
[
  {
    "class": "4D.NetKit._GraphNotificationHandler",
    "method": "getResponse",
    "regexPattern": "/\\$4dk-notification",
    "verbs": "post"
  }
]
```

> **Note:** If the component's own web server is used (different port), the handler is already preconfigured inside the component.

For more information, please refer to [HTTP Handlers](https://developer.4d.com/docs/WebServer/http-request-handler).

---

## Usage Examples

### Mail Notifications

```4d
// Create a notification object for all mail changes
$notif:=$office365.mail.notification({ \
    onCreate: Formula(ALERT("New mail: "+$1)); \
    onDelete: Formula(ALERT("Mail deleted: "+$1)); \
    onModify: Formula(ALERT("Mail modified: "+$1)) \
})

// Start listening
$status:=$notif.start()
// $status.success → True
// $notif.isStarted → True
// $notif.expiration → "2026-03-07T14:30:00.0000000Z"

// ... later, stop listening
$status:=$notif.stop()
// $notif.isStarted → False
// $notif.expiration → ""
```

### Mail Notifications on a Specific Folder

```4d
// Subscribe only to changes in the Inbox folder
$notif:=$office365.mail.notification({ \
    onCreate: Formula(handleNewMail($1)) \
}; "inbox")

$status:=$notif.start()
```

### Calendar Event Notifications

```4d
// Subscribe to event changes on the default calendar
$calNotif:=$office365.calendar.notification({ \
    onCreate: Formula(handleNewEvent($1)); \
    onModify: Formula(handleEventUpdate($1)); \
    onDelete: Formula(handleEventDeletion($1)) \
})

$status:=$calNotif.start()
```

### Calendar Notifications on a Specific Calendar

```4d
// Subscribe to event changes on a specific calendar
$calNotif:=$office365.calendar.notification({ \
    onCreate: Formula(handleNewEvent($1)) \
}; $calendarId)

$status:=$calNotif.start()
```

### Using Methods Instead of Formulas

```4d
// You can also pass 4D.Function references
$notif:=$office365.mail.notification({ \
    onCreate: Formula(myMailCreatedMethod($1)); \
    onDelete: Formula(myMailDeletedMethod($1)) \
})

$status:=$notif.start()
```
