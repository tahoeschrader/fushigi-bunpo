use color_eyre::Result;
use crossterm::event::{Event, KeyCode, KeyEventKind};
use ratatui::{
    buffer::Buffer,
    layout::Rect,
    style::Color,
    widgets::{List, ListItem, ListState, StatefulWidget, Widget},
};

use strum::{Display, EnumCount, EnumIter, FromRepr, IntoEnumIterator};

#[derive(Default, Display, FromRepr, Copy, Clone, EnumIter, EnumCount)]
pub enum Pages {
    #[default]
    #[strum(to_string = "Grammar")]
    Grammar,
    #[strum(to_string = "Journal")]
    Journal,
    #[strum(to_string = "Social")]
    Social,
}

impl Pages {
    fn list_item(self) -> ListItem<'static> {
        ListItem::from(format!("  {self}  "))
    }
}

pub struct Sidebar {
    pub active_page: Pages,
    list_location: i8,
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
                KeyCode::Char('k') | KeyCode::Up => {
                    self.list_location = (self.list_location - 1).rem_euclid(Pages::COUNT as i8);
                }
                KeyCode::Char('j') | KeyCode::Down => {
                    self.list_location = (self.list_location + 1).rem_euclid(Pages::COUNT as i8);
                }
                _ => {}
            },
            _ => {}
        };
        self.active_page = Pages::from_repr(self.list_location as usize).expect("Unreachable!");
        Ok(())
    }
}

impl Widget for &Sidebar {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let mut state = ListState::default();
        state.select(Some(self.active_page as usize));
        let highlight_style = (Color::Magenta, Color::default());
        let list = List::new(Pages::iter().map(Pages::list_item))
            .highlight_style(highlight_style)
            .highlight_symbol(">");
        StatefulWidget::render(list, area, buf, &mut state);
    }
}
