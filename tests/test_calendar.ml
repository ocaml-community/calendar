open Calendar;;

let print x = print_endline (to_string x);;
let print_date x = print_endline (Date.to_string x);;
let print_time x = print_endline (Time.to_string x);;

let x = now ();;

print_endline "======";
print x;;

print_endline "======";
print (from_string "2000-2-29; 22-10-11");;
print_endline "======";
print (make 2000 2 29 22 10 15);;

print_endline "\nconversion GMT --> local\n";;
Time_Zone.change Time_Zone.Local;;

print x;;

print_endline "======";
print (from_string "2000-2-29; 22-10-11");;
print_endline "======";
print (make 2000 2 29 22 10 15);;
