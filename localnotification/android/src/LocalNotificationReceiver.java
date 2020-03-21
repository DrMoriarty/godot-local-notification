package org.godotengine.godot;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.NotificationChannel;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import androidx.core.app.NotificationCompat;
import android.util.Log;
import android.net.Uri;
import android.media.RingtoneManager;
import com.godot.game.GodotApp;

public class LocalNotificationReceiver extends BroadcastReceiver {
    private static final String TAG = "Notification";
    public static final String NOTIFICATION_CHANNEL_ID = "10001" ;

    @Override
    public void onReceive(Context context, Intent intent) {
        int notificationId = intent.getIntExtra("notification_id", 0);
        String message = intent.getStringExtra("message");
        String title = intent.getStringExtra("title");
        Log.i(TAG, "Receive notification: "+message);

        NotificationManager manager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O ) {
            int importance = NotificationManager.IMPORTANCE_HIGH ;
            NotificationChannel notificationChannel = new NotificationChannel( NOTIFICATION_CHANNEL_ID , "NOTIFICATION_CHANNEL_NAME" , importance) ;
            notificationChannel.setShowBadge(true);
            //builder.setChannelId( NOTIFICATION_CHANNEL_ID ) ;
            manager.createNotificationChannel(notificationChannel) ;
        }

        Intent intent2 = new Intent(context, GodotApp.class);
        intent2.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent2, PendingIntent.FLAG_UPDATE_CURRENT);

        int iconID = context.getResources().getIdentifier("icon", "mipmap", context.getPackageName());
        Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), iconID);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID);
        //builder.setContentTitle(context.getString(R.string.app_name));
        builder.setShowWhen(false);
        builder.setContentTitle(title);
        builder.setContentText(message);
        builder.setSmallIcon(iconID);
        builder.setLargeIcon(largeIcon);
        builder.setTicker(message);
        builder.setAutoCancel(true);
        builder.setDefaults(Notification.DEFAULT_ALL);
        builder.setContentIntent(pendingIntent);
        builder.setNumber(1);
        //builder.setSound(Uri.parse("android.resource://" + context.getPackageName() + "/" + R.raw.bomb3));
        builder.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE));
        //long[] pattern = {10,10};
        //builder.setVibrate(pattern);
        builder.setPriority(NotificationCompat.PRIORITY_HIGH);

        Notification notification = builder.build();
        notification.sound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
        //notification.vibrate = pattern;

        manager.notify(notificationId, notification);
    }

}
