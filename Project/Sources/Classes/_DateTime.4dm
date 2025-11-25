// Largely inspired by https://github.com/4d-depot/DateTimeClass

property date : Date
property time : Integer
property timeZone : Text

Class constructor( ...  : Variant)
	
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
	
	
	// Mark: - [Public]
	// ----------------------------------------------------
	
	
Function getGraphDateTime() : Object  // returns GraphDateTime Object
	
	var $bIsTimeZoneUndefined : Boolean:=(Bool(Value type(This.timeZone)=Is undefined) || Bool(Length(String(This.timeZone))=0))
	var $timeZone : Text:=($bIsTimeZoneUndefined) ? "Etc/GMT" : This.timeZone
	var $dateTimeString : Text:=String(Date(This.date); $bIsTimeZoneUndefined ? ISO date GMT : ISO date; Time(This.time))
	
	return New object("@odata.type"; "microsoft.graph.dateTimeTimeZone"; "dateTime"; $dateTimeString; "timeZone"; $timeZone)
	
	
	// ----------------------------------------------------
	
	
Function getGoogleDateTime() : Object  // returns Google DateTime Object
	
	var $bIsTimeZoneUndefined : Boolean:=(Bool(Value type(This.timeZone)=Is undefined) || Bool(Length(String(This.timeZone))=0))
	var $timeZone : Text:=($bIsTimeZoneUndefined) ? "Etc/GMT" : This.timeZone
	var $dateTimeString : Text:=String(Date(This.date); $bIsTimeZoneUndefined ? ISO date GMT : ISO date; Time(This.time))
	
	return {dateTime: $dateTimeString; timeZone: $timeZone}
	
	
	// ----------------------------------------------------
	
	
Function getGoogleDate() : Object  // returns Google Date Object
	
	var $dateString : Text:=String(Date(This.date); "yyyy-MM-dd")
	
	return {date: $dateString}
	
	
	// ----------------------------------------------------

	
Function getDateTimeURLParameter()->$dateTimeString : Text  // returns Graph DateTime URL parameter
	
	$dateTimeString:=String(Date(This.date); ISO date GMT; Time(This.time))
	$dateTimeString:=Replace string($dateTimeString; "Z"; ".0000000")
	
	
	// ----------------------------------------------------
	
	
Function addTime($duration : Time)
	
	var $extraDays : Real
	
	This.time+=$duration
	If (This.time>=(3600*24))
		$extraDays:=This.time\(3600*24)
		This.time:=This.time%(3600*24)
		This.date:=Add to date(This.date; 0; 0; $extraDays)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function addDate($years : Integer; $months : Integer; $days : Integer; $duration : Time)
	
	If (Count parameters>=4)
		This.addTime($duration)
	End if 
	
	This.date:=Add to date(This.date; $years; $months; $days)
	
	
	// Mark: - Getters
	// ----------------------------------------------------
	
	
Function get year()->$year : Integer  // year
	If (Not(Undefined(This.date)))
		$year:=Year of(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get month()->$month : Integer  // month
	If (Not(Undefined(This.date)))
		$month:=Month of(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get day()->$day : Integer  // day of the month
	If (Not(Undefined(This.date)))
		$day:=Day of(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get hours()->$hours : Integer  // hours
	If (Not(Undefined(This.time)))
		$hours:=This.time\3600
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get minutes()->$minutes : Integer  // minutes
	If (Not(Undefined(This.time)))
		$minutes:=(This.time-((This.time\3600)*3600))\60
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get seconds()->$seconds : Integer  // seconds
	If (Not(Undefined(This.time)))
		$seconds:=This.time%60
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get dayNumber()->$dayNumber : Integer  // day number of the week
	If (Not(Undefined(This.date)))
		$dayNumber:=Day number(This.date)
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get dayName()->$dayName : Text  // day name
	If (Not(Undefined(This.date)))
		$dayName:=String(This.date; "EEEE")
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get monthName()->$monthName : Text  // month name
	If (Not(Undefined(This.date)))
		$monthName:=String(This.date; "MMMM")
	End if 
	
	
	// ----------------------------------------------------
	
	
Function get weekNumber()->$weekNumber : Integer
	
	$weekNumber:=(Num(String(This.date; "w")))
