from typing import List

from pydantic import BaseModel


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
