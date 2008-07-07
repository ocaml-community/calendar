(*i $Id: test.ml,v 1.6 2008-07-07 09:42:17 signoles Exp $ i*)

(* Display the results *)

let ok = 
  Test_timezone.ok + Test_time.ok + Test_ftime.ok 
  + Test_date.ok + Test_calendar.ok + Test_pcalendar.ok 
  + Test_fcalendar.ok + Test_fpcalendar.ok
  + Test_printer.ok;;

let bug =
  Test_timezone.bug + Test_time.bug + Test_ftime.bug
  + Test_date.bug + Test_calendar.bug + Test_pcalendar.bug 
  + Test_fcalendar.bug + Test_fpcalendar.bug
  + Test_printer.bug;;

Printf.printf "\nFinal results:\n";;
Printf.printf "tests ok : %d; tests ko : %d\n" ok bug;;

assert (bug >= 0);;

if bug > 0 then exit 1;;
