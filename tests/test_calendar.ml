(*i $Id: test_calendar.ml,v 1.5 2003-07-08 08:12:19 signoles Exp $ i*)

Printf.printf "\nTests of Calendar:\n\n";;

open Calendar;;
include Gen_test;;
reset ();;

let eps = 0.000001;;

Time_Zone.change Time_Zone.GMT;;

(* Calendar *)

test_exn (lazy (make (-4712) 1 1 12 0 (-1))) "-4713-12-31-23-59-59";;
test (make (-4712) 1 1 12 0 0 = make (-4712) 1 0 36 0 0) "calendar coercion";;
test (from_jd 0. = make (-4712) 1 1 12 0 0) "from_jd 0 = 4713 BC-1-1";;
test (from_mjd 0. = make 1858 11 17 0 0 0) "from_mjd 0 = 1858-11-17";;

Time_Zone.change (Time_Zone.GMT_Plus 5);;

test (abs_float (to_jd (from_jd 12345.6789) -. 12345.6789) < eps) 
  "to_jd (from_jd x) = x";;
test (abs_float (to_mjd (from_mjd 12345.6789) -. 12345.6789) < eps) 
  "to_mjd (from_mjd x) = x";;
test (Period.to_date (Period.hour 59) = Date.Period.day 2) 
  "period(59h) = period(2d)";;
test (Period.to_date (Period.hour 60) = Date.Period.day 3) 
  "period(60h) = period(3d)";;
test (to_string (from_string "1-2-3; 4-5-6") = "1-2-3; 4-5-6") 
  "to_string from_string = id";;

(* Date *)

let d = make 2003 12 31 12 24 48;;
test (to_string (next d `Month) = "2004-1-31; 12-24-48") 
  "2003-12-31 + 1 mois";;
test (to_string (add d (Period.month 2)) = "2004-3-2; 12-24-48") 
  "2003-12-31 + 2 mois";;
let d2 = make (-3000) 1 1 6 12 24;;
test (egal (rem d (sub d d2)) d2) "rem x (sub x y) = y";;

(* Time *)

Time_Zone.change (Time_Zone.GMT_Plus 10);;

test (egal (add (make 0 0 0 10 0 0) (Period.hour 30)) (make 0 0 1 16 0 0))
  "add 0-0-0-20-0-0 30h";;
test (egal (next (make 1999 12 31 23 59 59) `Second) (make 2000 1 1 0 0 0))
  "next 1999-31-12-23-59-59 `Second";;
(*Time_Zone.change Time_Zone.Local;;*)
let n = now ();;
Printf.printf "sss %s %s %s\n" (to_string (now ())) (to_string n) (to_string (prev (next n `Minut) `Minut));;
Printf.printf "sss %s %s\n" (to_string (next n `Minut)) (to_string (prev n `Minut));;

test (egal (prev (next n `Minut) `Minut) n) "prev next = id";;
test (egal 
	(convert 
	   (make 0 0 0 23 0 0) 
	   (Time_Zone.GMT_Plus 2) 
	   (Time_Zone.GMT_Plus 4))
	(make 0 0 1 1 0 0)) "convert";;
test (hour (make 0 0 0 20 0 0) = 20) "hour";;
test (minut (make 0 0 0 20 10 0) = 10) "minut";;
test (second (make 0 0 0 20 10 5) = 5) "second";;
test (is_pm (make 0 0 0 10 0 0)) "is_pm 10-0-0";;
test (is_pm (make 0 0 0 34 0 0)) "is_pm 34-0-0";;
test (not (is_pm (make 0 0 0 (- 10) 0 0))) "not (is_pm (- 10) 0 0)";;
test (is_am (make 0 0 0 20 0 0)) "is_am 20-0-0";;
test (is_am (make 0 0 0 (- 34) 0 0)) "is_am (- 34) 0 0";;
test (not (is_am (make 0 0 0 34 0 0))) "not (is_pm 34 0 0)";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
