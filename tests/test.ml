(*i $Id: test.ml,v 1.2 2004-10-25 14:12:51 signoles Exp $ i*)

(* Execute all the tests. *)

open Test_timezone;;
open Test_time;;
open Test_date;;
open Test_calendar;;

(* Display the results *)

let ok = 
  Test_timezone.ok + Test_time.ok + Test_date.ok + Test_calendar.ok + 
  Test_printer.ok;;

let bug =
  Test_timezone.bug + Test_time.bug +Test_date.bug + Test_calendar.bug +
  Test_printer.bug;;

Printf.printf "\nfinal results:";;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;

assert (bug >= 0);;

if bug > 0 then exit 1;;
