var $user : cs.User

// Test constructor
$user:=cs.User.new("1"; "John Doe"; "john.doe@example.com")
ASSERT($user.id="1")
ASSERT($user.name="John Doe")
ASSERT($user.email="john.doe@example.com")

// Test toString method
ASSERT($user.toString()="John Doe <john.doe@example.com>")
