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

(*i $Id: calendar.mli,v 1.5 2003-07-08 08:12:18 signoles Exp $ i*)

(*S Introduction. 

  This module combines the implementations on [Date] and [Time].
  So, a calendar is a 6-uple (year, month, day, hour, minut, second).

  If you only need operations on dates, you should better use the module 
  [Date]. But if you need to manage more precise date, use this module. 

  The exact Julian period is now\\ 
  [[January, 1st 4713 BC at midday GMT; January 22th, 3268 AC at midday GMT]].

  This module uses floating point arithmetics. 
  Then, egality over calendars may be erroneous (as egality over [float]).
  [egal] function defined in this module is however more precise than [(=)]. *)

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

(* [make year month day hour minut second] makes the calendar
   "year-month-day; hour-minut-second". *)
val make : int -> int -> int -> int -> int -> int -> t

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
val minut : t -> int
val second : t -> int

(*S Boolean operations on calendars. *)

(* [egal] should be used instead of [(=)]. *)
val egal : t -> t -> bool

(* Those functions have the same behavious as those defined in [Date]. *)

val compare : t -> t -> int
val is_leap_day : t -> bool
val is_gregorian : t -> bool
val is_julian : t -> bool

(* Those functions have the same behavious as those defined in [Time]. *)

val is_pm : t -> bool
val is_am : t -> bool

(*S Coercions. *)

(* Convert a calendar to a string with the format "y-m-d; h-mn-s". *)
val to_string : t -> string

(* Inverse of [to_string].
   Raise [Invalid_argument] if the string format is bad. *)
val from_string : string -> t

(* Convert a date to a calendar. 
   The time is midnight in the current time zone. *)
val from_date : Date.t -> t

(* Convert a calendar to a date. Time part of the calendar is ignored. *)
val to_date : t -> Date.t

(*S Period.

  A period is the number of seconds between two calendars. *)

module Period : sig
  include Period.S

  (* Constructors *)

  (* [make year month day hour minut second] makes a period of the specified
     length. *)
  val make : int -> int -> int -> int -> int -> int -> t

  (* Those functions have the same behavious as those defined in [Date]. *)

  val year : int -> t
  val month : int -> t
  val week : int -> t
  val day : int -> t

  (* Those functions have the same behavious as those defined in [Time]. *)

  val hour : int -> t
  val minut : int -> t
  val second : int -> t

  (* Coercions *)

  (* Convert a calendar period to a date period. 
     The time period is rounded to the nearest day
     (e.g. if the time period is 15 hours, it is rounded to 1 day). *)
  val to_date : t -> Date.Period.t

  (* Convert a date period to a calendar period. *)
  val from_date : Date.Period.t -> t

  (* Convert a time period to a calendar period. 
     Note there is no [to_time] function because it is not possible to compute
     such a time period from a date period. *)
  val from_time : Time.Period.t -> t
end

(*S Arithmetic operations on calendars and periods. *)

(* Those functions have the same behavious as those defined in [Date]. *)

val add : t -> Period.t -> t
val sub : t -> t -> Period.t
val rem : t -> Period.t -> t
val next : t -> field -> t
val prev : t -> field -> t
