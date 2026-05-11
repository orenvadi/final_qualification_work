#let template(doc) = {
  set page(paper: "a4", margin: (top: 2cm, bottom: 2.5cm, left: 3cm, right: 1.5cm), numbering: "1", footer: context [
    #align(right)[
      #set text(size: 9pt)
      #counter(page).display("1")
    ]
  ])
  set text(font: "Times New Roman", size: 14pt, lang: "ru", hyphenate: false)
  set par(justify: true, first-line-indent: (amount: 1.25cm, all: true), spacing: 0.55em, leading: 0.55em)
  show heading.where(level: 1): set align(center)
  show heading.where(level: 2): set text(weight: "regular")
  show heading: set text(size: 14pt)
  doc
}

#let title_page(practice_number: str, practice_place: str, group: str, author: str, supervisor: str, year: str) = {
  set page(paper: "a4", margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 1.5cm))

  set text(font: "Times New Roman", size: 14pt, lang: "ru")
  set par(justify: true, first-line-indent: (amount: 1cm, all: true), spacing: 0.55em, leading: 0.55em)

  // --- Header ---
  align(center)[
    #upper(text(weight: "bold", size: 12pt)[
      Министерство образования и науки Кыргызской Республики \
      Кыргызско-Германский институт прикладной информатики
    ])
  ]

  v(5cm)

  // --- Title ---
  align(center)[
    #text(weight: "bold", size: 28pt)[ОТЧЕТ] \
    #v(0.2cm)
    о преддипломной практике\
    #text(size: 12pt)[место прохождения практики: #practice_place]
  ]

  v(4cm)

  // --- Credentials Section ---
  align(horizon)[

    #grid(columns: (1fr, 1fr), rect(stroke: none), grid(
      columns: (1fr),
      row-gutter: 1.2em,
      [Выполнил:],
      [студент группы #group],
      [#author],
      [Руководитель практики:],
      [Заведующий кафедрой, доцент],
      [#supervisor#text("_______")],
    ))
  ]

  v(1fr)

  // --- Footer ---
  align(center)[
    Бишкек #year
  ]
}
