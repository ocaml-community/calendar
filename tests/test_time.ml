open Time;;

let print t = print_endline (to_string t);;

let now = now ();;
let midnight = midnight ();;
let midday = midday ();;

print midnight;;
print midday;;
print now;;

print (from_seconds (to_seconds midnight));;
print (from_seconds (to_seconds midday));;
print (from_seconds (to_seconds now));;

print_endline "conversion GMT --> local";;
Time_Zone.change Time_Zone.Local;;

let midnight = Time.midnight ();;
let midday = Time.midday ();;

print midnight;;
print midday;;
print now;;

print (from_seconds (to_seconds midnight));;
print (from_seconds (to_seconds midday));;
print (from_seconds (to_seconds now));;

Printf.printf "%f\n" (to_hours now);;
Printf.printf "%f\n" (to_minuts now);;
Printf.printf "%d\n" (to_seconds now);;


