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

(*i $Id: calendar.mli,v 1.14 2003-09-18 10:29:27 signoles Exp $ i*)

(*S Introduction. 

  This module combines the implementations on [Date] and [Time].
  So, a calendar is a 6-uple (year, month, day, hour, minute, second).

  If you only need operations on dates, you should better use the module 
  [Date]. But if you need to manage more precise date, use this module. 

  The exact Julian period is now\\ 
  [[January, 1st 4713 BC at midday GMT; January 22th, 3268 AC at midday GMT]].

  This module uses floating point arithmetics. 
  Then, egality over calendars may be erroneous (as egality over [float]).
  You should better use the [equal] function defined in this module instead 
  of [(=)]. *)

(*S Datatypes. *)

(* Type of a date refined with a time, so called a \emph{calendar}. *)
type t

(* Days of the week. *)
type day = Date.day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

(* Months of the year. *)
type month = Date.month =
    Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

(* The different fields of a calendar. *)
type field = [ Date.field | Time.field ]

(*S Constructors. *)

(* [make year month day hour minute second] makes the calendar
   "year-month-day; hour-minute-second". *)
val make : int -> int -> int -> int -> int -> int -> t

(* Labelled version of [make]. 
   The default value of [month] and [day] (resp. of [hour], [minute] 
   and [second]) is [1] (resp. [0]). *)
val lmake : 
  year:int -> ?month:int -> ?day:int -> 
  ?hour:int -> ?minute:int -> ?second:int -> unit -> t

(* [create d t] creates a calendar from the given date and time. *)
val create : Date.t -> Time.t -> t

(* [now ()] returns the current date and time (in the current time zone). *)
val now : unit -> t

(* Return the Julian day. 
   More precise than [Date.from_jd]: the fractional part represents the 
   time. *)
val from_jd : float -> t

(* Return the Modified Julian day.
   It is [Julian day - 2 400 000.5] (more precise than [Date.from_mjd]). *)
val from_mjd : float -> t

(*S Conversions. *)

(*  Those functions have the same behaviour as those defined in [Time]. *)

val convert : t -> Time_Zone.t -> Time_Zone.t -> t
val to_gmt : t -> t
val from_gmt : t -> t

(*S Getters. *)

(* Those functions have the same behavious as those defined in [Date]. *)
  
val days_in_month : t -> int
val day_of_week : t -> day
val day_of_month : t -> int
val day_of_year : t -> int
val week : t -> int
val month : t -> month
val year : t -> int

(* [to_jd] and [to_mjd] are more precise than [Date.to_jd] and 
   [Date.to_mjd]. *)
val to_jd : t -> float
val to_mjd : t -> float

(* Those functions have the same behavious as those defined in [Time]. *)

val hour : t -> int
val minute : t -> int
val second : t -> int

(*S Boolean operations on calendars. *)

(* [equal] should be used instead of [(=)]. *)
val equal : t -> t -> bool

(* Those functions have the same behavious as those defined in [Date]. *)

val compare : t -> t -> int
val is_leap_day : t -> bool
val is_gregorian : t -> bool
val is_julian : t -> bool

(* Those functions have the same behavious as those defined in [Time]. *)

val is_pm : t -> bool
val is_am : t -> bool

(*S Coercions. *)
(*
(* Convert a calendar to a string with the format "y-m-d; h-mn-s". *)
val to_string : t -> string

(* Inverse of [to_string].
   Raise [Invalid_argument] if the string format is bad. *)
val from_string : string -> t
*)
(* Convert a calendar into the [unix.tm] type.
   The field [isdst] is always [false]. 
   More precise than [Date.to_unixtm]. *)
val to_unixtm : t -> Unix.tm

(* Inverse of [to_unixtm]. *)
val from_unixtm : Unix.tm -> t

(* Convert a calendar to a float such than [to_unixfloat (make 1970 1 1 0 0 0)]
   returns [0.0] at UTC. So such a float is convertible with those of the 
   [Unix] module. More precise than [Date.to_unixfloat]. *)
val to_unixfloat : t -> float

(* Inverse of [from_unixfloat]. *)
val from_unixfloat : float -> t

(* Convert a date to a calendar. 
   The time is midnight in the current time zone. *)
val from_date : Date.t -> t

(* Convert a calendar to a date. Time part of the calendar is ignored. *)
val to_date : t -> Date.t

(* Convert a calendar to a time. Date part of the calendar is ignored. *)
val to_time : t -> Time.t

(*S Period.

  A period is the number of seconds between two calendars. *)

module Period : sig
  include Period.S (*r Arithmetic operations. *)

  (* Constructors.\\ *)

  (* [make year month day hour minute second] makes a period of the specified
     length. *)
  val make : int -> int -> int -> int -> int -> int -> t

  (* Labelled version of [make]. The default value of each argument is [0]. *)
  val lmake : 
    ?year:int -> ?month:int -> ?day:int -> 
      ?hour:int -> ?minute:int -> ?second:int -> unit -> t

  (* Those functions have the same behavious as those defined in [Date]. *)

  val year : int -> t
  val month : int -> t
  val week : int -> t
  val day : int -> t

  (* Those functions have the same behavious as those defined in [Time]. *)

  val hour : int -> t
  val minute : int -> t
  val second : int -> t

  (* Coercions.\\ *)

  (* Convert a calendar period to a date period. 
     The fractional time period is ignored. 
     E.g. [to_date (hour 60)] is equivalent to [Date.Period.days 2]. *)
  val to_date : t -> Date.Period.t

  (* Convert a date period to a calendar period. *)
  val from_date : Date.Period.t -> t

  (* Convert a time period to a calendar period. *)
  val from_time : Time.Period.t -> t

  exception Not_computable (*r [= Date.Period.Not_computable] *)

  (* Convert a calendar period to a date period. Throw [Not_computable] if the
     time period is not computable.
     E.g. [to_time (day 6)] and [to_time (second 30)] respectively return a
     time period of [24 * 3600 * 6 = 518400] seconds and a time period of [30]
     seconds but [to_time (year 1)] throws [Not_computable] because a year is
     not a constant number of days. *)
  val to_time : t -> Time.Period.t
end

(*S Arithmetic operations on calendars and periods. *)

(* Those functions have the same behavious as those defined in [Date]. *)

val add : t -> Period.t -> t
val sub : t -> t -> Period.t
val rem : t -> Period.t -> t
val next : t -> field -> t
val prev : t -> field -> t
