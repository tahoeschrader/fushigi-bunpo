use ratatui::layout::{Constraint, Flex, Layout, Rect};
use tui_textarea::{CursorMove, TextArea};

pub fn center_widget(area: Rect, horizontal: Constraint, vertical: Constraint) -> Rect {
    let [area] = Layout::horizontal([horizontal])
        .flex(Flex::Center)
        .areas(area);
    let [area] = Layout::vertical([vertical]).flex(Flex::Center).areas(area);
    area
}

pub fn wipe_text_area(textarea: &mut TextArea) {
    while !textarea.is_empty() {
        textarea.move_cursor(CursorMove::End);
        textarea.delete_line_by_head();
    }
}
