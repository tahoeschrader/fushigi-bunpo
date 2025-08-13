CREATE TABLE grammar (
    id SERIAL PRIMARY KEY,
    usage TEXT NOT NULL,
    meaning TEXT NOT NULL,
    level TEXT,  -- can be NULL
    tags TEXT[] NOT NULL,
    notes TEXT, -- can be NULL
    examples JSONB NOT NULL,  -- structured JSON data
    enhanced_notes JSONB NOT NULL  -- structured JSON data
);
