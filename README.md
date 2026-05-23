# Local Services Marketplace

Cross-platform Flutter app with a **Node.js + Express + SQLite** REST API backend.

## Quick start

### 1. Start the API

```bash
cd backend
npm install
npm run seed    # first time only — demo users & data
npm run dev     # http://localhost:3000
```

### 2. Run the Flutter app

```bash
flutter pub get
flutter run
```

The app defaults to the production API: **https://localservicemarket-api.onrender.com**

Local backend during development:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Use the offline mock store instead of the API:

```bash
flutter run --dart-define=USE_MOCK_API=true
```

## Demo accounts

| Role | Email | Password |
|------|-------|----------|
| Customer | `customer@demo.com` | `password123` |
| Provider | `provider1@demo.com` | `password123` |

## Architecture

```
lib/          Flutter — Clean Architecture + BLoC
backend/      REST API — Express, SQLite, JWT auth
```

### API highlights

- `POST /api/v1/auth/login` · `register` · `GET /auth/me`
- `GET /api/v1/categories` · `services` · `providers/nearby`
- `GET /api/v1/slots` · `POST /bookings` · `PATCH /bookings/:id/status`
- `POST /api/v1/payments` · `POST /payments/:id/process`
- `POST /api/v1/reviews`

All protected routes use `Authorization: Bearer <token>`.

## Google Maps (Android)

The Maps SDK key is configured in `android/app/src/main/AndroidManifest.xml`. In [Google Cloud Console](https://console.cloud.google.com/), enable **Maps SDK for Android** and restrict the key to your app package: `com.localservicemarket.localservicemarket`.
