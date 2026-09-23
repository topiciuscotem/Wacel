// Wacel Firebase Config - حط معلومات مشروعك هنا (مجاني)
// 1. سير لـ https://console.firebase.google.com/
// 2. Create Project > Wacel
// 3. Firestore Database > Create > Start in test mode
// 4. Project Settings > General > Your apps > Web > انسخ الـ config

const firebaseConfig = {
  apiKey: "ضع API KEY هنا",
  authDomain: "wacel-ma.firebaseapp.com",
  projectId: "wacel-ma",
  storageBucket: "wacel-ma.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456:web:xxxxxx"
};

// لا تنسى تفعل هاد الخدمات فـ Firebase Console:
// - Authentication > Sign-in method > Google + Anonymous = Enable
// - Firestore Database > Rules: بدلها بهادي باش يخدم المنتدى والمتجر:

/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /forum/{doc} { allow read, write: if true; }
    match /comments/{doc} { allow read, write: if true; }
    match /orders/{doc} { allow read, write: if true; }
    match /products/{doc} { allow read: if true; allow write: if false; }
  }
}
*/

export default firebaseConfig;
