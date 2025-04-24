#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_load() {
        // Ultra basic integration test to make sure entire json file could be loaded into rust objects
        assert!(load().is_ok());
    }

    #[test]
    fn test_grammar_struct_format() {
        // Make sure format of a grammar object hasn't changed
        let data = r#"
            {
              "usage": "いらっしゃいます",
              "meaning": "replacement for 行く, 来る, and いる",
              "level": "",
              "tags": [
                "greeting",
                "respectful-honorific"
              ],
              "notes": "",
              "examples": [
                {
                  "japanese": "「」はいらっしゃいますか",
                  "romaji": "[name/person] wa irasshaimasu ka",
                  "english": "Is [name/person] there?"
                },
                {
                  "japanese": "今週末どこへいらっしゃいますか",
                  "romaji": "Konshūmatsu doko e irasshaimasuka",
                  "english": "Where are you going this weekend?"
                }
              ],
              "enhanced_notes": {
                "nuance": "Denotes respect, often to express modesty about one’s own actions or to speak humbly about someone else's actions.",
                "usage_tips": "Use いらっしゃいます when referring to someone of a higher status or in situations requiring politeness.",
                "common_mistakes": "Frequently confused with います (for animate objects) and あります (for inanimate objects); not interchangeable.",
                "register": "Used in formal settings and business contexts; inappropriate for casual conversation."
              }
            }"#;

        let g: Grammar = serde_json::from_str(data).expect("Test is broken.");

        assert_eq!("いらっしゃいます", g.usage);
        assert_eq!("greeting", g.tags[0]);
        assert_eq!("Konshūmatsu doko e irasshaimasuka", g.examples[1].romaji);
        assert_eq!(
            "Used in formal settings and business contexts; inappropriate for casual conversation.",
            g.enhanced_notes.register
        );
    }
}
