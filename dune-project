(lang dune 2.8)
(generate_opam_files true)
(name calendar)

(source (github ocaml-community/calendar))
(license "LGPL-2.1-only WITH OCaml-LGPL-linking-exception")
(authors "Julien Signoles")
(maintainers "https://github.com/orgs/ocaml-community/people")

(package
 (name calendar)
 (synopsis "Library for handling dates and times in your program")
 (depends
   ocaml
   stdlib-shims))

(package
 (name CalendarLib)
 (synopsis "Library for handling dates and times in your program")
 (depends
   ocaml
   stdlib-shims))
