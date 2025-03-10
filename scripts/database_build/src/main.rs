use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::PgPool;
use std::fs::File;
use std::io::BufReader;

// TODO: add cli that runs the builder and nothing else if given flag, otherwise regular activ-web server mode
// TODO: add the actix-web server mode logic
// TODO: move datatypes and build logic to different file/folder
// TODO: start building tests for user creation, journal creation, and sentence tagging

#[derive(Serialize, Deserialize)]
struct GrammarWrapper {
    grammar: Vec<Grammar>,
}

#[derive(Serialize, Deserialize)]
struct Grammar {
    usage: String,
    meaning: String,
    level: String,
    tags: Vec<String>,
    notes: String,
    examples: Vec<Example>,
    enhanced_notes: EnhancedNote,
}

#[derive(Serialize, Deserialize)]
struct Example {
    japanese: String,
    romaji: String,
    english: String,
}

#[derive(Serialize, Deserialize)]
struct EnhancedNote {
    nuance: String,
    usage_tips: String,
    common_mistakes: String,
    register: String,
}

async fn connect(database_url: &str) -> sqlx::Result<PgPool, sqlx::Error> {
    let pool = PgPool::connect(database_url).await?;
    Ok(pool)
}

fn load() -> std::io::Result<Vec<Grammar>> {
    println!("Filling database from enhanced_data.json...");
    let file = File::open("../enhanced_data.json")?;
    let reader = BufReader::new(file);
    let data: GrammarWrapper = serde_json::from_reader(reader)?;
    Ok(data.grammar)
}

async fn fill_db_with_grammar(pool: &PgPool) -> sqlx::Result<()> {
    let grammar_list: Vec<Grammar> = load()?;
    for grammar in grammar_list {
        sqlx::query(
            r#"
            INSERT INTO grammar (usage, meaning, level, tags, notes, examples, enhanced_notes)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            "#,
        )
        .bind(grammar.usage)
        .bind(grammar.meaning)
        .bind(grammar.level)
        .bind(grammar.tags)
        .bind(grammar.notes)
        .bind(json!(grammar.examples))
        .bind(json!(grammar.enhanced_notes))
        .execute(pool)
        .await?;
    }
    println!("Finished filling database.");
    Ok(())
}

#[actix_web::main]
async fn main() -> sqlx::Result<()> {
    let database_url = "postgres://tester:testpassword@localhost/fushigidb";
    println!("You are using: {}", &database_url);

    let pool = connect(&database_url).await?;
    fill_db_with_grammar(&pool).await?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    // TODO: add test that checks if test database is active, and checks total entries
    // TODO: add test that checks if test database is active, grabs a grammar and checks the contents
    // TODO: if test database is not active, skip test and show that in the test report

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
