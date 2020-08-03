#include <Godot.hpp>
#include "LocalNotification.hpp"

extern "C" void GDN_EXPORT localnotification_gdnative_init(godot_gdnative_init_options *o)
{
	godot::Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT localnotification_gdnative_terminate(godot_gdnative_terminate_options *o)
{
	godot::Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT localnotification_nativescript_init(void *handle)
{
	godot::Godot::nativescript_init(handle);


	godot::register_class<LocalNotification>();
}

extern "C" void GDN_EXPORT localnotification_gdnative_singleton()
{
}
