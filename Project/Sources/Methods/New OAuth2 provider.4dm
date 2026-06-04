//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
/**
 * @method New OAuth2 provider
 * @description Factory method — creates and returns a new `cs.OAuth2Provider` instance.
 * @param {Object} $inParameters - Provider configuration (see `cs.OAuth2Provider` constructor)
 * @returns {cs.OAuth2Provider} New OAuth2 provider instance
 */
#DECLARE($inParameters : Object) : cs.OAuth2Provider

return cs.OAuth2Provider.new($inParameters)
