-- Learning notes: what each user learned, optionally linked to an exercise.
\connect tracking

CREATE TABLE learning_notes (
    note_id       SERIAL PRIMARY KEY,
    user_id       INT         NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    exercise_code VARCHAR(60) REFERENCES exercises(code),
    topic         VARCHAR(60) NOT NULL,
    note          TEXT        NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
