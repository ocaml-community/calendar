(*i $Id: test.ml,v 1.1 2003-07-07 17:34:56 signoles Exp $ i*)

(* Execute all the tests. *)

open Test_timezone;;
open Test_time;;
open Test_date;;
open Test_calendar;;

Printf.printf "\nfinal results:";;
Printf.printf "\ntests ok : %d; tests ko : %d\n" 
  (Test_timezone.ok + Test_time.ok +Test_date.ok + Test_calendar.ok) 
  (Test_timezone.bug + Test_time.bug +Test_date.bug + Test_calendar.bug) 

