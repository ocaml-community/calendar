(*
 * Calendar library
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

(*i $Id: time_Zone.mli,v 1.2 2003-07-04 12:15:35 signoles Exp $ i*)

(* [Time_Zone] manages the time zone by side effects:
   there is a [current] time zone in the program you can [change]. *)

(* Type of a time zone. *)
type t = 
  | GMT             (*r Greenwich Meridian Time              *)
  | Local           (*r Local Time                           *)
  | GMT_Plus of int (*r Another time zone specified from GMT *)

(* Return the current time zone. It is [GMT] before any change. *)
val current : unit -> t

(* Change the current time zone by another one. 
   Raise [Invalid_argument] is the specified time zone is [(GMT_Plus x)] with
   x < -12 or x > 11 *)
val change : t -> unit

(* Return the gap between two time zone. 
   E.g. [(gap GMT (GMT_Plus 5))] returns 5 and, at Paris in summer,
   [(gap Local GMT)] returns -2. *)
val gap : t -> t -> int
