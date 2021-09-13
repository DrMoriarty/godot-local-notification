//
//  LocalNotification.mm
//
//  Created by Vasiliy on 25.04.19.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LocalNotification.hpp"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <objc/runtime.h>

using namespace godot;

static NSString *deviceToken;
static LocalNotification * notificationObject;

/*****************
 *
 * MyNotificationListener
 *
 *****************/

/*
@interface MyNotificationListener : NSObject

-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification;

@end

@implementation MyNotificationListener {
    GodotLocalNotification * notificationObject;
}

-(void)setNotificationObject:(GodotLocalNotification*)no
{
    notificationObject = no;
}

-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification
{
    NSLog(@"Catched up device token for remote notifications: %@", notification.object);
    if(notification && notification.object && [notification.object isKindOfClass:NSData.class]) {
        NSData *d = notification.object;
        NSString *str = [[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding];
        notificationObject->setDeviceToken(str);
    }
}

@end

static MyNotificationListener *notificationListener = nil;
*/

/*****************
 *
 * UIApplicationDelegate swizzling
 *
 *****************/

typedef IMP *IMPPointer;

BOOL class_swizzleMethodAndStore(Class cl, SEL original, IMP replacement, IMPPointer store, const char* types = NULL) {
    IMP imp = NULL;
    Method method = class_getInstanceMethod(cl, original);
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(cl, original, replacement, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    } else if(types != NULL) {
        imp = class_replaceMethod(cl, original, replacement, types);
    }
    if (imp && store) *store = imp; 
    return (imp != NULL);
}

@interface UIApplicationDelegateReloader : NSObject
@end

@implementation UIApplicationDelegateReloader {
}

static void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication *application, NSData *deviceToken);
static void (*didRegisterForRemoteNotificationsWithDeviceTokenIMP)(id self, SEL _cmd, UIApplication *application, NSData *deviceToken);
static void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication *application, NSData *deviceToken) {

    if(didRegisterForRemoteNotificationsWithDeviceTokenIMP != nil)
        didRegisterForRemoteNotificationsWithDeviceTokenIMP(self, _cmd, application, deviceToken);

    //[NSNotificationCenter.defaultCenter postNotificationName:@"DEVICE_TOKEN" object:deviceToken];
    NSLog(@"Catched up device token for remote notifications: %@", deviceToken);
    if(notificationObject) {
        NSString *str = [[NSString alloc] initWithData:deviceToken encoding:NSASCIIStringEncoding];
        notificationObject->setDeviceToken((__bridge void*)str);
    }
}

static void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication *application, NSError* error);
static void (*didFailToRegisterForRemoteNotificationsWithErrorIMP)(id self, SEL _cmd, UIApplication *application, NSError* error);
static void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication *application, NSError* error) {
    if(didFailToRegisterForRemoteNotificationsWithErrorIMP != nil)
        didFailToRegisterForRemoteNotificationsWithErrorIMP(self, _cmd, application, error);

    NSLog(@"Failed registering for remote notifications: %@", error);
}

static void didReceiveRemoteNotification(id self, SEL _cmd, UIApplication *application, NSDictionary *userInfo, void (^completionHandler)(UIBackgroundFetchResult result));
static void (*didReceiveRemoteNotificationIMP)(id self, SEL _cmd, UIApplication *application, NSDictionary *userInfo, void (^completionHandler)(UIBackgroundFetchResult result));
static void didReceiveRemoteNotification(id self, SEL _cmd, UIApplication *application, NSDictionary *userInfo, void (^completionHandler)(UIBackgroundFetchResult result)) {
    if(didReceiveRemoteNotificationIMP != nil)
        didReceiveRemoteNotificationIMP(self, _cmd, application, userInfo, completionHandler);
    
    NSLog(@"Did receive remote notification: %@", userInfo);
}

+ (BOOL)swizzle:(NSObject*)target method:(SEL)original with:(IMP)replacement store:(IMPPointer)store types:(const char*)types {
    if(!target) {
        NSLog(@"Can not swizzle method for nil");
        return NO;
    }
    return class_swizzleMethodAndStore(target.class, original, replacement, store, types);
}

+ (void)load
{
    // makeSwizzling();
}

+ (void)makeSwizzling
{
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
            NSObject *delegate = UIApplication.sharedApplication.delegate;

            [self swizzle:delegate method:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) with:(IMP)didRegisterForRemoteNotificationsWithDeviceToken store:(IMP*)&didRegisterForRemoteNotificationsWithDeviceTokenIMP types:"v@:@@"];
            [self swizzle:delegate method:@selector(application:didFailToRegisterForRemoteNotificationsWithError:) with:(IMP)didFailToRegisterForRemoteNotificationsWithError store:(IMP*)&didFailToRegisterForRemoteNotificationsWithErrorIMP types:"v@:@@"];
            [self swizzle:delegate method:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:) with:(IMP)didReceiveRemoteNotification store:(IMP*)&didReceiveRemoteNotificationIMP types:"v@:@@?"];
            
            NSLog(@"Swizzle UIApplicationDelegate methods");
        });
}

@end

/*****************
 *
 * GodotLocalNotification
 *
 *****************/

LocalNotification::LocalNotification()
{
    notificationObject = this;
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
    [UIApplicationDelegateReloader makeSwizzling];
}

LocalNotification::~LocalNotification()
{
}

void LocalNotification::_init()
{
}

void LocalNotification::init()
{
    if(inited) return;
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            inited = true;
            if(error) NSLog(@"Registering notification error: %@", error);
            if(granted) {
                enabled = true;
                NSLog(@"Notification access granted!");
                emit_signal("notifications_enabled");
            } else {
                enabled = false;
                NSLog(@"Notifications disabled");
            }
            [UNUserNotificationCenter.currentNotificationCenter removeAllDeliveredNotifications];
        }];
}

bool LocalNotification::isEnabled()
{
    return enabled;
}

bool LocalNotification::isInited()
{
    return inited;
}

void LocalNotification::showLocalNotification(const String message, const String title, int interval, int tag)
{
    if(!enabled) {
        NSLog(@"Can not show local notification!");
        return;
    }
    NSString *msg = [NSString stringWithUTF8String:message.utf8().get_data()];
    NSString *tit = [NSString stringWithUTF8String:title.utf8().get_data()];
    NSString *ident = [NSString stringWithFormat:@"ln_%d", tag];
    NSLog(@"showLocalNotification: %@, %@, %@", msg, @(interval), @(tag));

    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:@[ident]];
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = tit;
        content.body = msg;
        content.sound = [UNNotificationSound defaultSound];

        //content.categoryIdentifier = @"Call menu";
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:interval repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:ident content:content trigger:trigger];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if(error) NSLog(@"Error when schedule the notification: %@", error);
            }];
    } 
}

void LocalNotification::showRepeatingNotification(const godot::String message, const godot::String title, int interval, int tag, int repeating_interval)
{
    if(!enabled) {
        NSLog(@"Can not show local notification!");
        return;
    }
    NSString *msg = [NSString stringWithUTF8String:message.utf8().get_data()];
    NSString *tit = [NSString stringWithUTF8String:title.utf8().get_data()];
    NSString *ident = [NSString stringWithFormat:@"ln_%d", tag];
    NSLog(@"showRepeatingNotification: %@, %@, %@", msg, @(interval), @(tag));

    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:@[ident]];
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = tit;
        content.body = msg;
        content.sound = [UNNotificationSound defaultSound];

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:repeating_interval repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:ident content:content trigger:trigger];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if(error) NSLog(@"Error when schedule the notification: %@", error);
            }];
    } 
}

void LocalNotification::showDailyNotification(const godot::String message, const godot::String title, int hour, int minute, int tag)
{
    if(!enabled) {
        NSLog(@"Can not show local notification!");
        return;
    }
    NSString *msg = [NSString stringWithUTF8String:message.utf8().get_data()];
    NSString *tit = [NSString stringWithUTF8String:title.utf8().get_data()];
    NSString *ident = [NSString stringWithFormat:@"ln_%d", tag];
    NSLog(@"showDailyNotification: %@, %@:%@, %@", msg, @(hour), @(minute), @(tag));

    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:@[ident]];
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        content.title = tit;
        content.body = msg;
        content.sound = [UNNotificationSound defaultSound];

        NSDateComponents* date = [[NSDateComponents alloc] init];
        date.hour = hour;
        date.minute = minute;

        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:ident content:content trigger:trigger];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if(error) NSLog(@"Error when schedule the notification: %@", error);
            }];
    }
}

void LocalNotification::cancelLocalNotification(int tag)
{
    NSString *ident = [NSString stringWithFormat:@"ln_%d", tag];
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:@[ident]];
    }
}

void LocalNotification::cancelAllNotifications()
{
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter.currentNotificationCenter removeAllPendingNotificationRequests];
    }
}

void LocalNotification::registerRemoteNotifications()
{
    //notificationListener = [MyNotificationListener new];
    //[notificationListener setNotificationObject:this];
    //[NSNotificationCenter.defaultCenter addObserver:notificationListener selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:@"DEVICE_TOKEN" object:nil];

    [UIApplication.sharedApplication registerForRemoteNotifications];
}

void LocalNotification::setDeviceToken(void* devToken)
{
    deviceToken = [(__bridge NSString*)devToken copy];
    String dt = String(deviceToken.UTF8String);
    emit_signal("device_token_received", dt);
    NSLog(@"Sent device token: %@", deviceToken);
}

String LocalNotification::getDeviceToken()
{
    String dt = String(deviceToken.UTF8String);
    return dt;
}

Dictionary LocalNotification::getNotificationData()
{
    return Dictionary();
}

String LocalNotification::getDeeplinkAction()
{
    return String("");
}

String LocalNotification::getDeeplinkUri()
{
    return String("");
}

void LocalNotification::_register_methods()
{
    register_method("_init", &LocalNotification::_init);
    register_method("showLocalNotification", &LocalNotification::showLocalNotification);
    register_method("showRepeatingNotification", &LocalNotification::showRepeatingNotification);
    register_method("showDailyNotification", &LocalNotification::showDailyNotification);
    register_method("cancelLocalNotification", &LocalNotification::cancelLocalNotification);
    register_method("cancelAllNotifications", &LocalNotification::cancelAllNotifications);
    register_method("isEnabled", &LocalNotification::isEnabled);
    register_method("isInited", &LocalNotification::isInited);
    register_method("init", &LocalNotification::init);
    register_method("register_remote_notification", &LocalNotification::registerRemoteNotifications);
    register_method("get_device_token", &LocalNotification::getDeviceToken);
    register_method("get_notification_data", &LocalNotification::getNotificationData);
    register_method("get_deeplink_action", &LocalNotification::getDeeplinkAction);
    register_method("get_deeplink_uri", &LocalNotification::getDeeplinkUri);

    register_signal<LocalNotification>("notifications_enabled");
    register_signal<LocalNotification>("device_token_received", "device_token", GODOT_VARIANT_TYPE_STRING);
}
