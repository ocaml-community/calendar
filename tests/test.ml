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

(*i $Id$ i*)

(* Display the results *)

let ok = 
  Test_timezone.ok + Test_time.ok + Test_ftime.ok 
  + Test_date.ok + Test_calendar.ok + Test_pcalendar.ok 
  + Test_fcalendar.ok + Test_fpcalendar.ok
  + Test_printer.ok;;

let bug =
  Test_timezone.bug + Test_time.bug + Test_ftime.bug
  + Test_date.bug + Test_calendar.bug + Test_pcalendar.bug 
  + Test_fcalendar.bug + Test_fpcalendar.bug
  + Test_printer.bug;;

Printf.printf "\nFinal results:\n";;
Printf.printf "tests ok : %d; tests ko : %d\n" ok bug;;

assert (bug >= 0);;

if bug > 0 then exit 1;;
