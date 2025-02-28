# Japanese Grammar Dataset Conversion Specification

## Overview
This document outlines the standardization process for converting the original grammar point data from "fushigi-bunpo" to a consistent, well-structured format.

Disclaimer: It was written during a back-and-forth with Claude. I built the entire source myself, along with example sentences. Overtime, my consistency was
deteriorating and I started not being able to see overall patterns to suggest good tags. I thought, AI must be good at this natural language stuff. So I did
my first attempt at proompting to build this spec. Claude then provided the JavaScript function to do the conversion to fit this spec. It's important to note 
that all original notes, tags, and sentences came from my head during class at ISI Shibuya in Tokyo, Japan. 


## Source Format
Original data format has inconsistencies including:
- Some entries use "name" while others use "usage" for the same concept
- Inconsistent example formatting (sometimes strings, sometimes arrays)
- Vague or overlapping tags
- Inconsistent note formatting

## Target Format
Each grammar entry should be converted to this standardized JSON structure:

```json
{
  "id": "unique-identifier",
  "usage": "Grammar pattern with particles/verb forms",
  "meaning": "Concise English explanation of function",
  "level": "N5/N4/N3/N2/N1",
  "tags": ["primary-function", "secondary-function", "tone", "formality-level"],
  "notes": "Additional usage information or exceptions",
  "examples": [
    {
      "japanese": "日本語の例文",
      "romaji": "nihongo no reibun",
      "english": "English translation of example"
    }
  ]
}
```

## Field Conversion Rules

### ID Field
- Generate from the usage/name field, creating a romanized slug
- Remove Japanese characters, tildes, and punctuation
- Examples: 〜たら → "tara", 〜んです → "ndesu"

### Usage Field
- Prioritize existing "usage" field, fall back to "name" field
- Preserve Japanese characters and punctuation
- Format consistently with tildes for variable parts: 〜てください

### Meaning Field
- Extract from notes if not explicitly provided
- The first sentence of notes often serves as a good meaning
- Keep concise but descriptive

### Level Field
- Determine JLPT level (N5-N1) based on:
  1. Explicit level tags in the original data
  2. Pattern complexity and common usage
  3. Default to N4 if uncertain

### Tags Field
- Apply mapping system to standardize and improve tags
- Organize into categories:
  1. **Grammatical Function** (conditional, causal, temporal)
  2. **Part of Speech** (verb-modifier, noun-modifier, adverbial)
  3. **Register/Tone** (formal, informal, polite, casual)
  4. **Difficulty** (beginner, intermediate, advanced)

### Notes Field
- Clean up and standardize
- Remove first sentence if it's already used as the meaning
- Focus on usage details, exceptions, nuances

### Examples Field
- Convert to standardized array of objects
- Each example should include:
  1. Japanese text
  2. Romaji transliteration
  3. English translation
- If original examples lack translations, add them

## Tag Mapping System
Convert original tags to standardized categories using this mapping system:

### Function Tags
- conditional, condition, if → "conditional"
- explanation, explaining → "explanation"
- emphasis, emphasizing → "emphasis"
- reason, cause, causation → "causal"
- temporal, sequence, time → "temporal"
- comparison, comparing → "comparative"
- contrast, but, however → "contrastive"
- command, imperative → "imperative"
- request, requesting → "request"
- invitation, inviting → "invitation"
- prohibition → "prohibition"
- etc.

### Part of Speech Tags
- verb, verb form → "verb-modifier"
- noun, adjectival → "noun-modifier"
- adverb, adverbial → "adverbial"
- conjunction, connecting → "conjunctive"
- sentence final, ending → "sentence-final"
- etc.

### Register/Tone Tags
- formal → "formal"
- polite, desu/masu → "polite"
- casual, informal, plain form → "casual"
- literary, written → "literary"
- colloquial, spoken → "colloquial"
- etc.

### Level Tags
- n5, basic, beginner → "beginner"
- n3, intermediate → "intermediate"
- n2, n1, advanced → "advanced"
- common, general, everyday → "common"
- etc.

## Special Cases

### Example Format Conversion
- String examples with line breaks: Split by "\n"
- String examples with translations: Split by "/" or " - "
- Array examples: Map each to standardized format
- Add romaji transliteration for all examples

### Level Classification Heuristics
- N5: Basic patterns (です/ます, て-form, simple particles)
- N4: Common patterns (ば, たり, なら, のに, など)
- N3: More complex patterns (によって, わけ, ばかり)
- N2: Advanced patterns (からといって, にすぎない)
- N1: Literary or highly specialized patterns

## Implementation Approach
1. Function to extract and normalize tags
2. Function to determine JLPT level
3. Function to generate consistent ID
4. Function to format examples consistently
5. Function to extract meaning from notes if needed
6. Main conversion function applying all transformations
