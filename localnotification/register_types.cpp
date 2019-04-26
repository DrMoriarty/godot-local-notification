#include "register_types.h"
#if defined(__APPLE__)
#include "ios/LocalNotification.h"
#endif

void register_localnotification_types() {
#if defined(__APPLE__)
	ClassDB::register_class<GodotLocalNotification>();
#endif
}

void unregister_localnotification_types() {
}
