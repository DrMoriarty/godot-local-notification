//
//  LocalNotification.mm
//
//  Created by Vasiliy on 25.04.19.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "./LocalNotification.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <objc/runtime.h>

String GodotLocalNotification::deviceToken;
static GodotLocalNotification * notificationObject;

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
        notificationObject->setDeviceToken(str);
    }
}

static void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication *application, NSError* error);
static void didFailToRegisterForRemoteNotificationsWithErrorIMP(id self, SEL _cmd, UIApplication *application, NSError* error);
static void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication *application, NSError* error) {
    if(didFailToRegisterForRemoteNotificationsWithErrorIMP != nil)
        didFailToRegisterForRemoteNotificationsWithErrorIMP(self, _cmd, application, error);

    NSLog(@"Failed registering for remote notifications: %@", error);
}

static void didReceiveRemoteNotification(id self, SEL _cmd, UIApplication *application, NSDictionary *userInfo, void (^completionHandler)(UIBackgroundFetchResult result));
static void didReceiveRemoteNotificationIMP(id self, SEL _cmd, UIApplication *application, NSDictionary *userInfo, void (^completionHandler)(UIBackgroundFetchResult result));
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

GodotLocalNotification::GodotLocalNotification()
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
                emit_signal("notifications_enabled");
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

void GodotLocalNotification::registerRemoteNotifications()
{
    //notificationListener = [MyNotificationListener new];
    //[notificationListener setNotificationObject:this];
    //[NSNotificationCenter.defaultCenter addObserver:notificationListener selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:@"DEVICE_TOKEN" object:nil];

    [UIApplication.sharedApplication registerForRemoteNotifications];
}

void GodotLocalNotification::setDeviceToken(void* devToken)
{
    NSString *str = (NSString*)devToken;
    deviceToken = String(str.UTF8String);
    emit_signal("device_token_received", deviceToken);
    print_line(String("Sent device token: ")+deviceToken);
}

String GodotLocalNotification::getDeviceToken()
{
    return deviceToken;
}

void GodotLocalNotification::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("showLocalNotification", "message", "title", "interval", "tag"), &GodotLocalNotification::showLocalNotification);
    ClassDB::bind_method(D_METHOD("isEnabled"), &GodotLocalNotification::isEnabled);
    ClassDB::bind_method(D_METHOD("isInited"), &GodotLocalNotification::isInited);
    ClassDB::bind_method(D_METHOD("init"), &GodotLocalNotification::init);
    ClassDB::bind_method(D_METHOD("register_remote_notification"), &GodotLocalNotification::registerRemoteNotifications);
    ClassDB::bind_method(D_METHOD("get_device_token"), &GodotLocalNotification::getDeviceToken);
    ADD_SIGNAL(MethodInfo("notifications_enabled"));
    ADD_SIGNAL(MethodInfo("device_token_received"));
}
