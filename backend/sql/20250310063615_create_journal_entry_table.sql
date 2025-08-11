CREATE TABLE journal_entry (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    private BOOLEAN NOT NULL,

    -- constraints
    CONSTRAINT fk_user_journal FOREIGN KEY (user_id) REFERENCES users(id)
)
