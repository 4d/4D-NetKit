//%attributes = {"invisible":true}
// ----------------------------------------------------
// Method: Date_ToEpoch
// ----------------------------------------------------
// Call:   Epoch:=Date_ToEpoch(Date;Time)
// ----------------------------------------------------
// UserName (OS): Alexander Heintz
// Date and Time: 24.03.17, 12:49:26
// ----------------------------------------------------
// Does:
//      converts a given date and time into UNIX Epoch
//      thats seconds since midnight 1970 01 01
// ----------------------------------------------------
// Parameters:
// ->  $1     date        the date
// ->  $2     time        the time
// <-  $0     real     unix epoch
// ----------------------------------------------------
// Parameter Definition
C_DATE:C307($1)
C_TIME:C306($2)
C_REAL:C285($0)
// ----------------------------------------------------
// Local Variable Definition
C_DATE:C307($d_Date)
C_TIME:C306($h_Time)
C_LONGINT:C283($l_Days)
C_LONGINT:C283($l_Hours)
C_LONGINT:C283($l_Minutes)
C_LONGINT:C283($l_Time)
C_REAL:C285($r_Epoch)
C_TEXT:C284($t_Timestamp)
// ----------------------------------------------------
// Parameter Assignment
$d_Date:=$1
$h_Time:=$2
// ----------------------------------------------------
//GMT Correction
$t_Timestamp:=String:C10($d_Date; ISO date GMT:K1:10; $h_Time)
//2017-03-24T12:04:55Z
//just strip the Z at the end
$t_Timestamp:=Substring:C12($t_Timestamp; 1; 19)
//2017-03-24T12:01:17
//now get the GMT date and time for calculations
$d_Date:=Date:C102($t_Timestamp)
$h_Time:=Time:C179($t_Timestamp)
//get number of days
$l_Days:=$d_Date-!1970-01-01!
//start calculating the unix time
//add the days
$r_Epoch:=$l_Days*86400
$l_Time:=$h_Time*1  //make it a longint
//add the hours
$l_Hours:=Trunc:C95($l_Time/3600; 0)
$r_Epoch:=$r_Epoch+($l_Hours*3600)
$l_Time:=Mod:C98($l_Time; 3600)
//add the minutes
$l_Minutes:=Trunc:C95($l_Time/60; 0)
$r_Epoch:=$r_Epoch+($l_Minutes*60)
$l_Time:=Mod:C98($l_Time; 60)
//add the seconds
$r_Epoch:=$r_Epoch+$l_Time
$0:=$r_Epoch