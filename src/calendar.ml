type t = float

type field = [ Date.field | Time.field ]
    
include (Date : sig 
	   include Date.S
	   val make : int -> int -> int -> Date.t
	   val compare : Date.t -> Date.t -> int
	 end)

include (Time : sig
	   include Time.S
	   val make : int -> int -> int -> Time.t
	   val compare : Time.t -> Time.t -> int
	 end)

let from_date x = float_of_int (to_jd x)

let to_date x = from_jd (int_of_float x)

(* return a number in [0 .. 1] *)
let from_time x = float_of_int (to_seconds ((*from_gmt*) x)) /. 86400.

let to_time x = 
  let t, _ = modf x in 
  let f, i = modf (t *. 86400.) in
  Printf.printf "%f\n" f;
  (*from_gmt*) (from_seconds (int_of_float i))

let build d t = from_date d +. from_time t

let make y m d h mn s = 
  build (Date.make y m d) (Time.make h mn s)

let now () = build (Date.today ()) (Time.now ())

let next x f = 
  let t, d = modf x in
  match f with
    | #Date.field as f -> from_date (Date.next (to_date d) f) +. t
    | #Time.field as f -> d +. from_time (Time.next (to_time t) f)
      
let prev x f = next (-. x) f

module Period = struct
  type t = int
  let make _ = assert false
  let year _ = assert false
  let month _ = assert false
  let week _ = assert false
  let day _ = assert false
  let hour h = h * 3600
  let minut m = m * 60
  let second s = s
  let empty = 0
  let add = (+)
  let sub = (-)
  let mul = ( * )
  let div = (/)
  let opp x = - x
  let compare = (-)
end

let rem _ = assert false
let sub _ = assert false
let add _ = assert false

let from_string s =
  match Str.split (Str.regexp "; ") s with
    | [ d; t ] -> build (Date.from_string d) (Time.from_string t)
    | _ -> raise (Invalid_argument (s ^ " is not a calendar"))

let to_string x = 
  Date.to_string (to_date x) ^ "; " ^ Time.to_string (to_time x)

let compare = Pervasives.compare
