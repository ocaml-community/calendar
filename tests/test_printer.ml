(*i $Id: test_printer.ml,v 1.1 2003-12-05 15:41:37 signoles Exp $ i*)

Printf.printf "\nTests of Printer:\n\n";;

open Printer;;
include Gen_test;;
reset ();;

open DatePrinter;;
let d = Date.make 2003 1 6;;
test (sprint "%D" d = "01/06/03") "sprint %D";;
test (sprint "the date is %B, the %-dth" d = "the date is January, the 6th")
  "sprint (long sentence)";;
test (from_string "01/06/03" = Date.make 1903 1 6) "from_string";;

open TimePrinter;;
test (to_string (Time.make 12 1 4) = "12:01:04") "to_string (on TimePrinter)";;

open CalendarPrinter;;
test (sprint "%c" (Calendar.make 2003 1 6 12 1 4) = "Mon Jan 06 12:01:04 2003")
  "sprint %c";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
flush stdout;;
