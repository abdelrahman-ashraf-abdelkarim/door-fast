# Door Fast Captain App

Flutter captain app for Door Fast delivery operations.

## Configuration

API and realtime connection values are provided at build/run time with Dart
environment variables. Do not hardcode production IP addresses or API keys in
source code.

Available variables:

- `BASE_URL`: Backend API root, for example `http://192.168.1.14:8000/api`
- `REVERB_KEY`: Reverb/Pusher app key
- `API_KEY`: Optional realtime API key override. Defaults to `REVERB_KEY`
- `WS_URL`: WebSocket URL. Defaults to `ws://localhost:8000`
- `REVERB_HOST`: Reverb host. Defaults to `localhost`
- `REVERB_PORT`: Reverb port. Defaults to `8000`
- `PUSHER_CLUSTER`: Pusher cluster. Defaults to `mt1`

## Run

```bash
flutter run \
  --dart-define=BASE_URL=http://192.168.1.14:8000/api \
  --dart-define=REVERB_KEY=xxx \
  --dart-define=WS_URL=ws://192.168.1.14:8000 \
  --dart-define=REVERB_HOST=192.168.1.14 \
  --dart-define=REVERB_PORT=8000 \
  --dart-define=PUSHER_CLUSTER=mt1
```

If `API_KEY` is different from `REVERB_KEY`, add:

```bash
--dart-define=API_KEY=xxx
```

## إعداد Firebase

1. احصل على ملف `google-services.json` من [Firebase Console](https://console.firebase.google.com)
2. ضعه في المسار: `android/app/google-services.json`
3. لا ترفع هذا الملف للـ repository أبداً
