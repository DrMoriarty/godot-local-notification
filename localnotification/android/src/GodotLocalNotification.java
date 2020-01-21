package org.godotengine.godot;

import android.app.Activity;
import android.app.PendingIntent;
import android.app.AlarmManager;
import android.os.Bundle;
import android.content.Intent;
import android.util.Log;
import android.net.Uri;
import java.util.Map;
import java.util.List;
import java.util.Arrays;
import java.util.Calendar;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

public class GodotLocalNotification extends Godot.SingletonBase {

    private Godot activity = null;
    private Dictionary notificationData = new Dictionary();
    private String action = null;
    private String uri = null;

    static public Godot.SingletonBase initialize(Activity p_activity) 
    { 
        return new GodotLocalNotification(p_activity); 
    } 

    public GodotLocalNotification(Activity p_activity) 
    {
        registerClass("GodotLocalNotification", new String[]{
                "init",
                "showLocalNotification",
                "isInited",
                "isEnabled",
                "register_remote_notification",
                "get_device_token",
                "get_notification_data",
                "get_deeplink_action",
                "get_deeplink_uri"
            });
        activity = (Godot)p_activity;
        checkIntent();
    }

    // Public methods

    public void init() {
    }

    public boolean isInited() {
        return true;
    }

    public boolean isEnabled() {
        return true;
    }

    public void showLocalNotification(String message, String title, int interval, int tag) {
        if(interval <= 0) return;
        Log.i("godot", "showLocalNotification: "+message+", "+Integer.toString(interval)+", "+Integer.toString(tag));
        PendingIntent sender = getPendingIntent(message, title, tag);
               
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.add(Calendar.SECOND, interval);
               
        AlarmManager am = (AlarmManager)activity.getSystemService(activity.ALARM_SERVICE);
        am.set(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), sender);
    }

    public void register_remote_notification() {
    }

    public String get_device_token() {
        return "";
    }

    // Internal methods

    private PendingIntent getPendingIntent(String message, String title, int tag) {
        Intent i = new Intent(activity.getApplicationContext(), LocalNotificationReceiver.class);
        i.putExtra("notification_id", tag);
        i.putExtra("message", message);
        i.putExtra("title", title);
        PendingIntent sender = PendingIntent.getBroadcast(activity, tag, i, PendingIntent.FLAG_UPDATE_CURRENT);
        return sender;
    }

    @Override protected void onMainActivityResult (int requestCode, int resultCode, Intent data)
    {
    }

    @Override protected void onMainResume() {
        checkIntent();
    } 

    private void checkIntent() {
        Intent intent = Godot.getCurrentIntent();
        if(intent == null) {
            Log.e("godot", "RN: No intent in app activity!");
            return;
        }
        if(intent.getExtras() != null) {
            Bundle extras = Godot.getCurrentIntent().getExtras();
            Log.e("godot", "RN: Extras:" + extras.toString());
            notificationData = new Dictionary();
            for (String key : extras.keySet()) {
                Object value = extras.get(key);
                try {
                    notificationData.put(key, value);
                } catch(Exception e) {
                    Log.e("godot", "RN: Conversion error: " + e.toString());
                    e.printStackTrace();
                }
                Log.e("godot", "RN: Extras content: " + notificationData.toString());
            }
        } else {
            Log.e("godot", "RN: No extra bundle in app activity!");
        }
        if(intent.getAction() != null) {
            action = intent.getAction();
        }
        if(intent.getData() != null) {
            uri = intent.getData().toString();
        }
    }

    public Dictionary get_notification_data() {
        return notificationData;
    }

    public String get_deeplink_action() {
        return action;
    }

    public String get_deeplink_uri() {
        return uri;
    }
}
