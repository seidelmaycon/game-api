# Game Stats API

This is a RESTful JSON API built with Ruby on Rails to support a mobile game app. It allows users to sign up, log in, submit game completion events, and retrieve personalized stats — including subscription status from an external billing service.

## Dependencies
- **Ruby**: 3.3.5
- **Rails**: 8.0.2
- **Database**: PostgreSQL


## Setup Instructions

1. Clone and Install Dependencies

```bash
git clone git@github.com:seidelmaycon/game-api.git
cd game-api
bundle install
```

2. Setup Database: `rails db:setup`

3. Run the Server: `rails server`

4. Environment

*The `config/master.key` is exceptionally versioned in the repository.*

## Running Tests

The API has unit tests powered by RSpec.

To run all tests: `rspec`

## API Details

### Authentication

This API uses **JWT-based stateless authentication**, which is ideal for mobile clients:

- Users sign up via `POST /api/user` with email and password.
  - User is created with password encrypted using `has_secure_password` and `bcrypt`.
- Upon login (`POST /api/sessions`), a JWT is issued.
  - JWT is signed using Rails' secret key base.
  - JWT is valid for 7 days.
- The JWT must be included in future requests using the `Authorization: Bearer <token>` header.

**Why JWT?**

- Stateless and scalable (no sessions to track);
- Mobile and REST friendly;
- Easy to test and extend;

### Game Event Submission

Authenticated users can submit game events:

```json
curl --request POST \
  --url http://localhost:3000/api/user/game_events \
  --header 'authorization: Bearer <JWT-TOKEN>' \
  --header 'content-type: application/json' \
  --data '{
  "game_event": {
    "game_name":"Brevity",
    "type":"COMPLETED",
    "occurred_at":"2025-04-01T00:00:00.00Z"
  }
}'
```

- Only `COMPLETED` is accepted as a type.
- This endpoint is idempotent, meaning identical requests will return the same result.
- Expected http codes:
  - 201: if the game event was created;
  - 200: if identical game event already exists;
  - 401: if the JWT is invalid;
  - 422: if the game event is invalid
    - An example of unprocessable entity response body:
      - `{ "errors": [ "Type is not included in the list" ] }`

## User Stats

Authenticated users can retrieve their details, stats and subscription status:

```json
curl --request GET \
  --url http://localhost:3000/api/user \
  --header 'authorization: Bearer <JWT-TOKEN>' \
  --header 'content-type: application/json'
```

```json
GET /api/user
{
  "user": {
    "id": 1,
    "email": "test@example.com",
    "stats": {
      "total_games_played": 5
    },
    "subscription_status": "active"
  }
}
```

- Subscription status is retrieved from the external billing service.
  - Possible values: `active`, `expired`, `not_found`, `unknown`;
  - Unknown is returned when the external billing service is unavailable.
- Expected http codes:
  - 200: if the user was found;
  - 401: if the JWT is invalid;

## Design Decisions

#### JWT over Session-Based Auth
- Stateless, mobile-friendly, avoids session storage complexity.

#### Manual Auth vs Devise
- Chose `has_secure_password` + custom JWT logic for full control, transparency and readability.

#### Service Objects
- External billing integration encapsulated in a `BillingService` to keep controllers clean and code testable;
- Billing integration handles flakiness and errors gracefully (e.g., returning `"unknown"` on failure).

#### Serializer
- Use `ActiveModelSerializers` to provide a clean abstraction for JSON rendering
- Chose over alternatives like JBuilder or custom to_json for:
  - Readable, object-oriented approach to JSON formatting
  - Simple integration with Rails controllers
  - Support for nested relationships and custom attributes
  - Ability to include context-specific data (like subscription_status)
  - Separation of presentation logic from models and controllers

#### Testing
- Use RSpec for unit testing;
- Use Factory Bot for test data generation;
- Use Shoulda Matchers for common validations;
- Use WebMock for HTTP request stubs;

## Future Improvements

- Add Swagger for API documentation;
- Add refresh tokens for better auth UX;
- Add retry and cache logic for external billing service.
