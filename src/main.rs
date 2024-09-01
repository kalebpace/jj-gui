use gpui::*;
use jj_cli::commands;

struct HelloWorld {
    text: SharedString,
}

impl Render for HelloWorld {
    fn render(&mut self, _cx: &mut ViewContext<Self>) -> impl IntoElement {
        div()
            .flex()
            .bg(rgb(0x000000))
            .size_full()
            .justify_center()
            .items_center()
            .text_xl()
            .text_color(rgb(0xffffff))
            .child(format!("{}", &self.text))
    }
}

fn main() {
    // CliRunner::init().version(env!("JJ_VERSION")).run();
    let mock_version = "0.20.0";
    let version = commands::default_app()
        .version(mock_version)
        .render_version();

    App::new().run(|cx: &mut AppContext| {
        cx.open_window(WindowOptions::default(), |cx| {
            cx.new_view(|_cx| HelloWorld {
                text: version.into(),
            })
        })
        .unwrap();
    });
}
