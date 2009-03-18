(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2009 Julien Signoles                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License version 2.1 as published by the         *)
(*  Free Software Foundation.                                             *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public Licence version 2.1 for more        *)
(*  details (enclosed in the file LGPL).                                  *)
(*                                                                        *)
(**************************************************************************)

(*i $Id: test_timezone.ml,v 1.8 2008-02-08 10:36:14 signoles Exp $ i*)

Printf.printf "Tests of Time_Zone:\n";;

open CalendarLib
open Time_Zone;;
include Gen_test;;
reset ();;

test (current () = UTC) "current () = UTC";;
change Local;;
test (current () = Local) "current () = Local";;
test (gap UTC (UTC_Plus (-5)) = -5) "gap UTC (UTC_Plus (-5)) = -5";;
let g6 = UTC_Plus 6;;
test 
  (gap g6 Local = gap g6 UTC + gap UTC Local)
  "gap g6 Local = gap g6 UTC + gap UTC Local";;
test_exn (lazy (change (UTC_Plus 13))) "change 13";;
test_exn (lazy (change (UTC_Plus (-15)))) "change (-15)";;
change (UTC_Plus 4);;
test (from_gmt () = 4) "from_gmt () = 4";;
test (to_gmt () = -4) "to_gmt () = -4";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "tests ok : %d; tests ko : %d\n" ok bug;;
flush stdout;;
