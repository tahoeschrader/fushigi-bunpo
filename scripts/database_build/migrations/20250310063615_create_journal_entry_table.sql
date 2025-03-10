-- Add migration script here
CREATE TABLE journal_entry (
    id SERIAL PRIMARY KEY,
    user_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- constraints
    CONSTRAINT fk_user_journal FOREIGN KEY (user_id) REFERENCES users(id)
)
