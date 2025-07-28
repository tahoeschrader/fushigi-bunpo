from typing import List

from pydantic import BaseModel, ConfigDict

# for backend, db creation
class Example(BaseModel):
    japanese: str
    romaji: str
    english: str


class EnhancedNote(BaseModel):
    nuance: str
    usage_tips: str
    common_mistakes: str
    situation: str


class Grammar(BaseModel):
    usage: str
    meaning: str
    level: str
    tags: List[str]
    notes: str
    examples: List[Example]
    enhanced_notes: EnhancedNote


class GrammarWrapper(BaseModel):
    grammar: List[Grammar]


# for frontend
class GrammarInDB(Grammar):
    id: int
    model_config = ConfigDict(from_attributes=True)


class TaggedGrammarCreate(BaseModel):
    grammar_id: int


class SentenceCreate(BaseModel):
    content: str
    tagged_grammar: List[TaggedGrammarCreate]


class JournalEntryCreate(BaseModel):
    title: str
    content: str
    sentences: List[SentenceCreate]
    private: bool

class TaggedGrammar(BaseModel):
    grammar_id: int


class Sentence(BaseModel):
    id: int
    content: str
    tagged_grammar: List[TaggedGrammar]


class JournalEntryInDB(BaseModel):
    id: int
    user_id: int
    title: str
    content: str
    created_at: str  # or datetime if you prefer
    sentences: List[Sentence]
    private: bool
    
