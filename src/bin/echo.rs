extern crate clap;

use std::str;

use clap::{crate_version, App, AppSettings, Arg};

fn main() {
    let args = App::new("echo")
        .setting(AppSettings::TrailingVarArg)
        .version(crate_version!())
        .arg(
            Arg::with_name("no_newline")
                .short("n")
                .help("Do not output a newline"),
        )
        .arg(
            Arg::with_name("no_space")
                .short("s")
                .help("Do not separate arguments with spaces"),
        )
        .arg(Arg::with_name("STRING").multiple(true))
        .get_matches();

    let strings : Vec<&str> =
        args.values_of("STRING").unwrap_or_default().collect();

    strings.iter().enumerate().for_each(|(i, s)| {
        print!("{}", s);

        if !args.is_present("no_space") && i < strings.len() - 1 {
            print!(" ");
        }
    });

    if !args.is_present("no_newline") {
        println!()
    }
}
