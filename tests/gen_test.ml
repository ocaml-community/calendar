(*i $Id: gen_test.ml,v 1.2 2008-02-01 10:48:33 signoles Exp $ i*)

let ok_ref = ref 0
let ok () = incr ok_ref
let nb_ok () = !ok_ref

let bug_ref = ref 0
let bug () = incr bug_ref
let nb_bug () = !bug_ref

let reset () =
  ok_ref := 0;
  bug_ref := 0

let test x s = 
  if x then ok () else begin Printf.printf "%s\n" s; bug () end;;

let test_exn x s =
  try
    ignore (Lazy.force x);
    Printf.printf "%s\n" s;
    bug ()
  with _ ->
    ok ();;
