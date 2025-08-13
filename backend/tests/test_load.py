import json
from pathlib import Path
from unittest.mock import mock_open, patch

import pytest

from fushigi_backend.data.load import load_defaults
from fushigi_backend.data.models import Grammar


def test_load_defaults_reads_real_file(tmp_path: Path) -> None:
    # Setup
    dummy_data = {
        "grammar": [
            {
                "usage": "いらっしゃいます",
                "meaning": "replacement for 行く, 来る, and いる",
                "level": "",
                "tags": ["greeting", "respectful-honorific"],
                "notes": "",
                "examples": [
                    {
                        "japanese": "「」はいらっしゃいますか",
                        "romaji": "[name/person] wa irasshaimasu ka",
                        "english": "Is [name/person] there?",
                    },
                    {
                        "japanese": "今週末どこへいらっしゃいますか",
                        "romaji": "Konshūmatsu doko e irasshaimasuka",
                        "english": "Where are you going this weekend?",
                    },
                ],
                "enhanced_notes": {
                    "nuance": "Denotes respect, often to express modesty about one’s own actions or to speak humbly about someone else's actions.",  # noqa: E501
                    "usage_tips": "Use いらっしゃいます when referring to someone of a higher status or in situations requiring politeness.",  # noqa: E501
                    "common_mistakes": "Frequently confused with います (for animate objects) and あります (for inanimate objects); not interchangeable.",  # noqa: E501
                    "situation": "Used in formal settings and business contexts; inappropriate for casual conversation.",  # noqa: E501
                },
            }
        ]
    }
    test_file = tmp_path / "grammar.json"
    test_file.write_text(json.dumps(dummy_data), encoding="utf-8")

    # Act
    result = load_defaults(path=str(test_file))

    # Assert
    assert isinstance(result, list)
    assert len(result) == 1
    assert isinstance(result[0], Grammar)
    assert result[0].usage == "いらっしゃいます"


def test_load_defaults_parses_mocked_data_correctly() -> None:
    # Setup
    dummy_data = {
        "grammar": [
            {
                "usage": "いらっしゃいます",
                "meaning": "replacement for 行く, 来る, and いる",
                "level": "",
                "tags": ["greeting", "respectful-honorific"],
                "notes": "",
                "examples": [
                    {
                        "japanese": "「」はいらっしゃいますか",
                        "romaji": "[name/person] wa irasshaimasu ka",
                        "english": "Is [name/person] there?",
                    },
                    {
                        "japanese": "今週末どこへいらっしゃいますか",
                        "romaji": "Konshūmatsu doko e irasshaimasuka",
                        "english": "Where are you going this weekend?",
                    },
                ],
                "enhanced_notes": {
                    "nuance": "Denotes respect, often to express modesty about one’s own actions or to speak humbly about someone else's actions.",  # noqa: E501
                    "usage_tips": "Use いらっしゃいます when referring to someone of a higher status or in situations requiring politeness.",  # noqa: E501
                    "common_mistakes": "Frequently confused with います (for animate objects) and あります (for inanimate objects); not interchangeable.",  # noqa: E501
                    "situation": "Used in formal settings and business contexts; inappropriate for casual conversation.",  # noqa: E501
                },
            }
        ]
    }
    mocked_json = json.dumps(dummy_data)

    # Act
    with patch("builtins.open", mock_open(read_data=mocked_json)):
        result = load_defaults("ignored.json")

    # Assert
    assert isinstance(result, list)
    assert len(result) == 1
    assert isinstance(result[0], Grammar)
    assert result[0].usage == "いらっしゃいます"


def test_load_defaults_missing_file_raises() -> None:
    with pytest.raises(FileNotFoundError):
        load_defaults("nonexistent_file.json")


def test_load_defaults_invalid_json_raises(tmp_path: Path) -> None:
    test_file = tmp_path / "bad.json"
    test_file.write_text("{ this is not valid JSON }", encoding="utf-8")

    with pytest.raises(json.JSONDecodeError):
        load_defaults(str(test_file))
