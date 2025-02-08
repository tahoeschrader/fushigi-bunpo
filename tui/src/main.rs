mod components;
mod utils;
use crate::components::login::Login;

use color_eyre::Result;
use crossterm::event::{self, Event, KeyCode, KeyEventKind};
use ratatui::{
    buffer::Buffer, layout::Rect, style::Stylize, text::Text, widgets::Widget, DefaultTerminal,
    Frame,
};

fn main() -> Result<()> {
    color_eyre::install()?;
    let mut terminal = ratatui::init();
    let result = App::new().run(&mut terminal);
    ratatui::restore();
    result
}

struct App {
    login: Login,
    exit: bool,
}

impl App {
    pub fn new() -> Self {
        Self {
            login: Login::new(),
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
            login_event => {
                if self.login.is_authenticated() {
                    //hello
                } else {
                    self.login.handle_event(login_event)?;
                }
            }
        };
        Ok(())
    }
}

impl Widget for &App {
    fn render(self, area: Rect, buf: &mut Buffer) {
        if self.login.is_authenticated() {
            Text::from("Success".bold()).render(area, buf);
        } else {
            self.login.render(area, buf);
        }
    }
}
