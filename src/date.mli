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

(*i $Id: date.mli,v 1.16 2004-05-18 15:20:00 signoles Exp $ i*)

(** Date operations.

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
  This rule is called the coercion rule.
  As an exception to the coercion rule, the date belonging to 
  [[October 5th, 1582; October 14th, 1582]] do not exist and an [Undefined] 
  exception is raised if you attempt to create such a date.
  Those dropped days correspond to the change from the Julian to the Gregorian
  calendar. *)

(** {1 Datatypes} *)

(** Type of a date. *)
type t

(** Days of the week. *)
type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

(** Months of the year. *)
type month = 
    Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

(** Year as an [int]. *)
type year = int

(** The different fields of a date. *)
type field = [ `Year | `Month | `Week | `Day ]

(** {1 Exceptions} *)

exception Out_of_bounds
  (** Raised when a date is outside the Julian period. *)

exception Undefined
  (** Raised when a date belongs to [[October 5th, 1582; October 14th, 1582]].
   *)

(** {1 Constructors} *)

val make : year -> int -> int -> t
  (** [make year month day] makes the date year-month-day.
    A BC year [y] corresponds to the year [-(y+1)].
    E.g. the years (5 BC) and (1 BC) respectively correspond to the years 
    (-4) and 0. *)

val lmake : year:year -> ?month:int -> ?day:int -> unit -> t
  (** Labelled version of [make]. 
    The default value of [month] and [day] is [1]. *)

val today : unit -> t
  (** Date of the current day (based on [Time_Zone.current ()]). *)

val from_jd : int -> t
  (** Make a date from its Julian day. 
    E.g. [from_jd 0] returns the date 4713 BC-1-1. *)

val from_mjd : int -> t
  (** Make a date from its modified Julian day (i.e. Julian day - 2 400 001).
    The Modified Julian day is more manageable than the Julian day.
    E.g. [from_mjd 0] returns the date 1858-11-17. *)
    
(** {1 Getters} *)
  
val days_in_month : t -> int
  (** Number of days in the month of a date.
    E.g [days_in_month (make 2003 6 26)] returns [30]. *)

val day_of_week : t -> day
  (** Day of the week. 
    E.g. [day_of_week (make 2003 6 26)] returns [Thu]. *)

val day_of_month : t -> int
  (** Day of the month. 
    E.g. [day_of_month (make 2003 6 26)] returns [26]. *)

val day_of_year : t -> int
  (** Day of the year.
    E.g. [day_of_year (make 2003 1 5)] returns [5]
    and [day_of_year (make 2003 12 28)] returns [362]. *)

val week : t -> int
  (** Week. 
    E.g. [week (make 2003 1 5)] returns [1]
    and [week (make 2003 12 28)] returns [52]. *)

val month : t -> month
  (** Month. E.g. [month (make 2003 6 26)] returns [Jun]. *)

val year : t -> year
  (** Year. E.g. [year (make 2003 6 26)] returns [2003]. *)

val to_jd : t -> int
  (** Julian day. E.g. [to_jd (make (-4712) 1 1)] returns 0. *)
  
val to_mjd : t -> int
  (** Modified Julian day (i.e. Julian day - 2 400 001).
    The Modified Julian day is more manageable than the Julian day. 
    E.g. [to_mjd (make 1858 11 17)] returns 0. *)

(** {1 Boolean operations on dates} *)

val compare : t -> t -> int
  (** Comparison function between two dates. 
    Same behavior as [Pervasives.compare]. *)

val is_leap_day : t -> bool
  (** Return [true] if a date is a leap day
    (i.e. February, 24th of a leap year); [false] otherwise. *)

val is_gregorian : t -> bool
  (** Return [true] if a date belongs to the Gregorian calendar;
    [false] otherwise. *)

val is_julian : t -> bool
  (** Return [true] iff a date belongs to the Julian calendar;
    [false] otherwise. *)

(** {1 Coercions} *)

val to_unixtm : t -> Unix.tm
  (** Convert a date into the [Unix.tm] type. 
    The field [is_isdst] is always [false]. The fields [Unix.tm_sec], 
    [Unix.tm_min] and [Unix.tm_hour] are irrelevant. *)

val from_unixtm : Unix.tm -> t
  (** Inverse of [to_unixtm]. *)

val to_unixfloat : t -> float
  (** Convert a date to a float such than [to_unixfloat (make 1970 1 1)] 
    returns [0.0]. So such a float is convertible with those of the [Unix] 
    module. The fractional part of the result is always [0]. *)

val from_unixfloat : float -> t
  (** Inverse of [to_unixfloat]. Ignore the fractional part of the argument. *)

val int_of_day : day -> int
  (** Convert a day to an integer respecting ISO-8601.
    So, Monday is 1, Tuesday is 2, ..., and sunday is 7. *)
    
val day_of_int : int -> day
  (** Inverse of [int_of_day]. 
    Raise [Invalid_argument] if the argument $\notin [1; 7]$. *)

val int_of_month : month -> int
  (** Convert a month to an integer respecting ISO-8601.
    So, January is 1, February is 2 and so on. *)

val month_of_int : int -> month
  (** Inverse of [int_of_month]. 
    Raise [Invalid_argument] if the argument $\notin [1; 12]$. *)

(** {1 Period} *)

module Period : sig
  (** A period is the number of days between two date. *)

  (** {2 Arithmetic operations} *)

  include Period.S

  (** {2 Constructors} *)

  val make : int -> int -> int -> t
    (** [make year month day] makes a period of the specified lenght. *)

  val lmake : ?year:int -> ?month:int -> ?day:int -> unit -> t
    (** Labelled version of [make]. 
      The default value of each argument is [0]. *)

  val year : int -> t
    (** [year n] makes a period of [n] years. *)

  val month : int -> t
    (** [month n] makes a period of [n] months. *)

  val week : int -> t
    (** [week n] makes a period of [n] weeks. *)

  val day : int -> t
    (** [day n] makes a period of [n] days. *)

  (** {2 Getters} *)
    
  exception Not_computable

  val nb_days : t -> int
    (** Number of days of a period. Throw [Not_computable] 
      if the number of days is not computable. 
      E.g. [nb_days (day 6)] returns [6] but [nb_days (year 1)] throws
      [Not_computable] because a year is not a constant number of days. *)

end

(** {1 Arithmetic operations on dates and periods} *)

val add : t -> Period.t -> t
  (** [add d p] returns [d + p].
    E.g. [add (make 2003 12 31) (Period.month 1)] returns the date 
    2004-1-31 and [add (make 2003 12 31) (Period.month 2)] returns the date 
    2004-3-2 (following the coercion rule describes in the introduction). *)

val sub : t -> t -> Period.t
  (** [sub d1 d2] returns the period between [d1] and [d2]. *)

val rem : t -> Period.t -> t
  (** [rem d p] is equivalent to [add d (Period.opp p)]. *)

val next : t -> field -> t
  (** [next d f] returns the date corresponding to the next specified field.\\
    E.g [next (make 2003 12 31) `Month] returns the date 2004-1-31
    (i.e. one month later). *)

val prev : t -> field -> t
  (** [prev d f] returns the date corresponding to the previous specified 
    field.
    E.g [prev (make 2003 12 31) `Year] returns the date 2002-12-31
    (i.e. one year ago). *)

(** {1 Operations on years} *)

val is_leap_year : year -> bool
  (** Return [true] if a year is a leap year; [false] otherwise. *)

val same_calendar : year -> year -> bool
  (** Return [true] if two years have the same calendar; [false] otherwise. *)

val days_in_year : year -> int
  (** Number of days in a year. *)

val weeks_in_year : year -> int
  (** Number of weeks in a year. *)

val week_first_last : int -> year -> t * t
  (** Return the first and last days of a week in a year *)

val century : year -> int
  (** Century of a year. 
    E.g. [century 2000] returns 20 and [century 2001] returns 21. *)

val millenium : year -> int
  (** Millenium of a year.
    E.g. [millenium 2000] returns 2 and [millenium 2001] returns 3. *)

val solar_number : year -> int
  (** Solar number. 

    In the Julian calendar there is a one-to-one relationship between the
    Solar number and the day on which a particular date falls. *)

val indiction : year -> int
  (** Indiction. 
   
    The Indiction was used in the middle ages to specify the position of a 
    year in a 15 year taxation cycle. It was introduced by emperor Constantine 
    the Great on 1 September 312 and ceased to be used in 1806. 

    The Indiction has no astronomical significance. *)

val golden_number : year -> int
  (** Golden number. 

    Considering that the relationship between the moon's phases and the days 
    of the year repeats itself every 19 years, it is natural to associate a 
    number between 1 and 19 with each year. 
    This number is the so-called Golden number. *)

val epact : year -> int
  (** Epact. 

    The Epact is a measure of the age of the moon (i.e. the number of days 
    that have passed since an "official" new moon) on a particular date. *)

val easter : year -> t
  (** Date of Easter. 

    In the Christian world, Easter (and the days immediately preceding it) is 
    the celebration of the death and resurrection of Jesus in (approximately) 
    AD 30. *)
