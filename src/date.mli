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

(*i $Id: date.mli,v 1.12 2003-09-18 07:03:14 signoles Exp $ i*)

(*S Introduction. 

  This module implements operations on dates. 
  A date is a triple (year, month, day). 

  All the dates should belong to 
  [[January, 1st 4713 BC; January 22th, 3268 AC]] (called the Julian period).
  An [Out_of_bounds] exception is raised if you attempt to create a date 
  outside the Julian period.

  If a date [d] does not exists and if [d_bef] (resp. [d_aft]) is 
  the last (resp. first) existing date before (resp. after) [d], 
  [d] is automatically coerced to [d_aft + d - d_bef - 1].
  For example, both dates "February 29th, 2003" and 
  "February 30th, 2003" do not exist and they are coerced respectively to the 
  date "Mars 1st, 2003" and "Mars 2nd, 2003". 
  This rule is called the \emph{coercion rule}.
  As an exception to the coercion rule, the date belonging to 
  [[October 5th, 1582; October 14th, 1582]] do not exist and an [Undefined] 
  exception is raised if you attempt to create such a date.
  Those dropped days correspond to the change from the Julian to the Gregorian
  calendar.\\ *)

(*S Datatypes. *)

(* Type of a date. *)
type t

(* Days of the week. *)
type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

(* Months of the year. *)
type month = 
    Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

(* The different fields of a date. *)
type field = [ `Year | `Month | `Week | `Day ]

(*S Exceptions. *)

(* Raised when a date is outside the Julian period. *)
exception Out_of_bounds

(* Raised when a date belongs to [[October 5th, 1582; October 14th, 1582]]. *)
exception Undefined

(*S Constructors. *)

(* [make year month day] makes the date year-month-day.
   A BC year [y] corresponds to the year [-(y+1)].
   E.g. the years (5 BC) and (1 BC) respectively correspond to the years 
   (-4) and 0. *)
val make : int -> int -> int -> t

(* Labelled version of [make]. 
   The default value of [month] and [day] is [1]. *)
val lmake : year:int -> ?month:int -> ?day:int -> unit -> t

(* Date of the current day (based on [Time_Zone.current ()]). *)
val today : unit -> t

(* Make a date from its Julian day. 
   E.g. [from_jd 0] returns the date 4713 BC-1-1. *)
val from_jd : int -> t

(* Make a date from its modified Julian day (i.e. Julian day - 2 400 001).
   The Modified Julian day is more manageable than the Julian day.
   E.g. [from_mjd 0] returns the date 1858-11-17. *)
val from_mjd : int -> t
    
(*S Getters. *)
  
(* Number of days in the month of a date.
   E.g [days_in_month (make 2003 6 26)] returns [30]. *)
val days_in_month : t -> int

(* Day of the week. 
   E.g. [day_of_week (make 2003 6 26)] returns [Thu]. *)
val day_of_week : t -> day

(* Day of the month. 
   E.g. [day_of_month (make 2003 6 26)] returns [26]. *)
val day_of_month : t -> int

(* Day of the year.
   E.g. [day_of_year (make 2003 1 5)] returns [5]
   and [day_of_year (make 2003 12 28)] returns [362]. *)
val day_of_year : t -> int

(* Week. 
   E.g. [week (make 2003 1 5)] returns [1]
   and [week (make 2003 12 28)] returns [52]. *)
val week : t -> int

(* Month.
   E.g. [month (make 2003 6 26)] returns [Jun]. *)
val month : t -> month

(* Year.
   E.g. [year (make 2003 6 26)] returns [2003]. *)
val year : t -> int

(* Julian day. 
   E.g. [to_jd (make (-4712) 1 1)] returns 0. *)
val to_jd : t -> int
  
(* Modified Julian day (i.e. Julian day - 2 400 001).
   The Modified Julian day is more manageable than the Julian day. 
   E.g. [to_mjd (make 1858 11 17)] returns 0. *)
val to_mjd : t -> int

(*S Boolean operations on dates. *)

(* Comparison function between two dates. 
   Same behavior as [Pervasives.compare]. *)
val compare : t -> t -> int

(* Return [true] if a date is a leap day
   (i.e. February, 24th of a leap year); [false] otherwise. *)
val is_leap_day : t -> bool

(* Return [true] if a date belongs to the Gregorian calendar;
   [false] otherwise. *)
val is_gregorian : t -> bool

(* Return [true] iff a date belongs to the Julian calendar;
   [false] otherwise. *)
val is_julian : t -> bool

(*S Coercions. *)

(* Convert a date into the [Unix.tm] type. 
   The field [is_isdst] is always [false]. The fields [Unix.tm_sec], 
   [Unix.tm_min] and [Unix.tm_hour] are irrelevant. *)
val to_unixtm : t -> Unix.tm

(* Inverse of [to_unixtm]. *)
val from_unixtm : Unix.tm -> t

(* Convert a date to a float such than [to_unixfloat (make 1970 1 1)] returns 
   [0.0]. So such a float is convertible with those of the [Unix] module. 
   The fractional part of the result is always [0]. *)
val to_unixfloat : t -> float

(* Inverse of [to_unixfloat]. Ignore the fractional part of the argument. *)
val from_unixfloat : float -> t

(* Convert a day to an integer respecting ISO-8601.
   So, Monday is 1, Tuesday is 2, ..., and sunday is 7. *)
val int_of_day : day -> int
    
(* Inverse of [int_of_day]. 
   Raise [Invalid_argument] if the argument $\notin [1; 7]$. *)
val day_of_int : int -> day

(* Convert a month to an integer respecting ISO-8601.
   So, January is 1, February is 2 and so on. *)
val int_of_month : month -> int

(* Inverse of [int_of_month]. 
   Raise [Invalid_argument] if the argument $\notin [1; 12]$. *)
val month_of_int : int -> month

(*S Pretty pritting and string coercions.

  The four following references are used by the pretty printers.\bigskip

  String representation of a day. By default, English names are used
  (so [!day_name Sun] is ["Sunday"], etc). *)
val day_name : (day -> string) ref

(* Short string representation of a day. By default, English names are used
   (so [!day_name Sun] is ["Sun"], etc). *)
val short_day_name : (day -> string) ref

(* String representation of a month. By default, English names are used
   (so [!day_name Jan] is ["January"], etc). *)
val month_name : (month -> string) ref

(* Short string representation of a month. By default, English names are used
   (so [!day_name Jan] is ["Jan"], etc). *)
val short_month_name : (month -> string) ref

(* [fprint format formatter date] outputs [date] on [formatter] according to
   the specified [format]. Only the date with a positive year are correctly 
   pretty printed. Raise [Invalid_argument] if the format is incorrect.

   A format is based on the Unix date format. It is
   a string which contains two types of objects: plain characters and 
   conversion specifications. Those specifications are introduced by a [%]
   character and their meanings are:

   \begin{tabular}{l@{\hspace{5mm}}l}
   [%%] & a literal [%]\\
   [%a] & short day name (by using [short_day_name])\\
   [%A] & day name (by using [day_name])\\
   [%b] & short month name (by using [short_month_name])\\
   [%B] & month name (by using [month_name])\\
   [%d] & day of month (01..31)\\
   [%D] & shortcut for [%m/%d/%y]\\
   [%e] & day of month, blank padded ( 1..31)\\
   [%h] & same as [%b]\\
   [%j] & day of year (001..366)\\
   [%m] & month (01..12)\\
   [%n] & a newline (same as [\n])\\
   [%t] & a horizontal tab (same as [\t])\\
   [%V] & week number of year (01..53)\\
   [%w] & day of week (0..6);  0 represents Sunday\\
   [%W] & same as [%V]\\
   [%y] & last two digits of year (00..99)\\
   [%Y] & year (1970...)
   \end{tabular}

   By default, date pads numeric fields with zeroes. 
   Two special modifiers between [`%'] and a numeric directive are recognized:

   \begin{tabular}{l@{\hspace{5mm}}l}
   ['-' (hyphen)] & do not pad the field\\
   ['_' (underscore)] & pad the field with spaces
   \end{tabular}

   Some examples follows ([d = make 2003 1 6] and 
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

(*S Period. 

  A period is the number of days between two date. *)

module Period : sig
  include Period.S (*r Arithmetic operations. *)

  (* Constructors.\\ *)

  (* [make year month day] makes a period of the specified lenght. *)
  val make : int -> int -> int -> t

  (* Labelled version of [make]. The default value of each argument is [0]. *)
  val lmake : ?year:int -> ?month:int -> ?day:int -> unit -> t

  (* [year n] makes a period of [n] years. *)
  val year : int -> t

  (* [month n] makes a period of [n] months. *)
  val month : int -> t

  (* [week n] makes a period of [n] weeks. *)
  val week : int -> t

  (* [day n] makes a period of [n] days. *)
  val day : int -> t

  (* Getters.\\ *)
    
  exception Not_computable

  (* Number of days of a period. Throw [Not_computable] if the number of days
     is not computable. 
     E.g. [nb_days (day 6)] returns [6] but [nb_days (year 1)] throws
     [Not_computable] because a year is not a constant number of days. *)
  val nb_days : t -> int
end

(*S Arithmetic operations on dates and periods. *)

(* [add d p] returns [d + p].
   E.g. [add (make 2003 12 31) (Period.month 1)] returns the date 
   2004-1-31 and [add (make 2003 12 31) (Period.month 2)] returns the date 
   2004-3-2 (following the coercion rule describes in the introduction). *)
val add : t -> Period.t -> t

(* [sub d1 d2] returns the period between [d1] and [d2]. *)
val sub : t -> t -> Period.t

(* [rem d p] is equivalent to [add d (Period.opp p)]. *)
val rem : t -> Period.t -> t

(* [next d f] returns the date corresponding to the next specified field.\\
   E.g [next (make 2003 12 31) `Month] returns the date 2004-1-31
   (i.e. one month later). *)
val next : t -> field -> t

(* [prev d f] returns the date corresponding to the previous specified 
   field.\\
   E.g [prev (make 2003 12 31) `Year] returns the date 2002-12-31
   (i.e. one year ago). *)
val prev : t -> field -> t

(*S Operations on years. *)

(* Return [true] if a year is a leap year; [false] otherwise. *)
val is_leap_year : int -> bool

(* Return [true] if two years have the same calendar; [false] otherwise. *)
val same_calendar : int -> int -> bool

(* Number of days in a year. *)
val days_in_year : int -> int

(* Number of weeks in a year. *)
val weeks_in_year : int -> int

(* Century of a year. 
   E.g. [century 2000] returns 20 and [century 2001] returns 21. *)
val century : int -> int

(* Millenium of a year.
   E.g. [millenium 2000] returns 2 and [millenium 2001] returns 3. *)
val millenium : int -> int

(* Solar number. 

   In the Julian calendar there is a one-to-one relationship between the
   Solar number and the day on which a particular date falls. *)
val solar_number : int -> int

(* Indiction. 
   
   The Indiction was used in the middle ages to specify the position of a 
   year in a 15 year taxation cycle. It was introduced by emperor Constantine 
   the Great on 1 September 312 and ceased to be used in 1806. 

   The Indiction has no astronomical significance. *)
val indiction : int -> int

(* Golden number. 

   Considering that the relationship between the moon's phases and the days 
   of the year repeats itself every 19 years, it is natural to associate a 
   number between 1 and 19 with each year. 
   This number is the so-called Golden number. *)
val golden_number : int -> int

(* Epact. 

   The Epact is a measure of the age of the moon (i.e. the number of days 
   that have passed since an "official" new moon) on a particular date. *)
val epact : int -> int

(* Date of Easter. 

   In the Christian world, Easter (and the days immediately preceding it) is 
   the celebration of the death and resurrection of Jesus in (approximately) 
   AD 30. *)
val easter : int -> t
