Printf.printf "\nTests of Date:\n\n";;

let ok, nb_ok =
  let ok = ref 0 in
  (fun () -> incr ok; "true"),
  fun () -> !ok;;

let bug, nb_bug =
  let bug = ref 0 in
  (fun () -> incr bug; "!!! FALSE !!!"),
  fun () -> !bug;;

let test x s = 
  Printf.printf "%s : %s\n" s (if x then ok () else bug ());;

let test_exn x s =
  Printf.printf "%s : %s\n" 
    s
    (try 
       ignore (Lazy.force x);
       bug ()
     with _ -> ok ());;

open Date;;

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

Printf.printf "\ntests ok : %d; tests ko : %d\n" (nb_ok ()) (nb_bug ());;

(*
let d = make 2003 6 26;;

let print d = print_endline (to_string d);;

print d;;
print_newline ();;
print (add d (Period.year 2));;
print (add d (Period.month 2));;
print (add d (Period.day 2));;
print_newline ();;
print (next d `Year);;
print (next d `Month);;
print (next d `Day);;
print_newline ();;
print (prev d `Year);;
print (prev d `Month);;
print (prev d `Day);;

print_newline ();;
let d2 = make 2008 5 24;;
print (rem d2 (sub d2 d));;
print_newline ();;
try print (next (make 1582 9 10) `Month)
with Undefined -> print_endline "Undefined";;
print (add (make 2003 12 31) (Period.month 2))
*)
