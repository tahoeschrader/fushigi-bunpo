from datetime import datetime
from typing import List

from pydantic import BaseModel, ConfigDict


# for backend, db creation
class Example(BaseModel):
    japanese: str
    english: str


class Grammar(BaseModel):
    usage: str
    meaning: str
    context: str
    tags: List[str]
    notes: str
    nuance: str
    examples: List[Example]


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

class SRSReview(BaseModel):
    user_id: int
    grammar_id: int
    quality: int  # 0-5 quality rating; 5 = perfect
