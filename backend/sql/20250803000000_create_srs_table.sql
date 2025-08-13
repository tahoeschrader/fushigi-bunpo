CREATE TABLE srs (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    grammar_id INT NOT NULL,
    ease_factor FLOAT NOT NULL DEFAULT 2.5,
    interval_days INT NOT NULL DEFAULT 0,
    repetition INT NOT NULL DEFAULT 0,
    due_date DATE NOT NULL DEFAULT CURRENT_DATE,
    last_reviewed DATE,
    UNIQUE(user_id, grammar_id),
    CONSTRAINT fk_srs_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_srs_grammar FOREIGN KEY (grammar_id) REFERENCES grammar(id)
);

-- Index for fast queries by user and due date
CREATE INDEX idx_srs_user_due ON srs(user_id, due_date);

-- prefile just for testing for now
INSERT INTO srs (user_id, grammar_id)
--SELECT :new_user_id, id FROM grammar
SELECT 1, id FROM grammar
ON CONFLICT DO NOTHING;
