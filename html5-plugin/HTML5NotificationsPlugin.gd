func showLocalNotification(message: String, title: String, interval: int, tag: int) -> void:
	var jsFile = _load("res://html5-plugin/Notification.js")
	JavaScript.eval(jsFile \
		.replace("title_parameter", title) \
		.replace("body_parameter", message ) \
		.replace("interval_parameter", interval * 1000)) \
		.replace("tag_parameter", str(tag))

func _load(filePath: String) -> String:
	var fopen = File.new()
	fopen.open(filePath, File.READ)
	if fopen.file_exists(filePath):
		return fopen.get_as_text()		
	
func init() -> void:
	var jsFile = _load("res://html5-plugin/Permission.js")
	JavaScript.eval(jsFile)
