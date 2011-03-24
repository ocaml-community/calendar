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

(** Time zone management.

  You can [change] the [current] time zone in your program by side effect. *)

(** Type of a time zone. *)
type t =
  | UTC             (** Greenwich Meridian Time              *)
  | Local           (** Local Time                           *)
  | UTC_Plus of int (** Another time zone specified from UTC *)

val current : unit -> t
  (** Return the current time zone. It is [UTC] before any change. *)

val change : t -> unit
  (** Change the current time zone by another one.
      Raise [Invalid_argument] if the specified time zone is [UTC_Plus x] with
      [x < -12] or [x > 11] *)

val gap : t -> t -> int
  (** Return the gap between two time zone.
      @example [gap UTC (UTC_Plus 5)] returns 5 and, at Paris in summer,
      [gap Local UTC] returns -2. *)

val from_gmt : unit  -> int
  (** [from_gmt ()] is equivalent to [gap UTC (current ())]. *)

val to_gmt : unit -> int
  (** [to_gmt ()] is equivalent to [gap (current ()) UTC]. *)

val is_dst : unit -> bool
  (** [is_dst ()] checks if daylight saving time is in effect.
      Only relevant in local time.
      Returns alway [false] in another time zone.
      @since 1.09.4 *)

val hour_of_dst : unit -> int
  (** [hour_of_dst ()] returns [1] if [is_dst ()] and [0] otherwise.
      @since 1.09.4 *)

val on: ('a -> 'b) -> t -> 'a -> 'b
  (** [on f tz x] changes the time zone to [tz], then computes [f x], and
      finally reset the time zone to the initial one and returns the result of
      the computation.
      @since 2.0 *)
