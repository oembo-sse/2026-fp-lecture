use clap::Parser;
use color_eyre::{Result, eyre::eyre};
use heck::ToKebabCase;
use indexmap::IndexMap;
use itertools::Itertools;
use std::{
    fs,
    path::{Path, PathBuf},
};

#[derive(clap::Parser)]
enum Cli {
    Step {
        file: PathBuf,
        include: Vec<String>,
    },
    Parts {
        file: PathBuf,
        folder: PathBuf,
    },
    Readme {
        files: Vec<PathBuf>,
        #[clap(long)]
        base: String,
        #[clap(long)]
        raw: String,
    },
    StepIndex {
        files: Vec<PathBuf>,
        #[clap(long)]
        raw: String,
    },
}

struct File {
    prelude: String,
    markers: IndexMap<String, String>,
}

fn get_markers(file: &Path) -> Result<File> {
    let src = fs::read_to_string(file)?;

    let markers = src.match_indices("/-! # ").collect_vec();
    let prelude = src[0..markers[0].0].to_string();

    let markers: IndexMap<String, String> = markers
        .into_iter()
        .chain([(src.len(), "")])
        .tuple_windows()
        .map(|((idx, s), (end, _))| {
            let name = src[s.len() + idx..]
                .split_once("\n")
                .unwrap()
                .0
                .trim_end_matches("-/")
                .trim_end();
            let contents = &src[idx..end];
            (name.to_string(), contents.to_string())
        })
        .collect();
    Ok(File { prelude, markers })
}

fn main() -> Result<()> {
    color_eyre::install()?;

    match Cli::parse() {
        Cli::Step { file, include } => {
            let File { prelude, markers } = get_markers(&file)?;
            for name in &include {
                if !markers.contains_key(name.as_str()) {
                    Err(eyre!(
                        "missing key {name:?}\npossible keys are:\n - {:?}",
                        markers.keys().format("\n - ")
                    ))?;
                }
            }

            print!("{prelude}");
            for name in &include {
                print!("{}", markers[name.as_str()]);
            }
        }
        Cli::Parts { file, folder } => {
            let File {
                prelude: _,
                markers,
            } = get_markers(&file)?;
            let mut files = Vec::new();
            for (name, content) in markers.iter() {
                let name = folder.join(format!("{}.lean", name.to_kebab_case()));
                fs::write(&name, content)?;
                files.push(name);
            }
            fs::write(
                folder.join("index.txt"),
                files.iter().map(|x| x.display()).join("\n"),
            )?;
        }
        Cli::Readme { files, base, raw } => {
            let links = files
                .into_iter()
                .enumerate()
                .map(|(i, f)| {
                    let gh = format!("{base}/{}", f.display());
                    let play = mk_playground_link(&format!("{raw}/{}", f.display()));
                    format!("| **Step {i}** | [Link]({gh}) | [Link]({play}) |")
                })
                .join("\n");

            let out = README.replace("LINKS", &links);
            println!("{}", out.trim())
        }
        Cli::StepIndex { files, raw } => {
            let links = files
                .into_iter()
                .map(|f| mk_playground_link(&format!("{raw}/{}", f.display())))
                .join("\n");

            println!("{}", links.trim())
        }
    }

    Ok(())
}

fn mk_playground_link(url: &str) -> String {
    let playground = "https://live.lean-lang.org";
    let encoded = urlencoding::encode(url);
    format!("{playground}/#url={encoded}")
}

const README: &str = r#"
# 2026 Functional Programming guest lecture

_By Oliver Bøving_

## Slides

The slides are [here](slides.pdf). If you want to code along, the links below will take you to the online playground where you can try Lean in your browser. The slides also contains links as we introduce concepts.

## Links

| Step | GitHub | Lean Playground |
|------|--------|-----------------|
LINKS

"#;
