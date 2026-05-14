# Tasks: AI Emotional Analysis Suite

**Input**: Design documents from `/specs/001-ai-emotional-analysis/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create project structure per implementation plan (directories under `lib/`)
- [X] T002 [P] Configure `analysis_options.yaml` with strict linting rules
- [X] T003 Ensure `SecureVaultService` is initialized in `lib/main.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [X] T004 Create base `User` entity in `lib/models/user_model.dart`
- [X] T005 [P] Implement `Dass21Scorer` service with unit tests in `lib/services/dass21_scorer.dart`
- [X] T006 [P] Setup core `AnalysisService` skeleton in `lib/services/analysis_service.dart`
- [X] T007 Implement global `PointNotifier` using Provider in `lib/services/point_notifier.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Assessment & AI Analysis (Priority: P1) 🎯 MVP

**Goal**: Complete the core loop: Assessment -> Audio Recording -> AI Analysis -> Result

**Independent Test**: Complete DASS-21 and audio recording to receive a generated emotional report.

### Implementation for User Story 1

- [X] T008 [P] [US1] Create `Assessment` model in `lib/models/assessment_model.dart`
- [X] T009 [P] [US1] Implement DASS-21 Questionnaire screen in `lib/screens/assessment/dass21_screen.dart`
- [X] T010 [US1] Implement Audio Recording interface in `lib/screens/assessment/audio_recording_screen.dart`
- [X] T011 [US1] Integrate `SocketService` for real-time audio streaming in `lib/services/analysis_service.dart`
- [X] T012 [P] [US1] Implement `VirtualCharacter` widget using Rive state machine in `lib/widgets/virtual_character.dart`
- [X] T013 [US1] Create Emotional Analysis Summary screen in `lib/screens/assessment/analysis_summary_screen.dart`

**Checkpoint**: User Story 1 (MVP) is fully functional and testable independently.

---

## Phase 4: User Story 2 - Progress & Reward Roadmap (Priority: P2)

**Goal**: Track emotional trends and award points for completing relaxation tasks.

**Independent Test**: View population of the weekly graph and earn points after a relaxation task.

### Implementation for User Story 2

- [X] T014 [P] [US2] Create `Roadmap` and `Activity` models in `lib/models/roadmap_model.dart`
- [X] T015 [US2] Implement `RoadmapService` for milestone tracking in `lib/services/roadmap_service.dart`
- [X] T016 [P] [US2] Create Dashboard screen with `fl_chart` weekly trend graph in `lib/screens/dashboard/dashboard_screen.dart`
- [X] T017 [US2] Implement point reward animation and snackbar in `lib/widgets/reward_animation.dart`

**Checkpoint**: User Stories 1 and 2 work together.

---

## Phase 5: User Story 4 - Professional Consultation (Priority: P2)

**Goal**: Host secure, in-app video/chat sessions with human therapists.

**Independent Test**: Book a therapist and join a functional video call session within the app.

### Implementation for User Story 3

- [X] T018 [P] [US3] Create `ConsultationSession` model in `lib/models/consultation_model.dart`
- [X] T019 [US3] Implement `ConsultationService` using `agora_rtc_ng` in `lib/services/consultation_service.dart`
- [X] T020 [P] [US3] Create Therapist Booking screen in `lib/screens/consultation/booking_screen.dart`
- [X] T021 [US3] Implement In-App Video Call UI in `lib/screens/consultation/video_call_screen.dart`

---

## Phase 6: User Story 3 - Affirmations & Community (Priority: P3)

**Goal**: Daily engagement through affirmations and anonymous milestone sharing.

**Independent Test**: Receive a daily affirmation and see an anonymous post in the community feed.

### Implementation for User Story 4

- [X] T022 [US4] Implement `AffirmationService` for fetching daily content in `lib/services/affirmation_service.dart`
- [X] T023 [US4] Create Community Feed screen for sharing anonymous milestones in `lib/screens/dashboard/community_screen.dart`

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final verification, performance, and security.

- [X] T024 [P] Ensure full responsive layout across all screens (Mobile/Web/Desktop)
- [X] T025 [P] Audit `SecureVaultService` usage to ensure 100% encryption coverage of personal data
- [X] T026 Final end-to-end validation using `quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Phase 1 - BLOCKS all User Stories.
- **User Stories (Phase 3+)**: All depend on Phase 2. Can proceed sequentially (P1 -> P2 -> P3) or in parallel.

### Parallel Opportunities

- T002, T005, T006 can run in parallel with initialization tasks.
- US1 UI (T009) can be built while `AnalysisService` (T011) is being integrated.
- Different User Stories (Phase 4, 5, 6) can be assigned to different developers once Phase 2 is complete.

---

## Implementation Strategy

### MVP First (Phase 3)

1. Complete Setup + Foundational.
2. Complete Phase 3 (US1).
3. **STOP and VALIDATE**: Verify the AI analysis loop works from start to finish.

### Incremental Delivery

1. Add Phase 4 (Roadmap/Graphs) to provide long-term value.
2. Add Phase 5 (Consultation) for clinical safety and escalation.
3. Add Phase 6 (Affirmations/Community) for engagement.
