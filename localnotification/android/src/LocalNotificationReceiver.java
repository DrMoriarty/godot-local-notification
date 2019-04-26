package org.godotengine.godot;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import android.net.Uri;
import android.media.RingtoneManager;

public class LocalNotificationReceiver extends BroadcastReceiver {
    private static final String TAG = "Notification";

	@Override
	public void onReceive(Context context, Intent intent) {
		int notificationId = intent.getIntExtra("notification_id", 0);
		String message = intent.getStringExtra("message");
        String title = intent.getStringExtra("title");
        Log.i(TAG, "Receive notification: "+message);

		Intent intent2 = new Intent(context, Godot.class);
		intent2.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent2,
				PendingIntent.FLAG_UPDATE_CURRENT);

        int iconID = context.getResources().getIdentifier("icon", "drawable", context.getPackageName());
		Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), iconID);
		NotificationCompat.Builder builder = new NotificationCompat.Builder(context);
		//builder.setContentTitle(context.getString(R.string.app_name));
        builder.setContentTitle(title);
		builder.setContentText(message);
		builder.setSmallIcon(iconID);
		builder.setLargeIcon(largeIcon);
		builder.setTicker(message);
		builder.setAutoCancel(true);
		builder.setDefaults(Notification.DEFAULT_ALL);
		builder.setContentIntent(pendingIntent);
        //builder.setSound(Uri.parse("android.resource://" + context.getPackageName() + "/" + R.raw.bomb3));
        //builder.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE));
        //long[] pattern = {10,10};
        //builder.setVibrate(pattern);

        Notification notification = builder.build();
        //notification.sound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
        //notification.vibrate = pattern;

		NotificationManager manager = (NotificationManager) context
				.getSystemService(Context.NOTIFICATION_SERVICE);

		manager.notify(notificationId, notification);
	}

}
