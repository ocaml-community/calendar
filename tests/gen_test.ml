(*i $Id: gen_test.ml,v 1.1 2003-07-07 17:34:56 signoles Exp $ i*)

let ok_ref = ref 0
let ok () = incr ok_ref; "true"
let nb_ok () = !ok_ref

let bug_ref = ref 0
let bug () = incr bug_ref; "!!! FALSE !!!"
let nb_bug () = !bug_ref

let reset () =
  ok_ref := 0;
  bug_ref := 0

let test x s = 
  Printf.printf "%s : %s\n" s (if x then ok () else bug ());;

let test_exn x s =
  Printf.printf "%s : %s\n" 
    s
    (try 
       ignore (Lazy.force x);
       bug ()
     with _ -> ok ());;
