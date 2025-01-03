property userId : Text
property userName : Text
property userEmail : Text
property userRole : Text

Class constructor($userId : Text; $userName : Text; $userEmail : Text; $userRole : Text)
    This.userId := $userId
    This.userName := $userName
    This.userEmail := $userEmail
    This.userRole := $userRole

Function getUserId() : Text
    return This.userId

Function setUserId($userId : Text)
    This.userId := $userId

Function getUserName() : Text
    return This.userName

Function setUserName($userName : Text)
    This.userName := $userName

Function getUserEmail() : Text
    return This.userEmail

Function setUserEmail($userEmail : Text)
    This.userEmail := $userEmail

Function getUserRole() : Text
    return This.userRole

Function setUserRole($userRole : Text)
    This.userRole := $userRole
