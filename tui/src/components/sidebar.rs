use color_eyre::Result;
use crossterm::event::{Event, KeyCode, KeyEventKind};
use ratatui::{
    buffer::Buffer,
    layout::Rect,
    style::{Color, Style},
    widgets::{List, ListItem, Widget},
};

enum Pages {
    Grammar = 0,
    Journal = 1,
    Social = 2,
}

pub struct Sidebar {
    active_page: Pages,
    list_location: i32,
}

impl Sidebar {
    pub fn new() -> Self {
        Self {
            active_page: Pages::Grammar,
            list_location: 0,
        }
    }

    pub fn handle_event(&mut self, event: Event) -> Result<()> {
        match event {
            Event::Key(key) if key.kind == KeyEventKind::Press => match key.code {
                KeyCode::Char('k') => {
                    self.list_location = (self.list_location - 1).rem_euclid(3);
                }
                KeyCode::Char('j') => {
                    self.list_location = (self.list_location + 1).rem_euclid(3);
                }
                _ => {}
            },
            _ => {}
        };
        self.set_active_page();
        Ok(())
    }

    fn set_active_page(&mut self) {
        match self.list_location {
            0 => {
                self.active_page = Pages::Grammar;
            }
            1 => {
                self.active_page = Pages::Journal;
            }
            2 => {
                self.active_page = Pages::Social;
            }
            _ => unreachable!(),
        }
    }
}

impl Widget for &Sidebar {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let pages = match self.active_page {
            Pages::Grammar => [
                ListItem::new("> Grammar").style(Style::new().fg(Color::Magenta)),
                ListItem::new("  Journal"),
                ListItem::new("  Social"),
            ],
            Pages::Journal => [
                ListItem::new("  Grammar"),
                ListItem::new("> Journal").style(Style::new().fg(Color::Magenta)),
                ListItem::new("  Social"),
            ],
            Pages::Social => [
                ListItem::new("  Grammar"),
                ListItem::new("  Journal"),
                ListItem::new("> Social").style(Style::new().fg(Color::Magenta)),
            ],
        };
        List::new(pages).render(area, buf);
    }
}
