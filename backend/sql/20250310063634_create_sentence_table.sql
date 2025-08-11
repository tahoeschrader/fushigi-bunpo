CREATE TABLE sentence (
    id SERIAL PRIMARY KEY,
    journal_entry_id INT NOT NULL,
    content TEXT NOT NULL,

    -- constraints
    CONSTRAINT fk_journal_sentence FOREIGN KEY (journal_entry_id) REFERENCES journal_entry(id)
)
