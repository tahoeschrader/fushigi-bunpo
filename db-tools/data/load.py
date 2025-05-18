import json
from .models import GrammarWrapper, Grammar
from typing import List, Union
from pathlib import Path


def load_defaults(path: Union[Path, str, None] = None) -> List[Grammar]:
    if path is None:
        path = Path(__file__).parent / "grammar.json"
    else:
        path = Path(path)
    with open(path, "r", encoding="utf-8") as f:
        return GrammarWrapper(**json.load(f)).grammar
