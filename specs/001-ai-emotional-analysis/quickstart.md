# Quickstart: AI Emotional Analysis Suite

## Local Development Setup

### 1. Prerequisites
- Flutter SDK ^3.10.4
- Python 3.9+ (for the FastAPI backend)
- Socket.IO client installed

### 2. Service Initialization
Ensure the `SecureVaultService` is initialized in your `main()` before using the app:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureVaultService.instance.initialize();
  runApp(const SafeaApp());
}
```

### 3. Testing the Analysis Flow
To test the real-time AI analysis locally:
1. Start the FastAPI Mock Server (see `api/mock/server.py`).
2. Open the "Assessment" screen in the Flutter app.
3. Complete DASS-21 and start recording.
4. Verify the `SocketService` connection and `emotion_metadata_response` logs.

## Verification Checklist

### Unit Tests
```bash
flutter test tests/unit/dass21_scorer_test.dart
flutter test tests/unit/point_accumulation_test.dart
```

### Integration Tests
```bash
flutter test integration_test/assessment_flow_test.dart
```
