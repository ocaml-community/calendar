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

(*S Introduction.

  A time is represents by a number of seconds in UTC.
  Outside this module, a time is interpreted in the current time zone.
  So, each operations have to coerce a given time according to the current
  time zone. *)

(*S Datatypes. *)

include Utils.Int

type second = int

type field = [ `Hour | `Minute | `Second ]

(*S Conversions. *)

let one_day = 86400

let convert t t1 t2 = t + 3600 * Time_Zone.gap t1 t2
let from_gmt t = convert t Time_Zone.UTC (Time_Zone.current ())
let to_gmt t = convert t (Time_Zone.current ()) Time_Zone.UTC

(* Coerce [t] into the interval $[0; 86400[$ (i.e. a one day interval). *)
let normalize t =
  let t = from_gmt t in
  let t_mod, t_div = to_gmt (t mod one_day), t / one_day in
  if t < 0 then t_mod + one_day, t_div - 1 else t_mod, t_div

(*S Constructors. *)

let make h m s = to_gmt (h * 3600 + m * 60 + s)
let lmake ?(hour = 0) ?(minute = 0) ?(second = 0) () = make hour minute second

let midnight () = to_gmt 0

let midday () = to_gmt 43200

let now () =
  let now = Unix.gmtime (Unix.time ()) in
  3600 * now.Unix.tm_hour + 60 * now.Unix.tm_min + now.Unix.tm_sec

(*S Getters. *)

let hour t = from_gmt t / 3600
let minute t = from_gmt t mod 3600 / 60
let second t = from_gmt t mod 60

let to_hours t = float (from_gmt t) /. 3600.
let to_minutes t = float (from_gmt t) /. 60.
let to_seconds t = from_gmt t

(*S Boolean operations. *)

let is_pm t =
  let t, _ = normalize t in
  let m, _ = normalize (midday ()) in
  t < m

let is_am t =
  let t, _ = normalize t in
  let m, _ = normalize (midday ()) in
  t >= m

(*S Coercions. *)

let from_hours t = to_gmt (int_of_float (t *. 3600.))
let from_minutes t = to_gmt (int_of_float (t *. 60.))
let from_seconds t = to_gmt t

(*S Seconds. *)

module Second = struct
  type t = second
  let from_int x = x
  let to_int x = x
  let from_float = Utils.Float.round
  let to_float = float
end

(*S Period. *)

module Period = struct

  type +'a period = int constraint 'a = [< Period.date_field ]
  include Utils.Int

  let make h m s = h * 3600 + m * 60 + s
  let lmake ?(hour=0) ?(minute=0) ?(second=0) () = make hour minute second

  let length x = x

  let hour x = x * 3600
  let minute x = x * 60
  let second x = x

  let empty = 0

  let add = (+)
  let sub = (-)
  let mul = ( * )
  let div = (/)

  let opp x = - x

  let to_seconds x = x
  let to_minutes x = float x /. 60.
  let to_hours x = float x /. 3600.

end

(*S Arithmetic operations on times and periods. *)

let add = (+)
let sub = (-)
let rem = (-)

let next x = function
  | `Hour   -> x + 3600
  | `Minute -> x + 60
  | `Second -> x + 1

let prev x = function
  | `Hour   -> x - 3600
  | `Minute -> x - 60
  | `Second -> x - 1
