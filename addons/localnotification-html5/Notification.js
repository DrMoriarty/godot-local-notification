setTimeout(() => {
        sendNotification('title_parameter', {
            body: 'body_parameter',
            icon: 'img.png',
            dir: 'auto'
            //, tag: 'tag_parameter' <- can (will) be implemented
        });
    }, interval_parameter);

function sendNotification(title, options) {
    var notification = new Notification(title, options);
    // OnClick action, deep link URI realization? 
    // function clickFunc() { alert(notification.title); }
    // notification.onclick = clickFunc;
}
