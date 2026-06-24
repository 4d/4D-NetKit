// Largely inspired by https://github.com/4d-depot/DateTimeClass

/**
 * @class _DateTime
 * @description Wraps a 4D date and time into a single object with timezone support;
 *   provides serialization helpers for Microsoft Graph and Google Calendar API formats.
 *   Constructor accepts: no args (current), Date, Time, timestamp string,
 *   GraphDateTime object, (Date + Time), or (timestamp string + timezone string).
 */

property date : Date
property time : Integer
property timeZone : Text

Class constructor( ...  : Variant)
/**
 * @constructor
 * @param {...Variant} - Variadic; see class description for accepted signatures
 * @example
 *   var $dt : cs.NetKit._DateTime
 *   $dt:=cs.NetKit._DateTime.new()                            // current date+time
 *   $dt:=cs.NetKit._DateTime.new(!2026-06-03!)                // date only
 *   $dt:=cs.NetKit._DateTime.new(?09:30:00?)                  // time only
 *   $dt:=cs.NetKit._DateTime.new("2026-06-03T09:30:00.000Z")  // ISO timestamp
 *   $dt:=cs.NetKit._DateTime.new(!2026-06-03!; ?09:30:00?)    // date + time
 *   $dt:=cs.NetKit._DateTime.new("2026-06-03T09:30:00Z"; "America/New_York")  // with timezone
 */
	
	Case of 
		: (Count parameters=0)  // current date
			var $ts : Text:=Timestamp
			
			This.date:=Date($ts)
			This.time:=Time($ts)
			
		: (Count parameters=1)
			Case of 
				: (Value type($1)=Is date)  // date, no time
					This.date:=$1
					This.time:=?00:00:00?
					
				: ((Value type($1)=Is real) || (Value type($1)=Is time))  // no date, time
					This.time:=$1
					This.date:=!00-00-00!
					
				: (Value type($1)=Is text)  // timestamp string
					This.date:=Date($1)
					This.time:=Time($1)
					
				: (Value type($1)=Is object)  // GraphDateTime object
					If (Value type($1.dateTime)=Is text)  // date and time string
						This.date:=Date($1.dateTime)
						This.time:=Time($1.dateTime)
					Else 
						If (Value type($1.date)#Is undefined)  // date
							This.date:=Date($1.date)
						End if 
						If (Value type($1.time)#Is undefined)  // time
							This.time:=Time($1.time)
						End if 
					End if 
					If (Value type($1.timeZone)=Is text)
						This.timeZone:=String($1.timeZone)
					End if 
			End case 
			
		: (Count parameters>=2)
			Case of 
				: (Value type($1)=Is date) && ((Value type($2)=Is real) || (Value type($2)=Is time))  // date and time
					This.date:=$1
					This.time:=$2
					
				: (Value type($1)=Is text) && (Value type($2)=Is text)  // timestamp string and timezone string
					This.date:=Date($1)
					This.time:=Time($1)
					This.timeZone:=String($2)
			End case 
			If ((Count parameters>2) && (Value type($3)=Is text))
				This.timeZone:=String($3)
			End if 
			
	End case 
	
	
	// Mark: - [Private]
	// ----------------------------------------------------
	
	
Function _getDateTimeComponents() : Object
/**
 * @function _getDateTimeComponents
 * @private
 * @returns {Object} Object with `dateTime` (ISO string) and `timeZone` (IANA name or "Etc/GMT")
 * @description Serializes `date` and `time` into an ISO 8601 string; falls back to "Etc/GMT"
 *   when `timeZone` is undefined or empty
 */
	
	var $bIsTimeZoneUndefined : Boolean:=(Bool(Value type(This.timeZone)=Is undefined) || Bool(Length(String(This.timeZone))=0))
	var $timeZone : Text:=($bIsTimeZoneUndefined) ? "Etc/GMT" : This.timeZone
	var $dateTimeString : Text:=String(Date(This.date); $bIsTimeZoneUndefined ? ISO date GMT : ISO date; Time(This.time))
	
	return {dateTime: $dateTimeString; timeZone: $timeZone}
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getGraphDateTime() : Object  // returns GraphDateTime Object
/**
 * @function getGraphDateTime
 * @returns {Object} Microsoft Graph `dateTimeTimeZone` resource object
 * @description Returns an object with `dateTime`, `timeZone`, and `@odata.type` properties
 *   suitable for use in Microsoft Graph API requests (e.g. event start/end times)
 * @example
 *   // { "@odata.type": "microsoft.graph.dateTimeTimeZone",
 *   //   "dateTime": "2026-06-03T09:30:00.000Z", "timeZone": "Etc/GMT" }
 *   var $obj : Object:=$dt.getGraphDateTime()
 */
	
	var $dt : Object:=This._getDateTimeComponents()
	$dt["@odata.type"]:="microsoft.graph.dateTimeTimeZone"
	return $dt
	
	
	// ----------------------------------------------------
	
	
Function getGoogleDateTime() : Object  // returns Google DateTime Object
/**
 * @function getGoogleDateTime
 * @returns {Object} Google Calendar `dateTime` resource object
 * @description Returns an object with `dateTime` (ISO 8601) and `timeZone` (IANA name)
 *   suitable for use in Google Calendar API requests
 * @example
 *   // { "dateTime": "2026-06-03T09:30:00.000Z", "timeZone": "Etc/GMT" }
 *   var $obj : Object:=$dt.getGoogleDateTime()
 */
	
	return This._getDateTimeComponents()
	
	
	// ----------------------------------------------------
	
	
Function getGoogleDate() : Object  // returns Google Date Object
/**
 * @function getGoogleDate
 * @returns {Object} Google Calendar all-day event date object
 * @description Returns an object with a `date` property formatted as `"yyyy-MM-dd"`;
 *   used for all-day events in the Google Calendar API (no time component)
 * @example
 *   // { "date": "2026-06-03" }
 *   var $obj : Object:=$dt.getGoogleDate()
 */
	
	var $dateString : Text:=String(Date(This.date); "yyyy-MM-dd")
	
	return {date: $dateString}
	
	
	// ----------------------------------------------------
	
	
Function getDateTimeURLParameter()->$dateTimeString : Text  // returns Graph DateTime URL parameter
/**
 * @function getDateTimeURLParameter
 * @returns {Text} ISO 8601 string formatted for use as a Microsoft Graph `$filter` / OData URL parameter
 * @description Returns an ISO UTC string with the trailing `Z` replaced by `.0000000`
 *   as required by the Graph API `calendarView` and `$filter` query parameters
 * @example
 *   // "2026-06-03T09:30:00.0000000"
 *   var $s : Text:=$dt.getDateTimeURLParameter()
 */
	
	$dateTimeString:=String(Date(This.date); ISO date GMT; Time(This.time))
	$dateTimeString:=Replace string($dateTimeString; "Z"; ".0000000")
	
	
	// ----------------------------------------------------
	
	
Function addTime($duration : Time)
/**
 * @function addTime
 * @param {Time} $duration - Duration to add (4D Time value)
 * @description Adds a time duration to the current time; automatically carries over into the
 *   date component when the result exceeds midnight (i.e. wraps days correctly)
 * @example
 *   $dt.addTime(?02:30:00?)  // add 2 hours 30 minutes
 */
	
	var $extraDays : Real
	
	This.time+=$duration
	If (This.time>=(3600*24))
		$extraDays:=This.time\(3600*24)
		This.time:=This.time%(3600*24)
		This.date:=Add to date(This.date; 0; 0; $extraDays)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function addDate($years : Integer; $months : Integer; $days : Integer; $duration : Time)
/**
 * @function addDate
 * @param {Integer} $years - Number of years to add
 * @param {Integer} $months - Number of months to add
 * @param {Integer} $days - Number of days to add
 * @param {Time} $duration - Optional time duration to add (only applied when Count parameters >= 4)
 * @description Adds date components (and optionally a time duration) to the current date;
 *   delegates time overflow handling to `addTime` when a duration is provided
 * @example
 *   $dt.addDate(0; 1; 0)              // add 1 month
 *   $dt.addDate(0; 0; 7; ?01:00:00?)  // add 1 week and 1 hour
 */
	
	If (Count parameters>=4)
		This.addTime($duration)
	End if 
	
	This.date:=Add to date(This.date; $years; $months; $days)
	
	
	// Mark: - Getters
	// ----------------------------------------------------
	
	
Function get year()->$year : Integer  // year
/**
 * @function get year
 * @returns {Integer} The 4-digit year component of `date`
 */
	If (Not(Undefined(This.date)))
		$year:=Year of(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get month()->$month : Integer  // month
/**
 * @function get month
 * @returns {Integer} The month component of `date` (1–12)
 */
	If (Not(Undefined(This.date)))
		$month:=Month of(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get day()->$day : Integer  // day of the month
/**
 * @function get day
 * @returns {Integer} The day-of-month component of `date` (1–31)
 */
	If (Not(Undefined(This.date)))
		$day:=Day of(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get hours()->$hours : Integer  // hours
/**
 * @function get hours
 * @returns {Integer} The hours component of `time` (0–23)
 */
	If (Not(Undefined(This.time)))
		$hours:=This.time\3600
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get minutes()->$minutes : Integer  // minutes
/**
 * @function get minutes
 * @returns {Integer} The minutes component of `time` (0–59)
 */
	If (Not(Undefined(This.time)))
		$minutes:=(This.time-((This.time\3600)*3600))\60
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get seconds()->$seconds : Integer  // seconds
/**
 * @function get seconds
 * @returns {Integer} The seconds component of `time` (0–59)
 */
	If (Not(Undefined(This.time)))
		$seconds:=This.time%60
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get dayNumber()->$dayNumber : Integer  // day number of the week
/**
 * @function get dayNumber
 * @returns {Integer} Day number of the week (1=Sunday, 2=Monday, …, 7=Saturday)
 */
	If (Not(Undefined(This.date)))
		$dayNumber:=Day number(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get dayName()->$dayName : Text  // day name
/**
 * @function get dayName
 * @returns {Text} Full localized day name (e.g. "Monday"); uses 4D "EEEE" date format
 */
	If (Not(Undefined(This.date)))
		$dayName:=String(This.date; "EEEE")
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get monthName()->$monthName : Text  // month name
/**
 * @function get monthName
 * @returns {Text} Full localized month name (e.g. "June"); uses 4D "MMMM" date format
 */
	If (Not(Undefined(This.date)))
		$monthName:=String(This.date; "MMMM")
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get weekNumber()->$weekNumber : Integer
/**
 * @function get weekNumber
 * @returns {Integer} ISO 8601 week number of the year (1–53); uses 4D "w" date format
 */
	
	$weekNumber:=(Num(String(This.date; "w")))
	
	
	// ----------------------------------------------------
	
	
Function toString()->$result : Text
/**
 * @function toString
 * @returns {Text} ISO 8601 UTC representation of the date and time (e.g. "2026-06-03T09:30:00Z")
 * @description Useful for logging and debugging; equivalent to `getDateTimeURLParameter` without
 *   the Graph-specific `.0000000` suffix
 * @example
 *   var $s : Text:=$dt.toString()  // "2026-06-03T09:30:00Z"
 */
	
	$result:=String(Date(This.date); ISO date GMT; Time(This.time))
	
	
	// ----------------------------------------------------
	
	
Function isNull()->$result : Boolean
/**
 * @function isNull
 * @returns {Boolean} True when both `date` and `time` are zero/empty (i.e. no meaningful value was set)
 * @description Useful to detect an instance built from an incomplete or missing object
 * @example
 *   var $dt : cs.NetKit._DateTime:=cs.NetKit._DateTime.new({})
 *   $dt.isNull()  // True
 */
	
	$result:=(Bool(This.date=!00-00-00!) && Bool(This.time=0))
	
	
	// ----------------------------------------------------
	
	
Function isBefore($other : cs.NetKit._DateTime)->$result : Boolean
/**
 * @function isBefore
 * @param {cs.NetKit._DateTime} $other - The other _DateTime instance to compare against
 * @returns {Boolean} True if this instance represents a point in time strictly before `$other`
 * @description Compares by converting both instances to a number of seconds since
 *   1970-01-01 (epoch). Timezone is not taken into account; comparison is based on the
 *   stored date/time values as-is, so both instances should share the same timezone.
 * @example
 *   $dtStart.isBefore($dtEnd)  // True if start is earlier than end
 */
	
	var $thisVal : Real:=((This.date-!1970-01-01!)*86400)+This.time
	var $otherVal : Real:=(($other.date-!1970-01-01!)*86400)+$other.time
	$result:=Bool($thisVal<$otherVal)
	
	
	// ----------------------------------------------------
	
	
Function isAfter($other : cs.NetKit._DateTime)->$result : Boolean
/**
 * @function isAfter
 * @param {cs.NetKit._DateTime} $other - The other _DateTime instance to compare against
 * @returns {Boolean} True if this instance represents a point in time strictly after `$other`
 * @description Compares by converting both instances to a number of seconds since
 *   1970-01-01 (epoch). Timezone is not taken into account; comparison is based on the
 *   stored date/time values as-is, so both instances should share the same timezone.
 * @example
 *   $dtEnd.isAfter($dtStart)  // True if end is later than start
 */
	
	var $thisVal : Real:=((This.date-!1970-01-01!)*86400)+This.time
	var $otherVal : Real:=(($other.date-!1970-01-01!)*86400)+$other.time
	$result:=Bool($thisVal>$otherVal)
	
	
	// ----------------------------------------------------
	
	
Function addDays($days : Integer)
/**
 * @function addDays
 * @param {Integer} $days - Number of days to add (can be negative to subtract days)
 * @description Convenience shortcut for `addDate(0; 0; $days)`
 * @example
 *   $dt.addDays(7)   // add one week
 *   $dt.addDays(-1)  // subtract one day
 */
	
	This.date:=Add to date(This.date; 0; 0; $days)
