(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2011 Julien Signoles                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License version 2.1 as published by the         *)
(*  Free Software Foundation, with a special linking exception (usual     *)
(*  for Objective Caml libraries).                                        *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR                           *)
(*                                                                        *)
(*  See the GNU Lesser General Public Licence version 2.1 for more        *)
(*  details (enclosed in the file LGPL).                                  *)
(*                                                                        *)
(*  The special linking exception is detailled in the enclosed file       *)
(*  LICENSE.                                                              *)
(**************************************************************************)

module type S = sig
  type t

  val fprint : string -> Format.formatter -> t -> unit
  val print : string -> t -> unit
  val dprint : t -> unit
  val sprint : string -> t -> string
  val to_string : t -> string

  val from_fstring : string -> string -> t
  val from_string : string -> t
end

let day_name =
  ref (function
	 | Date.Sun -> "Sunday"
	 | Date.Mon -> "Monday"
	 | Date.Tue -> "Tuesday"
	 | Date.Wed -> "Wednesday"
	 | Date.Thu -> "Thursday"
	 | Date.Fri -> "Friday"
	 | Date.Sat -> "Saturday")

let name_of_day d = !day_name d

let short_name_of_day d =
  let d = name_of_day d in
  try String.sub d 0 3 with Invalid_argument _ -> d

let month_name =
  ref (function
	 | Date.Jan -> "January"
	 | Date.Feb -> "February"
	 | Date.Mar -> "March"
	 | Date.Apr -> "April"
	 | Date.May -> "May"
	 | Date.Jun -> "June"
	 | Date.Jul -> "July"
	 | Date.Aug -> "August"
	 | Date.Sep -> "September"
	 | Date.Oct -> "October"
	 | Date.Nov -> "November"
	 | Date.Dec -> "December")

let name_of_month m = !month_name m

let short_name_of_month m =
  let m = name_of_month m in
  try String.sub m 0 3 with Invalid_argument _ -> m

type pad =
  | Zero
  | Blank
  | Empty
  | Uppercase

(* [k] should be a power of 10. *)
let print_number fmt pad k n =
  assert (k > 0);
  let rec aux k n =
    let fill fmt = function
      | Zero -> Format.pp_print_int fmt 0
      | Blank -> Format.pp_print_char fmt ' '
      | Empty | Uppercase -> ()
    in
    if k = 1 then Format.pp_print_int fmt n
    else begin
      if n < k then fill fmt pad;
      aux (k / 10) n
    end
  in
  if n < 0 then Format.pp_print_char fmt '-';
  aux k (abs n)

let bad_format s = raise (Invalid_argument ("bad format: " ^ s))

let not_match f s =
  raise (Invalid_argument (s ^ " does not match the format " ^ f))

let gen_month_of_name f fmt name =
  let rec aux i =
    if i = 0 then not_match fmt name
    else if f (Date.month_of_int i) = name then i
    else aux (i-1)
  in
  aux 12

let month_of_name = gen_month_of_name name_of_month "%b"
let month_of_short_name = gen_month_of_name short_name_of_month "%B"

let gen_day_of_name f fmt name =
  let rec aux i =
    if i = 0 then not_match fmt name
    else if f (Date.day_of_int i) = name then i
    else aux (i-1)
  in
  aux 7

let day_of_name = gen_day_of_name name_of_day "%a"
let day_of_short_name = gen_day_of_name short_name_of_day "%A"

let word_regexp = ref (Str.regexp "[a-zA-Z]+")

let set_word_regexp r = word_regexp := r

(* [Make] creates a printer from a small set of functions. *)
module Make(X : sig
	      type t
	      val make : int -> int -> int -> int -> int -> int -> t
	      val from_business: Date.year -> int -> Date.day -> t
	      val default_format : string
	      val hour : t -> int
	      val minute : t -> int
	      val second : t -> int
	      val day_of_week : t -> Date.day
	      val day_of_month : t -> int
	      val day_of_year : t -> int
	      val week : t -> int
	      val month : t -> Date.month
	      val year : t -> int
	      val century: t -> int
	      val seconds_since_1970: t -> int
	    end) =
struct

  type t = X.t

  let short_interval h =
    let h = Lazy.force h mod 12 in
    if h = 0 then 12 else h

  let fprint f fmt x =
    let len = String.length f in
    let weekday = lazy (name_of_day (X.day_of_week x)) in
    let sweekday = lazy (short_name_of_day (X.day_of_week x)) in
    let day_of_week = lazy (Date.int_of_day (X.day_of_week x)) in
    let month_name = lazy (name_of_month (X.month x)) in
    let smonth_name = lazy (short_name_of_month (X.month x)) in
    let int_month = lazy (Date.int_of_month (X.month x)) in
    let day_of_month = lazy (X.day_of_month x) in
    let day_of_year = lazy (X.day_of_year x) in
    let week = lazy (X.week x) in
    let year = lazy (X.year x) in
    let syear = (* work only if year in (0..9999) *)
      lazy (Lazy.force year mod 100) in
    let century = lazy (X.century x) in
    let hour = lazy (X.hour x) in
    let shour = lazy (short_interval hour) in
    let minute = lazy (X.minute x) in
    let second = lazy (X.second x) in
    let apm = lazy (if Lazy.force hour mod 24 < 12 then "AM" else "PM") in
    let tz = lazy (Time_Zone.from_gmt ()) in
    let seconds_since_1970 = lazy (X.seconds_since_1970 x) in
    let print_char c = Format.pp_print_char fmt c in
    let print_int pad k n = print_number fmt pad k (Lazy.force n) in
    let print_string pad s =
      let pad s = match pad with
	| Uppercase -> String.uppercase s
	| Empty | Zero | Blank -> s
      in
      Format.pp_print_string fmt (pad (Lazy.force s))
    in
    let print_time pad h =
      print_int pad 10 h;
      print_char ':';
      print_int pad 10 minute;
      print_char ':';
      print_int pad 10 second in
    let rec parse_option i pad =
      let parse_char c =
	let jump = ref 0 in
	begin match c with
	| '%' -> print_char '%'
	| 'a' -> print_string pad sweekday
	| 'A' -> print_string pad weekday
	| 'b' | 'h' -> print_string pad smonth_name
	| 'B' -> print_string pad month_name
	| 'c' ->
	    print_string pad sweekday;
	    print_char ' ';
	    print_string pad smonth_name;
	    print_char ' ';
	    print_int pad 10 day_of_month;
	    print_char ' ';
	    print_time pad hour;
	    print_char ' ';
	    print_int pad 1000 year
	| 'C' -> print_int pad 10 century
	| 'd' -> print_int pad 10 day_of_month
	| 'D' ->
	    print_int pad 10 int_month;
	    print_char '/';
	    print_int pad 10 day_of_month;
	    print_char '/';
	    print_int pad 10 syear
	| 'e' -> print_int Blank 10 day_of_month
	| 'F' | 'i' ->
	    print_int pad 1000 year;
	    print_char '-';
	    print_int pad 10 int_month;
	    print_char '-';
	    print_int pad 10 day_of_month
	| 'H' -> print_int pad 10 hour;
	| 'I' -> print_number fmt pad 10 (short_interval hour)
	| 'j' -> print_int pad 100 day_of_year
	| 'k' -> print_int Blank 10 hour
	| 'l' -> print_number fmt Blank 10 (short_interval hour)
	| 'm' -> print_int pad 10 int_month
	| 'M' -> print_int pad 10 minute
	| 'n' -> print_char '\n'
	| 'p' -> print_string pad apm
	| 'P' ->
	    Format.pp_print_string fmt (String.lowercase (Lazy.force apm))
	| 'r' ->
	    print_time pad shour;
	    print_char ' ';
	    print_string pad apm
	| 's' -> print_int pad 1 seconds_since_1970
	| 'R' ->
	    print_int pad 10 hour;
	    print_char ':';
	    print_int pad 10 minute
	| 'S' -> print_int pad 10 second
	| 't' -> print_char '\t'
	| 'T' -> print_time pad hour
	| 'V' | 'W' -> print_int pad 10 week
	| 'w' -> print_int Empty 1 day_of_week
	| 'y' -> print_int pad 10 syear
	| 'Y' -> print_int pad 1000 year
	| 'z' ->
	    if Lazy.force tz >= 0 then print_char '+';
	    print_int pad 10 tz;
	    print_number fmt Zero 10 0
	| ':' ->
	    let idx =
	      try Str.search_forward (Str.regexp "z\\|:z\\|::z") f (i+1)
	      with Not_found -> bad_format f
	    in
	    let next = Str.matched_string f in
	    if idx <> i+1 then bad_format f;
	    if Lazy.force tz >= 0 then print_char '+';
	    print_int pad 10 tz;
	    let print_block () =
	      print_char ':';
	      print_number fmt Zero 10 0
	    in
	    jump := String.length next;
	    (match next with
	     | "z" -> print_block ()
	     | ":z" -> print_block (); print_block ()
	     | "::z" -> ()
	     | _ -> assert false);
	| c  -> bad_format ("%" ^ String.make 1 c)
	end;
	parse_format (i + 1 + !jump)
      in
      assert (i <= len);
      if i = len then bad_format f;
      (* else *)
      let pad p =
	if pad <> Zero then bad_format f;
	(* else *) parse_option (i + 1) p
      in
      match f.[i] with
      | '0' -> pad Zero
      | '-' -> pad Empty
      | '_' -> pad Blank
      | '^' -> pad Uppercase
      | c  -> parse_char c
    and parse_format i =
      assert (i <= len);
      if i = len then ()
      else match f.[i] with
      | '%' -> parse_option (i + 1) Zero
      | c   ->
	  Format.pp_print_char fmt c;
	  parse_format (i + 1)
    in
    parse_format 0;
    Format.pp_print_flush fmt ()

  let print f = fprint f Format.std_formatter

  let dprint = print X.default_format

  let sprint f d =
    let buf = Buffer.create 15 in
    let fmt = Format.formatter_of_buffer buf in
    fprint f fmt d;
    Buffer.contents buf

  let to_string = sprint X.default_format

  let from_fstring f s =
    let delayed_computations = ref [] in
    let day_of_week, week = ref min_int, ref min_int in
    let year, month, day = ref min_int, ref min_int, ref min_int in
    let hour, minute, second, pm =
      ref min_int, ref min_int, ref min_int, ref 0
    in
    let tz = ref 0 in
    let from_biz () =
      if !week = -1 || !year = -1 then
	bad_format (f ^ " (either week or year is not provided)");
      let d = X.from_business !year !week (Date.day_of_int !day_of_week) in
      year := X.year d;
      month := Date.int_of_month (X.month d);
      day := X.day_of_month d
    in
    let j = ref 0 in
    let lenf = String.length f in
    let lens = String.length s in
    let read_char c =
      if !j >= lens || s.[!j] != c then not_match f s;
      incr j
    in
    let read_number n =
      let jn = !j + n in
      if jn > lens then not_match f s;
      let res =
	try int_of_string (String.sub s !j n)
	with Failure _ -> not_match f s
      in
      j := jn;
      res
    in
    let read_word ?(regexp=(!word_regexp)) () =
      let jn =
	try Str.search_forward regexp s !j with Not_found -> not_match f s
      in
      if jn <> !j then not_match f s;
      let w = Str.matched_string s in
      j := jn + String.length w;
      w
    in
    let parse_a () = ignore (day_of_short_name (read_word ())) in
    let parse_b () = month := month_of_short_name (read_word ()) in
    let parse_d () = day := read_number 2 in
    let parse_H () = hour := read_number 2 in
    let parse_I () = hour := read_number 2 in
    let parse_m () = month := read_number 2 in
    let parse_M () = minute := read_number 2 in
    let parse_p () =
      match read_word () with
      | "AM" -> pm := 0
      | "PM" -> pm := 12
      | s -> not_match "%p" ("\"" ^ s ^ "\"")
    in
    let parse_S () = second := read_number 2 in
    let parse_V fmt =
      let n = read_number 2 in
      if n < 1 || n > 53 then not_match fmt (string_of_int n);
      week := n
    in
    let parse_y () = year := read_number 2 + 1900 in
    let parse_Y () = year := read_number 4 in
    let parse_tz () =
      let sign = match read_word ~regexp:(Str.regexp "[\\+-]") () with
	| "+" -> -1
	| "-" -> 1
	| _ -> assert false
      in
      let n = read_number 2 in
      tz := sign * n;
    in
    let rec parse_option i =
      assert (i <= lenf);
      if i = lenf then bad_format f;
      (* else *)
      let jump = ref 0 in
      (match f.[i] with
       | '%' -> read_char '%'
       | 'a' -> parse_a ()
       | 'A' -> ignore (day_of_short_name (read_word ()))
       | 'b' -> parse_b ()
       | 'B' -> month := month_of_name (read_word ())
       | 'c' ->
	   parse_a ();
	   read_char ' ';
	   parse_b ();
	   read_char ' ';
	   parse_d ();
	   read_char ' ';
	   parse_H ();
	   read_char ':';
	   parse_M ();
	   read_char ':';
	   parse_S ();
	   read_char ' ';
	   parse_Y ()
       | 'C' -> ignore (read_number 2)
       | 'd' -> parse_d ()
       | 'D' ->
	   parse_m ();
	   read_char '/';
	   parse_d ();
	   read_char '/';
	   parse_y ()
       | 'F' | 'i' ->
	   parse_Y ();
	   read_char '-';
	   parse_m ();
	   read_char '-';
	   parse_d ()
       | 'h' -> parse_b ()
       | 'H' -> parse_H ()
       | 'I' -> parse_I ()
       | 'j' ->
	   let n = read_number 3 in
	   if n < 1 || n > 366 then not_match "%j" (string_of_int n);
	   delayed_computations :=
	     (fun () ->
		if !year = -1 then bad_format "%j (year not provided)";
		let d = Date.from_day_of_year !year n in
		month := Date.int_of_month (Date.month d);
		day := Date.day_of_month d)
	   :: !delayed_computations
       | 'm' -> parse_m ()
       | 'M' -> parse_M ()
       | 'n' -> read_char '\n'
       | 'p' -> parse_p ()
       | 'P' ->
	   (match read_word () with
	    | "am" -> pm := 0
	    | "pm" -> pm := 12
	    | s -> not_match "%P" ("\"" ^ s ^ "\""))
       | 'r' ->
	   parse_I ();
	   read_char ':';
	   parse_M ();
	   read_char ':';
	   parse_S ();
	   read_char ' ';
	   parse_p ()
       | 'R' ->
	   parse_H ();
	   read_char ':';
	   parse_M ()
       | 'S' -> parse_S ()
       | 't' -> read_char '\t'
       | 'T' ->
	   parse_H ();
	   read_char ':';
	   parse_M ();
	   read_char ':';
	   parse_S ()
       | 'V' -> parse_V "%V"
       | 'w' ->
	   let n = read_number 1 in
	   if n < 1 || n > 7 then not_match "%w" (string_of_int n);
	   day_of_week := n;
	   delayed_computations := from_biz :: !delayed_computations;
       | 'W' -> parse_V "%W"
       | 'y' -> parse_y ()
       | 'Y' -> parse_Y  ()
       | 'z' ->
	   parse_tz ();
	   ignore (read_number 2)
       | ':' ->
	   let rec dot acc i = match f.[i] with
	     | ':' -> if acc = 3 then bad_format "%::::" else dot (acc+1) (i+1)
	     | 'z' -> acc
	     | c -> bad_format ("%:" ^ String.make 1 c)
	   in
	   let nb_dots = dot 1 (i+1) in
	   jump := nb_dots;
	   let next = String.make nb_dots ':' ^ "z" in
	   parse_tz ();
	   let read_block () = read_char ':'; ignore (read_number 2) in
	   (match next with
	    | ":z" -> read_block ()
	    | "::z" -> read_block (); read_block ()
	    | ":::z" -> () (* the only available precision is "hh" like "%z" *)
	    | _ -> assert false)
       | c  -> bad_format ("%" ^ String.make 1 c));
      parse_format (i + 1 + !jump)
    and parse_format i =
      assert (i <= lenf);
      if i = lenf then begin if !j != lens then not_match f s end
      else match f.[i] with
      | '%' -> parse_option (i + 1)
      | c ->
	  read_char c;
	  parse_format (i + 1)
    in
    parse_format 0;
    List.iter (fun f -> f ()) !delayed_computations;
    X.make !year !month !day (!hour + !pm + !tz) !minute !second

  let from_string = from_fstring X.default_format

end

let cannot_create_event kind args =
  if List.exists ((=) min_int) args then
    raise (Invalid_argument ("Cannot create the " ^ kind))

module Date =
  Make(struct
	 include Date
	 let make y m d _ _ _ =
	   cannot_create_event "date" [ y; m; d ];
	   make y m d
	 let default_format = "%i"
	 let hour _ = bad_format "hour"
	 let minute _ = bad_format "minute"
	 let second _ = bad_format "second"
	 let century d = century (year d)
	 let seconds_since_1970 _ = bad_format "seconds_since_1970"
       end)

module DatePrinter = Date

module Time =
  Make(struct
	 include Time
	 let make _ _ _ h m s =
	   cannot_create_event "time" [ h; m; s ];
	   make h m s
	 let default_format = "%T"
	 let from_business _ _ _ = bad_format "from_business"
	 let day_of_week _ = bad_format "day_of_week"
	 let day_of_month _ = bad_format "day_of_month"
	 let day_of_year _ = bad_format "day_of_year"
	 let week _ = bad_format "week"
	 let month _ = bad_format "month"
	 let int_month _ = bad_format "int_month"
	 let year _ = bad_format "year"
	 let century _ = bad_format "century"
	 let seconds_since_1970 _ = bad_format "seconds_since_1970"
       end)

module TimePrinter = Time

module Ftime =
  Make(struct
	 include Ftime
	 let make _ _ _ h m s =
	   cannot_create_event "time" [ h; m; s ];
	   make h m (Second.from_int s)
	 let second x = Second.to_int (second x)
	 let default_format = "%T"
	 let from_business _ _ _ = bad_format "from_business"
	 let day_of_week _ = bad_format "day_of_week"
	 let day_of_month _ = bad_format "day_of_month"
	 let day_of_year _ = bad_format "day_of_year"
	 let week _ = bad_format "week"
	 let month _ = bad_format "month"
	 let int_month _ = bad_format "int_month"
	 let year _ = bad_format "year"
	 let century _ = bad_format "century"
	 let seconds_since_1970 _ = bad_format "seconds_since_1970"
       end)

module Precise_Calendar =
  Make(struct
	 include Calendar.Precise
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn s
	 let from_business y w d = from_date (Date.from_business y w d)
	 let default_format = "%i %T"
	 let century c = Date.century (year c)
	 let seconds_since_1970 c =
	   let p = sub c (make 1970 1 1 0 0 0) in
	   Time.Second.to_int (Time.Period.to_seconds (Period.to_time p))
       end)

module Calendar =
  Make(struct
	 include Calendar
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn s
	 let from_business y w d = from_date (Date.from_business y w d)
	 let default_format = "%i %T"
	 let century c = Date.century (year c)
	 let seconds_since_1970 c =
	   let p = sub c (make 1970 1 1 0 0 0) in
	   Time.Second.to_int (Time.Period.to_seconds (Period.to_time p))
       end)

module CalendarPrinter = Calendar

module Precise_Fcalendar =
  Make(struct
	 include Fcalendar.Precise
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn (Time.Second.from_int s)
	 let from_business y w d = from_date (Date.from_business y w d)
	 let second s = Time.Second.to_int (second s)
	 let default_format = "%i %T"
	 let century c = Date.century (year c)
	 let seconds_since_1970 c =
	   let p = sub c (make 1970 1 1 0 0 0) in
	   Time.Second.to_int (Time.Period.to_seconds (Period.to_time p))
       end)

module Fcalendar =
  Make(struct
	 include Fcalendar
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn (Time.Second.from_int s)
	 let from_business y w d = from_date (Date.from_business y w d)
	 let second s = Time.Second.to_int (second s)
	 let default_format = "%i %T"
	 let century c = Date.century (year c)
	 let seconds_since_1970 c =
	   let p = sub c (make 1970 1 1 0 0 0) in
	   Time.Second.to_int (Time.Period.to_seconds (Period.to_time p))
       end)
