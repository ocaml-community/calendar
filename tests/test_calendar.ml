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

Printf.printf "Tests of Calendar:\n";;

open CalendarLib;;
open Calendar;;
include Gen_test;;
reset ();;

let eps = 0.000001;;

Time_Zone.change Time_Zone.UTC;;

(* Calendar *)

test_exn (lazy (make (-4712) 1 1 12 0 (-1))) "-4713-12-31-23-59-59";;
test (make (-4712) 1 1 12 0 0 = make (-4712) 1 0 36 0 0) "calendar coercion";;
test (from_jd 0. = make (-4712) 1 1 12 0 0) "from_jd 0 = 4713 BC-1-1";;
test (from_mjd 0. = make 1858 11 17 0 0 0) "from_mjd 0 = 1858-11-17";;

test (Precise.compare (Precise.make 2009 12 14 13 49 0) (Precise.make 2009 12 14 13 49 1) < 0)
  "Precise.compare 2009/12/14/13/19/0 2009/12/14/13/19/1";;

Utils.Float.set_precision 1e-5;;
test (compare (make 2009 12 14 13 49 0) (make 2009 12 14 13 49 1) < 0)
  "compare 2009/12/14/13/19/0 2009/12/14/13/19/1";;
Utils.Float.set_precision 1e-3;;

Time_Zone.change (Time_Zone.UTC_Plus 5);;

test (abs_float (to_jd (from_jd 12345.6789) -. 12345.6789) < eps)
  "to_jd (from_jd x) = x";;
test (abs_float (to_mjd (from_mjd 12345.6789) -. 12345.6789) < eps)
  "to_mjd (from_mjd x) = x";;
test (Period.to_date (Period.hour 60) = Date.Period.day 2)
  "period(60h) = period(2d)";;
test (Period.compare (Period.day 2) (Period.hour 60) < 0) "Period.compare <";;
test (Period.compare (Period.day 3) (Period.hour 60) > 0) "Period.compare >";;
test (Period.compare
	(Period.add (Period.day 2) (Period.hour 12))
	(Period.hour 60) = 0) "Period.compare =";;
test
  (add (make 1 2 3 4 5 6) (Period.make 9 8 7 6 5 4) = make 10 10 10 10 10 10)
  "add 1-2-3-4-5-6 9-8-7-6-5-4";;
test
  (add (make 3 1 1 0 0 0) (Period.make 0 0 0 (-25) 0 (-1)) =
  make 2 12 30 22 59 59)
  "add 3-1-1-0-0-0 0-0-0-(-25)-0-(-1)";;

test
  (equal (rem (make 9 8 7 6 5 4) (Period.make 1 2 3 4 5 6))
     (make 8 6 4 1 59 58))
  "rem 9-8-7-6-5-4 1-2-3-4-5-6";;
test (Period.equal
	(sub (make 0 0 7 6 5 4) (make 0 0 3 54 5 6))
	(Period.make 0 0 1 23 59 58))
  "sub 0-0-7-6-5-4 0-0-3-54-5-6";;

test (Date.Period.ymd
	(Period.to_date
	   (precise_sub (make 2010 10 5 0 0 0) (make 2010 6 2 0 0 0)))
      = (0, 4, 3))
"precise_sub 2010-10-5 2010-6-2";;
test (Date.Period.ymd
	(Period.to_date
	   (precise_sub (make 2010 10 5 0 2 3) (make 2010 6 5 0 0 0))) =
    (0, 4, 0))
"precise_sub 2010-10-5 2010-6-2";;
test (Date.Period.ymd
	(Period.to_date
	   (precise_sub (make 2010 10 5 0 32 12) (make 2010 6 6 0 31 3)))
      = (0, 3, 29))
"precise_sub 2010-10-5 2010-6-6";;
test (Date.Period.ymd
	(Period.to_date
	   (precise_sub (make 2010 10 5 1 3 3) (make 2010 6 4 0 23 3))) =
    (0, 4, 1))
"precise_sub 2010-10-5 2010-6-4";;
test (Date.Period.ymd
	(Period.to_date
	   (precise_sub (make 2010 1 1 0 0 0) (make 2000 1 1 0 0 0)))
      = (10, 0, 0))
"precise_sub 2010-1-1 2000-1-1";;

test (Period.equal
	(Period.opp (Period.make 0 0 2 3 0 0))
	(Period.make 0 0 (-2) (-3) 0 0))
  "period opp";;

(* Date *)

let d = make 2003 12 31 12 24 48;;
test (next d `Month = make 2004 1 31 12 24 48) "2003-12-31 + 1 mois";;
test (add d (Period.month 2) = make 2004 3 2 12 24 48) "2003-12-31 + 2 mois";;
let d3 = make 2011 3 24 0 0 0;;
test (prev d3 `Year = make 2010 3 24 0 0 0) "2011-3-24 - 1 year";;
let d2 = make (-3000) 1 1 6 12 24;;
test (equal (rem d (sub d d2)) d2) "rem x (sub x y) = y";;
test (is_leap_day (make 2000 2 24 0 0 0)) "2000-2-24 leap day";;
test (not (is_leap_day (make 2000 2 25 0 0 0))) "2000-2-25 not leap day";;
test (is_gregorian (make 1600 1 1 0 0 0)) "1600-1-1 gregorian";;
test (not (is_gregorian (make 1400 1 1 0 0 0))) "1400-1-1 not gregorian";;
test (is_julian (make 1582 1 1 0 0 0)) "1582-1-1 julian";;
test (not (is_julian (make 1583 1 1 0 0 0))) "1583-1-1 not julian";;

(* Time *)

test (let n = Unix.gmtime (Unix.time ()) in
      hour (from_unixtm n) = n.Unix.tm_hour) "from_unixtm invariant UTC";;
test (let n = Unix.time () in
      hour (from_unixfloat n) = (Unix.gmtime n).Unix.tm_hour)
  "from_unixfloat invariant UTC";;

Time_Zone.change (Time_Zone.UTC_Plus 10);;

test (let n = Unix.gmtime (Unix.time ()) in
      hour (from_unixtm n) = n.Unix.tm_hour) "from_unixtm invariant +10";;
test (let n = Unix.time () in
      hour (from_unixfloat n) = (Unix.gmtime n).Unix.tm_hour)
  "from_unixfloat invariant +10";;

test (equal (add (make 0 0 0 10 0 0) (Period.hour 30)) (make 0 0 1 16 0 0))
  "add 0-0-0-20-0-0 30h";;
test (equal (next (make 1999 12 31 23 59 59) `Second) (make 2000 1 1 0 0 0))
  "next 1999-31-12-23-59-59 `Second";;
let n = now ();;
test (equal (prev (next n `Minute) `Minute) n) "prev next = id";;
test (equal
	(convert
	   (make 0 0 0 23 0 0)
	   (Time_Zone.UTC_Plus 2)
	   (Time_Zone.UTC_Plus 4))
	(make 0 0 1 1 0 0)) "convert";;
test (hour (make 0 0 0 20 0 0) = 20) "hour";;
test (minute (make 0 0 0 20 10 0) = 10) "minute";;
test (second (make 0 0 0 20 10 5) = 5) "second";;
test (is_pm (make 0 0 0 10 0 0)) "is_pm 10-0-0";;
test (is_pm (make 0 0 0 34 0 0)) "is_pm 34-0-0";;
test (not (is_pm (make 0 0 0 (- 10) 0 0))) "not (is_pm (- 10) 0 0)";;
test (is_am (make 0 0 0 20 0 0)) "is_am 20-0-0";;
test (is_am (make 0 0 0 (- 34) 0 0)) "is_am (- 34) 0 0";;
test (not (is_am (make 0 0 0 34 0 0))) "not (is_pm 34 0 0)";;

Time_Zone.change Time_Zone.UTC;;

test (let n = Unix.gmtime (Unix.time ()) in
      hour (from_unixtm n) = n.Unix.tm_hour) "from_unixtm invariant UTC2";;
test (let n = Unix.time () in
      hour (from_unixfloat n) = (Unix.gmtime n).Unix.tm_hour)
  "from_unixfloat invariant UTC2";;

test (to_unixfloat (make 1970 1 1 0 0 0) = 0.) "to_unixfloat 1 Jan 1970";;
test (from_unixfloat 0. = make 1970 1 1 0 0 0) "from_unixfloat 1 Jan 1970";;
test (Utils.Float.equal (to_unixfloat (make 2004 11 13 19 17 9)) 1100373429.)
  "to_unixfloat";;
test (equal (from_unixfloat 1100373429.) (make 2004 11 13 19 17 9))
  "from_unixfloat";;
test (from_unixtm (to_unixtm (make 2003 7 16 23 22 21)) =
	make 2003 7 16 23 22 21)
  "from_unixtm to_unixtm = id";;

test (Period.to_time (Period.second 30) = Time.Period.second 30)
  "Period.to_time second";;
test (Period.to_time (Period.day 6) = Time.Period.second 518400)
  "Period.to_time day";;
test (Period.safe_to_time (Period.second 30) = Time.Period.second 30)
  "Period.safe_to_time second";;
test (Period.safe_to_time (Period.day 6) = Time.Period.second 518400)
  "Period.safe_to_time day";;
test_exn (lazy (Period.to_time (Period.year 1))) "Period.to_time year";;
test (Period.ymds (Period.make 1 2 3 1 2 3) = (1, 2, 3, 3723)) "Period.ymds";;
test
  (Period.ymds (Period.make (-1) (-2) (-3) (-1) (-2) (-3)) = (-1,-2,-4,82677))
  "Period.ymds neg";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "tests ok : %d; tests ko : %d\n" ok bug;;
flush stdout;;
