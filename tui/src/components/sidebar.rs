use ratatui::{
    buffer::Buffer,
    layout::Rect,
    widgets::{List, Widget},
};

pub struct Sidebar {}

impl Sidebar {
    pub fn new() -> Self {
        Self {}
    }
}

impl Widget for &Sidebar {
    fn render(self, area: Rect, buf: &mut Buffer) {
        List::new(["Grammar", "Journal", "Social"]).render(area, buf);
    }
}
