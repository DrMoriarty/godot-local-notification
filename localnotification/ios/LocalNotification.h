//
//  LocalNotification.h
//
//  Created by Vasiliy on 25.04.19.
//
//

#ifndef LocalNotification_h
#define LocalNotification_h

#include "core/object.h"

class GodotLocalNotification : public Object {
    GDCLASS(GodotLocalNotification, Object);

    static void _bind_methods();
    bool enabled;
    bool inited;

public:
    GodotLocalNotification();
    ~GodotLocalNotification();

    void showLocalNotification(const String& message, const String& title, int interval, int tag);
    bool isEnabled();
    bool isInited();
    void init();

};

#endif /* LocalNotification_h */
