//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
#DECLARE($inProvider : cs:C1710.OAuth2Provider; $inParameters : Object) : Object

return cs:C1710.Office365.new($inProvider; $inParameters)
