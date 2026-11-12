#import "@preview/typslides:1.4.0": *

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

#front-slide(
  title: "Lean and mean",
  subtitle: [Using _typslides_],
  authors: [Oliver Bøving],
  info: [#link("https://github.com/oembo-see/2026-fp-lecture")],
)

#let lean-code(code) = {
  let kw(x) = text(rgb(215, 57, 72), x)
  show "deriving": it => kw(it)
  show "fun_induction": it => kw(it)
  show "where": it => kw(it)
  show "abbrev": it => kw(it)
  show "#guard_msgs": it => kw(it)
  set text(0.9em)
  raw(code, lang: "lean")
}

#let code-slide(file, title: auto, nth: auto, map: it => it) = {
  let file = parseFile(file)
  let contents = map(if nth == auto { file.content } else {
    let xs = file.content.split("\n\n")
    let nths = if type(nth) == int { (nth,) } else { nth }
    nths.map(n => xs.at(n)).join("\n\n")
  })
  let full-title = if title == auto or type(title) != content { file.title } else { title }
  if title != auto { title-slide[#full-title] }
  slide(title: full-title)[
    #lean-code(contents)
  ]
}

#table-of-contents()

#slide[
  Lean is a _functional programming language_ with _dependent types_
]

#focus-slide[
  Lean enables _formal verification_\ using _functional programming_\ with _dependent types_

]

#code-slide("Fp/Parts/mini-compiler-project.lean", nth: 0, title: true)
#code-slide("Fp/Parts/mini-compiler-project.lean", nth: (1, 2))
#code-slide("Fp/Parts/mini-compiler-project.lean", nth: 3)
#code-slide("Fp/Parts/optimization.lean", nth: 0, title: true)
#code-slide("Fp/Parts/optimization.lean", nth: 1, title: [Soundness of optimization], map: x => (
  x.split(" := ").at(0) + " := ..."
))

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
