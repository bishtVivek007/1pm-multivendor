importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBdhSMui3y6AxHqQ045ZVxW0M4XgIezGPc",
  authDomain: "quickshopy-a347b.firebaseapp.com",
  projectId: "quickshopy-a347b",
  storageBucket: "quickshopy-a347b.firebasestorage.app",
  messagingSenderId: "17078083013",
  appId: "1:17078083013:web:ceb57f87292ad44acc3fac",
  measurementId: "G-2V95N8PM6R"
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