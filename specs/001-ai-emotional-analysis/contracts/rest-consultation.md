# REST Contract: Professional Consultation

**Base URL**: `https://api.safea.com/v1`

## Endpoints

### `GET /therapists`
- **Purpose**: Retrieve a list of available psychologists/therapists.
- **Query Params**: `specialization` (Optional), `availability` (Boolean)
- **Response**: `200 OK`
    ```json
    [
      {
        "id": "uuid",
        "name": "Dr. Sarah",
        "specialization": "Anxiety Specialist",
        "rating": 4.9
      }
    ]
    ```

### `POST /consultations/book`
- **Purpose**: Book a new consultation session.
- **Request Body**:
    ```json
    {
      "therapistId": "uuid",
      "scheduledTime": "2026-05-15T10:00:00Z"
    }
    ```
- **Response**: `201 Created`
    ```json
    {
      "sessionId": "uuid",
      "rtcChannelName": "safea_room_xyz",
      "securityToken": "agora_token_abc"
    }
    ```

### `GET /affirmations/daily`
- **Purpose**: Get a private affirmation for the day.
- **Response**: `200 OK`
    ```json
    {
      "content": "You have the strength to overcome today's challenges.",
      "category": "positivity"
    }
    ```
