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

let ok_ref = ref 0
let ok () = incr ok_ref
let nb_ok () = !ok_ref

let bug_ref = ref 0
let bug () = incr bug_ref
let nb_bug () = !bug_ref

let reset () =
  ok_ref := 0;
  bug_ref := 0

let test x s = 
  if x then ok () else begin Printf.printf "%s\n" s; bug () end;;

let test_exn x s =
  try
    ignore (Lazy.force x);
    Printf.printf "%s\n" s;
    bug ()
  with _ ->
    ok ();;
