(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2008 Julien Signoles                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License version 2.1 as published by the         *)
(*  Free Software Foundation.                                             *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public Licence version 2.1 for more        *)
(*  details (enclosed in the file LGPL).                                  *)
(*                                                                        *)
(**************************************************************************)

(*i $Id: printer.ml,v 1.17 2008-02-15 07:38:25 signoles Exp $ i*)

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
	 | Date.Thu -> "Thurday"
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

(* [k] should be a power of 10. *)
let print_number fmt pad k n =
  let rec aux k n =
    let fill fmt = function
      | Zero -> Format.pp_print_int fmt 0
      | Blank -> Format.pp_print_char fmt ' '
      | Empty -> ()
    in
    if k = 0 then Format.pp_print_int fmt n
    else begin
      if n < k then fill fmt pad;
      aux (k mod 10) n
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
    let syear = lazy (Lazy.force year mod 100) in
    let hour = lazy (X.hour x) in
    let shour = lazy (short_interval hour) in
    let minute = lazy (X.minute x) in
    let second = lazy (X.second x) in
    let apm = lazy (if Lazy.force hour mod 24 < 12 then "AM" else "PM") in
    let print_char c = Format.pp_print_char fmt c in
    let print_int pad k n = print_number fmt pad k (Lazy.force n) in
    let print_string s = Format.pp_print_string fmt (Lazy.force s) in
    let print_time pad h =
      print_int pad 10 h;
      print_char ':';
      print_int pad 10 minute;
      print_char ':';
      print_int pad 10 second in
    let rec parse_option i pad =
      let parse_char c = 
	begin match c with
	  | '%' -> print_char '%'
	  | 'a' -> print_string sweekday
	  | 'A' -> print_string weekday
	  | 'b' | 'h' -> print_string smonth_name
	  | 'B' -> print_string month_name
	  | 'c' ->
	      print_string sweekday;
	      print_char ' ';
	      print_string smonth_name;
	      print_char ' ';
	      print_int pad 10 day_of_month;
	      print_char ' ';
	      print_time pad hour;
	      print_char ' ';
	      print_int pad 1000 year
	  | 'd' -> print_int pad 10 day_of_month
	  | 'D' -> 
	      print_int pad 10 int_month;
	      print_char '/';
	      print_int pad 10 day_of_month;
	      print_char '/';
	      print_int pad 10 syear
	  | 'e' -> print_int Blank 10 day_of_month
	  | 'H' -> print_int pad 10 hour;
	  | 'i' ->
	      print_int pad 1000 year;
	      print_char '-';
	      print_int pad 10 int_month;
	      print_char '-';
	      print_int pad 10 day_of_month
	  | 'I' -> print_number fmt pad 10 (short_interval hour)
	  | 'j' -> print_int pad 100 day_of_year
	  | 'k' -> print_int Blank 10 hour
	  | 'l' -> print_number fmt Blank 10 (short_interval hour)
	  | 'm' -> print_int pad 10 int_month
	  | 'M' -> print_int pad 10 minute
	  | 'n' -> print_char '\n'
	  | 'p' -> print_string apm
	  | 'r' -> 
	      print_time pad shour;
	      print_char ' ';
	      print_string apm
	  | 'S' -> print_int pad 10 second
	  | 't' -> print_char '\t'
	  | 'T' -> print_time pad hour
	  | 'V' | 'W' -> print_int pad 10 week	     
	  | 'w' -> print_int Empty 1 day_of_week
	  | 'y' -> print_int pad 10 syear
	  | 'Y' -> print_int pad 1000 year
	  | c  -> bad_format ("%" ^ String.make 1 c)
	end;
	parse_format (i + 1)
      in
      assert (i <= len);
      if i = len then bad_format f;
      (* else *)
      match f.[i] with
	| '-' -> 
	    if pad <> Zero then bad_format f;
	    (* else *) parse_option (i + 1) Empty
	| '_' -> 
	    if pad <> Zero then bad_format f;
	    (* else *) parse_option (i + 1) Blank
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
    let year, month, day = ref (-1), ref (-1), ref (-1) in
    let hour, minute, second, pm = ref (-1), ref (-1), ref (-1), ref 0 in
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
    let read_word () = 
      let jn = Str.search_forward !word_regexp s !j in
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
      if n < 1 || n > 53 then not_match fmt (string_of_int n)
    in
    let parse_y () = year := read_number 2 + 1900 in
    let parse_Y () = year := read_number 4 in
    let rec parse_option i = 
      assert (i <= lenf);
      if i = lenf then bad_format f;
      (* else *)
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
	 | 'd' -> parse_d ()
	 | 'D' -> 
	     parse_m ();
	     read_char '/';
	     parse_d ();
	     read_char '/';
	     parse_y ()
	 | 'h' -> parse_b ()
	 | 'H' -> parse_H ()
	 | 'i' ->
	     parse_Y ();
	     read_char '-';
	     parse_m ();
	     read_char '-';
	     parse_d ()
	 | 'I' -> parse_I ()
	 | 'j' ->
	     let n = read_number 3 in
	     if n < 1 || n > 366 then not_match "%j" (string_of_int n)
	 | 'm' -> parse_m ()
	 | 'M' -> parse_M ()
	 | 'n' -> read_char '\n'
	 | 'p' -> parse_p ()
	 | 'r' ->
	     parse_I ();
	     read_char ':';
	     parse_M ();
	     read_char ':';
	     parse_S ();
	     read_char ' ';
	     parse_p ()
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
	     if n < 1 || n > 7 then not_match "%w" (string_of_int n)
	 | 'W' -> parse_V "%W"
	 | 'y' -> parse_y ()
	 | 'Y' -> parse_Y  ()
	 | c  -> bad_format ("%" ^ String.make 1 c));
      parse_format (i + 1)
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
    X.make !year !month !day (!hour + !pm) !minute !second

  let from_string = from_fstring X.default_format

end

let cannot_create_event kind args =
  if List.exists ((=) (-1)) args then
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
       end)

module DatePrinter = Date

module Time = 
  Make(struct
	 include Time
	 let make _ _ _ h m s =
	   cannot_create_event "time" [ h; m; s ];
	   make h m s
	 let default_format = "%T"
	 let day_of_week _ = bad_format "day_of_week"
	 let day_of_month _ = bad_format "day_of_month"
	 let day_of_year _ = bad_format "day_of_year"
	 let week _ = bad_format "week"
	 let month _ = bad_format "month"
	 let int_month _ = bad_format "int_month"
	 let year _ = bad_format "year"
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
	 let day_of_week _ = bad_format "day_of_week"
	 let day_of_month _ = bad_format "day_of_month"
	 let day_of_year _ = bad_format "day_of_year"
	 let week _ = bad_format "week"
	 let month _ = bad_format "month"
	 let int_month _ = bad_format "int_month"
	 let year _ = bad_format "year"
       end)

module Precise_Calendar = 
  Make(struct
	 include Calendar.Precise
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn s
	 let default_format = "%i %T"
       end)

module Calendar = 
  Make(struct
	 include Calendar
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn s
	 let default_format = "%i %T"
       end)

module CalendarPrinter = Calendar

module Precise_Fcalendar = 
  Make(struct
	 include Fcalendar.Precise
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn (Time.Second.from_int s)
	 let second s = Time.Second.to_int (second s)
	 let default_format = "%i %T"
       end)

module Fcalendar = 
  Make(struct
	 include Fcalendar
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn (Time.Second.from_int s)
	 let second s = Time.Second.to_int (second s)
	 let default_format = "%i %T"
       end)
