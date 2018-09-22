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

open CalendarLib
open Time_Zone;;

let tz = Alcotest.testable (Fmt.always "timezone") (=) ;;

let test () =
  change UTC;
  Alcotest.(check tz) "current () = UTC" UTC (current ());
  change Local;
  Alcotest.(check tz) "current () = Local" Local (current ());
  Alcotest.(check int) "gap UTC (UTC_Plus (-5)) = -5" ~-5 (gap UTC (UTC_Plus ~-5));
  let g6 = UTC_Plus 6 in
  Alcotest.(check int)
    "gap g6 Local = gap g6 UTC + gap UTC Local"
    (gap g6 Local) (gap g6 UTC + gap UTC Local);
  Gen_test.test_exn (lazy (change (UTC_Plus 13))) "change 13";
  Gen_test.test_exn (lazy (change (UTC_Plus (-15)))) "change (-15)";
  change (UTC_Plus 4);
  Alcotest.(check int) "from_gmt () = 4" 4 (from_gmt ()) ;
  Alcotest.(check int) "to_gmt () = -4" ~-4 (to_gmt ());
  ()

let suite = ["timezone", `Quick, test]
