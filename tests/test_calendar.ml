(*i $Id: test_calendar.ml,v 1.3 2003-07-07 17:34:56 signoles Exp $ i*)

Printf.printf "\nTests of Calendar:\n\n";;

open Calendar;;
include Gen_test;;
reset ();;

let eps = 0.000001;;

Time_Zone.change Time_Zone.GMT;;

test_exn (lazy (make (-4712) 1 1 12 0 (-1))) "-4713-12-31-23-59-59";;
test (make (-4712) 1 1 12 0 0 = make (-4712) 1 0 36 0 0) "calendar coercion";;
test (from_jd 0. = make (-4712) 1 1 12 0 0) "from_jd 0 = 4713 BC-1-1";;
test (from_mjd 0. = make 1858 11 17 0 0 0) "from_mjd 0 = 1858-11-17";;

Time_Zone.change (Time_Zone.GMT_Plus 5);;

test (abs_float (to_jd (from_jd 12345.6789) -. 12345.6789) < eps) 
  "to_jd (from_jd x) = x";;
test (abs_float (to_mjd (from_mjd 12345.6789) -. 12345.6789) < eps) 
  "to_mjd (from_mjd x) = x";;
test (to_string (from_string "1-2-3; 4-5-6") = "1-2-3; 4-5-6") 
  "to_string from_string = id";;

let d = make 2003 12 31 12 24 48;;
test (to_string (next d `Month) = "2004-1-31; 12-24-48") 
  "2003-12-31 + 1 mois";;
test (to_string (add d (Period.month 2)) = "2004-3-2; 12-24-48") 
  "2003-12-31 + 2 mois";;
let d2 = make (-3000) 1 1 6 12 24;;
test (egal (rem d (sub d d2)) d2) "rem x (sub x y) = y";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
