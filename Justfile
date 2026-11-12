set unstable
set lists

BIN := "target/release/xtask"
INPUT := "Fp/Final.lean"
BASE := "https://github.com/oembo-sse/2026-fp-lecture"

build:
    @- rm Fp/Step*.lean
    cargo build --release
    @- rm Fp/Parts/*.lean
    {{BIN}} parts {{INPUT}} Fp/Parts/
    just mk "Lean lecture" "Mini compiler project"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project" "Visualization"
    {{BIN}} readme --base {{BASE}} Fp/Step*.lean

mk *files:
    {{BIN}} step {{INPUT}} {{ quote(files) }} > "Fp/Step$(ls Fp/Step*.lean | wc -l | tr -d ' ').lean"
