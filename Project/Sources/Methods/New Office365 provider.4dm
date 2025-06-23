//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
#DECLARE($inProvider : cs.OAuth2Provider; $inParameters : Object) : cs.Office365

return cs.Office365.new($inProvider; $inParameters)
