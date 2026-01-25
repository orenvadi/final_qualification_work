#let template(doc) = {
  set page(paper: "a4", margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1.5cm), numbering: "1", footer: context [
    #align(right)[
      #counter(page).display("1")
    ]
  ])
  set text(font: "Times New Roman", size: 12pt, lang: "ru", hyphenate: false)
  set par(justify: true, first-line-indent: (amount: 1cm, all: true), spacing: 0.54em, leading: 0.54em)
  show heading: set align(center)
  show heading: set text(size: 13pt)
  set heading(numbering: "1.1")
  doc
}
