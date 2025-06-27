importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCdgxeJwA57mS2EOG80gvmva7Af83QgQc0",
  authDomain: "talkaalseva.firebaseapp.com",
  projectId: "talkaalseva",
  storageBucket: "talkaalseva.firebasestorage.app",
  messagingSenderId: "996097508873",
  appId: "1:996097508873:web:60cafca3c1e342de171ad8",
  measurementId: "G-6R1327PD44"
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