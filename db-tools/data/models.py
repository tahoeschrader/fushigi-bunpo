from pydantic import BaseModel
from typing import List


class Example(BaseModel):
    japanese: str
    romaji: str
    english: str


class EnhancedNote(BaseModel):
    nuance: str
    usage_tips: str
    common_mistakes: str
    register: str


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
