importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDs6mSLlayL0JvL6gVVehrNdzAFRcmRI5A",
  authDomain: "mandiatdoor-2f296.firebaseapp.com",
  projectId: "mandiatdoor-2f296",
  storageBucket: "mandiatdoor-2f296.firebasestorage.app",
  messagingSenderId: "495489572152",
  appId: "1:495489572152:web:583474f651bba1640835cd",
  measurementId: "G-9G2P3GM3HS"
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