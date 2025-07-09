importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBPk9_-LMzdt_xtkp-K630BctEl3diTSZc",
  authDomain: "a2zcart-cecd2.firebaseapp.com",
  projectId: "a2zcart-cecd2",
  storageBucket: "a2zcart-cecd2.firebasestorage.app",
  messagingSenderId: "534442184736",
  appId: "1:534442184736:web:35e0ed5d8d8178da8b6c45",
  measurementId: "G-NNS69B1YVF"
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