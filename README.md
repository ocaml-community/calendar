# Calendar

A calendar library for OCaml.

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
This library requires OCaml 3.09.1 or higher.
OCaml 3.09 is usable at your own risk.
Older OCaml versions are unsupported.

## 2- Contents

- `CHANGES`		  Information about the last changes
- `COPYING`		  Information about copyright
- `LGPL`		  Information about LGPL
- `README.md`		  This file
- `Makefile.in`	  Makefile used by configure
- `configure`	  Script generating Makefile
- `configure.in`	  Script generating configure (with autoconf)
- `calendar_faq.txt`  FAQ frow which some algorithms come
- `doc`		  HTML documentation of the API
- `src`		  Source files directory
- `target`		  Directory containing the built library
- `tests`		  Test files directory
- `utils`		  Some utilities

## 3- Copyright

This program is distributed under the GNU LGPL 2.1.
See the enclosed file COPYING for more details.

## 4- Installation

You need Objective Caml >= 3.09.1 to compile the sources.
You need too ocamlfind coming with findlib and available at:
	http://www.ocaml-programming.de/packages/

1. Configure with `./configure`.
2. Compile with `make`.
3. Install with `make install` (you may need superuser permissions).
4. Clean the directory with `make clean`.

You can remove files installed by "make install" at any time with :

`make uninstall` (you may need superuser permissions)

## 5- How to use

(a) Use the GODI package of calendar !

  see: http://godi.ocaml-programming.de

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
This documentation is available online at http://calendar.forge.ocamlcore.org/doc/

## 7- Makefile

A description of some Makefile entries follows :

- i. tests
  Execute some tests

- ii. wc
  Give informations about the size of the source files. You need ocamlwc `(*)`.

- iii. doc
  Produce the documentation of the API. You need ocamldoc `(**)`.

`(*)`  ocamlwc is available at http://www.lri.fr/~filliatr/software.en.html
`(**)` ocamldoc is included with Objective Caml

## 8- Contact the developers

You can report bugs at https://github.com/ocaml-community/calendar/issues
