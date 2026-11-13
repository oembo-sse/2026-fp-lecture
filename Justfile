set unstable
set lists

BIN := "target/release/xtask"
INPUT := "Fp/Final.lean"
BASE := "https://github.com/oembo-sse/2026-fp-lecture/tree/main"
RAW := "https://raw.githubusercontent.com/oembo-sse/2026-fp-lecture/refs/heads/main"

build:
    @- rm Fp/Step*.lean
    cargo build --release
    @- rm Fp/Parts/*.lean
    {{BIN}} parts {{INPUT}} Fp/Parts/
    just mk "Lean lecture"
    just mk "Lean lecture" "Warmup"
    just mk "Lean lecture" "Mini compiler project"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project" "Optimization"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project" "Optimization" "Visualization"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project" "Optimization" "Visualization" "Virtual Machine"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project" "Optimization" "Visualization" "Virtual Machine" "Compilation" "Soundness of compilation"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project" "Optimization" "Visualization" "Virtual Machine" "Compilation" "Soundness of compilation" "Repeated optimization"
    just mk "Lean lecture" "Graphviz widgets" "Mini compiler project" "Optimization" "Visualization" "Virtual Machine" "Compilation" "Soundness of compilation" "Repeated optimization" "Fast and correct semantics"
    {{BIN}} readme --base {{BASE}} --raw {{RAW}} Fp/Step*.lean > README.md
    {{BIN}} step-index --raw {{RAW}} Fp/Step*.lean > steps.txt
    typst compile slides.typ

mk *files:
    {{BIN}} step {{INPUT}} {{ quote(files) }} > "Fp/Step$(ls Fp/Step*.lean | wc -l | tr -d ' ').lean"
