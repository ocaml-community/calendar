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

(*i $Id: calendar.ml,v 1.3 2003-07-04 13:59:42 signoles Exp $ i*)

type t = float

type field = [ Date.field | Time.field ]
    
include (Date : sig 
	   include Date.S
	   val make : int -> int -> int -> Date.t
	   val compare : Date.t -> Date.t -> int
	 end)

include (Time : sig
	   include Time.S
	   val make : int -> int -> int -> Time.t
	   val compare : Time.t -> Time.t -> int
	 end)

let from_date x = float_of_int (to_jd x)

let to_date x = from_jd (int_of_float x)

(* return a number in [0 .. 1] *)
let from_time x = 
  let x = from_gmt x in float_of_int (to_seconds x) /. 86400.

let to_time x = 
  let t, _ = modf x in 
  let f, i = modf (t *. 86400.) in
  let i = if f < 0.5 then int_of_float i else int_of_float i + 1 in
  from_gmt (from_seconds i)

let build d t = from_date d +. from_time t

let build_in d t = 
  let from_time x = float_of_int (to_seconds x) /. 86400. in
  from_date d +. from_time t

let make y m d h mn s = build_in (Date.make y m d) (to_gmt (Time.make h mn s))

let now () = build (Date.today ()) (Time.now ())

let next x f = 
  let t, d = modf x in
  match f with
    | #Date.field as f -> from_date (Date.next (to_date d) f) +. t
    | #Time.field as f -> d +. from_time (Time.next (to_time t) f)
      
let prev x f = next (-. x) f

module Period = struct
  type t = { d : Date.Period.t; t : Time.Period.t }

  let empty = { d = Date.Period.empty; t = Time.Period.empty }

  let make y m d h mn s = 
    { d = Date.Period.make y m d; t = Time.Period.make h mn s }

  let year x = { empty with d = Date.Period.year x }

  let month x = { empty with d = Date.Period.month x }

  let week x = { empty with d = Date.Period.week x }

  let day x = { empty with d = Date.Period.day x }

  let hour x = { empty with t = Time.Period.hour x }

  let minut x = { empty with t = Time.Period.minut x }

  let second x = { empty with t = Time.Period.second x }

  let add _ = assert false
  let sub _ = assert false
  let mul _ = assert false
  let div _ = assert false
  let opp x = assert false

  let compare = Pervasives.compare
end

let rem _ = assert false
let sub _ = assert false
let add _ = assert false

let from_string s =
  match Str.split (Str.regexp "; ") s with
    | [ d; t ] -> build_in (Date.from_string d) (to_gmt (Time.from_string t))
    | _ -> raise (Invalid_argument (s ^ " is not a calendar"))

let to_string x = 
  Date.to_string (to_date x) ^ "; " ^ Time.to_string (to_time x)

let compare = Pervasives.compare
