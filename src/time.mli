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

(*i $Id: time.mli,v 1.7 2003-07-08 08:12:18 signoles Exp $ i*)

(*S Introduction.

  This module implements operations on times.
  A time is a triple (hour, minut, second). 

  If minuts and seconds do not belong to [[0; 59]], they are coerced into this
  interval. For example, the time "30 hours, 60 minuts, 80 seconds" is coerced
  to the time "31 hours, 1 minut, 20 seconds". 

  Each time is interpreted in the current time zone (given by 
  [Time_Zone.current ()]). So, if you change the time zone (by 
  [Time_Zone.change]), each time consequently changes. 
  If you want to express a time in another time zone (and do not affect 
  others times), use the [convert] function.\\ *)

(*S Datatypes. *)

(* Type of a time. *)
type t

(* The different fields of a time. *)
type field = [ `Hour | `Minut | `Second ]

(*S Constructors. *)

(* [make hour minut second] makes the time hour-minut-second. *)
val make : int -> int -> int -> t

(* The current time based on [Time_Zone.current ()]. *)
val now : unit -> t
  
(* [midnight ()] is midnight (expressed in the current time zone).
   So, it has always the same behaviour as [make 0 0 0]. *)
val midnight : unit -> t
  
(* [midday ()] is midday (expressed in the current time zone).
   So, it has always the same behaviour as [make 12 0 0]. *)
val midday : unit -> t

(*S Conversions. *)

(* [convert t t1 t2] converts the time [t] expressed in the time zone [t1]
   to the same time expressed in the time zone [t2].\\
   E.g. 
   [convert (make 20 0 0) (Time_Zone.GMT_Plus 2) (Time_Zone.GMT_Plus 4)] 
   returns the time 22-0-0. *)
val convert : t -> Time_Zone.t -> Time_Zone.t -> t

(* [from_gmt t] is equivalent to
   [convert t Time_Zone.GMT (Time_Zone.current ())]. *)
val from_gmt : t -> t

(* [to_gmt t] is equivalent to 
   [convert t (Time_Zone.current ()) Time_Zone.GMT]. *)
val to_gmt : t -> t

(* [normalize t] returns [t] such that [hour t] $\in [0; 23]$.
   The second component of the result is the number of days needed by the 
   modification.
   E.g. [normalize (make 22 0 0)] returns the time 22-0-0 and 0,
   [normalize (make 73 0 0)] returns the time 1-0-0 and 3 and
   [normalize (make (-73) 0 0)] returns the time 23-0-0 and (-4). *)
val normalize : t -> t * int

(*S Getters. *)

(* Hour.
   E.g. [hour (make 20 0 0)] returns 20. *)
val hour : t -> int

(* Minut.
   E.g. [minut (make 20 10 0)] returns 10. *)
val minut : t -> int

(* Second.
   E.g. [second (make 20 10 5)] returns 5. *)
val second : t -> int

(* Number of seconds of a time. 
   E.g. [to_seconds (make 1 2 3)] returns [3600 + 120 + 3 = 3723]. *)
val to_seconds : t -> int

(* Number of minuts of a time. The resulting fractional part represents 
   seconds.\\
   E.g. [to_minuts (make 1 2 3)] returns [60 + 2 + 0.05 = 62.05]. *)
val to_minuts : t -> float

(* Number of hours of a time. The resulting fractional part represents 
   minuts and seconds.
   E.g. [to_hours (make 1 3 0)] returns [1 + 0.05 = 1.05]. *)
val to_hours : t -> float

(*S Boolean operations on times. *)
  
(* Comparison function between two times.
   Same behaviour as [Pervasives.compare]. *)
val compare : t -> t -> int

(* Return [true] is the time is before midday; [false] otherwise. 
   E.g. both [is_pm (make 10 0 0)] and [is_pm (make 34 0 0)] return [true]. *)
val is_pm : t -> bool
    
(* Return [true] is the time is after midday; [false] otherwise. 
   E.g. both [is_am (make 20 0 0)] and [is_am (make 44 0 0)] return [true]. *)
val is_am : t -> bool

(*S Coercions. *)

(* Convert a time to a string with the format "h-m-s". *)
val to_string : t -> string

(* Inverse of [to_string].
   Raise [Invalid_argument] if the string format is bad. *)
val from_string : string -> t

(* Inverse of [to_seconds]. *)
val from_seconds : int -> t

(* Inverse of [to_minuts]. *)
val from_minuts : float -> t

(* Inverse of [to_hours]. *)
val from_hours : float -> t

(*S Period.

  A period is the number of seconds between two times. *)

module Period : sig
  include Period.S (*r Arithmetic operations. *)

  (* Some other arithmetic operations. *)

  (* Number of seconds of a period. *)
  val length : t -> int

  (* Multiplication. *)
  val mul : t -> t -> t

  (* Division. *)
  val div : t -> t -> t

  (* Constructors. *)

  (* [make hour minut second] makes a period of the specified length. *)
  val make : int -> int -> int -> t

  (* [hour n] makes a period of [n] hours. *)
  val hour : int -> t

  (* [minut n] makes a period of [n] minuts. *)
  val minut : int -> t

  (* [second n] makes a period of [n] seconds. *)
  val second : int -> t
end

(*S Arithmetic operations on times and periods. *)

(* [app t p] returns [t + p]. 
   E.g. [add (make 20 0 0) (Period.minut 70)] returns the time 21-10-0. *)
val add : t -> Period.t -> t

(* [sub t1 t2] returns the period between [t1] and [t2]. *)
val sub : t -> t -> Period.t

(* [rem t p] is equivalent to [add t (Period.opp p)]. *)
val rem : t -> Period.t -> t

(* [next t f] returns the time corresponding to the next specified field.\\
   E.g [next (make 20 3 31) `Minut] returns the time 20-4-31.
   (i.e. one minut later). *)
val next : t -> field -> t

(* [prev t f] returns the time corresponding to the previous specified field.\\
   E.g [prev (make 20 3 31) `Second] returns the time 20-3-30.
   (i.e. one second ago). *)
val prev : t -> field -> t
