//%attributes = {"invisible":true}
#DECLARE() : Object

C_LONGINT(Error; Error line; $i)
C_TEXT(Error method; Error formula)

return { error: Error; \
         line: Error line; \
         method: Error method; \
         formula: Error formula; \
         errors: Last errors }
