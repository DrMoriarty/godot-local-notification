# godot-local-notification

This is a module for [Godot Game Engine](http://godotengine.org/) which add local notification feature. 

## Android usage (You need godot version 3.2.2.beta or higher.)

Copy `LocalNotification.gdap` to `android/plugins`. Then enable plugin `LocalNotification` in export settings.

## iOS usage

Coming soon...


Usage example:

```
if Globals.has_singleton("LocalNotification"):
        var ln = Globals.get_singleton("LocalNotification")
        ln.showLocalNotification("Message", "Title or application name", 20, 1)
        # 20 is an interval in seconds
        # 1 is a notification tag
        # you can override the notification with the same tag before it was fired

```
