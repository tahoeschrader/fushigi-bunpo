mod components;
mod utils;
use crate::components::{home::Home, login::Login};
use color_eyre::Result;
use crossterm::event::{self, Event, KeyCode, KeyEventKind};
use ratatui::{buffer::Buffer, layout::Rect, widgets::Widget, DefaultTerminal, Frame};

fn main() -> Result<()> {
    color_eyre::install()?;
    let mut terminal = ratatui::init();
    let result = App::new().run(&mut terminal);
    ratatui::restore();
    result
}

struct App {
    login: Login,
    home: Home,
    exit: bool,
}

impl App {
    pub fn new() -> Self {
        Self {
            login: Login::new(),
            home: Home::new(),
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
        match event::read()? {
            Event::Key(key) if key.kind == KeyEventKind::Press && key.code == KeyCode::Esc => {
                self.exit = true;
            }
            login_event => match self.login.is_authenticated() {
                true => self.home.handle_event(login_event)?,
                false => self.login.handle_event(login_event)?,
            },
        };
        Ok(())
    }
}

impl Widget for &App {
    fn render(self, area: Rect, buf: &mut Buffer) {
        match self.login.is_authenticated() {
            true => self.home.render(area, buf),
            false => self.login.render(area, buf),
        }
    }
}
