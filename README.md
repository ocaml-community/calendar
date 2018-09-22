# Calendar

A calendar library for OCaml.

[![Travis build Status](https://travis-ci.org/ocaml-community/calendar.svg?branch=2.x)](https://travis-ci.org/ocaml-community/calendar)

1. [Introduction](#1--introduction)
2. [Contents](#2--contents)
3. [Copyright](#3--copyright)
4. [Installation](#4--installation)
5. [How to use](#5--how-to-use)
6. [Documentation](#6--documentation)
7. [Makefile](#7--makefile)
8. [Contact the developper](#8--contact-the-developper)

## 1- Introduction

The Calendar library provides types and operations over dates and times.
This library requires OCaml 4.03.0 or higher.
Older OCaml versions are unsupported.

## 2- Contents

- `CHANGES`		  Information about the last changes
- `COPYING`		  Information about copyright
- `LGPL`		  Information about LGPL
- `README.md`		  This file
- `calendar_faq.txt`  FAQ frow which some algorithms come
- `doc`		  HTML documentation of the API
- `src`		  Source files directory
- `_build/default/`		  Directory containing the built library
- `tests`		  Test files directory
- `utils`		  Some utilities

## 3- Copyright

This program is distributed under the GNU LGPL 2.1.
See the enclosed file COPYING for more details.

## 4- Installation

Easiest way is `opam install calendar`.

To manually install the library, you first need to install `dune` and `re`.
Then:

```
$ dune build @install
$ dune install
```

You can remove files installed with :

`dune uninstall`

## 5- How to use

Use the `calendar` library using ocamlfind. In dune, it means having
an entry `(libraries calendar)`.

## 6- Documentation

The doc directory contains an html documentation of the .mli files.
This documentation is available online at http://calendar.forge.ocamlcore.org/doc/

## 7- Makefile

A description of some Makefile entries follows :

- `make test` will execute some tests. You'll need [alcotest](https://github.com/mirage/alcotest).

  To run only some tests: `dune exec ./tests/test.exe test time` (for example)

- `make doc` to produce the documentation of the API. You need [odoc](https://github.com/ocaml/odoc)

## 8- Contact the developper

You can report bugs at https://github.com/ocaml-community/calendar/issues
