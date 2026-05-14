# Data Model: AI Emotional Analysis Suite

## Entities

### User
- **Purpose**: Represents the application user and their gamification state.
- **Fields**:
    - `id`: UUID (Primary Key)
    - `displayName`: String
    - `totalPoints`: Integer (Default: 0)
    - `level`: Integer (Default: 1)
    - `currentRoadmapId`: UUID (Foreign Key)

### Assessment
- **Purpose**: Captures results of a DASS-21 and audio analysis session.
- **Fields**:
    - `id`: UUID
    - `userId`: UUID
    - `timestamp`: DateTime
    - `responses`: Map<Integer, Integer> (Question ID to Score 0-3)
    - `depressionScore`: Integer
    - `anxietyScore`: Integer
    - `stressScore`: Integer
    - `audioAnalysisResult`: String (Summary text from AI)

### Roadmap
- **Purpose**: A sequence of relaxation activities assigned to a user.
- **Fields**:
    - `id`: UUID
    - `userId`: UUID
    - `title`: String
    - `activities`: List<Activity>
    - `isCompleted`: Boolean

### Activity
- **Purpose**: Individual tasks within a roadmap.
- **Fields**:
    - `id`: UUID
    - `title`: String
    - `pointValue`: Integer
    - `isCompleted`: Boolean
    - `type`: Enum (Breathing, Meditation, Exercise)

### ConsultationSession
- **Purpose**: Records for in-app professional consultations.
- **Fields**:
    - `id`: UUID
    - `userId`: UUID
    - `therapistId`: UUID
    - `scheduledTime`: DateTime
    - `rtcChannelName`: String (Agora channel identifier)
    - `status`: Enum (Scheduled, Completed, Cancelled)

## Relationships

- **User** has-many **Assessments** (1:N)
- **User** has-one **Roadmap** (active) (1:1)
- **Roadmap** contains-many **Activities** (1:N)
- **User** has-many **ConsultationSessions** (1:N)

## State Transitions

### Assessment Flow
1. `Started` -> User opens DASS-21 form.
2. `ResponsesCaptured` -> Questions 1-21 answered.
3. `AudioStreaming` -> WebSocket active, data being sent.
4. `Completed` -> Backend returns emotional metadata; local scores calculated.

### Roadmap Progress
1. `Assigned` -> New assessment triggers roadmap generation.
2. `InProgress` -> Activities being completed.
3. `Completed` -> All activities finished; reward bonus points awarded.
