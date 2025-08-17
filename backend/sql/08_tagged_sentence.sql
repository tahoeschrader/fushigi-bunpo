CREATE TABLE tagged_sentence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sentence_id UUID NOT NULL REFERENCES sentence(id),
    grammar_id UUID NOT NULL REFERENCES grammar(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_tagged_by_sentence ON tagged_sentence(sentence_id);
CREATE INDEX idx_tagged_by_grammar ON tagged_sentence(grammar_id);
