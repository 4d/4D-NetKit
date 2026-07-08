# DateTime Class

## Overview

The `DateTime` class wraps a 4D date and time into a single object and provides helpers to serialize values for Microsoft Graph and Google Calendar APIs.

The class supports multiple constructor signatures (current datetime, date only, time only, text timestamp, object input, and date/time pair).

This class is instantiated by calling `cs.DateTime.new()`.

**Note:** Shared objects are not supported by the 4D NetKit API.

## Table of contents

* [cs.DateTime.new()](#csdatetimenew)
* [DateTime.getGraphDateTime()](#datetimegetgraphdatetime)
* [DateTime.getGoogleDateTime()](#datetimegetgoogledatetime)
* [DateTime.getGoogleDate()](#datetimegetgoogledate)
* [DateTime.getDateTimeURLParameter()](#datetimegetdatetimeurlparameter)
* [DateTime.addTime()](#datetimeaddtime)
* [DateTime.addDate()](#datetimeadddate)
* [DateTime.addDays()](#datetimeadddays)
* [DateTime.toString()](#datetimetostring)
* [DateTime.isNull()](#datetimeisnull)
* [DateTime.isBefore()](#datetimeisbefore)
* [DateTime.isAfter()](#datetimeisafter)
* [Computed properties](#computed-properties)

## cs.DateTime.new()

**cs.DateTime.new** ( ... : Variant ) : `cs.DateTime`

### Parameters

| Parameter | Type | | Description |
|---|---|:---:|---|
| ... | Variant | -> | Accepted forms: no parameter, `Date`, `Time`, timestamp `Text`, object (`dateTime` or `date`/`time`, optional `timeZone`), `Date` + `Time`, or timestamp `Text` + `timeZone` `Text`. |
| Result | cs.DateTime | <- | A `DateTime` instance. |

### Example

```4d
var $dt : cs.DateTime

$dt:=cs.DateTime.new()
$dt:=cs.DateTime.new(!2026-06-03!)
$dt:=cs.DateTime.new(?09:30:00?)
$dt:=cs.DateTime.new("2026-06-03T09:30:00.000Z")
$dt:=cs.DateTime.new(!2026-06-03!; ?09:30:00?)
$dt:=cs.DateTime.new("2026-06-03T09:30:00Z"; "America/New_York")
```

## .getGraphDateTime()

**.getGraphDateTime**() : Object

### Description

Returns a Microsoft Graph `dateTimeTimeZone` object, including `@odata.type`, `dateTime`, and `timeZone`.

### Example

```4d
var $start : cs.DateTime:=cs.DateTime.new("2026-07-08T09:30:00Z"; "Etc/GMT")
var $graphStart : Object:=$start.getGraphDateTime()
```

## .getGoogleDateTime()

**.getGoogleDateTime**() : Object

### Description

Returns a Google Calendar datetime object with `dateTime` and `timeZone`.

## .getGoogleDate()

**.getGoogleDate**() : Object

### Description

Returns a Google Calendar all-day date object with the `date` property.

### Example

```4d
var $day : cs.DateTime:=cs.DateTime.new(!2026-07-08!)
var $googleDate : Object:=$day.getGoogleDate()
```

## .getDateTimeURLParameter()

**.getDateTimeURLParameter**() : Text

### Description

Returns a datetime string formatted for Microsoft Graph URL parameters.

## .addTime()

**.addTime**( *duration* : Time )

### Description

Adds a duration to the current time and carries overflow into the date part.

## .addDate()

**.addDate**( *years* : Integer ; *months* : Integer ; *days* : Integer { ; *duration* : Time } )

### Description

Adds date parts and optionally a time duration.

## .addDays()

**.addDays**( *days* : Integer )

### Description

Adds (or subtracts) a number of days.

## .toString()

**.toString**() : Text

### Description

Returns an ISO 8601 datetime string representation.

## .isNull()

**.isNull**() : Boolean

### Description

Returns `True` when both date and time are empty values.

## .isBefore()

**.isBefore**( *other* : cs.DateTime ) : Boolean

### Description

Returns `True` when the current instance is before `other`.

### Example

```4d
var $start : cs.DateTime:=cs.DateTime.new("2026-07-08T09:30:00Z")
var $end : cs.DateTime:=cs.DateTime.new("2026-07-08T10:30:00Z")

If ($start.isBefore($end))
    ALERT("Start is before end")
End if
```

## .isAfter()

**.isAfter**( *other* : cs.DateTime ) : Boolean

### Description

Returns `True` when the current instance is after `other`.

## Computed properties

The class exposes computed getters:

| Property | Type | Description |
|---|---|---|
| year | Integer | Year component of `date`. |
| month | Integer | Month component of `date`. |
| day | Integer | Day component of `date`. |
| hours | Integer | Hour component of `time`. |
| minutes | Integer | Minute component of `time`. |
| seconds | Integer | Second component of `time`. |
| dayNumber | Integer | Day index in week. |
| dayName | Text | Localized day name. |
| monthName | Text | Localized month name. |
| weekNumber | Integer | Week number of year. |

## See also

* [GoogleCalendar](./GoogleCalendar.md)
* [Office365Calendar](./Office365Calendar.md)

