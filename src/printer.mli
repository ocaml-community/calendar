(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2011 Julien Signoles                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License version 2.1 as published by the         *)
(*  Free Software Foundation, with a special linking exception (usual     *)
(*  for Objective Caml libraries).                                        *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR                           *)
(*                                                                        *)
(*  See the GNU Lesser General Public Licence version 2.1 for more        *)
(*  details (enclosed in the file LGPL).                                  *)
(*                                                                        *)
(*  The special linking exception is detailled in the enclosed file       *)
(*  LICENSE.                                                              *)
(**************************************************************************)

(** Pretty printing and parsing from string.
    In the following, an "event" is either a date or a time or a calendar.

    This module implements different printers: one for each kind of events.
    The three printers have the same signature:
    they mainly implement a [fprint : string -> formatter -> t -> unit] function
    and a [from_fstring : string -> string -> t] function.
    The first one prints an event according to a format string
    (see below for a description of such a format).
    The second one converts a string to an event according to a format string.

    A format string follows the unix utility 'date' (with few modifications).
    It is a string which contains two types of objects: plain characters and
    conversion specifiers. Those specifiers are introduced by
    a [%] character and their meanings are:
    - [%%]: a literal [%]
    - [%a]: short day name (by using a short version of [day_name])
    - [%A]: day name (by using [day_name])
    - [%b]: short month name (by using a short version of [month_name])
    - [%B]: month name (by using [month_name])
    - [%c]: shortcut for [%a %b %d %H:%M:%S %Y]
    - [%C]: century: as %Y without the two last digits (since version 2.01)
    - [%d]: day of month (01..31)
    - [%D]: shortcut for [%m/%d/%y]
    - [%e]: same as [%_d]
    - [%F]: shortcut for [%Y-%m-%d]: ISO-8601 notation (since version 2.01)
    - [%h]: same as [%b]
    - [%H]: hour (00..23)
    - [%I]: hour (01..12)
    - [%i]: same as [%F]; deprecated since 2.01
    - [%j]: day of year (001..366)
    - [%k]: same as [%_H]
    - [%l]: same as [%_I]
    - [%m]: month (01..12)
    - [%M]: minute (00..59)
    - [%n]: a newline (same as [\n])
    - [%p]: AM or PM
    - [%P]: am or pm (same as %p in lowercase) (since version 2.01)
    - [%r]: shortcut for [%I:%M:%S %p]
    - [%R]: shortcut for [%H:%M] (since version 2.01)
    - [%s]: number of seconds since 1970/1/1 (since version 2.01)
    - [%S]: second (00..60)
    - [%t]: a horizontal tab (same as [\t])
    - [%T]: shortcut for [%H:%M:%S]
    - [%V]: week number of year (01..53)
    - [%w]: day of week (1..7)
    - [%W]: same as [%V]
    - [%y]: last two digits of year (00..99)
    - [%Y]: year (four digits)
    - [%z]: time zone in the form +hhmm (e.g. -0400) (since version 2.01)
    - [%:z]: time zone in the form +hh:mm (e.g. -04:00) (since version 2.01)
    - [%::z]: time zone in the form +hh:mm:ss (e.g. -04:00:00)
    (since version 2.01)
    - [%:::z]: time zone in the form +hh (e.g. -04) (since version 2.01)

    By default, date pads numeric fields with zeroes. Two special modifiers
    between [`%'] and a numeric directive are recognized:
    - ['-' (hyphen)]: do not pad the field
    - ['_' (underscore)]: pad the field with spaces
    - ['0' (zero)]: pad the field with zeroes (default) (since version 2.01)
    - ['^']: use uppercase if possible (since version 2.01)
    Padding is only available for printers, not for parsers.

    @example a possible output of [%D] is [01/06/03]
    @example a possible output of [the date is %B, the %-dth] is
    [the date is January, the 6th] is matched by ;
    @example a possible output of [%c] is [Thu Sep 18 14:10:51 2003].

    @since 1.05 *)

(** {2 Internationalization}

    You can manage the string representations of days and months.
    By default, the English names are used but you can change their by
    setting the references [day_name] and [month_name].

    @example
    [day_name := function Date.Mon -> "lundi" | Date.Tue -> "mardi" |
    Date.Wed -> "mercredi" | Date.Thu -> "jeudi" | Date.Fri -> "vendredi" |
    Date.Sat -> "samedi" | Date.Sun -> "dimanche"]
    sets the names of the days to the French names. *)

val day_name : (Date.day -> string) ref
(** String representation of a day. *)

val name_of_day : Date.day -> string
(** [name_of_day d] is equivalent to [!day_name d].
    Used by the specifier [%A]. *)

val short_name_of_day : Date.day -> string
(** [short_name_of_day d] returns the 3 first characters of [name_of_day d].
    Used by the specifier [%a]. *)

val month_name : (Date.month -> string) ref
(** String representation of a month. *)

val name_of_month : Date.month -> string
(** [name_of_month m] is equivalent to [!day_month m].
    Used by the specifier [%B]. *)

val short_name_of_month : Date.month -> string
(** [short_name_of_month d] returns the 3 first characters of
    [name_of_month d].
    Used by the specifier [%b]. *)

val set_word_regexp: Str.regexp -> unit
  (** Set the regular expression used to recognize words in
      [from_fstring]. Default is [[a-zA-Z]*].
      @since 1.10 *)

(** {2 Printers (including parsers from string)}

    Printers also contain parsers which allow to build events from strings. *)

(** Generic signature of a printer-parser. *)
module type S = sig

  type t
    (** Generic type of a printer. *)

  val fprint : string -> Format.formatter -> t -> unit
    (** [fprint format formatter x] outputs [x] on [formatter] according to
	the specified [format].
	@raise Invalid_argument if the format is incorrect. *)

  val print : string -> t -> unit
    (** [print format] is equivalent to [fprint format Format.std_formatter] *)

  val dprint : t -> unit
    (** Same as [print d] where [d] is the default format
	(see the printer implementations). *)

  val sprint : string -> t -> string
    (** [sprint format date] converts [date] to a string according to
	[format]. *)

  val to_string : t -> string
    (** Same as [sprint d] where [d] is the default format
	(see the printer implementations). *)

  (** {3 Parsers from string} *)

  val from_fstring : string -> string -> t
  (** [from_fstring format s] converts [s] to a date according to [format].

      Date padding (i.e. a special directive following ['%']) and
      specifiers [%e], [%k] and [%l] are not recognized. Specifiers
      [%a], [%A], [%j], [%v], [%w] and [%W] are recognized but mainly ignored:
      only the validity of the format is checked.

      In order to recognize words (used by [%a], [%A], [%b], [%B] and [%p]), a
      regular expression is used which can be configured by
      {!Printer.set_word_regexp}. When the format has only two digits for the
      year number, 1900 are added to this number (see examples).

      @raise Invalid_argument if either the format is incorrect or the string
      does not match the format or the event cannot be created (e.g. if you do
      not specify a year for a date).

      @example [from_fstring "the date is %D" "the date is 01/06/03"]
      returns a date equivalent to [Date.make 1903 1 6]
      @example [from_fstring "the date is %B, the %dth %Y" "the date is May,
      the 14th 2007"] returns a date equivalent to [Date.make 2007 5 14] (with
      default internationalization). *)

  val from_string : string -> t
    (** Same as [from_fstring d] where [d] is the default format. *)

end

(** Date printer. Specifiers which use time functionalities are not available
    on this printer.
    Default format is [%i].
    @since 2.0 *)
module Date: S with type t = Date.t

(** @deprecated Replaced by {!Printer.Date}. *)
module DatePrinter: S with type t = Date.t

(** Time printer. Specifiers which use date functionalities are not available
    on this printer.
    Default format is [%T].
    @since 2.0 *)
module Time: S with type t = Time.t

(** @deprecated Replaced by {!Printer.Time}. *)
module TimePrinter : S with type t = Time.t

(** Ftime printer. Seconds are rounded to integers before pretty printing.
    Specifiers which use date functionalities are not available
    on this printer.
    Default format is [%T].
    @since 2.0 *)
module Ftime: S with type t = Ftime.t

(** Precise Calendar printer. Default format is [%i %T].
    @since 2.0 *)
module Precise_Calendar: S with type t = Calendar.Precise.t

(** Calendar printer. Default format is [%i %T].
    @since 2.0 *)
module Calendar: S with type t = Calendar.t

(** @deprecated Replaced by {!Printer.Calendar}. *)
module CalendarPrinter: S with type t = Calendar.t

(** Precise Fcalendar printer.
    Seconds are rounded to integers before pretty printing.
    Default format is [%i %T].
    @since 2.0 *)
module Precise_Fcalendar: S with type t = Fcalendar.Precise.t

(** Fcalendar printer. Seconds are rounded to integers before pretty printing.
    Default format is [%i %T].
    @since 2.0 *)
module Fcalendar: S with type t = Fcalendar.t
