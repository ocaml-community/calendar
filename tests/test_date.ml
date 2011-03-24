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

Printf.printf "Tests of Date:\n";;

open CalendarLib;;
open Date;;
include Gen_test;;
reset ();;

test_exn (lazy (make (-4713) 1 1)) "make (-4713) 1 1";;
test_exn (lazy (make 3268 1 23)) "make 3268 1 23";;
test_exn (lazy (make 1582 10 5)) "make 1582 10 10";;
test (compare (make 2003 2 29) (make 2003 3 1) = 0) "2003-2-29 = 2003-3-1";;
let d = make 2003 12 31;;
test (next d `Month = make 2004 1 31) "2003-12-31 + 1 mois";;
test (add d (Period.month 2) = make 2004 3 2) "2003-12-31 + 2 mois";;
test (add (make 2008 12 31) (Period.month 6) = make 2009 7 1)
  "2008-12-31 + 6 mois";;
test (rem (make 2008 6 2) (Period.month 12) = make 2007 6 2)
  "2008-6-2 - 12 mois";;
test (rem (make 2007 2 30) (Period.month 4) = make 2006 11 2)
  "2008-2-30 - 4 mois";;
test (make 2007 (-38) 30 = make 2003 10 30)
  "2007-(-38)-30 - 2003 10 30";;
test (rem (make 2007 2 30) (Period.month 40) = make 2003 11 2)
  "2008-2-30 - 40 mois";;
let d2 = make (-3000) 1 1;;
test (rem d (sub d d2) = d2) "rem x (sub x y) = y";;
test (Period.ymd (precise_sub (make 2010 10 5) (make 2010 6 2)) = (0, 4, 3))
"precise_sub 2010-10-5 2010-6-2";;
test (Period.ymd (precise_sub (make 2010 10 5) (make 2010 6 5)) = (0, 4, 0))
"precise_sub 2010-10-5 2010-6-2";;
test (Period.ymd (precise_sub (make 2010 10 5) (make 2010 6 6)) = (0, 3, 29))
"precise_sub 2010-10-5 2010-6-6";;
test (Period.ymd (precise_sub (make 2010 10 5) (make 2010 6 4)) = (0, 4, 1))
"precise_sub 2010-10-5 2010-6-4";;
test (Period.ymd (precise_sub (make 2010 1 1) (make 2000 1 1)) = (10, 0, 0))
"precise_sub 2010-1-1 2000-1-1";;
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
test (days_in_year ~month:Jan 2000 = 31) "days_in_year Jan 2000";;
test (days_in_year ~month:Feb 2000 = 60) "days_in_year Feb 2000";;
test (days_in_year ~month:Jan 2000 = 31) "days_in_year Jan 2000";;
test (days_in_year ~month:Mar 1900 = 90) "days_in_year Mar 1900";;
test (weeks_in_year 2000 = 52) "weeks_in_year 2000";;
test (weeks_in_year 2020 = 53) "weeks_in_year 2020";;
test (weeks_in_year 1991 = 52) "weeks_in_year 1991";;
test (weeks_in_year 1999 = 52) "weeks_in_year 1999";;
test (days_in_month (make 2000 2 18) = 29) "days_in_month 2000-2-18";;
test (days_in_month (make_year_month 2000 2) = 29) "days_in_month 2000-2";;
(* untypable: *)
(* test (days_in_month ((make_year 2000 :> [ `Year | `Month ] Date.date)) = 29) "days_in_month 2000-2";; *)
test (days_in_year 1900 = 365) "days_in_year 1900";;
test (century 2000 = 20) "century 2000";;
test (century 2001 = 21) "century 2001";;
test (millenium 2000 = 2) "millenium 2000";;
test (millenium 2001 = 3) "millenium 2001";;
test (year (make_year_month 2000 3) = 2000) "year 2000-3";;
test (year (make_year 2000) = 2000) "year 2000";;
test (month (make 2000 4 23) = Apr) "year 2000-4-23";;
test (month (make_year_month 2000 3) = Mar) "year 2000-3";;
(* untypable: *)
(*test (month (make_year 2000) = Mar) "year 2000";;*)
test (easter 2003 = make 2003 4 20) "Paques 2003";;
test (Period.nb_days (Period.make 0 0 6) = 6) "Period.nb_days ok";;
test (Period.safe_nb_days (Period.week 3) = 21) "Period.safe_nb_days ok";;
test_exn (lazy (Period.nb_days (Period.make 1 0 0))) "Period.nb_days ko";;
test (week_first_last 21 2004 = (make 2004 5 17, make 2004 5 23))
  "week_beggining_end";;
test (Period.ymd (Period.make 1 2 3) = (1, 2, 3)) "Period.ymd";;
test (nth_weekday_of_month 2004 Oct Thu 4 = make 2004 10 28)
  "nth_weekday_of_month";;
test (nth_weekday_of_month 2006 Mar Fri 3 = make 2006 3 17)
  "nth_weekday_of_month";;
test (equal (from_day_of_year 2008 39) (make 2008 2 8))
  "from_day_of_year";;
test (is_valid_date 2008 2 8) "is_valid_date";;
test (not (is_valid_date 2008 2 30)) "not is_valid_date";;

(* Unix *)
Time_Zone.change Time_Zone.UTC;;
test (to_unixfloat (make 1970 1 1) = 0.) "to_unixfloat 1 Jan 1970";;
test (from_unixfloat 0. = make 1970 1 1) "from_unixfloat 0.";;
test (to_unixfloat (make 2004 11 13) = 1100304000.) "to_unixfloat";;
test (from_unixfloat 1100304000. = make 2004 11 13) "from_unixfloat";;
test (from_unixtm (to_unixtm (make 2003 7 16)) = make 2003 7 16)
  "from_unixtm to_unixtm = id";;
Time_Zone.change (Time_Zone.UTC_Plus (-1));;
test (from_unixfloat 0. = make 1969 12 31) "from_unixfloat 0. (dec-)";;
test (from_unixtm { Unix.tm_sec = 0; tm_min = 0; tm_hour = 0; tm_mday = 1;
		    tm_mon = 0; tm_year = 70; tm_wday = 4; tm_yday = 0;
		    tm_isdst = false } = make 1969 12 31)
  "from_unixtm (dec-)";;
Time_Zone.change (Time_Zone.UTC_Plus 1);;
test (from_unixfloat 1100390390. = make 2004 11 14) "from_unixfloat (dec+)";;
test (from_unixtm { Unix.tm_sec = 0; tm_min = 0; tm_hour = 0; tm_mday = 14;
		    tm_mon = 10; tm_year = 104; tm_wday = 0; tm_yday = 318;
		    tm_isdst = false } = make 2004 11 14)
  "from_unixtm (dec+)";;
test (from_unixtm (to_unixtm (make 2003 7 16)) = make 2003 7 16)
  "from_unixtm to_unixtm = id";;

(* to_business *)
test (to_business (make 2003 1 1) = (2003, 1, Wed)) "to_business 1";;
test (to_business (make 2003 12 31) = (2004, 1, Wed)) "to_business 2";;
test (to_business (make 2002 12 31) = (2003, 1, Tue)) "to_business 3";;
test (to_business (make 2005 1 1) = (2004, 53, Sat)) "to_business 4";;
test (to_business (make 2004 12 31) = (2004, 53, Fri)) "to_business 5";;
test (to_business (make 2006 1 1) = (2005, 52, Sun)) "to_business 6";;
test (to_business (make 2005 1 17) = (2005, 3, Mon)) "to_business 7";;
test (to_business (make 2006 1 31) = (2006, 5, Tue)) "to_business 8";;
test (to_business (make 2005 1 31) = (2005, 5, Mon)) "to_business 9";;
(* from_business *)
test (from_business 2003 1 Wed = make 2003 1 1) "from_business 1";;
test (from_business 2004 1 Wed = make 2003 12 31) "from_business 2";;
test (from_business 2003 1 Tue = make 2002 12 31) "from_business 3";;
test (from_business 2004 53 Sat = make 2005 1 1) "from_business 4";;
test (from_business 2004 53 Fri = make 2004 12 31) "from_business 5";;
test (from_business 2005 52 Sun = make 2006 1 1) "from_business 6";;
test (from_business 2005 3 Mon = make 2005 1 17) "from_business 7";;
test (from_business 2006 5 Tue = make 2006 1 31) "from_business 8";;
test (from_business 2005 5 Mon = make 2005 1 31) "from_business 9";;
test_exn (lazy (from_business 2005 0 Sun)) "from_business_bad 1";;
test_exn (lazy (from_business 2005 53 Sun)) "from_business_bad 2";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "tests ok : %d; tests ko : %d\n" ok bug;;
flush stdout;;
