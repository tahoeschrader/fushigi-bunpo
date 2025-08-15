CREATE TABLE srs (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    grammar_id INT NOT NULL REFERENCES grammar(id),
    ease_factor FLOAT NOT NULL DEFAULT 2.5,
    interval_days INT NOT NULL DEFAULT 0,
    repetition INT NOT NULL DEFAULT 0,
    due_date DATE NOT NULL DEFAULT CURRENT_DATE,
    last_reviewed DATE
);

CREATE INDEX idx_by_user_due ON srs(user_id, due_date);
