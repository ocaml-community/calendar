(*
 * Date
 * Copyright (C) 2003 Julien SIGNOLES
 * 
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License version 2, as published by the Free Software Foundation.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * See the GNU Library General Public License version 2 for more details
 *)

(*i $Id: date.mli,v 1.1.1.1 2003-06-26 16:09:30 signoles Exp $ i*)

(*S Introduction. 

  This module implements operations on dates. 
  A date is a triple (year, month, day). 

  The function [today] uses the module [Unix] and 
  the function [from_string] uses the module [Str].
  So, link this library with [Unix] and [Str]. *)

(*S Datatypes. *)

(* Days of the week. *)
type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

(* Month of the year. *)
type month = 
    Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

(* Type of a date. *)
type t

(*S Constructors. *)

(* Date of the current day (based on UTC / GMT). *)
val today : unit -> t

(* [make year month day] makes the date year-month-day.
   Raise [Invalid_argument] if the triple (year, month, day) is 
   unacceptable. 
   A BC year [y] corresponds to the year [-(y+1)].
   E.g. the years (5 BC) and (1 BC) respectively corresponds to the years 
   (-4) and 0. *)
val make : int -> int -> int -> t

(* Make a date from its Julian day. *)
val from_jd : int -> t

(* Make a date from its modified Julian day. *)
val from_mjd : float -> t

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

(* Modified Julian day. *)
val to_mjd : t -> float

(*S Boolean operations on dates. *)

(* Return [true] iff a date is a leap day. *)
val is_leap_day : t -> bool

(* Return [true] iff a date belongs to the Gregorian calendar. *)
val in_gregorian_calendar : t -> bool

(* Return [true] iff a date belongs to the Julian calendar. *)
val in_julian_calendar : t -> bool

(* Comparison function between two dates. 
   Same behavior as [Pervasives.compare]. *)
val compare : t -> t -> int

(*S Arithmetic operations on dates. *)

(* [add d n] adds [n] days to [d]. *)
val add : t -> int -> t

(* Same as [add d (-n)]. *)
val remove : t -> int -> t

(* Same as [add d 1]. *)
val next : t -> t

(* Same as [remove d 1]. *)
val previous : t -> t

(*S Coercions. *)

(* Convert a date into a string with the format "y-m-d". *)
val to_string : t -> string

(* Inverse of [to_string]. *)
val from_string : string -> t

(* Convert a day to an integer respecting ISO-8601.
   So, Monday is 1, Tuesday is 2, ..., and sunday is 7 *)
val int_of_day : day -> int

(* Inverse of [int_of_day]. *)
val day_of_int : int -> day

(* Convert a month to an integer respecting ISO-8601.
   So, January is 1, February is 2 and so on. *)
val int_of_month : month -> int

(* Inverse of [int_of_month]. *)
val month_of_int : int -> month

(*S Operations on years. *)

(* Return [true] iff a year is a leap year. *)
val is_leap_year : int -> bool

(* Return [true] iff two years have the same calendar. *)
val same_calendar : int -> int -> bool

(* Number of days in a year. *)
val days_in_year : int -> int

(* Number of weeks in a year. *)
val weeks_in_year : int -> int

(* Century of a year. *)
val century : int -> int

(* Millenium of a year. *)
val millenium : int -> int

(* Solar number. *)
val solar_number : int -> int

(* Indiction. *)
val indiction : int -> int

(* Golden number. *)
val golden_number : int -> int

(* Epact. *)
val epact : int -> int

(* Date of Eastern. *)
val eastern : int -> t
