# WebSocket Contract: AI Emotional Analysis

**Protocol**: Socket.IO
**Namespace**: `/analysis`

## Client Emitters

### `microphone_audio_stream`
- **Description**: Streams raw audio bytes from the user's microphone for real-time analysis.
- **Payload**: `Uint8List` (Binary)
- **Frequency**: Every 1 second (recommended).

### `start_session`
- **Payload**:
    ```json
    {
      "userId": "uuid",
      "assessmentId": "uuid"
    }
    ```

## Server Emitters (Listeners)

### `emotion_metadata_response`
- **Description**: Real-time feedback on the emotional state detected from the audio stream.
- **Payload**:
    ```json
    {
      "stability_score": 0.85,
      "detected_emotions": {
        "calm": 0.7,
        "anxiety": 0.2,
        "stress": 0.1
      },
      "character_trigger": "happy",
      "transcript_snippet": "I am feeling a bit better today..."
    }
    ```

### `final_analysis_summary`
- **Description**: Summary report generated after the `audio_stream` is closed.
- **Payload**:
    ```json
    {
      "summary": "User shows signs of mild anxiety, recommended breathing exercise.",
      "roadmap_suggestion_id": "roadmap_001"
    }
    ```
