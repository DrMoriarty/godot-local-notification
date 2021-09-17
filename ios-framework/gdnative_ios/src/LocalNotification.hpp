//
//  LocalNotification.h
//
//  Created by Vasiliy on 25.04.19.
//
//

#ifndef LocalNotification_h
#define LocalNotification_h

#include <Godot.hpp>
#include <Object.hpp>

class LocalNotification : public godot::Object {
    GODOT_CLASS(LocalNotification, godot::Object);

    //static godot::String deviceToken;
    bool enabled;
    bool inited;

public:
    LocalNotification();
    ~LocalNotification();

    static void _register_methods();
    void _init();

    void showLocalNotification(const godot::String message, const godot::String title, int interval, int tag);
    void showRepeatingNotification(const godot::String message, const godot::String title, int interval, int tag, int repeating_interval);
    void showDailyNotification(const godot::String message, const godot::String title, int hour, int minute, int tag);
    void cancelLocalNotification(int tag);
    void cancelAllNotifications();
    bool isEnabled();
    bool isInited();
    void init();
    void registerRemoteNotifications();
    void setDeviceToken(void* devToken); // NSString * devToken
    godot::String getDeviceToken();
    godot::Dictionary getNotificationData();
    godot::String getDeeplinkAction();
    godot::String getDeeplinkUri();

};

#endif /* LocalNotification_h */
