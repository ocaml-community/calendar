open Date;;

let d = make 2003 6 26;;

let print d = print_endline (to_string d);;

print d;;
print_newline ();;
print (add d (Period.year 2));;
print (add d (Period.month 2));;
print (add d (Period.day 2));;
print_newline ();;
print (next d Year);;
print (next d Month);;
print (next d Day);;
print_newline ();;
print (prev d Year);;
print (prev d Month);;
print (prev d Day);;

print_newline ();;
let d2 = make 2008 5 24;;
print (rem d2 (sub d2 d));;
print_newline ();;
try print (next (make 1582 9 10) Month)
with Undefined -> print_endline "Undefined";;
print (add (make 2003 12 31) (Period.month 2))
