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

(*i $Id: time_Zone.mli,v 1.6 2003-07-16 09:04:30 signoles Exp $ i*)

(* [Time_Zone] manages the time zone by side effects:
   there is a [current] time zone in the program you can [change].\\ *)

(* Type of a time zone. *)
type t = 
  | UTC             (*r Greenwich Meridian Time              *)
  | Local           (*r Local Time                           *)
  | UTC_Plus of int (*r Another time zone specified from UTC *)

(* Return the current time zone. It is [UTC] before any change. *)
val current : unit -> t

(* Change the current time zone by another one. 
   Raise [Invalid_argument] if the specified time zone is [UTC_Plus x] with
   $x < -12$ or $x > 11$ *)
val change : t -> unit

(* Return the gap between two time zone. 
   E.g. [gap UTC (UTC_Plus 5)] returns 5 and, at Paris in summer,
   [gap Local UTC] returns -2. *)
val gap : t -> t -> int

(* [from_gmt ()] is equivalent to [gap UTC (current ())]. *)
val from_gmt : unit  -> int

(* [to_gmt ()] is equivalent to [gap (current ()) UTC]. *)
val to_gmt : unit -> int
