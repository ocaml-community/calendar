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

(** Date interface. A date may be seen as a triple (year, month, day).

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

(** Common operations for all date representations.
    @since 2.0 (this signature was before inlined in interface of Date). *)
module type S = sig

  (** {2 Datatypes} *)

  (** The different fields of a date.
      @since 2.02 *)
  type field = Period.date_field

  (** Type of a date, without specifying any precision level.
      @since 2.02 *)
  type -'a date constraint 'a = [< field ]

  (** Type of a date. *)
  type t = field date

  (** Days of the week. *)
  type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

  (** Months of the year. *)
  type month =
      Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

  (** Year as an [int]. *)
  type year = int

  (** {2 Exceptions} *)

  exception Out_of_bounds
    (** Raised when a date is outside the Julian period. *)

  exception Undefined
    (** Raised when a date belongs to
	[[October 5th, 1582; October 14th, 1582]]. *)

  (** {2 Constructors} *)

  val make : year -> int -> int -> t
    (** [make year month day] makes the date year-month-day. A BC year [y]
	corresponds to the year [-(y+1)].
	@example years (5 BC) and (1 BC) respectively correspond to years
	(-4) and 0.
	@raise Out_of_bounds when a date is outside the Julian period.
	@raise Undefined when a date belongs to [[October 5th, 1582; October
	14th, 1582]]. *)

  val lmake : year:year -> ?month:int -> ?day:int -> unit -> t
    (** Labelled version of [make].
	The default value of [month] and [day] is [1].
	@raise Out_of_bounds when a date is outside the Julian period.
	@raise Undefined when a date belongs to [[October 5th, 1582; October
	14th, 1582]].
	@since 1.05 *)

  val make_year: int -> [< `Year ] date
    (** [make_year y] makes a date only represented by its year [y]. The month
	and the day of such a date are not relevant.
	@since 2.02 *)

  val make_year_month: int -> int -> [< `Year | `Month ] date
    (** [make_year_month y m] makes a date only represented by its year [y] and
	its month [m]. The day of such a date is not relevant.
	@since 2.02 *)

  val today : unit -> t
    (** Date of the current day (based on [Time_Zone.current ()]). *)

  val from_jd : int -> t
    (** Make a date from its Julian day.
	@example [from_jd 0] returns the date 4713 BC-1-1. *)

  val from_mjd : int -> t
    (** Make a date from its modified Julian day (i.e. Julian day - 2 400 001).
	The Modified Julian day is more manageable than the Julian day.
	@example [from_mjd 0] returns the date 1858-11-17. *)

  val from_day_of_year: year -> int -> t
    (** Make a date from a year and its day of the year.
	@example [from_day_of_year 2008 39] returns the date 2008-2-8.
	@since 2.0 *)

  (** {2 Getters} *)

  val days_in_month : [> `Year | `Month ] date -> int
    (** Number of days in the month of a date.
	@example [days_in_month (make 2003 6 26)] returns [30]. *)

  val day_of_week : t -> day
  (** Day of the week.
      @example [day_of_week (make 2003 6 26)] returns [Thu]. *)

  val day_of_month : t -> int
    (** Day of the month.
	@example [day_of_month (make 2003 6 26)] returns [26]. *)

  val day_of_year : t -> int
    (** Day of the year.
	@example [day_of_year (make 2003 1 5)] returns [5]
	@example [day_of_year (make 2003 12 28)] returns [362]. *)

  val week : t -> int
    (** Week.
	@example [week (make 2000 1 3)] returns [1].
	@example [week (make 2000 1 2)] returns [52].
	@example [week (make 2003 12 28)] returns [52].
	@example [week (make 2003 12 29)] returns [1]. *)

  val month : [> `Month ] date -> month
    (** Month.
	@example [month (make 2003 6 26)] returns [Jun]. *)

  val year : [> `Year ] date -> year
    (** Year.
	@example [year (make 2003 6 26)] returns [2003]. *)

  val to_jd : t -> int
    (** Julian day.
	@example [to_jd (make (-4712) 1 1)] returns 0. *)

  val to_mjd : t -> int
    (** Modified Julian day (i.e. Julian day - 2 400 001).
	The Modified Julian day is more manageable than the Julian day.
	@example [to_mjd (make 1858 11 17)] returns 0. *)

  (** {2 Dates are comparable} *)

  val equal: 'a date -> 'b date -> bool
    (** Equality function between two dates.
	@see <Utils.Comparable.html#VALequal> Utils.Comparable.equal
	@since 1.09.0 *)

  val compare : 'a date -> 'b date -> int
    (** Comparison function between two dates.
 	@see <Utils.Comparable.html#VALcompare> Utils.Comparable.compare *)

  val hash: 'a date -> int
    (** Hash function for dates.
	@see <Utils.Comparable.html#VALhash> Utils.Comparable.hash
	@since 2.0 *)

  (** {2 Boolean operations on dates} *)

  val is_valid_date: year -> int -> int -> bool
    (** Check if a date is valid, that is the date has not been coerced to look
	like a real date.
	@example [is_valid_date 2008 2 8] returns [true]
	@example [is_valid_date 2008 2 30] returns [false]
	@since 2.0 *)

  val is_leap_day : t -> bool
    (** Return [true] if a date is a leap day
	(i.e. February, 24th of a leap year); [false] otherwise. *)

  val is_gregorian : t -> bool
    (** Return [true] if a date belongs to the Gregorian calendar;
	[false] otherwise. *)

  val is_julian : t -> bool
    (** Return [true] iff a date belongs to the Julian calendar;
	[false] otherwise. *)

  (** {2 Coercions} *)

  val to_unixtm : t -> Unix.tm
    (** Convert a date into the [Unix.tm] type.
	The field [is_isdst] is always [false]. The fields [Unix.tm_sec],
	[Unix.tm_min] and [Unix.tm_hour] are irrelevant.
	@since 1.01 *)

  val from_unixtm : Unix.tm -> t
    (** Inverse of [to_unixtm]. Assume the current time zone.
	@since 1.01 *)

  val to_unixfloat : t -> float
    (** Convert a date to a float such than [to_unixfloat (make 1970 1 1)]
	returns [0.0]. So such a float is convertible with those of the [Unix]
	module. The fractional part of the result is always [0].
	@since 1.01 *)

  val from_unixfloat : float -> t
    (** Inverse of [to_unixfloat]. Ignore the fractional part of the argument.
	Assume the current time zone.
	@since 1.01 *)

  val to_business: t -> year * int * day
    (** Return the "business week" and the day in this week respecting ISO 8601.
	Notice that business weeks at the beginning and end of the year can
	sometimes have year numbers which don't match the real year.
	@example [to_business (make 2000 1 3)] returns [2000, 1, Mon]
	@example [to_business (make 2000 1 2)] returns [1999, 52, Sun]
	@example [to_business (make 2003 12 28)] returns [2003, 52, Sun]
	@example [to_business (make 2003 12 29)] returns [2004, 1, Mon].
	@since 1.09.0 *)

  val from_business: year -> int -> day -> t
    (** Inverse of [to_business] respecting ISO-8601.
	Notice that business weeks at the beginning and end of the year
	can sometimes have year numbers which don't match the real year.
	@raise Invalid_argument if the date is bad.
	@since 1.09.0 *)

  val int_of_day : day -> int
    (** Convert a day to an integer respecting ISO-8601.
	So, Monday is 1, Tuesday is 2, ..., and sunday is 7. *)

  val day_of_int : int -> day
    (** Inverse of [int_of_day].
	@raise Invalid_argument if the argument does not belong to [1; 7]. *)

  val int_of_month : month -> int
    (** Convert a month to an integer respecting ISO-8601.
	So, January is 1, February is 2 and so on. *)

  val month_of_int : int -> month
    (** Inverse of [int_of_month].
	@raise Invalid_argument if the argument does not belong to [1; 12]. *)

  (** {2 Period} *)

  (** A period is the number of days between two dates. *)
  module Period : sig

    (** {3 Arithmetic operations} *)

    type +'a p constraint 'a = [< field ]
    include Period.S with type +'a period = 'a p

    (** {3 Constructors} *)

    val make: int -> int -> int -> t
      (** [make year month day] makes a period of the specified length. *)

    val lmake: ?year:int -> ?month:int -> ?day:int -> unit -> t
      (** Labelled version of [make].
	  The default value of each argument is [0]. *)

    val year: int -> [> `Year ] period
      (** [year n] makes a period of [n] years. *)

    val month: int -> [> `Year | `Month ] period
      (** [month n] makes a period of [n] months. *)

    val week: int -> [> `Week | `Day ] period
      (** [week n] makes a period of [n] weeks. *)

    val day: int -> [> `Week | `Day ] period
      (** [day n] makes a period of [n] days. *)

    (** {3 Getters} *)

    exception Not_computable
      (** @since 1.04 *)

    val nb_days: 'a period -> int
      (** Number of days in a period.
	  @raise Not_computable if the number of days is not computable.
	  @example [nb_days (day 6)] returns [6]
	  @example [nb_days (year 1)] raises [Not_computable] because a year is
	  not a constant number of days.
	  @since 1.04
	  @deprecated since 2.02: use {!safe_nb_days} instead *)

    val safe_nb_days: [< `Week | `Day ] period -> int
      (** Equivalent to {!nb_days} but never raises any exception.
	  @since 2.02 *)

    val ymd: 'a period -> int * int * int
      (** Number of years, months and days in a period.
	  @example [ymd (make 1 2 3)] returns [1, 2, 3].
	  @since 1.09.0 *)

  end

  (** {2 Arithmetic operations on dates and periods} *)

  val add : 'a date -> 'a Period.period -> 'a date
    (** [add d p] returns [d + p].
	@raise Out_of_bounds when the resulting date is outside the Julian
	period.
	@raise Undefined when the resulting date belongs to [[October 5th,
	1582; October 14th, 1582]].
	@example [add (make 2003 12 31) (Period.month 1)] returns the date
	2004-1-31
	@example [add (make 2003 12 31) (Period.month 2)] returns the date
	2004-3-2 (following the coercion rule describes in the introduction). *)

  val sub : 'a date -> 'a date -> [> `Week | `Day ] Period.period
    (** [sub d1 d2] returns the period between [d1] and [d2]. *)

  val precise_sub : 'a date -> 'a date -> Period.t
    (** [precise_sub d1 d2] returns the period between [d1] and [d2].
	It is equivalent to [sub], but:
	- the period is expressed with a number of years, months and days, not
	only with a number of days;
	- it is less efficient.
	@since 2.03 *)

  val rem : 'a date -> 'a Period.period -> 'a date
    (** [rem d p] is equivalent to [add d (Period.opp p)].
	@raise Out_of_bounds when the resulting date is outside the Julian
	period.
	@raise Undefined when the resulting date belongs to [[October 5th,
	1582; October 14th, 1582]]. *)

  val next : 'a date -> ([< field ] as 'a) -> 'a date
    (** [next d f] returns the date corresponding to the next specified field.
	@raise Out_of_bounds when the resulting date is outside the Julian
	period.
	@raise Undefined when the resulting date belongs to [[October 5th,
	1582; October 14th, 1582]].
	@example [next (make 2003 12 31) `Month] returns the date 2004-1-31
	(i.e. one month later). *)

  val prev : 'a date -> ([< field ] as 'a) -> 'a date
    (** [prev d f] returns the date corresponding to the previous specified
	field.
	@raise Out_of_bounds when the resulting date is outside the Julian
	period.
	@raise Undefined when the resulting date belongs to [[October 5th,
	1582; October 14th, 1582]].
	@example [prev (make 2003 12 31) `Year] returns the date 2002-12-31
	(i.e. one year ago). *)

  (** {2 Operations on years} *)

  val is_leap_year : year -> bool
    (** Return [true] if a year is a leap year; [false] otherwise. *)

  val same_calendar : year -> year -> bool
    (** Return [true] if two years have the same calendar; [false]
	otherwise. *)

  val days_in_year : ?month:month -> year -> int
    (** Number of days in a year.

	[days_in_year ~month y] returns the number of days in the year [y] up
	to the end of the given month. Thus [days_in_year ~month:Dec y] is the
	same as [days_in_year y]. *)

  val weeks_in_year: year -> int
    (** Number of weeks in a year. *)

  val week_first_last: int -> year -> t * t
    (** Return the first and last days of a week in a year.
	@since 1.08 *)

  val nth_weekday_of_month: year -> month -> day -> int -> t
    (** [nth_weekday_of_month y m d n] returns the [n]-th day [d] in the month
	[m] of the year [y] (for instance the 3rd Thursday of the month).
	@since 1.09.0 *)

  val century : year -> int
    (** Century of a year.
	@example [century 2000] returns 20
	@example [century 2001] returns 21. *)

  val millenium : year -> int
    (** Millenium of a year.
	@example [millenium 2000] returns 2
	@example [millenium 2001] returns 3. *)

  val solar_number : year -> int
    (** Solar number.

	In the Julian calendar there is a one-to-one relationship between the
	Solar number and the day on which a particular date falls. *)

  val indiction : year -> int
    (** Indiction.

	The Indiction was used in the middle ages to specify the position of a
	year in a 15 year taxation cycle. It was introduced by emperor
	Constantine  the Great on 1 September 312 and ceased to be used in
	1806.

	The Indiction has no astronomical significance. *)

  val golden_number : year -> int
    (** Golden number.

	Considering that the relationship between the moon's phases and the
	days  of the year repeats itself every 19 years, it is natural to
	associate a  number between 1 and 19 with each year.
	This number is the so-called Golden number. *)

  val epact : year -> int
    (** Epact.

	The Epact is a measure of the age of the moon (i.e. the number of days
	that have passed since an "official" new moon) on a particular date. *)

  val easter : year -> t
    (** Easter Sunday.

	In the Christian world, Easter (and the days immediately preceding it)
	is  the celebration of the death and resurrection of Jesus in
	(approximately) AD 30. *)

  val carnaval: year -> t
    (** Carnaval Monday. [carnaval y] is [easter y - 48].
	@since 1.09.0 *)

  val mardi_gras: year -> t
    (** Mardi Gras. [mardi_gras y] is [easter y - 47].
	@since 1.09.0 *)

  val ash: year -> t
    (** Ash Wednesday. [ash y] is [easter y - 46].
	@since 1.09.0 *)

  val palm: year -> t
    (** Palm Sunday. [palm y] is [easter y - 7].
	@since 1.09.0 *)

  val easter_friday: year -> t
    (** Easter Friday. [easter_friday y] is [easter y - 2].
	@since 1.09.0 *)

  val easter_saturday: year -> t
    (** Easter Saturday. [easter_saturday y] is [easter y - 1].
	@since 1.09.0 *)

  val easter_monday: year -> t
    (** Easter Monday. [easter_monday y] is [easter y + 1].
	@since 1.09.0 *)

  val ascension: year -> t
    (** Ascension. [ascension y] is [easter y + 39].
	@since 1.09.0 *)

  val withsunday: year -> t
    (** Withsunday. [withsunday y] is [easter y + 49].
	@since 1.09.0 *)

  val withmonday: year -> t
    (** Withmonday. [withmonday y] is [easter y + 50].
	@since 1.09.0 *)

  val corpus_christi: year -> t
    (** Feast of Corpus Christi. [corpus_christi y] is [easter + 60].
	@since 1.09.0 *)

end
