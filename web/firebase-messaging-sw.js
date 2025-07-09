importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyB9fNxE0W5zh1fg_5b6ppNgfq54oDC3xEo",
  authDomain: "easyshop-3b5e4.firebaseapp.com",
  projectId: "easyshop-3b5e4",
  storageBucket: "easyshop-3b5e4.firebasestorage.app",
  messagingSenderId: "883048804010",
  appId: "1:883048804010:web:056416232c02d84c4cead3",
  measurementId: "G-LR7ZTW8DKW"
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