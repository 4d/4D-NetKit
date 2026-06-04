/**
 * @method onWebConnection
 * @description Database method called by the 4D web server on each incoming HTTP request.
 *   Delegates all request handling to `_onWebConnection`.
 * @param {Text} $URL - Request URL
 * @param {Text} $header - Raw HTTP request headers
 * @param {Text} $peerIP - Client IP address
 * @param {Text} $localIP - Server IP address
 * @param {Text} $username - HTTP Basic Auth username (if any)
 * @param {Text} $password - HTTP Basic Auth password (if any)
 */
#DECLARE($URL : Text; $header : Text; $peerIP : Text; $localIP : Text; $username : Text; $password : Text)

_onWebConnection($URL; $header; $peerIP; $localIP; $username; $password)
