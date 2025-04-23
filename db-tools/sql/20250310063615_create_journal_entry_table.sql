CREATE TABLE journal_entry (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- constraints
    CONSTRAINT fk_user_journal FOREIGN KEY (user_id) REFERENCES users(id)
)
