This is a module for [Godot Game Engine](http://godotengine.org/) which add local notification feature (for Android only). 

To use it, make sure you're able to compile the Godot android template, you can find the instructions [here](http://docs.godotengine.org/en/latest/reference/compiling_for_android.html). After that, just copy the the localnotification folder to godot/modules and recompile it.

Also you should add `org/godotengine/godot/GodotLocalNotification` into android.modules config section of your project.

Example:

```
if Globals.has_singleton("GodotLocalNotification"):
        var ln = Globals.get_singleton("GodotLocalNotification")
        ln.showLocalNotification("Message", "Title or application name", 20)  # 20 is an interval in seconds

```
