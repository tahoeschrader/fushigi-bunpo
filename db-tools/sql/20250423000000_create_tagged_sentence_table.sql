CREATE TABLE tagged_sentence (
    id SERIAL PRIMARY KEY,
    sentence_id INT NOT NULL,
    grammar_id INT NOT NULL,
    
    -- constraints
    CONSTRAINT fk_grammar_tagged_sentence FOREIGN KEY (grammar_id) REFERENCES grammar(id),
    CONSTRAINT fk_sentenced_tagged_sentence FOREGIN KEY (sentence_id) REFERENCES sentence(id)
)
