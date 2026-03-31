#let colloq_exam_instructions(body) = {
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 1.5cm, top: 2cm, bottom: 2.5cm),
    // Нумерация страниц: внизу справа, 9pt, Times New Roman, интервал 1
    footer: context {
      let pg = counter(page).get().first()
      // Титульный лист не нумеруется (страница 1)
      if pg > 1 {
        align(right, text(font: "New Computer Modern", size: 9pt, str(pg)))
      }
    },
  )

  set text(font: "New Computer Modern", size: 11pt, lang: "ru", hyphenate: false)

  set par(
    justify: true, // выравнивание по ширине
    first-line-indent: (amount: 1.25cm, all: true), // красная строка 1.25 см
    leading: 0.60em, // расстояние между строками внутри абзаца
    spacing: 0.60em,
  )

  show heading.where(level: 2): it => {
    v(0.3em)
    align(center, text(weight: "bold", size: 12pt, it.body))
    v(0.3em)
  }

  set list(marker: [$-$], indent: 1em)

  set enum(indent: 1.5em, body-indent: 0.5em)

  body
}

#let cover = [

  #v(9cm)

  #text(size: 10pt)[Курс 4 Семестр 8]

  #v(0.5cm)

  #text(size: 10pt)[Программа обсуждена и утверждена на заседании Ученого совета Протокол №9 от 26.05.2022 г.]

  #v(0.5cm)

  // --- Main Title ---
  #align(center)[
    #text(weight: "bold")[
      #text(size: 14pt)[Программа по сдаче Коллоквиума]

      студентами Кыргызско-Германского института прикладной информатики \
      по направлению подготовки «Информатика», \
      профиль: «Программные технологии», «Веб-информатика» \
      (уровень квалификации — «бакалавр»)
    ]
  ]
]
