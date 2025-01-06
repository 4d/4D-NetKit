property id : Text
property name : Text
property email : Text

Class constructor($id : Text; $name : Text; $email : Text)
    This.id := $id
    This.name := $name
    This.email := $email

Function toString() : Text
    return This.name + " <" + This.email + ">"
