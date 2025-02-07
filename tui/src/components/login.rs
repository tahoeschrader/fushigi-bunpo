use crate::utils::center_widget;
use color_eyre::Result;
use crossterm::event::Event;
use ratatui::{
    buffer::Buffer,
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style, Stylize},
    symbols::border,
    text::Text,
    widgets::{Block, Widget},
};
use tui_textarea::{Input, Key, TextArea};

fn inactivate(textarea: &mut TextArea<'_>) {
    textarea.set_cursor_style(Style::default());
}

fn activate(textarea: &mut TextArea<'_>) {
    textarea.set_cursor_style(Style::default().add_modifier(Modifier::REVERSED));
}

enum ActiveInput {
    Username,
    Password,
}

pub struct Login {
    username: TextArea<'static>,
    password: TextArea<'static>,
    active_input: ActiveInput,
}

impl Login {
    pub fn new() -> Self {
        let mut username = TextArea::default();
        let mut password = TextArea::default();
        username.set_style(Style::default().fg(Color::LightMagenta));
        username.set_cursor_line_style(Style::default());
        password.set_cursor_line_style(Style::default());
        password.set_mask_char('\u{1F921}'); // clown emoji
        activate(&mut username);
        inactivate(&mut password);

        Self {
            username,
            password,
            active_input: ActiveInput::Username,
        }
    }

    pub fn handle_event(&mut self, event: Event) -> Result<()> {
        match event.into() {
            Input { key: Key::Tab, .. } => match self.active_input {
                ActiveInput::Username => {
                    inactivate(&mut self.username);
                    activate(&mut self.password);
                    self.active_input = ActiveInput::Password;
                }
                ActiveInput::Password => {
                    inactivate(&mut self.password);
                    activate(&mut self.username);
                    self.active_input = ActiveInput::Username;
                }
            },
            input => {
                let active_input = match self.active_input {
                    ActiveInput::Username => &mut self.username,
                    ActiveInput::Password => &mut self.password,
                };
                active_input.input(input);
            }
        };
        Ok(())
    }
}

impl Widget for &Login {
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
        let input_layout = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Length(10), Constraint::Min(1)]);

        let username_rect = input_layout.split(lines[1]);
        let password_rect = input_layout.split(lines[2]);

        Block::bordered()
            .border_set(border::THICK)
            .render(centered_rect, buf);
        Text::from("Fushigi".bold()).render(lines[0], buf);
        Text::from("Username: ".bold()).render(username_rect[0], buf);
        Text::from("Password: ".bold()).render(password_rect[0], buf);
        self.username.render(username_rect[1], buf);
        self.password.render(password_rect[1], buf);
    }
}
