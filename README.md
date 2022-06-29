# Calendar

A calendar library for OCaml. [API documentation](https://ocaml-community.github.io/calendar/calendar/CalendarLib/index.html)

[![Travis build Status](https://travis-ci.org/ocaml-community/calendar.svg?branch=master)](https://travis-ci.org/ocaml-community/calendar)

1. [Introduction](#1--introduction)
2. [Contents](#2--contents)
3. [Copyright](#3--copyright)
4. [Installation](#4--installation)
5. [How to use](#5--how-to-use)
6. [Documentation](#6--documentation)
7. [Makefile](#7--makefile)
8. [Contact the developers](#8--contact-the-developers)

## 1- Introduction

The Calendar library provides types and operations over dates and times.
This library requires OCaml 4.02 or higher.
Older OCaml versions are unsupported.

## 2- Contents

- `CHANGES`		  Information about the last changes
- `COPYING`		  Information about copyright
- `LGPL`		  Information about LGPL
- `README.md`		  This file
- `calendar_faq.txt`  FAQ frow which some algorithms come
- `doc`		  HTML documentation of the API
- `src`		  Source files directory
- `tests`		  Test files directory
- `utils`		  Some utilities

## 3- Copyright

This program is distributed under the GNU LGPL 2.1.
See the enclosed file COPYING for more details.

## 4- Installation

You need OCaml >= 4.02.0 to compile the sources.

1. `opam switch create ./ ocaml-base-compiler.4.14.0 --no-install`
1. `opam install . --deps-only --with-test`
1. `dune build`

## 5- How to use

Install the OPAM package of calendar:

`opam install calendar`

(a) Add `calendar` to your `dune` libraries:

```
    (libraries calendar)
```

(b) Or: simply link calendar with your files using ocamlfind.

For example, if you have a file foo_using_calendar.ml, compile it as follow:

	ocamlfind ocamlc -package calendar -linkpkg foo_using_calendar.ml
or

	ocamlfind ocamlopt -package calendar -linkpkg foo_using_calendar.ml

(c) Or: do not use ocamlfind, link calendar with unix and str and
specify the directory containing calendar:

	ocamlc -I /usr/local/lib/ocaml/site-lib/calendar unix.cma calendarLib.cmo foo_using_calendar.ml
or

	ocamlopt -I /usr/local/lib/ocaml/site-lib/calendar unix.cmxa calendarLib.cmx foo_using_calendar.ml

## 6- Documentation

The doc directory contains an html documentation of the .mli files.
This documentation is available online at https://ocaml-community.github.io/calendar/

## 7- Contact the developers

You can report bugs at https://github.com/ocaml-community/calendar/issues
