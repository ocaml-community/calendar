(*
 * Time
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

(*i $Id: time.ml,v 1.2 2003-07-04 12:15:52 signoles Exp $ i*)

type t = int (*r GMT time *)

type field = [ `Hour | `Minut | `Second ]

module Period = struct
  type t = int

  let make h m s = h * 3600 + m * 60 + s

  let hour h = h * 3600

  let minut m = m * 60

  let second s = s

  let empty = 0

  let add = (+)

  let sub = (-)

  let mul = ( * )

  let div = (/)

  let opp x = - x

  let compare = (-)
end

module type S = sig
  val convert : t -> Time_Zone.t -> t
  val to_gmt : t -> t
  val from_gmt : t -> t
  val midnight : unit -> t
  val midday : unit -> t
  val hour : t -> int
  val minut : t -> int
  val second : t -> int
  val to_seconds : t -> int
  val to_minuts : t -> float
  val to_hours : t -> float
  val from_seconds : int -> t
  val from_minuts : float -> t
  val from_hours : float -> t
  val is_pm : t -> bool
  val is_am : t -> bool
end

let normalize t = t mod 86400, t / 86400

let convert t tz = t + 3600 * Time_Zone.gap Time_Zone.GMT tz

let to_gmt x = x + 3600 * Time_Zone.gap (Time_Zone.current ()) Time_Zone.GMT

let from_gmt x = convert x (Time_Zone.current ())

let midnight () = to_gmt 0

let midday () = to_gmt 43200

let now () =
  let now = Unix.gmtime (Unix.gettimeofday ()) in
  3600 * now.Unix.tm_hour + 60 * now.Unix.tm_min + now.Unix.tm_sec

let make h m s = to_gmt (h * 3600 + m * 60 + s)

let hour t = from_gmt t / 3600

let minut t = from_gmt t mod 3600 / 60

let second t = from_gmt t mod 60

let to_hours t = float_of_int (from_gmt t) /. 3600.

let to_minuts t = float_of_int (from_gmt t) /. 60.

let to_seconds t = from_gmt t

let from_hours t = to_gmt (int_of_float (t *. 3600.))

let from_minuts t = to_gmt (int_of_float (t *. 60.))

let from_seconds t = to_gmt t

let is_pm t = t < midday ()

let is_am t = t >= midday ()

let compare = (-)

let add = (+)

let sub = (-)

let rem = (-)

let next x = function
  | `Hour   -> x + 3600
  | `Minut  -> x + 60
  | `Second -> x + 1

let prev x = function
  | `Hour   -> x - 3600
  | `Minut  -> x - 60
  | `Second -> x - 1

let to_string t = 
  string_of_int (hour t) ^ "-" ^ string_of_int (minut t) 
  ^ "-" ^ string_of_int (second t)

let from_string s =
  match List.map int_of_string (Str.split (Str.regexp "-") s) with
    | [ h; m; s ] -> make h m s
    | _ -> raise (Invalid_argument (s ^ " is not a time"))
