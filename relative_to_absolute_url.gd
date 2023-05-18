extends Object
class_name RelativeToAbsoluteURL

static func convert(relativeURL : String):
	var pageURL = JavaScriptBridge.eval("window.location.href")
	if (pageURL == null):
		push_error("Could not determine a URL for the host; therefore URL conversion is not possible.")
		return relativeURL
	else:
		# replace the old HTML page name with relative URL (assumed to be relative to HTML parent)
		var parts = pageURL.split('/')
		parts[parts.size() - 1] = relativeURL
		return '/'.join(parts)
