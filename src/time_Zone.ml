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

type t =
  | UTC
  | Local
  | UTC_Plus of int

let tz = ref UTC

let out_of_bounds x = x < - 12 || x > 11

let in_bounds x = not (out_of_bounds x)

let make_in_bounds x =
  let y = x mod 24 in
  if y < -12 then y + 24
  else if y > 11 then y - 24
  else y

let gap_gmt_local =
  let t = Unix.time () in
  (Unix.localtime t).Unix.tm_hour - (Unix.gmtime t).Unix.tm_hour

let current () = !tz

let change = function
  | UTC_Plus x when out_of_bounds x -> invalid_arg "Not a valid time zone"
  | _ as t -> tz := t

let gap t1 t2 =
  let aux t1 t2 =
    assert (t1 < t2);
    match t1, t2 with
      | UTC, Local             -> gap_gmt_local
      | UTC, UTC_Plus x        -> x
      | Local, UTC_Plus x      -> x - gap_gmt_local
      | UTC_Plus x, UTC_Plus y -> y - x
      | _                      -> assert false
  in
  let res =
    if t1 = t2 then 0
    else if t1 < t2 then aux t1 t2
    else - aux t2 t1
  in
  make_in_bounds res

let from_gmt () = gap UTC (current ())
let to_gmt () = gap (current ()) UTC

let is_dst () =
  current () = Local && (Unix.localtime (Unix.time ())).Unix.tm_isdst

let hour_of_dst () = if is_dst () then 1 else 0

let on f tz x =
  let old = current () in
  change tz;
  try
    let res = f x in
    change old;
    res
  with exn ->
    change old;
    raise exn
