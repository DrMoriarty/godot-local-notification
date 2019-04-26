//
//  LocalNotification.mm
//
//  Created by Vasiliy on 25.04.19.
//
//

#import <Foundation/Foundation.h>
#import "./LocalNotification.h"
#import <UserNotifications/UserNotifications.h>

GodotLocalNotification::GodotLocalNotification()
{
    inited = false;
    enabled = false;
    [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if(settings.authorizationStatus == UNAuthorizationStatusDenied) {
                inited = true;
                enabled = false;
            } else if(settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                inited = true;
                enabled = true;
            } else {
                inited = false;
                enabled = false;
            }
        }];
}

GodotLocalNotification::~GodotLocalNotification()
{
}

void GodotLocalNotification::init()
{
    if(inited) return;
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            inited = true;
            if(error) NSLog(@"Registering notification error: %@", error);
            if(granted) {
                enabled = true;
                NSLog(@"Notification access granted!");
            } else {
                enabled = false;
                NSLog(@"Notifications disabled");
            }
            [UNUserNotificationCenter.currentNotificationCenter removeAllDeliveredNotifications];
        }];
}

bool GodotLocalNotification::isEnabled()
{
    return enabled;
}

bool GodotLocalNotification::isInited()
{
    return inited;
}

void GodotLocalNotification::showLocalNotification(const String& message, const String& title, int interval, int tag)
{
    if(!enabled) {
        NSLog(@"Can not show local notification!");
        return;
    }
    NSString *msg = [NSString stringWithUTF8String:message.utf8().ptr()];
    NSString *tit = [NSString stringWithUTF8String:title.utf8().ptr()];
    NSString *ident = [NSString stringWithFormat:@"ln_%d", tag];
    NSLog(@"showLocalNotification: %@, %@, %@", msg, @(interval), @(tag));

    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:@[ident]];
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = tit;
        content.body = msg;
        //content.categoryIdentifier = @"Call menu";
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:interval repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:ident content:content trigger:trigger];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if(error) NSLog(@"Error when schedule the notification: %@", error);
            }];
    } 
}

void GodotLocalNotification::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("showLocalNotification", "message", "title", "interval", "tag"), &GodotLocalNotification::showLocalNotification);
    ClassDB::bind_method(D_METHOD("isEnabled"), &GodotLocalNotification::isEnabled);
    ClassDB::bind_method(D_METHOD("isInited"), &GodotLocalNotification::isInited);
    ClassDB::bind_method(D_METHOD("init"), &GodotLocalNotification::init);
}
