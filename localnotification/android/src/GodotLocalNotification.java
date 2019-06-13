package org.godotengine.godot;

import android.app.Activity;
import android.app.PendingIntent;
import android.app.AlarmManager;
import android.content.Intent;
import android.util.Log;
import java.util.Map;
import java.util.List;
import java.util.Arrays;
import java.util.Calendar;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

public class GodotLocalNotification extends Godot.SingletonBase {

    private Godot activity = null;

    static public Godot.SingletonBase initialize(Activity p_activity) 
    { 
        return new GodotLocalNotification(p_activity); 
    } 

    public GodotLocalNotification(Activity p_activity) 
    {
        registerClass("GodotLocalNotification", new String[]{"init", "showLocalNotification", "isInited", "isEnabled", "register_remote_notification", "get_device_token"});
        activity = (Godot)p_activity;
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

}
