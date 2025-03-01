# Japanese Grammar Dataset Conversion Specification

## Overview
This document outlines the standardization process for converting the original grammar point data from "fushigi-bunpo" to a consistent, well-structured format with gaps filled in. 
I care about the finished product and don't need to see every step you make. I would like to see some sample python/rust/go/java code that shows how to read the final JSON and maybe do some simple analysis like "total times tag used" and whatnot. Do not needlessly recalculate things and do not waste time printing things I don't need to see. 

## Source Format
Original data format has inconsistencies including:
- Vague or overlapping tags
- Potentially incorrect usage
- Missing level
- Missing "id"
- No romaji
- No English translation

## Target Format
Each grammar entry should have this standardized JSON structure:

```json
{
  "id": "unique-identifier",
  "usage": "Grammar pattern with particles/verb forms",
  "meaning": "Concise English explanation of function with nuance.",
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
- Generate something that will eventually be helpful when I create a PostgreSQL database from this.

### Usage Field
- Preserve Japanese characters and punctuation
- Do not edit unless there is incorrect usage or it could somehow be improved (for example, better placeholders?)

### Meaning Field
- Keep concise but descriptive
- Add nuances I might be forgetting

### Level Field
- Determine JLPT level (N5-N1) based on data you have previously been trained on
- There is no official source, so anything you are unsure of... make a guess and add an asterisk

### Tags Field
- Improve vague or incorrect tags
- Potential tag categories:
  1. **Grammatical Function** (conditional, causal, temporal)
  2. **Part of Speech** (verb-modifier, noun-modifier, adverbial)
  3. **Register/Tone** (formal, informal, polite, casual)
  4. **Difficulty** (beginner, intermediate, advanced)
  5. Negative tone, positive tone, set phrases, likelihood, prohibition, opinion, point of view, etc.
- I don't want any tag to only be used once. That is unhelpful. There should be groupings that just make sense and make finding near synonyms easier.

### Notes Field
- Clean up and standardize
- Focus on usage details, exceptions, nuances, important conjugation rules

### Examples Field
- Do not change my sentences unless there is incorrect usage
- Each example should include:
  1. Japanese text
  2. Romaji transliteration
  3. English translation
- If original examples lack translations and transliterations, add them. This is non-negotiable.

## Tag Mapping System
Convert original tags to standardized categories using this mapping system:

