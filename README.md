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

This API uses **JWT-based stateless authentication**:

- Users sign up via `POST /api/user` with email and password (minimum 8 characters, 1 letter, 1 number).
- Upon login (`POST /api/sessions`), a JWT is issued.
  - JWT is valid for 7 days.
- The JWT must be included in future requests using the `Authorization: Bearer <token>` header or `Authorization: <token>`.

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

#### Authentication
##### **JWT-Based Authentication**: Implemented a stateless JWT authentication system instead of session-based auth for its mobile-friendliness and elimination of server-side session storage complexity.

**Why JWT?**
- Stateless and scalable (no sessions to track):
  - JWTs are self-contained, making them ideal for stateless authentication and avoiding hitting the database on every request;
- Mobile and REST friendly:
  - JWTs empower mobile clients with a simple, secure, and scalable way to authenticate — without relying on web-specific mechanics like cookies or session state;
- Easy to test and extend:
  - JWTs are simple to mock and test;

**Token Implementation**:
- JWT tokens are generated using the HMAC-SHA256 algorithm (HS256);
- Tokens contain the `user_id` as payload, Rails' `secret_key_base` as the signing key, and a 7-day expiration time;
- Authentication headers follow the standard `Bearer {token}` format, but also supports `Authorization: {token}`, because specs are not clear about the format;
- User passwords are securely hashed via `has_secure_password` after a complexity validation.

#### Game Events Controller

There is a know race condition in the game events controller, where is possible to run the `find` before another identical request creates the record. This would make one request succeed (the one that creates the record) and the other fails due the unique violation.

To avoid data integrity issues, I added the unique index on the `game_name` and `type` columns.

I could have used an upsert strategy to eliminate the race condition, but I chose to go with the unique index for simplicity in this case, since upsert skips active record validations.


#### Event Type vs Type

The API handles a naming conflict between the mobile app's expectations and Rails conventions:

- The mobile app sends `type` in requests (as specified in requirements)
- Since `type` is a reserved keyword in Rails (used for Single Table Inheritance), I used `event_type` internally
- This required additional code to map between external `type` and internal `event_type`

The requirements also specified that only `"COMPLETED"` is accepted as a type value. Although I could have hardcoded this value, I chose to properly validate and store the incoming type to maintain API flexibility for future enhancements.

#### Game Events Controller

To support idempotency in the Game Events API, the controller follows a "find-then-create" pattern: it first checks if an identical game event exists before attempting to create a new one. This approach introduces a potential race condition when concurrent requests try to create the same record simultaneously — both might find no existing record and then attempt to create it, resulting in one success and one unique constraint violation.

Rather than implementing a more complex upsert strategy (which would bypass Active Record validations), I chose to accept this race condition risk in this first version in favor of simplicity and code consistency. To maintain data integrity, I added a unique index on the combination of `user_id`, `game_name`, `occurred_at`, and `event_type` columns.

#### Service Objects
- External billing integration encapsulated in a `BillingService` to keep controllers clean and code testable;
- Billing integration handles flakiness and errors gracefully (e.g., returning `"unknown"` on failure).

#### Serializer
- Use `ActiveModelSerializers` to provide a clean abstraction for JSON rendering.
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
- Add retry and cache logic for external billing service;
- Implement an upsert strategy to eliminate race conditions in game event processing.
