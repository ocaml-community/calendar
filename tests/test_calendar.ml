(*i $Id: test_calendar.ml,v 1.8 2003-07-16 16:21:18 signoles Exp $ i*)

Printf.printf "\nTests of Calendar:\n\n";;

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
test (to_string (from_string "1-2-3; 4-5-6") = "1-2-3; 4-5-6") 
  "to_string from_string = id";;
test 
  (add (make 1 2 3 4 5 6) (Period.make 9 8 7 6 5 4) = make 10 10 10 10 10 10) 
  "add 1-2-3-4-5-6 9-8-7-6-5-4";;
test (rem (make 9 8 7 6 5 4) (Period.make 1 2 3 4 5 6) = make 8 6 4 1 59 58) 
  "rem 9-8-7-6-5-4 1-2-3-4-5-6";;
test (sub (make 0 0 7 6 5 4) (make 0 0 3 54 5 6) = Period.make 0 0 1 23 59 58) 
  "sub 0-0-7-6-5-4 0-0-3-54-5-6";;

(* Date *)

let d = make 2003 12 31 12 24 48;;
test (to_string (next d `Month) = "2004-1-31; 12-24-48") 
  "2003-12-31 + 1 mois";;
test (to_string (add d (Period.month 2)) = "2004-3-2; 12-24-48") 
  "2003-12-31 + 2 mois";;
let d2 = make (-3000) 1 1 6 12 24;;
test (equal (rem d (sub d d2)) d2) "rem x (sub x y) = y";;
test (is_leap_day (make 2000 2 24 0 0 0)) "2000-2-24 leap day";;
test (not (is_leap_day (make 2000 2 25 0 0 0))) "2000-2-25 not leap day";;
test (is_gregorian (make 1600 1 1 0 0 0)) "1600-1-1 gregorian";;
test (not (is_gregorian (make 1400 1 1 0 0 0))) "1400-1-1 not gregorian";;
test (is_julian (make 1582 1 1 0 0 0)) "1582-1-1 julian";;
test (not (is_julian (make 1583 1 1 0 0 0))) "1583-1-1 not julian";;

(* Time *)

Time_Zone.change (Time_Zone.UTC_Plus 10);;

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

test (to_unixfloat (make 1970 1 1 0 0 0) = 0.) "to_unixfloat";;
test (from_unixfloat 0. = make 1970 1 1 0 0 0) "from_unixfloat";;
test (from_unixtm (to_unixtm (make 2003 7 16 23 22 21)) = 
	make 2003 7 16 23 22 21) 
  "from_unixtm to_unixtm = id";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
flush stdout;;
