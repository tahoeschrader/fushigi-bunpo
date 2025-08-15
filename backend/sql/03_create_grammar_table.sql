CREATE TABLE grammar (
    id SERIAL PRIMARY KEY,
    language_id INT NOT NULL REFERENCES languages(id),
    usage TEXT NOT NULL,
    meaning TEXT NOT NULL,
    context TEXT,
    tags TEXT[],
    notes TEXT,
    nuance TEXT,
    examples JSONB NOT NULL,
    created_by INT NULL REFERENCES users(id), -- NULL for official points
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_update TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
