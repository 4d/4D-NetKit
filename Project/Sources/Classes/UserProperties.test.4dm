Class UserPropertiesTest

Function testInitialization()
    var $userProperties : cs.UserProperties
    $userProperties:=cs.UserProperties.new("1"; "John Doe"; "john.doe@example.com"; "admin")
    
    ASSERT($userProperties.getUserId()="1")
    ASSERT($userProperties.getUserName()="John Doe")
    ASSERT($userProperties.getUserEmail()="john.doe@example.com")
    ASSERT($userProperties.getUserRole()="admin")

Function testGettersAndSetters()
    var $userProperties : cs.UserProperties
    $userProperties:=cs.UserProperties.new("1"; "John Doe"; "john.doe@example.com"; "admin")
    
    $userProperties.setUserId("2")
    ASSERT($userProperties.getUserId()="2")
    
    $userProperties.setUserName("Jane Doe")
    ASSERT($userProperties.getUserName()="Jane Doe")
    
    $userProperties.setUserEmail("jane.doe@example.com")
    ASSERT($userProperties.getUserEmail()="jane.doe@example.com")
    
    $userProperties.setUserRole("user")
    ASSERT($userProperties.getUserRole()="user")

Function testDifferentInputs()
    var $userProperties : cs.UserProperties
    $userProperties:=cs.UserProperties.new(""; ""; ""; "")
    
    ASSERT($userProperties.getUserId()="")
    ASSERT($userProperties.getUserName()="")
    ASSERT($userProperties.getUserEmail()="")
    ASSERT($userProperties.getUserRole()="")
    
    $userProperties.setUserId("3")
    $userProperties.setUserName("Alice")
    $userProperties.setUserEmail("alice@example.com")
    $userProperties.setUserRole("guest")
    
    ASSERT($userProperties.getUserId()="3")
    ASSERT($userProperties.getUserName()="Alice")
    ASSERT($userProperties.getUserEmail()="alice@example.com")
    ASSERT($userProperties.getUserRole()="guest")
