(*i $Id: test_time.ml,v 1.4 2003-07-08 09:46:16 signoles Exp $ i*)

Printf.printf "\nTests of Time:\n\n";;

open Time;;
include Gen_test;;
reset ();;

Time_Zone.change (Time_Zone.GMT_Plus 10);;

test (make 30 60 80 = make 31 1 20) "30-60-80 = 31-1-20";;
test (normalize (make 22 0 0) = (make 22 0 0, 0)) "normalize 22-0-0";;
test (normalize (make 73 0 0) = (make 1 0 0, 3)) "normalize 73-0-0";;
test (normalize (make (-73) 0 0) = (make 23 0 0, -4)) "normalize (-73)-0-0";;
test (add (make 20 0 0) (Period.minut 70) = make 21 10 0) "add 20-0-0 70mn";;
test (next (make 20 3 31) `Minut = make 20 4 31) "next 20-3-31 `Minut";
test (prev (make 20 3 31) `Second = make 20 3 30) "prev 20-3-31 `Second";;
test (sub (make 6 5 4) (make 4 5 6) = Period.make 1 59 58) "sub 6-5-4 4-5-6";;
test (Period.to_string (Period.make 1 59 58) = "1-59-58") "Period.to_string";;
test (convert (make 20 0 0) (Time_Zone.GMT_Plus 2) (Time_Zone.GMT_Plus 4) = 
	make 22 0 0) "convert";;
test (to_gmt (make 20 0 0) = make 10 0 0) "to_gmt";;
test (from_gmt (make 20 0 0) = make 30 0 0) "from_gmt";;
test (midnight () = make 0 0 0) "midnight";;
test (midday () = make 12 0 0) "midday";;
test (hour (make 20 0 0) = 20) "hour";;
test (minut (make 20 10 0) = 10) "minut";;
test (second (make 20 10 5) = 5) "second";;
test (to_seconds (make 1 2 3) = 3723) "to_seconds";;
test (to_minuts (make 1 2 3) = 62.05) "to_minuts";;
test (to_hours (make 1 3 0) = 1.05) "to_hours";;
test (from_seconds 3723 = from_minuts 62.05) "from_seconds; from_minuts";;
test (from_hours 1.05 = make 1 3 0) "from_hours";;
test (is_pm (midnight ())) "is_pm midnight";;
test (is_pm (make 10 0 0)) "is_pm 10-0-0";;
test (is_pm (make 34 0 0)) "is_pm 34-0-0";;
test (not (is_pm (make (- 10) 0 0))) "not (is_pm (- 10) 0 0)";;
test (is_am (midday ())) "is_am midday";;
test (is_am (make 20 0 0)) "is_am 20-0-0";;
test (is_am (make (- 34) 0 0)) "is_am (- 34) 0 0";;
test (not (is_am (make 34 0 0))) "not (is_pm 34 0 0)";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
