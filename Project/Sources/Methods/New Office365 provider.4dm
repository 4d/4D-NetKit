//%attributes = {"invisible":true,"shared":true}
#DECLARE($inOAuth2Provider : cs:C1710.OAuth2Provider; $inParameters : Object)->$provider : Object

$provider:=cs:C1710.Office365.new($inOAuth2Provider; $inParameters)
