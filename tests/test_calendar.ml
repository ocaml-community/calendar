open Calendar;;

let print x = print_endline (to_string x);;
let print_date x = print_endline (Date.to_string x);;
let print_time x = print_endline (Time.to_string x);;

let x = now ();;

print x;;
print_time (to_time x);;

print_date (Date.from_string "2000-2-29");;
print_time (Time.from_string "22-10-11");;
print (from_string "2000-2-29; 22-10-11");;

print_endline "conversion GMT --> local";;
Time_Zone.change Time_Zone.Local;;

print x;;
print_time (to_time x);;

print_date (Date.make 2000 2 29);;
print_time (Time.make 22 10 15);;
print (make 2000 2 29 22 10 15);;
