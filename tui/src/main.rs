use color_eyre::Result;
use crossterm::event;
use ratatui::{
    buffer::Buffer,
    layout::{Constraint, Direction, Layout, Rect},
    style::Stylize,
    symbols::border,
    text::Text,
    widgets::{Block, Widget},
    DefaultTerminal, Frame,
};
use tui_textarea::{Input, Key, TextArea};
mod utils;
use crate::utils::center_widget;

#[derive(Debug, Default)]
struct App {
    username: TextArea<'static>, // why does this need to be static to work
    password: String,
    exit: bool,
}

impl App {
    pub fn new() -> Self {
        let username = TextArea::default();
        let password = String::from("");

        Self {
            username,
            password,
            exit: false,
        }
    }

    pub fn run(&mut self, terminal: &mut DefaultTerminal) -> Result<()> {
        while !self.exit {
            terminal.draw(|frame| self.render(frame))?;
            self.handle_events()?;
        }
        Ok(())
    }

    fn render(&self, frame: &mut Frame) {
        frame.render_widget(self, frame.area());
    }

    fn handle_events(&mut self) -> Result<()> {
        match event::read()?.into() {
            Input { key: Key::Esc, .. } => self.exit = true,
            input => {
                self.username.input(input);
            }
        };
        Ok(())
    }
}

impl Widget for &App {
    fn render(self, area: Rect, buf: &mut Buffer) {
        let centered_rect = center_widget(area, Constraint::Length(50), Constraint::Length(5));
        let unbordered_rect = Rect {
            x: centered_rect.x + 1,
            y: centered_rect.y + 1,
            width: centered_rect.width - 2,
            height: centered_rect.height - 2,
        };
        // Split it into three lines
        let lines = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(1),
                Constraint::Length(1),
                Constraint::Length(1),
            ])
            .split(unbordered_rect);

        Block::bordered()
            .border_set(border::THICK)
            .render(centered_rect, buf);
        Text::from("Fushigi".bold()).render(lines[0], buf);
        self.username.render(lines[1], buf);
        Text::from(self.password.clone()).render(lines[2], buf);
    }
}

fn main() -> Result<()> {
    color_eyre::install()?;
    let mut terminal = ratatui::init();
    let result = App::new().run(&mut terminal);
    ratatui::restore();
    result
}
