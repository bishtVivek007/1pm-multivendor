importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyD7eyKiuO94YkfA8biQjO3DDUHGK6PDjKY",
  authDomain: "foodan-4ee52.firebaseapp.com",
  projectId: "foodan-4ee52",
  storageBucket: "foodan-4ee52.firebasestorage.app",
  messagingSenderId: "286606937619",
  appId: "1:286606937619:web:be94af0b527cc56bb979e6",
  measurementId: "G-886GZ1F6WJ"
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