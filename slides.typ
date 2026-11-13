#import "@preview/typslides:1.4.0": *
#import "@preview/cades:0.3.1": qr-code
#import "@preview/typewind:0.2.0": *

#let parseFile(name) = {
  let parts = read(name)
  let lines = parts.split("\n")
  let title = lines.first().trim("/-!").trim("-/").trim(" ").trim("#").trim(" ")
  let content = lines.slice(2).join("\n")
  (title: title, content: content)
}

// bluey: rgb("3059AB"),
// reddy: rgb("BF3D3D"),
// greeny: rgb("28842F"),
// yelly: rgb("C4853D"),
// purply: rgb("862A70"),
// dusky: rgb("1F4289"),
// darky: black,

// Project configuration
#show: typslides.with(
  ratio: "16-9",
  // theme: "bluey",
  theme: "dusky",
  font: "Fira Sans",
  font-size: 20pt,
  link-style: "color",
  show-progress: true,
)

#let github = "https://github.com/oembo-sse/2026-fp-lecture"

#front-slide(
  title: "Lean and mean",
  subtitle: [Dependable software using dependent types and how it somehow ended up revolutionizing the world of mathematics in the process],
  authors: [Oliver Bøving --- Postdoc @ DTU],
  info: [
    #link(github)
    #place(right + bottom, qr-code(github, width: 4em))
  ],
)

#let lean-code(code, lang: "lean", src: "") = {
  let kw(x) = text(rgb(215, 57, 72), x)
  show "deriving": it => kw(it)
  show "fun_induction": it => kw(it)
  show "where": it => kw(it)
  show "abbrev": it => kw(it)
  show "#guard_msgs": it => kw(it)
  show "termination_by": it => kw(it)
  show "decreasing_by": it => kw(it)
  show "return": it => kw(it)
  show "induction": it => kw(it)
  show "generalizing": it => kw(it)
  set text(0.8em)
  let name = (lean: "Lean", "f#": "F#").at(lang)
  align(start, block[
    #place(top + left, dx: .0em, dy: -1.4em, box(inset: .2em, fill: slate-400, radius: 15%)[#text(
      0.8em,
      white,
      raw(name),
    )])
    #align(start, raw(code, lang: lang))
  ])
}

#let code-slide(file, title: auto, nth: auto, map: it => it, lang: "lean") = {
  let file = parseFile(file)
  let contents = if nth == auto { file.content } else {
    let xs = file.content.split("\n\n")
    let nths = if type(nth) == int { (nth,) } else { nth }
    nths.map(n => map(xs.at(n))).join("\n\n")
  }
  let full-title = if title == auto or type(title) != content { file.title } else { title }
  if title != auto { title-slide[#full-title] }
  slide(title: full-title)[
    #lean-code(contents, lang: lang, src: file)
  ]
}

#let playground(n) = read("steps.txt").split("\n").at(n)
#let follow(n) = focus-slide[
  #raw("Step" + str(n) + ".lean")

  #link(playground(n), text(white, 0.3em)[Open Playground])

  #place(bottom + right, dy: 2.2em, box(fill: white, inset: .03em, qr-code(github, width: .6em)))
]



// #table-of-contents()

#slide[
  - Lean is a _functional programming language_ inspired by Ocaml, F\#, Rust, etc.
  #pause
  - _Dependent types_ enable reasoning about values at compile time
  #pause
  - Encode _propositions as types_ using dependent types
]

#follow(0)

#slide[
  #set align(center)
  Lean and other interactive theorem provers is a key to ensure correctness \ of contemporary research in Computer Science and Mathematics
]

#slide[
  #set align(center)
  #image("images/navier.png")

  #uncover((2, 3), place(center + horizon, dx: 1em, dy: 1em, image("images/dump.png")))
  #uncover(3, place(center + horizon, dx: 2em, dy: 2em, image("images/github-lean.png")))
]


#focus-slide(text-size: 40pt)[
  Lean enables _formal verification_\ using _functional programming_\ with _dependent types_
]

#let fixFS(x) = x.split("```fsharp\n").last().split("```").first().trim()

#title-slide[Mini compiler project]

#slide(title: [Callback to lecture 8])[
  #align(center, box(
    stroke: black.transparentize(50%) + .1em,
    radius: 1%,
    clip: true,
    outset: .1em,
    image("images/seb.png"),
  ))
]

#follow(1)

#code-slide("Fp/Parts/mini-compiler-project.lean", nth: 0, map: fixFS, lang: "f#")


#code-slide("Fp/Parts/mini-compiler-project.lean", nth: 4)
#code-slide("Fp/Parts/mini-compiler-project.lean", nth: (1, 2), map: fixFS, lang: "f#")
#code-slide("Fp/Parts/mini-compiler-project.lean", nth: (5, 6))
#code-slide("Fp/Parts/mini-compiler-project.lean", nth: 7)

#follow(2)

#code-slide("Fp/Parts/optimization.lean", nth: 0, title: true)
#code-slide("Fp/Parts/optimization.lean", nth: 1, title: [Soundness of optimization])

#follow(3)

#code-slide("Fp/Parts/visualization.lean", title: true, nth: 0, map: x => x.split("open Graph in").at(1).trim())

#follow(4)

#code-slide("Fp/Parts/virtual-machine.lean", title: true, nth: 0, map: fixFS, lang: "f#")
#code-slide("Fp/Parts/virtual-machine.lean", nth: 2)
#code-slide("Fp/Parts/virtual-machine.lean", nth: 1, map: fixFS, lang: "f#")
#code-slide("Fp/Parts/virtual-machine.lean", nth: 3)

#follow(5)

#code-slide("Fp/Parts/compilation.lean", title: true, nth: 0)
#code-slide("Fp/Parts/soundness-of-compilation.lean", title: true, nth: 1, map: x => x.split("by").at(0) + "...")
#code-slide("Fp/Parts/soundness-of-compilation.lean", nth: (1, 0), map: x => x.split("by").at(0) + "...")
#code-slide("Fp/Parts/soundness-of-compilation.lean", nth: (1, 0))

#follow(6)

#let hideTerm(x) = x.split("dec").at(0).replace("termination_by e.size", "termination_by ?").trim()
#code-slide("Fp/Parts/repeated-optimization.lean", title: true, nth: 2, map: x => x.split("term").at(0))
#code-slide("Fp/Parts/repeated-optimization.lean", nth: 2, map: hideTerm)
#code-slide("Fp/Parts/repeated-optimization.lean", nth: (2, 0), map: hideTerm)
#code-slide("Fp/Parts/repeated-optimization.lean", nth: (2, 0, 1), map: hideTerm)
#code-slide("Fp/Parts/repeated-optimization.lean", nth: (2, 0, 1), map: x => x.split("dec").at(0).trim())
#code-slide("Fp/Parts/repeated-optimization.lean", nth: (2, 0, 1))
#code-slide("Fp/Parts/repeated-optimization.lean", nth: 3, title: [Soundness of repeated optimization])

#follow(7)

#code-slide("Fp/Parts/fast-and-correct-semantics.lean", nth: 0, title: true)
#code-slide("Fp/Parts/fast-and-correct-semantics.lean", nth: (0, 1))
#code-slide("Fp/Parts/fast-and-correct-semantics.lean", nth: (0, 1, 2))

#follow(8)

#title-slide[
  Recap
]

#let res(x) = [#text(0.8em, baseline: -0.05em, link(x))]

#slide(title: [Learning resources])[
  - Official website: #res("https://lean-lang.org/")
  - Functional Programming in Lean: #res("https://lean-lang.org/functional_programming_in_lean/")
  - Theorem Proving in Lean 4: #res("https://lean-lang.org/theorem_proving_in_lean4/")
]


#front-slide(
  title: "Lean and mean",
  subtitle: [Dependable software using dependent types and how it somehow ended up revolutionizing the world of mathematics in the process],
  authors: [Oliver Bøving --- Postdoc @ DTU],
  info: [
    #link(github)
    #place(right + bottom, qr-code(github, width: 4em))
    #place(top + center, text(1.6em)[Thanks for attending!])
  ],
)

// // Custom outline
// #table-of-contents()

// // Title slides create new sections
// #title-slide[
//   This is a _Title slide_
// ]

// // A simple slide
// #slide[
//   - This is a simple `slide` with no title.
//   - #stress("Bold and coloured") text by using `#stress(text)`.
//   - Sample link: #link("typst.app").
//     - Link styling using `link-style`: `"color"`, `"underline"`, `"both"`
//   - Font selection using `font: "Fira Sans"`, `size: 21pt`.

//   #framed[This text has been written using `#framed(text)`. The background color of the box is customisable.]

//   #framed(title: "Frame with title")[This text has been written using `#framed(title:"Frame with title")[text]`.]
// ]


// // Focus slide
// #focus-slide[
//   This is an auto-resized _focus slide_.
// ]

// // Blank slide
// #blank-slide[
//   - This is a `#blank-slide`.

//   - Available #stress[themes]#footnote[Use them as *color* functions! e.g., `#reddy("your text")`]:

//   #framed(back-color: white)[
//     #bluey("bluey"), #reddy("reddy"), #greeny("greeny"), #yelly("yelly"), #purply("purply"), #dusky("dusky"), darky.
//   ]

//   // #show: typslides.with(
//   // ratio: "16-9",
//   // theme: "bluey",
//   // ...
//   // )

//   - Or just use *your own theme color*:
//     - `theme: rgb("30500B")`
// ]

// // Slide with title
// #slide(title: "Outlined slide", outlined: true)[
//   - Check out the *progress bar* at the bottom of the slide.

//     #h(1cm) `show-progress: true`

//   - Outline slides with `outlined: true`.

//   #grayed([This is a `#grayed` text. Useful for equations.])
//   #grayed($ P_t = alpha - 1 / (sqrt(x) + f(y)) $)

// ]

// // Dynamic display
// #slide(title: "Pause, only and uncover")[

//   #stress[Dynamic display] with `#pause`, `#only` and `#uncover`...

//   #only(1)[*Frame 1*: this text is replaced later (`#only`).]
//   #only("2-")[*Frames 2 and 3*: this is the replacement (`#only`).]
//   #uncover(3)[*Frame 3*: this line was invisible, but its space was reserved (`#uncover`).]

//   #pause
//   - Appears in *Frame 2* (`#pause`).
//   #pause
//   - Appears in *Frame 3* (`#pause`).
// ]

// // Columns
// #slide(title: "Columns")[

//   #cols(columns: (2fr, 1fr, 2fr), gutter: 2em)[
//     #grayed[Columns can be included using `#cols[...][...]`]
//   ][
//     #grayed[And this is]
//   ][
//     #grayed[an example.]
//   ]

//   - Custom spacing: `#cols(columns: (2fr, 1fr, 2fr), gutter: 2em)[...]`

// ]
