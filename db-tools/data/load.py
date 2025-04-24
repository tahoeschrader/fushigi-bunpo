import json
from models import GrammarWrapper, Grammar
from typing import List

def load_defaults(path: str = "grammar.json") -> List[Grammar]:
    with open(path, "r", encoding="utf-8") as f:
        return GrammarWrapper(**json.load(f)).grammar
