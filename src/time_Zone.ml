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

(*i $Id: time_Zone.ml,v 1.5 2003-07-07 21:01:34 signoles Exp $ i*)

type t = 
  | GMT
  | Local 
  | GMT_Plus of int

let tz = ref GMT

let out_of_bounds x = x < - 12 || x > 11

let in_bounds x = not (out_of_bounds x)

let gap_gmt_local = 
  let t = Unix.time () in
  (Unix.localtime t).Unix.tm_hour - (Unix.gmtime t).Unix.tm_hour

let current () = !tz

let change = function
  | GMT_Plus x when out_of_bounds x -> 
      raise (Invalid_argument "Not a valid time zone")
  | _ as t -> tz := t

let gap t1 t2 =
  let aux t1 t2 = 
    assert (t1 < t2);
    match t1, t2 with
      | GMT, Local             -> gap_gmt_local
      | GMT, GMT_Plus x        -> x
      | Local, GMT_Plus x      -> x - gap_gmt_local
      | GMT_Plus x, GMT_Plus y -> y - x
      | _                      -> assert false
  in let res = 
    if t1 = t2 then 0
    else if t1 < t2 then aux t1 t2
    else - aux t2 t1
  in
  assert (in_bounds res);
  res

let from_gmt () = gap GMT (current ())

let to_gmt () = gap (current ()) GMT
