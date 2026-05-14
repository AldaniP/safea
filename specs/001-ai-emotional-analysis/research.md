# Research: AI Emotional Analysis Suite

## Decision: DASS-21 Scoring Service
- **Decision**: Implement a dedicated `Dass21Scorer` service following official clinical standards.
- **Rationale**: Ensures accuracy and separation of concerns.
- **Details**:
    - Scoring: (Sum of 7 items) * 2.
    - Thresholds: 
        - Depression: Normal (0-9), Mild (10-13), Moderate (14-20), Severe (21-27), Extremely Severe (28+).
        - Anxiety: Normal (0-7), Mild (8-9), Moderate (10-14), Severe (15-19), Extremely Severe (20+).
        - Stress: Normal (0-14), Mild (15-18), Moderate (19-25), Severe (26-33), Extremely Severe (34+).
- **Alternatives considered**: Inline calculation in UI (rejected for testability).

## Decision: Interactive Virtual Character (Rive)
- **Decision**: Use **Rive** for the virtual character.
- **Rationale**: Rive supports State Machines, which allow the character to react dynamically to user emotional metadata (e.g., changing from `Idle` to `Happy` based on real-time AI feedback) with smooth blending.
- **Alternatives considered**: Lottie (rejected due to linear timeline limitations).

## Decision: In-App Professional Consultation (Agora)
- **Decision**: Use **Agora (`agora_rtc_ng`)** for video/audio consultations.
- **Rationale**: High scalability and support for Mobile/Web/Desktop (aligning with project structure). `agora_uikit` will be used for rapid prototyping.
- **Alternatives considered**: Daily.co (rejected due to limited native desktop support).

## Decision: Real-time AI Audio Analysis
- **Decision**: Leverage the existing `SocketService` pattern.
- **Rationale**: The current implementation already handles raw audio streaming to a FastAPI backend and expects `emotion_metadata_response`. 
- **Integration**: `AnalysisService` will wrap `SocketService` to map raw metadata to Rive state machine triggers.

## Decision: Gamified Points System
- **Decision**: Use `ChangeNotifier` with `provider` for global point state.
- **Rationale**: Already included in `pubspec.yaml`. Provides sufficient reactivity for updating UI point counters.
- **Persistence**: Store points in `SecureVaultService` (encrypted) to prevent local tampering in simple file storage.
