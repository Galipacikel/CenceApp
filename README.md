# cence_app

Flutter + Firebase teknik servis uygulaması.

## Firebase Kurulumu

1) Firebase projeni oluştur ve Android/iOS konfig dosyalarını ekle:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

2) Firestore koleksiyonları:
- `users`, `devices`, `service_records`, `service_records_archive`, `spare_parts`

3) Offline cache:
- `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);`

## Kurulum

```bash
flutter pub get
flutter run
```
