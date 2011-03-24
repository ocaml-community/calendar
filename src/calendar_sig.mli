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

(** Calendar interface. A calendar combines a date and a time: it may be seen
    as a 6-uple (year, month, day, hour, minute, second).

    If you only need operations on dates, you should better use a date
    implementation (like module [Date]). But if you need to manage more precise
    dates, use this module. The exact Julian period is now [[January, 1st 4713
    BC at midday GMT; January 22th, 3268 AC at midday GMT]]. *)

(** Common operations for all calendar representations.
    @since 2.0 (this signature was before inlined in interface of Calendar). *)
module type S = sig

  (** {2 Datatypes} *)

  module Date: Date_sig.S
    (** Date implementation used by this calendar.
	@since 2.0 *)

  module Time: Time_sig.S
    (** Time implementation used by this calendar.
	@since 2.0 *)

  type t

  type day = Date.day = Sun | Mon | Tue | Wed | Thu | Fri | Sat
      (** Days of the week. *)

  type month = Date.month =
      Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec
	  (** Months of the year. *)

  type year = Date.year
      (** Year as an int *)

  type second = Time.second

  type field = [ Date.field | Time.field ]
      (** The different fields of a calendar. *)

  (** {2 Constructors} *)

  val make : int -> int -> int -> int -> int -> second -> t
    (** [make year month day hour minute second] makes the calendar
	"year-month-day; hour-minute-second".
	@raise D.Out_of_bounds when a date is outside the Julian period.
	@raise D.Undefined when a date belongs to [[October 5th, 1582; October
	14th, 1582]]. *)

  val lmake :
    year:int -> ?month:int -> ?day:int ->
    ?hour:int -> ?minute:int -> ?second:second -> unit -> t
    (** Labelled version of [make].
	The default value of [month] and [day] (resp. of [hour], [minute]
	and [second]) is [1] (resp. [0]).
	@raise D.Out_of_bounds when a date is outside the Julian period.
	@raise D.Undefined when a date belongs to [[October 5th, 1582; October
	14th, 1582]].
	@since 1.05 *)

  val create : Date.t -> Time.t -> t
    (** [create d t] creates a calendar from the given date and time. *)

  val now : unit -> t
    (** [now ()] returns the current date and time (in the current time
	zone). *)

  val from_jd : float -> t
    (** Return the Julian day.
	More precise than [Date.from_jd]: the fractional part represents the
	time. *)

  val from_mjd : float -> t
    (** Return the Modified Julian day.
	It is [Julian day - 2 400 000.5] (more precise than [Date.from_mjd]). *)

  (** {2 Conversions} *)

  (**  Those functions have the same behaviour as those defined in
       {!Time_sig.S}. *)

  val convert : t -> Time_Zone.t -> Time_Zone.t -> t
    (** @see <Time_sig.S.html#VALconvert> Time_sig.S.convert *)

  val to_gmt : t -> t
    (** @see <Time_sig.S.html#VALto_gmt> Time_sig.S.to_gmt *)

  val from_gmt : t -> t
    (** @see <Time_sig.S.html#VALfrom_gmt> Time_sig.S.from_gmt *)

  (** {2 Getters} *)

  (** Those functions have the same behavious as those defined in
      {!Date_sig.S}. *)

  val days_in_month : t -> int
    (** @see <Date_sig.S.html#VALdays_in_month> Date_sig.S.days_in_month *)

  val day_of_week : t -> day
    (** @see <Date_sig.S.html#VALdays_of_week> Date_sig.S.days_of_week *)

  val day_of_month : t -> int
    (** @see <Date_sig.S.html#VALdays_of_month> Date_sig.S.days_of_month *)

  val day_of_year : t -> int
    (** @see <Date_sig.S.html#VALdays_of_year> Date_sig.S.days_of_year *)

  val week : t -> int
    (** @see <Date_sig.S.html#VALweek> Date_sig.S.week *)

  val month : t -> month
    (** @see <Date_sig.S.html#VALmonth> Date_sig.S.month *)

  val year : t -> int
    (** @see <Date_sig.S.html#VALyear> Date_sig.S.year *)

  (** [to_jd] and [to_mjd] are more precise than {!Date_sig.S.to_jd} and
      {!Date_sig.S.to_mjd}. *)

  val to_jd : t -> float
  val to_mjd : t -> float

  (** Those functions have the same behavious as those defined in
      {!Time_sig.S}. *)

  val hour : t -> int
    (** @see <Time_sig.S.html#VALhour> Time_sig.S.hour *)

  val minute : t -> int
    (** @see <Time_sig.S.html#VALminute> Time_sig.S.minute *)

  val second : t -> second
    (** @see <Time_sig.S.html#VALsecond> Time_sig.S.second *)

  (** {2 Calendars are comparable} *)

  val equal: t -> t -> bool
    (** Equality function between two calendars.
	@see <Utils.Comparable.html#VALequal> Utils.Comparable.equal. *)

  val compare: t -> t -> int
    (** Comparison function between two calendars.
	@see <Utils.Comparable.html#VALcompare> Utils.Comparable.compare. *)

  val hash: t -> int
    (** Hash function for calendars.
	@see <Utils.Comparable.html#VALhash> Utils.Comparable.hash.
	@since 2.0 *)

  (** Those functions have the same behavious as those defined in
      {!Date_sig.S}. *)

  val is_leap_day : t -> bool
    (** @see <Date_sig.S.html#VALis_leap_day> Date_sig.S.is_leap_day *)

  val is_gregorian : t -> bool
    (** @see <Date_sig.S.html#VALis_gregorian> Date_sig.S.is_gregorian *)

  val is_julian : t -> bool
    (** @see <Date_sig.S.html#VALis_julian> Date_sig.S.is_julian *)

  (** Those functions have the same behavious as those defined in
      {!Time_sig.S}. *)

  val is_pm : t -> bool
    (** @see <Time_sig.S.html#VALis_pm> Time_sig.S.is_pm *)

  val is_am : t -> bool
    (** @see <Time_sig.S.html#VALis_am> Time_sig.S.is_am *)

  (** {2 Coercions} *)

  val to_unixtm : t -> Unix.tm
    (** Convert a calendar into the [unix.tm] type.
	The field [isdst] is always [false]. More precise than
	{!Date_sig.S.to_unixtm}.
	@since 1.01 *)

  val from_unixtm : Unix.tm -> t
    (** Inverse of [to_unixtm]. Assumes the current time zone.
	So, The following invariant holds:
	[hour (from_unixtm u) = u.Unix.tm_hour].
	@since 1.01 *)

  val to_unixfloat : t -> float
    (** Convert a calendar to a float such than
	[to_unixfloat (make 1970 1 1 0 0 0)] returns [0.0] at UTC.
	So such a float is convertible with those of the module [Unix].
	More precise than {!Date_sig.S.to_unixfloat}.
	@since 1.01 *)

  val from_unixfloat : float -> t
    (** Inverse of [to_unixfloat]. Assumes the current time zone.
	So, the following invariant holds:
	[hour (from_unixfloat u) = (Unix.gmtime u).Unix.tm_hour].
	@since 1.01 *)

  val from_date : Date.t -> t
    (** Convert a date to a calendar.
	The time is midnight in the current time zone. *)

  val to_date : t -> Date.t
    (** Convert a calendar to a date. Time part of the calendar is ignored. *)

  val to_time : t -> Time.t
    (** Convert a calendar to a time. Date part of the calendar is ignored.
	@since 1.03 *)

  (** {2 Period} *)

  (** A period is the number of seconds between two calendars. *)
  module Period : sig

    (** {3 Arithmetic operations} *)

    type +'a period constraint 'a = [< Period.date_field ]
    type t = Period.date_field period
	(** Type of a period. *)

    (** {3 Period is an additive monoid} *)

    val empty : 'a period
      (** The empty period. *)

    val add : ([> `Day | `Week ] as 'a) period -> 'a period -> 'a period
      (** Addition of periods. *)

    val sub : ([> `Day | `Week ] as 'a) period -> 'a period -> 'a period
      (** Substraction of periods. *)

    val opp : ([> `Day | `Week ] as 'a) period -> 'a period
      (** Opposite of a period. *)

    (** {3 Periods are comparable} *)

    val equal: 'a period -> 'b period -> bool
      (** Equality function between two periods.
	  @see <Utils.Comparable.html#VALequal> Utils.Comparable.equal
	  @since 1.09.0 *)

    val compare : 'a period -> 'b period -> int
      (** Comparison function between two periods.
 	  @see <Utils.Comparable.html#VALcompare> Utils.Comparable.compare *)

    val hash: 'a period -> int
      (** Hash function for periods.
	  @see <Utils.Comparable.html#VALhash> Utils.Comparable.hash
	  @since 2.0 *)

    (** {3 Constructors} *)

    val make : int -> int -> int -> int -> int -> second -> t
      (** [make year month day hour minute second] makes a period of the
	  specified length. *)

    val lmake :
      ?year:int -> ?month:int -> ?day:int ->
      ?hour:int -> ?minute:int -> ?second:second -> unit -> t
      (** Labelled version of [make].
	  The default value of each argument is [0]. *)

    (** Those functions have the same behavious as those defined in
	{!Date_sig.S.Period}. *)

    val year : int -> [> `Year ] period
      (** @see <Date_sig.S.Period.html#VALyear> Date_sig.S.Period.year *)

    val month : int -> [> `Year | `Month ] period
      (** @see <Date_sig.S.Period.html#VALmonth> Date_sig.S.Period.month *)

    val week : int -> [> `Week | `Day ] period
      (** @see <Date_sig.S.Period.html#VALweek> Date_sig.S.Period.week *)

    val day : int -> [> `Week | `Day ] period
      (** @see <Date_sig.S.Period.html#VALday> Date_sig.S.Period.day *)

    (** Those functions have the same behavious as those defined in
	{Time_sig.S.Period}. *)

    val hour : int -> [> `Week | `Day ] period
      (** @see <Time_sig.S.Period.html#VALhour> Time_sig.S.Period.hour *)

    val minute : int -> [> `Week | `Day] period
      (** @see <Time_sig.S.Period.html#VALminute> Time_sig.S.Period.minute *)

    val second : second -> [> `Week | `Day] period
      (** @see <Time_sig.S.Period.html#VALsecond> Time_sig.S.Period.second *)

    (** {3 Coercions} *)

    val from_date : 'a Date.Period.period -> 'a period
      (** Convert a date period to a calendar period. *)

    val from_time : 'a Time.Period.period -> 'a period
      (** Convert a time period to a calendar period. *)

    val to_date : 'a period -> 'a Date.Period.period
      (** Convert a calendar period to a date period.
	  The fractional time period is ignored.
	  @example [to_date (hour 60)] is equivalent to [Date.Period.days 2]. *)

    exception Not_computable
      (** [= Date.Period.Not_computable].
	  @since 1.04 *)

    val to_time : 'a period -> 'a Time.Period.period
      (** Convert a calendar period to a date period.
	  @raise Not_computable if the time period is not computable.
	  @example [to_time (day 6)] returns a time period of [24 * 3600 * 6 =
	  518400] seconds
	  @example [to_time (second 30)] returns a time period of [30] seconds
	  @example [to_time (year 1)] raises [Not_computable] because
	  a year is not a constant number of days.
	  @since 1.04
	  @deprecated since 2.02: use {!safe_to_time} instead*)

    val safe_to_time:
      ([<  `Week | `Day ] as 'a) period -> 'a Time.Period.period
      (** Equivalent to {!to_time} but never raises any exception.
	  @since 2.02 *)

    val ymds: 'a period -> int * int * int * second
      (** Number of years, months, days and seconds in a period.
	  @example [ymds (make 1 2 3 1 2 3)] returns [1, 2, 3, 3723]
	  @example [ymds (make (-1) (-2) (-3) (-1) (-2) (-3)] returns
	  [-1, -2, -4, 82677].
	  @since 1.09.0 *)

  end

  (** {2 Arithmetic operations on calendars and periods} *)

  (** Those functions have the same behavious as those defined in
      {!Date_sig.S}. *)

  val add : t -> 'a Period.period -> t
    (** @see <Date_sig.S.html#VALadd> Date_sig.S.add *)

  val sub : t -> t -> [> `Week | `Day ] Period.period
    (** @see <Date_sig.S.html#VALsub> Date_sig.S.sub *)

  val precise_sub : t -> t -> Period.t
    (** @see <Date_sig.S.html#VALprecise_sub> Date_sig.S.precise_sub
	@since 2.03 *)

  val rem : t -> 'a Period.period -> t
    (** @see <Date_sig.S.html#VALrem> Date_sig.S.rem *)

  val next : t -> field -> t
    (** @see <Date_sig.S.html#VALnext> Date_sig.S.next *)

  val prev : t -> field -> t
    (** @see <Date_sig.S.html#VALprev> Date_sig.S.prev *)

end
