(*i $Id: test_date.ml,v 1.7 2003-08-31 07:50:47 signoles Exp $ i*)

Printf.printf "\nTests of Date:\n\n";;

open Date;;
include Gen_test;;
reset ();;

test_exn (lazy (make (-4713) 1 1)) "make (-4713) 1 1";;
test_exn (lazy (make 3268 1 23)) "make 3268 1 23";;
test_exn (lazy (make 1582 10 5)) "make 1582 10 10";;
test (to_string (make 2003 2 30) = "2003-3-2") "2003-2-30 = 2003-3-2";;
test (compare (make 2003 2 29) (make 2003 3 1) = 0) "2003-2-29 = 2003-3-1";;
let d = make 2003 12 31;;
test (to_string (next d `Month) = "2004-1-31") "2003-12-31 + 1 mois";;
test (to_string (add d (Period.month 2)) = "2004-3-2") "2003-12-31 + 2 mois";;
let d2 = make (-3000) 1 1;;
test (rem d (sub d d2) = d2) "rem x (sub x y) = y";;
test (from_jd 0 = make (-4712) 1 1) "from_jd 0 = 4713 BC-1-1";;
test (to_jd (from_jd 12345) = 12345) "to_jd (from_jd x) = x";;
test (from_mjd 0 = make 1858 11 17) "from_mjd 0 = 1858-11-17";;
test (to_mjd (from_mjd 12345) = 12345) "to_mjd (from_mjd x) = x";;
test (is_leap_day (make 2000 2 24)) "2000-2-24 leap day";;
test (not (is_leap_day (make 2000 2 25))) "2000-2-25 not leap day";;
test (is_gregorian (make 1600 1 1)) "1600-1-1 gregorian";;
test (not (is_gregorian (make 1400 1 1))) "1400-1-1 not gregorian";;
test (is_julian (make 1582 1 1)) "1582-1-1 julian";;
test (not (is_julian (make 1583 1 1))) "1583-1-1 not julian";;
test (int_of_day Mon = 1) "Monday = 1";;
test (int_of_day Sun = 7) "Sunday = 7";;
test (day_of_int 1 = Mon) "1 = Monday";;
test (day_of_int 7 = Sun) "1 = Monday";;
test (int_of_month Jan = 1) "January = 1";;
test (month_of_int 12 = Dec) "12 = December";;
test (not (is_leap_year 1999)) "1999 not leap year";;
test (not (is_leap_year 1800)) "1800 not leap year";;
test (is_leap_year 1996) "1996 leap year";;
test (is_leap_year 1600) "1600 leap year";;
test (same_calendar 1956 1900) "same calendar 1956 1900";;
test (same_calendar 2001 2013) "same calendar 2001 2013";;
test (same_calendar 1998 2009) "same calendar 1998 2009";;
test (same_calendar 2003 2025) "same calendar 2003 2025";;
test (days_in_year 2000 = 366) "days_in_year 2000";;
test (days_in_year 1900 = 365) "days_in_year 1900";;
test (weeks_in_year 2000 = 52) "weeks_in_year 2000";;
test (weeks_in_year 2020 = 53) "weeks_in_year 2020";;
test (weeks_in_year 1991 = 53) "weeks_in_year 1991";;
test (weeks_in_year 1999 = 52) "weeks_in_year 1991";;
test (century 2000 = 20) "century 2000";;
test (century 2001 = 21) "century 2001";;
test (millenium 2000 = 2) "millenium 2000";;
test (millenium 2001 = 3) "millenium 2001";;
test (easter 2003 = make 2003 4 20) "Paques 2003";;
test (to_unixfloat (make 1970 1 1) = 0.) "to_unixfloat";;
test (from_unixfloat 0. = make 1970 1 1) "from_unixfloat";;
test (from_unixtm (to_unixtm (make 2003 7 16)) = make 2003 7 16) 
  "from_unixtm to_unixtm = id";;

test (Period.nb_days (Period.make 0 0 6) = 6) "Period.nb_days ok";;
test_exn (lazy (Period.nb_days (Period.make 1 0 0))) "Period.nb_days ko";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
flush stdout;;
