importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBHd2uYqVIAv1YblA3YEP309EDoW1vsDOU",
  authDomain: "lucklore-5b602.firebaseapp.com",
  projectId: "lucklore-5b602",
  storageBucket: "lucklore-5b602.firebasestorage.app",
  messagingSenderId: "183155196837",
  appId: "1:183155196837:web:a1cc39e338b5139d9fde4c",
  measurementId: "G-K6M9GSXQWQ"
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