Class UserPropertiesTest

Function testConstructor()
    var $userProperties : cs.UserProperties
    $userProperties:=cs.UserProperties.new("1"; "John Doe"; "john.doe@example.com"; "admin"; "active")
    ASSERT($userProperties.getUserId()="1")
    ASSERT($userProperties.getUserName()="John Doe")
    ASSERT($userProperties.getEmail()="john.doe@example.com")
    ASSERT($userProperties.getRole()="admin")
    ASSERT($userProperties.getStatus()="active")

Function testGettersAndSetters()
    var $userProperties : cs.UserProperties
    $userProperties:=cs.UserProperties.new("1"; "John Doe"; "john.doe@example.com"; "admin"; "active")
    
    $userProperties.setUserId("2")
    ASSERT($userProperties.getUserId()="2")
    
    $userProperties.setUserName("Jane Doe")
    ASSERT($userProperties.getUserName()="Jane Doe")
    
    $userProperties.setEmail("jane.doe@example.com")
    ASSERT($userProperties.getEmail()="jane.doe@example.com")
    
    $userProperties.setRole("user")
    ASSERT($userProperties.getRole()="user")
    
    $userProperties.setStatus("inactive")
    ASSERT($userProperties.getStatus()="inactive")
