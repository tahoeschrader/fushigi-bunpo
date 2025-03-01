import json
import re
import os
from openai import OpenAI
from dotenv import load_dotenv

# Note: In a real implementation, you'd use a proper API key management system
load_dotenv('.env.key')

client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
model = os.getenv('OPENAI_MODEL')

class GrammarPointEnhancer:

    def romanize(self, japanese_text):
        """
        Convert Japanese text to romanized text using OpenAI's GPT model
        """
        try:
            prompt = f"""I need the hepburn romanization for the following example sentence in Japanese.

            Sentence: {japanese_text}
            """
            response = client.chat.completions.create(model=model,
            messages=[
                {"role": "system", "content": "You are a professional translator specializing in Japanese to English translation."},
                {"role": "user", "content": prompt}
            ])

            return response.choices[0].message.content.strip()
        except Exception as e:
            print(f"Error generating translation: {e}")
            return f"Translation unavailable for: {japanese_text}"

    def generate_enhanced_notes(self, usage, meaning, tags):
        """
        Generate comprehensive notes using OpenAI's GPT model
        """
        try:
            prompt = f"""I need detailed, nuanced notes for a Japanese grammar point. 
            Provide insights covering:
            - Precise nuance and emotional context
            - Detailed usage tips
            - Common mistakes learners make
            - Appropriate social register
            - Contextual variations

            Grammar Point: {usage}
            Meaning: {meaning}
            Current Tags: {', '.join(tags)}

            Format your response as a JSON object with these keys:
            {{
                "nuance": "",
                "usage_tips": "",
                "common_mistakes": "",
                "register": "",
                "contextual_variations": ""
            }}
            """

            response = client.chat.completions.create(model=model,
            messages=[
                {"role": "system", "content": "You are an expert in Japanese linguistics and language pedagogy."},
                {"role": "user", "content": prompt}
            ],
            response_format={"type": "json_object"})

            return json.loads(response.choices[0].message.content)
        except Exception as e:
            print(f"Error generating notes: {e}")
            return {
                "nuance": "Unable to generate detailed notes",
                "usage_tips": "",
                "common_mistakes": "",
                "register": "",
                "contextual_variations": ""
            }

    def generate_translation(self, japanese_text):
        """
        Generate a high-quality translation using OpenAI's GPT model
        """
        try:
            prompt = f"""Provide a professional, contextually accurate English translation of the following Japanese text. 
            Focus on capturing the precise meaning and nuance:

            Japanese: {japanese_text}

            Provide:
            1. A direct, natural translation
            2. Any cultural or contextual notes if relevant
            """

            response = client.chat.completions.create(model=model,
            messages=[
                {"role": "system", "content": "You are a professional translator specializing in Japanese to English translation."},
                {"role": "user", "content": prompt}
            ])

            return response.choices[0].message.content.strip()
        except Exception as e:
            print(f"Error generating translation: {e}")
            return f"Translation unavailable for: {japanese_text}"

    def enhance_grammar_points(self, input_file, output_file):
        """
        Enhance the entire grammar points dataset
        """
        # Load existing data
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # Process each grammar point
        enhanced_grammar = []
        for grammar_point in data['grammar']:

            # Generate enhanced notes
            enhanced_notes = self.generate_enhanced_notes(
                grammar_point['usage'], 
                grammar_point['meaning'], 
                grammar_point['tags']
            )
            grammar_point['enhanced_notes'] = enhanced_notes

            # Enhance examples
            enhanced_examples = []
            for example in grammar_point.get('examples', []):
                enhanced_example = example.copy()
                enhanced_example['romaji'] = self.romanize(example['japanese'])
                enhanced_example['english'] = self.generate_translation(example['japanese'])
                enhanced_examples.append(enhanced_example)

            grammar_point['examples'] = enhanced_examples

            enhanced_grammar.append(grammar_point)

        # Update the data structure
        data['grammar'] = enhanced_grammar

        # Save enhanced data
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"Enhanced grammar points saved to {output_file}")

# Usage example
if __name__ == "__main__":
    enhancer = GrammarPointEnhancer()
    enhancer.enhance_grammar_points('converted_data.json', 'enhanced_grammar_data.json')
