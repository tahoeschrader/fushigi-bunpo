use color_eyre::Result;
use crossterm::event::{Event, KeyCode, KeyEventKind, KeyModifiers};
use ratatui::{
    buffer::Buffer,
    layout::{Constraint, Layout, Margin, Rect},
    style::{self, Color, Modifier, Style},
    text::{Line, Text},
    widgets::{
        Cell, HighlightSpacing, Row, Scrollbar, ScrollbarOrientation, ScrollbarState,
        StatefulWidget, Table, TableState, Tabs, Widget,
    },
};
use strum::{Display, EnumIter, FromRepr, IntoEnumIterator};
use style::palette::tailwind;
use unicode_width::UnicodeWidthStr;

const ITEM_HEIGHT: usize = 4;

const PALETTES: [tailwind::Palette; 4] = [
    tailwind::BLUE,
    tailwind::EMERALD,
    tailwind::INDIGO,
    tailwind::RED,
];

struct TableColors {
    header_bg: Color,
    header_fg: Color,
    row_fg: Color,
    selected_row_style_fg: Color,
    normal_row_color: Color,
    alt_row_color: Color,
}

impl TableColors {
    const fn new(color: &tailwind::Palette) -> Self {
        Self {
            header_bg: Color::Magenta,
            header_fg: Color::White,
            row_fg: Color::White,
            selected_row_style_fg: color.c400,
            normal_row_color: tailwind::SLATE.c950,
            alt_row_color: tailwind::SLATE.c900,
        }
    }
}

#[derive(Default, Clone, Copy, Display, FromRepr, EnumIter)]
enum ContentTabs {
    #[default]
    #[strum(to_string = "All Grammar Points")]
    All,
    #[strum(to_string = "Grouped by Tags")]
    Tags,
}

impl ContentTabs {
    /// Get the previous tab, if there is no previous tab return the current tab.
    fn previous(self) -> Self {
        let current_index: usize = self as usize;
        let previous_index = current_index.saturating_sub(1);
        Self::from_repr(previous_index).unwrap_or(self)
    }

    /// Get the next tab, if there is no next tab return the current tab.
    fn next(self) -> Self {
        let current_index = self as usize;
        let next_index = current_index.saturating_add(1);
        Self::from_repr(next_index).unwrap_or(self)
    }

    fn title(self) -> Line<'static> {
        Line::from(format!("  {self}  "))
    }
}

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
    current_tab: ContentTabs,
    longest_items: (u16, u16, u16, u16),
    colors: TableColors,
    color_index: usize,
    current_scroll: usize,
    current_table_item: usize,
}

impl Content {
    pub fn new() -> Self {
        let data = fetch_data();
        Self {
            current_table_item: 0,
            current_scroll: 0,
            longest_items: constraint_len_calculator(&data),
            current_tab: ContentTabs::All,
            items: data,
            color_index: 0,
            colors: TableColors::new(&PALETTES[0]),
        }
    }

    pub fn handle_event(&mut self, event: Event) -> Result<()> {
        match event {
            Event::Key(key) if key.kind == KeyEventKind::Press => {
                let shift_pressed = key.modifiers.contains(KeyModifiers::SHIFT);
                match key.code {
                    KeyCode::Char('h') | KeyCode::Left if shift_pressed => self.previous_tab(),
                    KeyCode::Char('l') | KeyCode::Right if shift_pressed => self.next_tab(),
                    KeyCode::Char('j') | KeyCode::Down => self.next_row(),
                    KeyCode::Char('k') | KeyCode::Up => self.previous_row(),
                    KeyCode::Char(' ') => self.next_color(),
                    _ => {}
                };
                self.set_colors();
            }
            _ => {}
        };
        Ok(())
    }

    pub fn next_tab(&mut self) {
        self.current_tab = self.current_tab.next();
    }

    pub fn previous_tab(&mut self) {
        self.current_tab = self.current_tab.previous();
    }

    pub fn next_row(&mut self) {
        if self.current_table_item < self.items.len() - 1 {
            self.current_table_item += 1;
            self.current_scroll = self.current_table_item * ITEM_HEIGHT;
        };
    }

    pub fn previous_row(&mut self) {
        if self.current_table_item != 0 {
            self.current_table_item -= 1;
            self.current_scroll = self.current_table_item * ITEM_HEIGHT;
        };
    }

    pub fn next_color(&mut self) {
        self.color_index = (self.color_index + 1) % PALETTES.len();
    }

    pub fn set_colors(&mut self) {
        self.colors = TableColors::new(&PALETTES[self.color_index]);
    }
}

impl Widget for &Content {
    fn render(self, area: Rect, buf: &mut Buffer) {
        // Render tabs
        let vertical = Layout::vertical([Constraint::Length(1), Constraint::Min(0)]);
        let [tab_header_area, tab_content_area] = vertical.areas(area);
        let titles = ContentTabs::iter().map(ContentTabs::title);
        let highlight_style = (Color::default(), Color::Magenta);
        let selected_tab_index = self.current_tab as usize;
        Tabs::new(titles)
            .highlight_style(highlight_style)
            .select(selected_tab_index)
            .padding("", "")
            .divider(" ")
            .render(tab_header_area, buf);

        // Now, render the table
        match self.current_tab {
            ContentTabs::All => {
                let mut state = TableState::new().with_selected(self.current_table_item);
                let mut scroll = ScrollbarState::new((self.items.len() - 1) * ITEM_HEIGHT)
                    .position(self.current_scroll);
                let header_style = Style::default()
                    .fg(self.colors.header_fg)
                    .bg(self.colors.header_bg);
                let selected_row_style = Style::default()
                    .add_modifier(Modifier::REVERSED)
                    .fg(self.colors.selected_row_style_fg);
                let table_header = ["Point", "Tags", "Note", "Examples"]
                    .into_iter()
                    .map(Cell::from)
                    .collect::<Row>()
                    .style(header_style)
                    .height(1);
                let rows = self.items.iter().enumerate().map(|(i, data)| {
                    let color = match i % 2 {
                        0 => self.colors.normal_row_color,
                        _ => self.colors.alt_row_color,
                    };
                    let item = data.ref_array();
                    item.into_iter()
                        .map(|content| Cell::from(Text::from(format!("\n{content}\n"))))
                        .collect::<Row>()
                        .style(Style::new().fg(self.colors.row_fg).bg(color))
                        .height(4)
                });
                let bar = " █ ";
                let t = Table::new(
                    rows,
                    [
                        Constraint::Min(self.longest_items.0 + 1),
                        Constraint::Min(self.longest_items.1 + 1),
                        Constraint::Min(self.longest_items.2 + 1),
                        Constraint::Min(self.longest_items.3),
                    ],
                )
                .header(table_header)
                .row_highlight_style(selected_row_style)
                .highlight_symbol(Text::from(vec![
                    "".into(),
                    bar.into(),
                    bar.into(),
                    "".into(),
                ]))
                .highlight_spacing(HighlightSpacing::Always);
                StatefulWidget::render(t, tab_content_area, buf, &mut state);
                StatefulWidget::render(
                    Scrollbar::default()
                        .orientation(ScrollbarOrientation::VerticalRight)
                        .begin_symbol(None)
                        .thumb_style(Color::default())
                        .end_symbol(None),
                    area.inner(Margin {
                        vertical: 2,
                        horizontal: 1,
                    }),
                    buf,
                    &mut scroll,
                );
            }

            ContentTabs::Tags => {
                Text::from("Under Construction").render(tab_content_area, buf);
            }
        }
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

    (0..30)
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
