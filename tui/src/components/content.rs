use unicode_width::UnicodeWidthStr;

use ratatui::{
    buffer::Buffer,
    layout::{Constraint, Layout, Rect},
    style::Style,
    text::Text,
    widgets::{Cell, Row, Table, Tabs, Widget},
};

struct Data {
    name: String,
    tags: Vec<String>,
    note: String,
    examples: Vec<String>,
}

impl Data {
    fn ref_array(&self) -> [String; 4] {
        [
            self.name().clone(),
            self.tags().join("\n"),
            self.note().clone(),
            self.examples().join("\n"),
        ]
    }

    fn name(&self) -> &String {
        &self.name
    }

    fn tags(&self) -> &[String] {
        &self.tags
    }

    fn note(&self) -> &String {
        &self.note
    }

    fn examples(&self) -> &[String] {
        &self.examples
    }
}

pub struct Content {
    items: Vec<Data>,
    longest_items: (u16, u16, u16, u16),
}

impl Content {
    pub fn new() -> Self {
        let data = fetch_data();
        Self {
            longest_items: constraint_len_calculator(&data),
            items: data,
        }
    }
}

impl Widget for &Content {
    fn render(self, area: Rect, buf: &mut Buffer) {
        // Render tabs
        let vertical = Layout::vertical([Constraint::Length(1), Constraint::Min(0)]);
        let [tab_header_area, tab_content_area] = vertical.areas(area);
        Tabs::new(["All", "Tags"]).render(tab_header_area, buf);

        // Now, render the table
        let table_header = ["Point", "Tags", "Note", "Examples"]
            .into_iter()
            .map(Cell::from)
            .collect::<Row>()
            .height(1);
        let rows = self.items.iter().enumerate().map(|(_i, data)| {
            let item = data.ref_array();
            item.into_iter()
                .map(|content| Cell::from(Text::from(format!("\n{content}\n"))))
                .collect::<Row>()
                .style(Style::new())
                .height(4)
        });
        let t = Table::new(
            rows,
            [
                Constraint::Min(self.longest_items.0 + 1),
                Constraint::Min(self.longest_items.1 + 1),
                Constraint::Min(self.longest_items.2 + 1),
                Constraint::Min(self.longest_items.3),
            ],
        )
        .header(table_header);
        t.render(tab_content_area, buf);
    }
}

fn constraint_len_calculator(items: &[Data]) -> (u16, u16, u16, u16) {
    let name_len = items
        .iter()
        .map(|item| item.name.width())
        .max()
        .unwrap_or(0);
    let tags_len = items
        .iter()
        .map(|item| &item.tags)
        .flat_map(|tags| tags.iter().map(|tag| tag.width()).max())
        .max()
        .unwrap_or(0);
    let note_len = items
        .iter()
        .map(|item| item.note.width())
        .max()
        .unwrap_or(0);
    let examples_len = items
        .iter()
        .map(|item| &item.examples)
        .flat_map(|tags| tags.iter().map(|tag| tag.width()).max())
        .max()
        .unwrap_or(0);
    (
        name_len as u16,
        tags_len as u16,
        note_len as u16,
        examples_len as u16,
    )
}

fn fetch_data() -> Vec<Data> {
    use fakeit::words;

    (0..10)
        .map(|_| {
            let name = words::word();
            let tags = vec![words::word(), words::word(), words::word()];
            let note = words::sentence(5);
            let examples = vec![words::sentence(5), words::sentence(5), words::sentence(5)];
            Data {
                name,
                tags,
                note,
                examples,
            }
        })
        .collect()
}
