//%attributes = {"invisible":true}
#DECLARE() : Object

var $stack : Object

C_LONGINT(Error; Error line; $i)
C_TEXT(Error method; Error formula)

$stack:=New object("error"; Error; \
"line"; Error line; \
"method"; Error method; \
"formula"; Error formula; \
"errors"; Last errors)

return $stack
