//%attributes = {"invisible":true,"shared":true,"preemptive":"capable"}
/**
 * @method New Office365 provider
 * @description Factory method — creates and returns a new `cs.Office365` instance.
 * @param {cs.OAuth2Provider} $inProvider - Configured OAuth2 provider
 * @param {Object} $inParameters - Additional Office365 options (see `cs.Office365` constructor)
 * @returns {cs.Office365} New Office365 facade instance
 */
#DECLARE($inProvider : cs.OAuth2Provider; $inParameters : Object) : cs.Office365

return cs.Office365.new($inProvider; $inParameters)
