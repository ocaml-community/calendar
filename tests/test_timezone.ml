(*i $Id: test_timezone.ml,v 1.4 2003-07-07 17:34:56 signoles Exp $ i*)

Printf.printf "\nTests of Time_Zone:\n\n";;

open Time_Zone;;
include Gen_test;;
reset ();;

test (current () = GMT) "current () = GMT";;
change Local;;
test (current () = Local) "current () = Local";;
test (gap GMT (GMT_Plus (-5)) = -5) "gap GMT (GMT_Plus (-5)) = -5";;
let g6 = GMT_Plus 6;;
test 
  (gap g6 Local = gap g6 GMT + gap GMT Local)
  "gap g6 Local = gap g6 GMT + gap GMT Local";;
test_exn (lazy (change (GMT_Plus 13))) "change 13";;
test_exn (lazy (change (GMT_Plus (-15)))) "change (-15)";;
change (GMT_Plus 4);;
test (from_gmt () = 4) "from_gmt () = 4";;
test (to_gmt () = -4) "to_gmt () = -4";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
