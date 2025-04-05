importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDwsr1PHGRNLAN-rO6EqMSTOs_6k7aJY1M",
  authDomain: "pm-507ed.firebaseapp.com",
  projectId: "pm-507ed",
  storageBucket: "pm-507ed.firebasestorage.app",
  messagingSenderId: "417474721005",
  appId: "1:417474721005:web:314599404f47a1758308e4",
  measurementId: "G-WGE37ED1LJ"
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