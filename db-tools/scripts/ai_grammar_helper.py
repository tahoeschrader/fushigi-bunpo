import json
import os
from typing import Any, List

from dotenv import load_dotenv
from openai import OpenAI


def get_required_env(key: str) -> str:
    """
    Get a required environment variable or raise a clear error.
    """
    value = os.getenv(key)
    if value is None or value.strip() == "":
        raise EnvironmentError(f"Missing required environment variable: {key}")
    return value


class GrammarPointEnhancer:

    def __init__(self) -> None:
        """
        Initialize keys and models to query OpenAI with.
        Requires user to create a person .env.key secret file.
        """
        self.client = OpenAI(
            api_key=get_required_env("OPENAI_API_KEY"),
            organization=get_required_env("OPENAI_ORG_KEY"),
            project=get_required_env("OPENAI_PRJ_KEY"),
        )
        self.model: str = get_required_env("OPENAI_MODEL")

    def romanize(self, japanese_text: str) -> str:
        """
        Convert Japanese text to romanized text using OpenAI's GPT model
        """
        try:
            prompt = f"""I need the hepburn romanization for the following
            example sentence in Japanese.

            Sentence: {japanese_text}

            Don't add any extra information other than the hepburn romanization!
            """
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a professional translator specializing in Japanese to English translation.",  # noqa: E501
                    },
                    {"role": "user", "content": prompt},
                ],
            )
            content = response.choices[0].message.content
            if content is None:
                print(f"Error generating translation: {japanese_text}")
                return f"Translation unavailable for: {japanese_text}"
            return content.strip()
        except Exception as e:
            print(f"Error generating translation: {e} for {japanese_text}")
            return f"Translation unavailable for: {japanese_text}"

    def generate_enhanced_notes(self, usage: str, meaning: str, tags: List[str]) -> Any:
        """
        Generate comprehensive notes using OpenAI's GPT model.
        """
        try:
            prompt = f"""I need concise notes for a Japanese grammar point.
            Provide insights covering:
            - Precise nuance and emotional context
            - Usage tips
            - Common mistakes learners make
            - Appropriate social register

            Do NOT be verbose.
            Keep these short, concise, and no more than 1-2 sentences max.

            Grammar Point: {usage}
            Meaning: {meaning}
            Current Tags: {', '.join(tags)}

            Format your response as a JSON object with these keys:
            {{
                "nuance": "",
                "usage_tips": "",
                "common_mistakes": "",
                "situation": ""
            }}
            """

            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are an expert in Japanese linguistics and language pedagogy.",  # noqa: E501
                    },
                    {"role": "user", "content": prompt},
                ],
            )

            content = response.choices[0].message.content
            if content is None:
                print(f"Error generating notes for {usage}")
                return {
                    "nuance": "Unable to generate detailed notes",
                    "usage_tips": "",
                    "common_mistakes": "",
                    "register": "",
                }
            return json.loads(content)
        except Exception as e:
            print(f"Error generating notes: {e} for {usage}")
            return {
                "nuance": "Unable to generate detailed notes",
                "usage_tips": "",
                "common_mistakes": "",
                "register": "",
            }

    def generate_translation(self, japanese_text: str) -> Any:
        """
        Generate a high-quality translation using OpenAI's GPT model
        """
        try:
            prompt = f"""Provide a professional, contextually accurate English
            translation of the following Japanese text, focusing on capturing
            the precise meaning and nuance:

            Japanese: {japanese_text}

            Provide:
            1. A direct, natural translation only. No extra notes.
            2. The hepburn romanization of the sentence only. No extra notes.

            Format your response as a JSON object with these keys:
            {{
                "english": "",
                "romaji": ""
            }}
            """

            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a professional translator specializing in Japanese to English translation.",  # noqa: E501
                    },
                    {"role": "user", "content": prompt},
                ],
            )
            content = response.choices[0].message.content
            if content is None:
                print(f"Error generating translations for {japanese_text}")
                return {
                    "english": "Unable to generate translation.",
                    "romaji": "Unable to generate romanization.",
                }
            return json.loads(content)

        except Exception as e:
            print(f"Error generating translations: {e} for {japanese_text}")
            return {
                "english": "Unable to generate translation.",
                "romaji": "Unable to generate romanization.",
            }

    def enhance_grammar_points(self, input_file: str, output_file: str) -> None:
        """
        Enhance the entire grammar points dataset
        """
        # Load existing data
        with open(input_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Process each grammar point
        enhanced_grammar: list[dict[str, Any]] = []
        for grammar_point in data["grammar"]:

            # Generate enhanced notes
            enhanced_notes = self.generate_enhanced_notes(
                grammar_point["usage"], grammar_point["meaning"], grammar_point["tags"]
            )
            grammar_point["enhanced_notes"] = enhanced_notes

            # Enhance examples
            enhanced_examples: list[dict[str, Any]] = []

            for example in grammar_point.get("examples", []):
                enhanced_example = example.copy()
                translations = self.generate_translation(example["japanese"])
                enhanced_example["romaji"] = translations["romaji"]
                enhanced_example["english"] = translations["english"]
                enhanced_examples.append(enhanced_example)

            grammar_point["examples"] = enhanced_examples

            enhanced_grammar.append(grammar_point)
            print(f"Finished: {grammar_point['usage']}")

        # Update the data structure
        data["grammar"] = enhanced_grammar

        # Save enhanced data
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"Enhanced grammar points saved to {output_file}")


# Usage example
if __name__ == "__main__":
    """
    This script is currently a bit manual. Moves a filled
    `../data/grammar_template.json` to this folder and calls it `indata.json`.
    It will generate an `outdata.json` that can be copy-pasted into the official
    `../data/grammar.json` grammar source.
    """

    load_dotenv(".env.key")
    enhancer = GrammarPointEnhancer()
    enhancer.enhance_grammar_points("indata.json", "outdata.json")
