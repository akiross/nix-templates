use slint::{ModelRc, VecModel};

slint::slint! {
    import { Button, HorizontalBox, ListView, VerticalBox } from "std-widgets.slint";

    export struct Row := {
        first_name: string,
        last_name: string,
    }

    ListDisplay := Window {
        property <[Row]> elements;

        callback greet(string, string);

        width: 400px;
        height: 200px;
        VerticalBox {
            ListView {
                for data in root.elements:
                    HorizontalBox {
                        Text { text: data.first_name; }
                        Text { text: data.last_name; }
                        Button {
                            width: 100px; text: "Greet";
                            clicked => {
                                root.greet(data.first_name, data.last_name);
                            }
                        }
                    }
            }
        }
    }
}

fn main() {
    let app = ListDisplay::new();

    // Set the model with data to show
    let m = VecModel::default();
    m.push(Row {
        first_name: "John".into(),
        last_name: "Doe".into(),
    });
    m.push(Row {
        first_name: "Jane".into(),
        last_name: "Doe".into(),
    });
    let m = ModelRc::new(m);
    app.set_elements(m);

    // Register callback
    app.on_greet(|f, l| {
        println!("Hello, {} {}", f, l);
    });

    app.run();
}
