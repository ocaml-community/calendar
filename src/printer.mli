(*
 * Calendar library
 * Copyright (C) 2003 Julien SIGNOLES
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License version 2, as published by the Free Software Foundation.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * See the GNU Library General Public License version 2 for more details
 *)

(*i $Id: printer.mli,v 1.4 2003-09-18 13:16:55 signoles Exp $ i*)

module type S = sig
  type t

  (* [fprint format formatter x] outputs [x] on [formatter] according to
     the specified [format]. The year before 1 AC are not correctly 
     pretty printed. Raise [Invalid_argument] if the format is incorrect.
     
     The formats are based on the Unix date formats. It is
     a string which contains two types of objects: plain characters and 
     conversion specifications. Those specifications are introduced by a [%]
     character and their meanings are:

     \begin{tabular}{l@{\hspace{5mm}}l}
     [%%] & a literal [%]\\
     [%a] & short day name (by using [short_day_name])\\
     [%A] & day name (by using [day_name])\\
     [%b] & short month name (by using [short_month_name])\\
     [%B] & month name (by using [month_name])\\
     [%c] & shortcut for [%a %b %d %H:%M:%S %Y]\\
     [%d] & day of month (01..31)\\
     [%D] & shortcut for [%m/%d/%y]\\
     [%e] & same as [%_d]\\
     [%h] & same as [%b]\\
     [%H] & hour (00..23)\\
     [%I] & hour (01..12)\\
     [%j] & day of year (001..366)\\
     [%k] & same as [%_H]\\
     [%l] & same as [%_I]\\
     [%m] & month (01..12)\\
     [%M] & minute (00..59)\\
     [%n] & a newline (same as [\n])\\
     [%p] & AM or PM\\
     [%r] & shortcut for [%I:%M:%S %p]\\
     [%S] & second (00..60)\\
     [%t] & a horizontal tab (same as [\t])\\
     [%T] & shortcut for [%H:%M:%S]\\
     [%V] & week number of year (01..53)\\
     [%w] & day of week (1..7)\\
     [%W] & same as [%V]\\
     [%y] & last two digits of year (00..99)\\
     [%Y] & year (four digits)
     \end{tabular}
     
     By default, date pads numeric fields with zeroes. Two special modifiers 
     between [`%'] and a numeric directive are recognized:
     
     \begin{tabular}{l@{\hspace{5mm}}l}
     ['-' (hyphen)] & do not pad the field\\
     ['_' (underscore)] & pad the field with spaces
     \end{tabular}
     
     Some examples follows ([d = Date.make 2003 1 6] and 
     [fmt = Format.std_formatter]):\\
     [fprint "%D" fmt d] prints [01/06/03]\\
     [fprint "the date is %B, the %-dth" fmt d] prints 
     [the date is January, the 6th] *)
  val fprint : string -> Format.formatter -> t -> unit
    
  (* [print format] is equivalent to [fprint format Format.std_formatter] *)
  val print : string -> t -> unit

  (* Same as [print "%Y-%m-%d"] *)
  val dprint : t -> unit

  (* [sprint format date] converts [date] to a string according to [format]. 
   See [fprint] for the description of the available formats. *)
  val sprint : string -> t -> string
    
  (*  Same as [sprint "%Y-%m-%d"] *)
  val to_string : t -> string

  (* [from_fstring format s] converts [s] to a date according to [format].
     Only the format [%%], [%d], [%D], [%m], [%y] and [%Y] are available.
     See [fprint] for the description of those formats. 
     When the format has only two digits for the year number, 1900 are added
     to this number (see the example). Only positive year are recognized.
     
     Raise [Invalid_argument] if either the format is incorrect 
     or the string does not match the format
     or the date cannot be created.

     For example [from_fstring "the date is %D" "the date is 01/06/03"] returns
     a date equivalent to [make 1903 1 6]. *)
  val from_fstring : string -> string -> t

  (* Same as [from_fstring "%Y-%m-%d"] *)
  val from_string : string -> t
end

(* String representation of a day. By default, English names are used
   (so [!day_name Sun] is ["Sunday"], etc). *)
val day_name : (Date.day -> string) ref

(* String representation of a month. By default, English names are used
   (so [!day_name Jan] is ["January"], etc). *)
val month_name : (Date.month -> string) ref

module DatePrinter : S with type t = Date.t
module TimePrinter : S with type t = Time.t
module CalendarPrinter : S with type t = Calendar.t
