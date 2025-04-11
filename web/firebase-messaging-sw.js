importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDTUiWpck17q6yt3L_nfrlI-iP0gQIp3h4",
  authDomain: "lucklore-packaged.firebaseapp.com",
  projectId: "lucklore-packaged",
  storageBucket: "lucklore-packaged.firebasestorage.app",
  messagingSenderId: "941538571278",
  appId: "1:941538571278:web:94e7e4d47579d03b52b85f",
  measurementId: "G-8CBCMM6QZ9"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});