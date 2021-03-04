func showLocalNotification(message: String, title: String, interval: int, tag: int) -> void:
	var jsFile = _load("res://addons/localnotification-html5/Notification.js")
	JavaScript.eval(jsFile \
		.replace("title_parameter", title) \
		.replace("body_parameter", message ) \
		.replace("interval_parameter", interval * 1000)) \
		.replace("tag_parameter", str(tag))

func _load(filePath: String) -> String:
	var file = File.new()
	var error = file.open(filePath, File.READ)
	if not error:
		return file.get_as_text()		
	else:
		print_debug(str(error))
		return ""
	
func init() -> void:
	var jsFile = _load("res://addons/localnotification-html5/Permission.js")
	JavaScript.eval(jsFile)
