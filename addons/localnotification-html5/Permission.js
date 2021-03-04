// Checking if browser supports HTML5 Notifications
if (!("Notification" in window)) {
	alert('Godot can\'t show notifications in your browser: notifications aren\'t supported!');
}

// Permissions request if not granted 
else if (Notification.permission !== 'denied') {
	Notification.requestPermission((permission) => {
			// Permission request callback result
			if (permission === "granted") {
				// It's OK
			} else {
				// It's not
				alert('Godot can\'t show notifications in your browser: notifications were blocked!');
			}
		});
} else {
	// Notifications were denied already or blocked system-wide
	console.warn('Godot can\'t show notifications in your browser: notifications were blocked!')
}
