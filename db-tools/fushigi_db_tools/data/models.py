from datetime import datetime
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


class GrammarInDB(Grammar):
    id: int
    model_config = ConfigDict(from_attributes=True)


class JournalEntry(BaseModel):
    title: str
    content: str
    private: bool


class JournalEntryInDB(JournalEntry):
    id: int
    created_at: datetime
    user_id: int
    model_config = ConfigDict(from_attributes=True)
