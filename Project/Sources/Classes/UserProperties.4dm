Class UserProperties

property userId : Text
property userName : Text
property email : Text
property role : Text
property status : Text

Class constructor($userId : Text; $userName : Text; $email : Text; $role : Text; $status : Text)
    This.userId := $userId
    This.userName := $userName
    This.email := $email
    This.role := $role
    This.status := $status

Function get userId() : Text
    return This.userId

Function set userId($userId : Text)
    This.userId := $userId

Function get userName() : Text
    return This.userName

Function set userName($userName : Text)
    This.userName := $userName

Function get email() : Text
    return This.email

Function set email($email : Text)
    This.email := $email

Function get role() : Text
    return This.role

Function set role($role : Text)
    This.role := $role

Function get status() : Text
    return This.status

Function set status($status : Text)
    This.status := $status
