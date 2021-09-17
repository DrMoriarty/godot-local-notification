# Local/Push notification plugin for Godot engine

This is a module for [Godot Game Engine](http://godotengine.org/) which add local and remote notification feature for iOS and Android. 

## Installation

1. At first you need [NativeLib-CLI](https://github.com/DrMoriarty/nativelib-cli) or [NativeLib Addon](https://github.com/DrMoriarty/nativelib).

2. Make `nativelib -i local-notification` in your project directory if you are using CLI. Find `LOCAL-NOTIFICATION` in plugins list and press "Install" button if you are using GUI Addon.

3. Enable **Custom Build** for using in Android.

## Usage

Add wrapper `scripts/localnotification.gd` into autoloading list in your project. So you can use it everywhere in your code.

## API

### show(message: String, title: String, interval: float, tag: int, repeating_interval: int = 0)

Show notification with `title` and `message` after delay of `interval` seconds with `tag`. You can override notification by it's tag before it was fired.
If you defined `repeating_interval` the notification will be fired in a loop until you cancelled it.

### show_daily(message: String, title: String, hour: int, minute: int, tag: int = 1)

Show notification daily at specific hour and minute (in 24 hour format).
You can overide the notification with new time, or cancel it with tag and register a new one.

*Need help*: Currently just support ios, need help on Android

### cancel(tag: int)

Cancel previously created notification.

### cancel_all()

Cancel all pending notifications (implemented for iOS only).

### init()

Request permission for notifications (iOS only).

### is_inited() -> bool

Check if notification permission was requested from user (iOS only).

### is_enabled() -> bool

Check if notification permission was granted by user (iOS only).

### register_remote_notification()

Request system token for push notifications.

### get_device_token() -> String

Returns system token for push notification.

### get_notification_data() -> Dictionary

Returns custom data from activated notification (Android only).

### get_deeplink_action() -> String

Returns action from deeplink, if exists. (Android only).

### get_deeplink_uri() -> String

Returns deeplink URI, if exists (Android only).

## Customising notifications for Android

The default notification color is defined in `android/build/res/values/notification-color.xml`. You can change it at your desire. The color string format is `#RRGGBB`.

In order to change default notification icon you should make this new files:
```
android/build/res/mipmap/notification_icon.png            Size 192x192
android/build/res/mipmap-hdpi-v4/notification_icon.png    Size 72x72
android/build/res/mipmap-mdpi-v4/notification_icon.png    Size 48x48
android/build/res/mipmap-xhdpi-v4/notification_icon.png   Size 96x96
android/build/res/mipmap-xxhdpi-v4/notification_icon.png  Size 144x144
android/build/res/mipmap-xxxhdpi-v4/notification_icon.png Size 192x192
```
Notification icons should be b/w with alpha channel. They will be tinted with color which we discuss above.

## Use push notifications for iOS

1) check if notifications `is_inited`, it means that application requested permissions from user.
2) call `init` if app didn’t requested it yet.
3) catch signal `enabled` or check method `is_enabled`. It will return `false` if user didn’t grant you permission.
4) get device token (`get_device_token`) for push notifications or catch signal `device_token_received`
5) send your device token to the server side.

That’s all. Sending notifications processed by your server, receiving notifications processed by OS. 

## Troubleshooting

If the notification doesn't appear, make sure you're not trying to display it while your game is in the foreground. In iOS, apps can only show notifications if they are in the background. This implies that you must use `interval` > 0.
