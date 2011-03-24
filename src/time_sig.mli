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

(** Time interface. A time may be seen as a triple (hour, minute, second).

    If minutes and seconds do not belong to [\[0; 60\[], they are coerced into
    this interval.

    @example "30 hours, 60 minutes, 80 seconds" is coerced to "31 hours, 1
    minute, 20 seconds".

    Each time is interpreted in the current time zone (given by
    [Time_Zone.current ()]). So, if you change the time zone (by
    {!Time_Zone.change}), each time consequently changes.
    If you want to express a time in another time zone (and do not affect
    others times), use the [convert] function. *)

(** Interface for seconds.
    @since 2.0 *)
module type Second = sig

  type t
    (** Type of seconds. *)

  val from_int: int -> t
    (** Convert an integer to an equivalent number of seconds. *)

  val from_float: float -> t
    (** Convert a float to an equivalent number of seconds. *)

  val to_int: t -> int
    (** Inverse of [from_int]. *)

  val to_float: t -> float
    (** Inverse of [from_float]. *)

end

(** Common operations for all time representations.
    @since 2.0 (this signature was before inlined in interface of Time). *)
module type S = sig

  (** {2 Datatypes} *)

  type t
    (** Type of a time. *)

  type field = [ `Hour | `Minute | `Second ]
      (** The different fields of a time. *)

  (** {2 Second} *)

  type second
    (** Type of a second.
	@since 2.0 (was an integer in previous versions). *)

  (** Second implementation
      @since 2.0 *)
  module Second: Second with type t = second

  (** {2 Constructors} *)

  val make : int -> int -> second -> t
    (** [make hour minute second] makes the time hour-minute-second. *)

  val lmake : ?hour:int -> ?minute:int -> ?second:second -> unit -> t
    (** Labelled version of [make]. The default value is [0] for each argument.
	@since 1.05 *)

  val now : unit -> t
    (** The current time based on [Time_Zone.current ()]. *)

  val midnight : unit -> t
    (** [midnight ()] is midnight (expressed in the current time zone).
	So, it has always the same behaviour as [make 0 0 0]. *)

  val midday : unit -> t
    (** [midday ()] is midday (expressed in the current time zone).
	So, it has always the same behaviour as [make 12 0 0]. *)

  (** {2 Conversions} *)

  val convert : t -> Time_Zone.t -> Time_Zone.t -> t
    (** [convert t t1 t2] converts the time [t] expressed in the time zone [t1]
	to the same time expressed in the time zone [t2].
	@example [convert (make 20 0 0) (Time_Zone.GMT_Plus 2)
	(Time_Zone.GMT_Plus 4)] returns the time 22-0-0. *)

  val from_gmt : t -> t
    (** [from_gmt t] is equivalent to
	[convert t Time_Zone.GMT (Time_Zone.current ())]. *)

  val to_gmt : t -> t
    (** [to_gmt t] is equivalent to
	[convert t (Time_Zone.current ()) Time_Zone.GMT]. *)

  val normalize : t -> t * int
    (** [normalize t] returns [t] such that [hour t] belongs to [\[0; 24\[]. The
	second component of the result is the number of days needed by the
	modification.
	@example [normalize (make 22 0 0)] returns the time 22-0-0 and 0,
	[normalize (make 73 0 0)] returns the time 1-0-0 and 3 and [normalize
	(make (-73) 0 0)] returns the time 23-0-0 and (-4). *)

  (** {2 Getters} *)

  val hour : t -> int
    (** Hour.
	@example [hour (make 20 0 0)] returns 20. *)

  val minute : t -> int
    (** Minute.
	@example [minute (make 20 10 0)] returns 10. *)

  val second : t -> second
    (** Second.
	@example [second (make 20 10 5)] returns 5. *)

  val to_seconds : t -> second
    (** Number of seconds of a time.
	@example [to_seconds (make 1 2 3)] returns [3600 + 120 + 3 = 3723]. *)

  val to_minutes : t -> float
    (** Number of minutes of a time. The resulting fractional part represents
	seconds.
	@example [to_minutes (make 1 2 3)] returns [60+2+0.05 = 62.05]. *)

  val to_hours : t -> float
    (** Number of hours of a time. The resulting fractional part represents
	minutes and seconds.
	@example [to_hours (make 1 3 0)] returns [1 + 0.05 = 1.05]. *)

  (** {2 Times are comparable} *)

  val equal: t -> t -> bool
    (** Equality function between two times.
	@see <Utils.Comparable.html#VALequal> Utils.Comparable.equal.
	@since 1.09.0 *)

  val compare : t -> t -> int
    (** Comparison function between two times.
	@see <Utils.Comparable.html#VALcompare> Utils.Comparable.compare. *)

  val hash: t -> int
    (** Hash function for times.
	@see <Utils.Comparable.html#VALhash> Utils.Comparable.hash.
	@since 2.0 *)

  (** {2 Boolean operations on times} *)

  val is_pm : t -> bool
    (** Return [true] is the time is before midday in the current time zone;
	[false] otherwise.
	@example both [is_pm (make 10 0 0)] and [is_pm (make 34 0 0)] return
	[true]. *)

  val is_am : t -> bool
    (** Return [true] is the time is after midday in the current time zone;
	[false] otherwise.
	@example both [is_am (make 20 0 0)] and [is_am (make 44 0 0)] return
	[true]. *)

  (** {2 Coercions} *)

  val from_seconds: second -> t
    (** Inverse of [to_seconds]. *)

  val from_minutes: float -> t
    (** Inverse of [to_minutes]. *)

  val from_hours: float -> t
    (** Inverse of [to_hours]. *)

  (** {2 Period} *)

  (** A period is the number of seconds between two times. *)
  module Period : sig

    (** {3 Arithmetic operations} *)

    include Period.S

    val length : 'a period -> second
      (** Number of seconds of a period. *)

    val mul : 'a period -> 'a period -> 'a period
      (** Multiplication. *)

    val div : 'a period -> 'a period -> 'a period
      (** Division. *)

    (** {3 Constructors} *)

    val make : int -> int -> second -> 'a period
      (** [make hour minute second] makes a period of the specified length. *)

    val lmake : ?hour:int -> ?minute:int -> ?second:second -> unit -> 'a period
      (** Labelled version of [make].
	  The default value is [0] for each argument. *)

    val hour : int -> 'a period
      (** [hour n] makes a period of [n] hours. *)

    val minute : int -> 'a period
      (** [minute n] makes a period of [n] minutes. *)

    val second : second -> 'a period
      (** [second n] makes a period of [n] seconds. *)

    (** {3 Getters} *)

    val to_seconds : 'a period -> second
      (** Number of seconds of a period.
	  @example [to_seconds (make 1 2 3)] returns [3600 + 120 + 3 = 3723].
	  @since 1.04 *)

    val to_minutes : 'a period -> float
      (** Number of minutes of a period. The resulting fractional part
	  represents seconds.
	  @example [to_minutes (make 1 2 3)] returns [60 + 2 + 0.05 = 62.05].
	  @since 1.04 *)

    val to_hours : 'a period -> float
      (** Number of hours of a period. The resulting fractional part represents
	  minutes and seconds.
	  @example [to_hours (make 1 3 0)] returns [1 + 0.05 = 1.05].
	  @since 1.04 *)

  end

  (** {2 Arithmetic operations on times and periods} *)

  val add : t -> 'a Period.period -> t
    (** [app t p] returns [t + p].
	@example [add (make 20 0 0) (Period.minute 70)] returns the time
	21:10:0. *)

  val sub : t -> t -> 'a Period.period
    (** [sub t1 t2] returns the period between [t1] and [t2]. *)

  val rem : t -> 'a Period.period -> t
    (** [rem t p] is equivalent to [add t (Period.opp p)]. *)

  val next : t -> field -> t
    (** [next t f] returns the time corresponding to the next specified field.
	@example [next (make 20 3 31) `Minute] returns the time 20:04:31.
	(i.e. one minute later). *)

  val prev : t -> field -> t
    (** [prev t f] returns the time corresponding to the previous specified
	field.
	@example [prev (make 20 3 31) `Second] returns the time 20:03:30
	(i.e. one second ago). *)

end
