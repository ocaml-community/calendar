Printf.printf "\nTests of Time_Zone :\n\n";;

open Time_Zone;;

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
     with Invalid_argument _ -> ok ());;

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

Printf.printf "\ntests ok : %d; tests ko : %d\n" (nb_ok ()) (nb_bug ());;
