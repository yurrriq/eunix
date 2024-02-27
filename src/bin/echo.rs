extern crate clap;

use clap::Parser;

#[derive(Parser)]
#[command(trailing_var_arg = true, allow_hyphen_values = true)]
#[clap(disable_help_flag = true, disable_version_flag = true)]
struct Args {
    /// Do not output a newline
    #[arg(short = 'n', long)]
    no_newline : bool,

    /// Do not separate arguments with spaces
    #[arg(short = 's', long)]
    no_space : bool,

    string : Vec<String>,
}

fn main() {
    let args = Args::parse();

    let strings : Vec<_> = args.string;

    strings.iter().enumerate().for_each(|(i, s)| {
        print!("{}", s);

        if !args.no_space && i < strings.len() - 1 {
            print!(" ");
        }
    });

    if !args.no_newline {
        println!()
    }
}
