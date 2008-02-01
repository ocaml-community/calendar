(*i $Id: test.ml,v 1.4 2008-02-01 15:51:05 signoles Exp $ i*)

(* Execute all the tests. *)

open Test_timezone;;
open Test_time;;
open Test_ftime;;
open Test_date;;
open Test_calendar;;

(* Display the results *)

let ok = 
  Test_timezone.ok + Test_time.ok + Test_ftime.ok 
  + Test_date.ok + Test_calendar.ok + Test_printer.ok;;

let bug =
  Test_timezone.bug + Test_time.bug + Test_ftime.bug
  + Test_date.bug + Test_calendar.bug + Test_printer.bug;;

Printf.printf "final results:\n";;
Printf.printf "tests ok : %d; tests ko : %d\n" ok bug;;

assert (bug >= 0);;

if bug > 0 then exit 1;;
