# Local/Push notification plugin for Godot engine

This is a module for [Godot Game Engine](http://godotengine.org/) which add local and remote notification feature for iOS and Android. 

## Installation

1. At first you need [NativeLib-CLI](https://github.com/DrMoriarty/nativelib-cli) or [NativeLib Addon](https://github.com/DrMoriarty/nativelib).

2. Make `nativelib -i local-notification` in your project directory if you are using CLI. Find `LOCAL-NOTIFICATION` in plugins list and press "Install" button if you are using GUI Addon.

3. Enable **Custom Build** for using in Android.

## Usage

Add wrapper `scripts/localnotification.gd` into autoloading list in your project. So you can use it everywhere in your code.

## API

### show(message: String, title: String, interval: float, tag: int)

Show notification with `title` and `message` after delay of `interval` seconds with `tag`. You can override notification by it's tag before it was fired.

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
