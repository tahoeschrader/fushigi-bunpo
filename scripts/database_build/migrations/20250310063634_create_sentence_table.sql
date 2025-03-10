-- Add migration script here
CREATE TABLE sentence (
    id SERIAL PRIMARY KEY,
    journal_entry_id INT,
    user_id INT,
    grammar_id INT,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- constraints
    CONSTRAINT fk_journal_sentence FOREIGN KEY (journal_entry_id) REFERENCES journal_entry(id),
    CONSTRAINT fk_user_sentence FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_grammar_sentence FOREIGN KEY (grammar_id) REFERENCES grammar(id)
)
