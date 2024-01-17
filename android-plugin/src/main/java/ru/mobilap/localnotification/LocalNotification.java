package ru.mobilap.localnotification;

import android.app.Activity;
import android.app.PendingIntent;
import android.app.AlarmManager;
import android.os.Bundle;
import android.content.Intent;
import android.util.Log;
import android.net.Uri;
import android.view.View;
import java.util.Map;
import java.util.List;
import java.util.Arrays;
import java.util.List;
import java.util.Calendar;

import org.godotengine.godot.plugin.UsedByGodot;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import org.godotengine.godot.Godot;
import org.godotengine.godot.GodotLib;
import org.godotengine.godot.Dictionary;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;

public class LocalNotification extends GodotPlugin {

    private final String TAG = LocalNotification.class.getName();
    private Dictionary notificationData = new Dictionary();
    private String action = null;
    private String uri = null;
    private Boolean intentWasChecked = false;

    public LocalNotification(Godot godot) 
    {
        super(godot);
        intentWasChecked = false;
        //checkIntent();
    }

    @Override
    public String getPluginName() {
        return "LocalNotification";
    }

    @Override
    public List<String> getPluginMethods() {
        return Arrays.asList(
                "init",
                "showLocalNotification",
                "showRepeatingNotification",
                "cancelLocalNotification",
                "cancelAllNotifications",
                "isInited",
                "isEnabled",
                "register_remote_notification",
                "get_device_token",
                "get_notification_data",
                "get_deeplink_action",
                "get_deeplink_uri"
        );
    }

    /*
    @Override
    public Set<SignalInfo> getPluginSignals() {
        return Collections.singleton(loggedInSignal);
    }
    */

    @Override
    public View onMainCreate(Activity activity) {
        return null;
    }

    // Public methods
    @UsedByGodot
    public void init() {
    }
    @UsedByGodot
    public boolean isInited() {
        return true;
    }
    @UsedByGodot
    public boolean isEnabled() {
        return true;
    }
    @UsedByGodot
    public void showLocalNotification(String message, String title, int interval, int tag) {
        if(interval <= 0) return;
        Log.d(TAG, "showLocalNotification: "+message+", "+Integer.toString(interval)+", "+Integer.toString(tag));
        PendingIntent sender = getPendingIntent(message, title, tag);

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.add(Calendar.SECOND, interval);
               
        AlarmManager am = (AlarmManager)getActivity().getSystemService(getActivity().ALARM_SERVICE);
        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            am.setExact(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), sender);
        } else {
            am.set(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), sender);
        }
    }
    @UsedByGodot
    public void showRepeatingNotification(String message, String title, int interval, int tag, int repeat_duration) {
        if(interval <= 0) return;
        Log.d(TAG, "showRepeatingNotification: "+message+", "+Integer.toString(interval)+", "+Integer.toString(tag)+" Repeat after: "+Integer.toString(repeat_duration));
        PendingIntent sender = getPendingIntent(message, title, tag);

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.add(Calendar.SECOND, interval);
               
        AlarmManager am = (AlarmManager)getActivity().getSystemService(getActivity().ALARM_SERVICE);
        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            am.setRepeating(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), repeat_duration*1000, sender);
        } else {
            am.setInexactRepeating(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), repeat_duration*1000, sender);
        }
    }
    @UsedByGodot
    public void cancelLocalNotification(int tag) {
        AlarmManager am = (AlarmManager)getActivity().getSystemService(getActivity().ALARM_SERVICE);
        PendingIntent sender = getPendingIntent("", "", tag);
        am.cancel(sender);
    }
    @UsedByGodot
    public void cancelAllNotifications() {
        Log.w(TAG, "cancelAllNotifications not implemented");
    }
    @UsedByGodot
    public void register_remote_notification() {
    }
    @UsedByGodot
    public String get_device_token() {
        return "";
    }

    // Internal methods

    private PendingIntent getPendingIntent(String message, String title, int tag) {
        Intent i = new Intent(getActivity().getApplicationContext(), LocalNotificationReceiver.class);
        i.putExtra("notification_id", tag);
        i.putExtra("message", message);
        i.putExtra("title", title);
        PendingIntent sender = PendingIntent.getBroadcast(getActivity(), tag, i, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        return sender;
    }

    @Override public void onMainActivityResult (int requestCode, int resultCode, Intent data)
    {
    }

    @Override public void onMainResume() {
        //checkIntent();
        intentWasChecked = false;
    } 

    private void checkIntent() {
        Log.w(TAG, "I'm going to check application intent");
        Intent intent = Godot.getCurrentIntent();
        if(intent == null) {
            Log.d(TAG, "No intent in app activity");
            return;
        }
        Log.w(TAG, "The intent isn't null, so check it closely.");
        if(intent.getExtras() != null) {
            Bundle extras = Godot.getCurrentIntent().getExtras();
            Log.d(TAG, "Extras:" + extras.toString());
            notificationData = new Dictionary();
            for (String key : extras.keySet()) {
                Object value = extras.get(key);
                try {
                    notificationData.put(key, value);
                    Log.w(TAG, "Get new value " + value.toString() + " for key " + key);
                } catch(Exception e) {
                    Log.d(TAG, "Conversion error: " + e.toString());
                    e.printStackTrace();
                }
            }
            Log.d(TAG, "Extras content: " + notificationData.toString());
        } else {
            Log.d(TAG, "No extra bundle in app activity!");
        }
        if(intent.getAction() != null) {
            Log.w(TAG, "Get deeplink action from intent");
            action = intent.getAction();
        }
        if(intent.getData() != null) {
            Log.w(TAG, "Get uri from intent");
            uri = intent.getData().toString();
        }
        intentWasChecked = true;
    }
    @UsedByGodot
    public Dictionary get_notification_data() {
        if(!intentWasChecked) checkIntent();
        return notificationData;
    }
    @UsedByGodot
    public String get_deeplink_action() {
        if(!intentWasChecked) checkIntent();
        return action;
    }
    @UsedByGodot
    public String get_deeplink_uri() {
        if(!intentWasChecked) checkIntent();
        return uri;
    }
}
