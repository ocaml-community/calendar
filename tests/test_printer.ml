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

Printf.printf "Tests of Printer:\n";;

open CalendarLib;;
include Gen_test;;
reset ();;

open Printer.Date;;
let d = Date.make 2003 1 6;;
test (sprint "%D" d = "01/06/03") "sprint %D";;
test (sprint "the date is %B, the %-dth" d = "the date is January, the 6th")
  "sprint (long sentence)";;
test (sprint "%^B, the %0dth" d = "JANUARY, the 06th") "sprint padding";;
test (sprint "%j" d = "006") "sprint %j";;
test (sprint "%-j" d = "6") "sprint %j";;
test (sprint "%_j" d = "  6") "sprint %j";;
test (sprint "%j" (Date.make 2003 1 10) = "010") "sprint %j";;
test (sprint "%-j" (Date.make 2003 1 10) = "10") "sprint %j";;
test (sprint "%_j" (Date.make 2003 1 10) = " 10") "sprint %j";;
test (sprint "%C" (Date.make 2008 12 5) = "21") "sprint %C";;
test (from_string "2003-01-06" = Date.make 2003 1 6) "from_string";;
test (from_fstring "%y-%m-%d" "03-01-06" = Date.make 1903 1 6) "from_fstring";;
test 
  (from_fstring "%Y%t%m%t%d" "1903\t01\t06" = Date.make 1903 1 6) 
  "from_fstring %t";;
test 
  (from_fstring "%Y-%B-%d" "2007-May-14" = Date.make 2007 5 14) 
  "from_fstring %B";;

test 
  (from_fstring "%Y-%b-%d" "2007-Jan-14" = Date.make 2007 1 14) 
  "from_fstring %B";;

test (from_fstring "%Y %V %w" "2004 01 1" = Date.make 2003 12 29) 
  "from_fstring %Y %V %w";;
test (from_fstring "%V %Y %w" "52 1999 7" = Date.make 2000 1 2) 
  "from_fstring %V %Y %w";;
test_exn (lazy (from_fstring "%Y %w" "1999 7")) "from_fstring_exn";;
test (from_fstring "%Y%j" "1903001" = Date.make 1903 1 1) "from_fstring %Y%j";;
test (from_fstring "%j%Y" "0011903" = Date.make 1903 1 1) "from_fstring %j%Y";;
test_exn (lazy (from_fstring "%j" "001")) "from_fstring_exn 2";;

open Printer.Time;;
test (to_string (Time.make 12 1 4) = "12:01:04") "to_string (on TimePrinter)";;
test (sprint "%I" (Time.make 36 4 3) = "12") "sprint %I (on TimePrinter)";;
test (sprint "%r" (Time.make 24 4 3) = "12:04:03 AM") 
  "sprint %r (on TimePrinter)";;
test (sprint "%R %z" (Time.make 12 24 5) = "12:24 +0000") "sprint %R %z";;
test 
  (Time_Zone.on (fun () -> sprint "%R %z" (Time.make 12 24 5)) 
     (Time_Zone.UTC_Plus (-3)) () = "12:24 -0300") 
  "sprint %R %z neg";;
test (sprint "%R %S %:z" (Time.make 23 47 55) = "23:47 55 +00:00")
  "sprint %R %S %:z";;
test 
  (Time_Zone.on (fun () -> sprint "%R %S %::z" (Time.make 7 47 55)) 
     (Time_Zone.UTC_Plus 3) () = "07:47 55 +03:00:00") 
  "sprint %R %S %::z";;
test_exn (lazy (sprint "%R %:a" (Time.make 23 47 55))) "sprint %R %:a";;
test_exn (lazy (sprint "%::::z %R" (Time.make 23 47 55))) "sprint %::::z %R";;

test (from_fstring "%R %S %z" "10:47 55 -0300" = Time.make 13 47 55)
  "from_fstring %R %S %z";;
test (from_fstring "%R %S %:z" "10:47 55 -13:00" = Time.make 23 47 55)
  "from_fstring %R %S %:z";;
test_exn (lazy (from_fstring "%R %S %:z" "10:47 55 -0300"))
  "from_fstring %R %S %:z bug1";;
test_exn (lazy (from_fstring "%R %S %:z" "10:47 55 -03:00:00"))
  "from_fstring %R %S %:z bug2";;
test (from_fstring "%R %S %::z" "10:47 55 +03:00:00" = Time.make 7 47 55)
  "from_fstring %R %S %::z";;
test (from_fstring "%R %S %:::z" "10:47 55 -03" = Time.make 13 47 55)
  "from_fstring %R %S %:::z";;
test_exn (lazy (from_fstring "%R %S %::::z" "10:47 55 -0300"))
  "from_fstring %R %S %::::z";;
test (from_fstring "%r" "10:47:25 AM" = Time.make 10 47 25)
  "from_fstring AM (on TimePrinter)";;
test (from_fstring "%r" "10:47:25 PM" = Time.make 22 47 25)
  "from_fstring PM (on TimePrinter)";;
test_exn (lazy (from_fstring "%p %I:%M:%S" "TM 5:26:17"))
  "from_fstring error on %p (on TimePrinter)";;

open Printer.Calendar;;
test (sprint "%c" (Calendar.make 2003 1 6 12 1 4) = "Mon Jan 06 12:01:04 2003")
  "sprint %c";;
test (to_string (Calendar.make 2004 10 25 24 0 1) = "2004-10-26 00:00:01")
  "to_string (on CalendarPrinter)";;
test 
  (from_fstring "%c" "Mon May 14 10:30:00 2007" 
   = Calendar.make 2007 5 14 10 30 0)
  "from_fstring (on CalendarPrinter)";;
test (sprint "%s" (Calendar.make 1971 1 1 0 0 0) = "31536000")
  "sprint %s";;

test (Utils.Float.equal
        (Ftime.second
           (Printer.Ftime.from_fstring
              "%Y-%m-%dT%H:%M:%S%:z" "2014-03-19T15:51:25.05-07:00"))
        25.05)
  "from_string with floating seconds";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "tests ok : %d; tests ko : %d\n" ok bug;;
flush stdout;;
