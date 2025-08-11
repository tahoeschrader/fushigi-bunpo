CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    open_ai_hash VARCHAR(255),
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, password_hash) VALUES
    ('tester', 'test123');
