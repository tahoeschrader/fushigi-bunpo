use crate::components::{content::Content, sidebar::Sidebar};
use crate::utils::area_minus_border;
use color_eyre::Result;
use crossterm::event::Event;
use ratatui::{
    buffer::Buffer,
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Style},
    symbols::border,
    widgets::{Block, Widget},
};
use tui_textarea::{Input, Key};

pub struct Home {
    active_pane: ActivePane,
    content: Content,
    sidebar: Sidebar,
}

enum ActivePane {
    Sidebar,
    Content,
}

impl Home {
    pub fn new() -> Self {
        Self {
            active_pane: ActivePane::Sidebar,
            content: Content::new(),
            sidebar: Sidebar::new(),
        }
    }

    pub fn handle_event(&mut self, event: Event) -> Result<()> {
        match event.into() {
            Input { key: Key::Tab, .. } => match self.active_pane {
                ActivePane::Sidebar => {
                    self.active_pane = ActivePane::Content;
                }
                ActivePane::Content => {
                    self.active_pane = ActivePane::Sidebar;
                }
            },
            _ => {}
        };
        Ok(())
    }
}

impl Widget for &Home {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let panes = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Percentage(10), Constraint::Percentage(90)]);
        let [sidebar_area, tab_area] = panes.areas(area);
        Block::bordered()
            .border_set(border::THICK)
            .border_style(Style::default().fg(match self.active_pane {
                ActivePane::Sidebar => Color::Magenta,
                _ => Color::Gray,
            }))
            .render(sidebar_area, buf);
        Block::bordered()
            .border_set(border::THICK)
            .border_style(Style::default().fg(match self.active_pane {
                ActivePane::Content => Color::Magenta,
                _ => Color::Gray,
            }))
            .render(tab_area, buf);
        self.sidebar.render(area_minus_border(sidebar_area), buf);
        self.content.render(area_minus_border(tab_area), buf);
    }
}
