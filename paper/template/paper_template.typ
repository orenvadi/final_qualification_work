// ============================================================
// Шаблон оформления ВКР КГИПИ
// Соответствует «Унифицированным требованиям к оформлению ВКР»
// ============================================================

// ------- Основная функция шаблона --------

#let vkr(
  // Данные работы
  title: "Название темы выпускной квалификационной работы",
  author: "Фамилия Имя Отчество",
  group: "ИС-41",
  supervisor: "Фамилия И.О.",
  supervisor-degree: "к.т.н., доцент",
  reviewer: "Фамилия И.О.",
  vice-rector: "Фамилия И.О.",
  year: "2025",
  city: "Бишкек",
  // Аннотация (текст на двух языках)
  annotation-ru: [],
  annotation-kg: [],
  // Тело документа (основное содержание)
  body,
) = {
  // ---- Настройки страницы ----
  set page(
    paper: "a4",
    margin: (left: 3cm, right: 1.5cm, top: 2cm, bottom: 2.5cm),
    // Нумерация страниц: внизу справа, 9pt, Times New Roman, интервал 1
    footer: context {
      let pg = counter(page).get().first()
      // Титульный лист не нумеруется (страница 1)
      if pg > 1 {
        align(right, text(font: "Times New Roman", size: 9pt, str(pg)))
      }
    },
  )

  // ---- Базовые настройки текста ----
  set text(font: "Times New Roman", size: 14pt, lang: "ru", hyphenate: false)

  // ---- Межстрочный интервал 1.5 ----
  set par(
    justify: true, // выравнивание по ширине
    first-line-indent: (amount: 1.25cm, all: true), // красная строка 1.25 см
    leading: 1.05em, // расстояние между строками внутри абзаца
    spacing: 1.05em,
  )

  // ---- Заголовки ----
  // Уровень 1 — главы (заглавными буквами, жирный, по центру, с новой страницы)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0pt)
    align(center, text(weight: "bold", size: 14pt, upper(it.body)))
    v(0.5em)
  }

  // Уровень 2 — параграфы (с красной строки, прописная, жирный, по центру)
  show heading.where(level: 2): it => {
    v(0.3em)
    align(center, text(weight: "bold", size: 14pt, it.body))
    v(0.3em)
  }

  // Уровень 3 — подпараграфы (жирный, с абзаца)
  show heading.where(level: 3): it => {
    v(0.3em)
    text(weight: "bold", size: 14pt, it.body)
    v(0.2em)
  }

  // ---- Оформление рисунков ----
  // Нумерация: номер главы + номер рисунка, например «Рисунок 1.1 – Название»
  // Используется через функцию figure()
  show figure.where(kind: image): it => {
    v(0.5em)
    align(center, it.body)
    v(0.3em)
    align(center, text(size: 12pt, "Рисунок " + it.counter.display() + " – " + it.caption.body))
    v(0.5em)
  }

  // ---- Оформление таблиц ----
  // Нумерация: «Таблица Х.Х – Название», шрифт 12pt, интервал 1
  show figure.where(kind: table): it => {
    v(0.5em)
    align(left, text(size: 12pt, "Таблица " + it.counter.display() + " – " + it.caption.body))
    v(0.2em)
    it.body
    v(0.5em)
  }

  set figure(numbering: "1.1")
  set figure(supplement: none)

  // ---- ТИТУЛЬНЫЙ ЛИСТ ----
  {
    set page(footer: none) // на титульном листе нет нумерации
    set par(first-line-indent: 0cm, justify: false)

    align(center, [
      #text(size: 12pt)[
        *МИНИСТЕРСТВО ОБРАЗОВАНИЯ И НАУКИ КЫРГЫЗСКОЙ РЕСПУБЛИКИ* \
        *КЫРГЫЗСКО-ГЕРМАНСКИЙ ИНСТИТУТ ПРИКЛАДНОЙ ИНФОРМАТИКИ*
      ]
    ])

    v(5.5cm)

    align(center, [
      #text(size: 12pt, weight: "bold")[
        ВЫПУСКНАЯ КВАЛИФИКАЦИОННАЯ РАБОТА БАКАЛАВРА
      ]
    ])

    v(0.7cm)

    align(center, [
      #text(size: 14pt)[
        на тему: «#title»
      ]
    ])

    // v(3cm)

    // Блок с данными студента и руководителя — по правому краю
    // align(right, [
    // #table(
    // columns: (auto, auto),
    // stroke: none,
    // inset: (x: 4pt, y: 4pt),
    // [*Студент группы #group:*],
    // [#author],
    // [],
    // [Подпись #box(width: 5cm, stroke: (bottom: 0.5pt), inset: (bottom: 2pt))[#h(5cm)]],
    // [*Научный руководитель:*],
    // [#supervisor],
    // [],
    // [#supervisor-degree],
    // [],
    // [Подпись #box(width: 5cm, stroke: (bottom: 0.5pt), inset: (bottom: 2pt))[#h(5cm)]],
    // )
    // ])

    v(4cm)
    grid(
      columns: (1fr, 1fr, 1.5fr),
      gutter: 10pt,
      [#text(size: 14pt)[Студент группы] ],
      [#v(12pt) #line(length: 100%) #align(center)[#text(size: 10pt)[_(подпись)_]]],
      [#align(center)[#text(size: 14pt, style: "italic")[#author]]],
    )

    v(2cm)
    grid(
      columns: (1fr, 1fr, 1.5fr),
      gutter: 10pt,
      [#text(size: 14pt)[Научный руководитель]],
      [#v(12pt) #line(length: 100%) #align(center)[#text(size: 10pt)[_(подпись)_]]],
      [#align(center)[#text(size: 14pt, style: "italic")[#supervisor-degree, #supervisor]]],
    )

    v(1fr)

    align(center, [
      #text(size: 14pt)[
        #city – #year
      ]
    ])
  }

  // ---- АННОТАЦИЯ ----
  {
    set par(
      justify: true, // выравнивание по ширине
      first-line-indent: (amount: 1.25cm, all: true), // красная строка 1.25 см
      leading: 1.05em, // расстояние между строками внутри абзаца
      spacing: 1.05em,
    )
    counter(page).update(2) // аннотация = стр. 2

    align(center, text(weight: "bold", size: 14pt, "АННОТАЦИЯ"))
    v(0.5em)

    // Кыргызский текст (если передан)
    if annotation-kg != [] {
      annotation-kg
      // v(1em)
    }

    // Русский текст
    par[#annotation-ru]
  }

  pagebreak()

  // ---- СОДЕРЖАНИЕ ----
  {
    set par(first-line-indent: 0cm, justify: false)

    align(center, text(weight: "bold", size: 14pt, "СОДЕРЖАНИЕ"))
    v(0.5em)

    // Автоматическое оглавление
    outline(title: none, indent: auto, depth: 2)
  }

  pagebreak()

  // ---- ОСНОВНОЕ СОДЕРЖАНИЕ ----
  body
}

// ============================================================
// Вспомогательные функции оформления
// ============================================================

// Функция для подписи рисунка (12pt, по центру)
// Используется внутри figure: figure(image(...), caption: fig-caption("..."))
#let fig-caption(text) = text

// Функция для подписи таблицы
#let tbl-caption(text) = text

// Затекстовая ссылка: [номер, с. страница]
// Например: #ref-cite(6, 45) → [6, с. 45]
#let ref-cite(num, page: none) = {
  if page == none {
    [[#num]]
  } else {
    [[#num, с. #page]]
  }
}

// Несколько источников: #ref-cites(6, 12, 30) → [6, 12, 30]
#let ref-cites(..nums) = {
  [[#nums.pos().join(", ")]]
}

// ============================================================
// Вспомогательный набор стилей для структурных блоков
// ============================================================

// Заголовок главы (вызывается вручную, если не используется heading)
#let chapter(number, title) = {
  heading(level: 1, numbering: none, number + " " + upper(title))
}

// Параграф (подраздел)
#let section(number, title) = {
  heading(level: 2, numbering: none, number + " " + title)
}

// Подпараграф
#let subsection(number, title) = {
  heading(level: 3, numbering: none, number + " " + title)
}

// ============================================================
// Оформление библиографической записи (ГОСТ 7.1-2003)
// ============================================================

// Один автор
// #bib-one-author("Семенов, В. В.", "Название", "М.", "Наука", "2000", "64")
#let bib-one-author(author, title, place, publisher, year, pages) = {
  par(
    first-line-indent: 0cm,
    hanging-indent: 1.5cm,
    [#author #title \[Текст\] / #author. – #place: #publisher, #year. – #pages с.],
  )
}

// Электронный ресурс
#let bib-online(author, title, url, year: "") = {
  par(
    first-line-indent: 0cm,
    hanging-indent: 1.5cm,
    [#if author != "" [#author,] «#title» \[Электронный ресурс\]#if year != "" [. – #year]. – Режим доступа: #link(url) – Загл. с экрана.],
  )
}
