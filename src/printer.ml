(*
 * Calendar library
 * Copyright (C) 2003 Julien SIGNOLES
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License version 2, as published by the Free Software Foundation.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * See the GNU Library General Public License version 2 for more details
 *)

(*i $Id: printer.ml,v 1.3 2003-09-18 10:29:27 signoles Exp $ i*)

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

let short_day_name day = String.sub (!day_name day) 0 3

let month_name =
  ref (function
	 | Date.Jan -> "January"
	 | Date.Feb -> "February"
	 | Date.Mar -> "Mars"
	 | Date.Apr -> "April"
	 | Date.May -> "May"
	 | Date.Jun -> "June"
	 | Date.Jul -> "July"
	 | Date.Aug -> "August"
	 | Date.Sep -> "September"
	 | Date.Oct -> "October"
	 | Date.Nov -> "November"
	 | Date.Dec -> "December")

let short_month_name month = String.sub (!month_name month) 0 3

type pad =
  | Zero
  | Blank
  | Empty

let rec print_number fmt pad k n =
  let fill fmt = function
    | Zero -> Format.pp_print_int fmt 0
    | Blank -> Format.pp_print_char fmt ' '
    | Empty -> ()
  in
  if k = 0 then Format.pp_print_int fmt n
  else begin
    if n < k then fill fmt pad;
    print_number fmt pad (k mod 10) n
  end

let bad_format () = raise (Invalid_argument "bad format")

let not_match f s = 
  raise (Invalid_argument (s ^ " does not match the format " ^ f))

module Make(X : sig
	      type t
	      val make : int -> int -> int -> int -> int -> int -> t
	      val default_format : string
	      val day_of_week : t -> Date.day
	      val day_of_month : t -> int
	      val day_of_year : t -> int
	      val week : t -> int
	      val month : t -> Date.month
	      val year : t -> int
	    end) =
struct
  type t = X.t

  let fprint f fmt x =
    let weekday, sweekday, day_of_week =
      let dow = X.day_of_week x in
      !day_name dow, short_day_name dow, Date.int_of_day dow (* att : histoire de decalage par rapport au dimanche qq part *) in
    let month_name, smonth_name, int_month =
      let m = X.month x in
      !month_name m, short_month_name m, Date.int_of_month m in
    let day_of_month = X.day_of_month x in
    let day_of_year = X.day_of_year x in
    let week = X.week x in
    let year = X.year x in
    let syear = year mod 100 in
    let len = String.length f in
    let rec parse_option i pad =
      let parse_char c = 
	begin match c with
	  | '%' -> Format.pp_print_char fmt '%'
	  | 'a' -> Format.pp_print_string fmt sweekday
	  | 'A' -> Format.pp_print_string fmt weekday
	  | 'b' | 'h' -> Format.pp_print_string fmt smonth_name
	  | 'B' -> Format.pp_print_string fmt month_name
	  | 'd' -> print_number fmt pad 10 day_of_month
	  | 'D' -> 
	      print_number fmt Zero 10 int_month;
	      Format.pp_print_char fmt '/';
	      print_number fmt Zero 10 day_of_month;
	      Format.pp_print_char fmt '/';
	      print_number fmt Zero 10 syear
	  | 'e' -> print_number fmt Blank 10 day_of_month
	  | 'j' -> print_number fmt pad 100 day_of_year
	  | 'm' -> print_number fmt pad 10 int_month
	  | 'n' -> Format.pp_print_char fmt '\n'
	  | 't' -> Format.pp_print_char fmt '\t'
	  | 'V' | 'W' -> print_number fmt pad 10 week	     
	  | 'w' -> Format.pp_print_int fmt day_of_week
	  | 'y' -> print_number fmt pad 10 syear
	  | 'Y' -> print_number fmt pad 1000 year
	  | _  -> bad_format ()
	end;
	parse_format (i + 1) Zero
      in
      assert (i <= len);
      if i = len then bad_format ();
      (* else *)
      match f.[i] with
	| '-' -> 
	    if pad <> Zero then bad_format ();
	    (* else *) parse_option (i + 1) Empty
	| '_' -> 
	    if pad <> Zero then bad_format ();
	    (* else *) parse_option (i + 1) Blank
	| c  -> parse_char c
    and parse_format i pad =
      assert (i <= len && pad = Zero);
      if i = len then ()
      else match f.[i] with
	| '%' -> parse_option (i + 1) Zero
	| c   -> 
	    Format.pp_print_char fmt c;
	    parse_format (i + 1) Zero
    in parse_format 0 Zero

  let print f = fprint f Format.std_formatter

  let dprint = print X.default_format

  let sprint f d = 
    let buf = Buffer.create 15 in
    let fmt = Format.formatter_of_buffer buf in
    fprint f fmt d;
    Format.pp_print_flush fmt ();
    Buffer.contents buf

  let to_string = sprint X.default_format

  let from_fstring f s = 
    let year, month, day = ref (-1), ref (-1), ref (-1) in
    let hour, minute, second = ref (-1), ref (-1), ref (-1) in
    let j = ref 0 in
    let lenf = String.length f in
    let lens = String.length s in
    let read_char c =
      if !j >= lens || s.[!j] != c then not_match f s;
      incr j 
    in
    let read_number n =
      if !j + n > lens then not_match f s;
      let res = 
	try int_of_string (String.sub s !j n)
	with Failure _ -> not_match f s
      in 
      j := !j + n;
      res
    in
    let rec parse_option i = 
      assert (i <= lenf);
      if i = lenf then bad_format ();
      (* else *)
      (match f.[i] with
	 | '%' | 'n' | 't' as c -> read_char c
	 | 'd' -> day := read_number 2
	 | 'D' -> 
	     month := read_number 2;
	     read_char '/';
	     day := read_number 2;
	     read_char '/';
	     year := read_number 2 + 1900
	 | 'm' -> month := read_number 2
	 | 'y' -> year := read_number 2 + 1900
	 | 'Y' -> year := read_number 4
	 | _  -> bad_format ());
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
    X.make !year !month !day !hour !minute !second

  let from_string = from_fstring X.default_format
end

let cannot_create_event kind args =
  if List.exists ((=) (-1)) args then
    raise (Invalid_argument ("Cannot create the " ^ kind))

module DatePrinter = 
  Make(struct 
	 include Date
	 let make y m d _ _ _ =
	   cannot_create_event "date" [ y; m; d ];
	   make y m d
	 let default_format = "%Y-%m-%d"
       end)

module TimePrinter = 
  Make(struct
	 include Time
	 let make _ _ _ h m s =
	   cannot_create_event "time" [ h; m; s ];
	   make h m s
	 let default_format = ""
	 let day_of_week x = bad_format ()
	 let day_of_month x = bad_format ()
	 let day_of_year x = bad_format ()
	 let week x = bad_format ()
	 let month x = bad_format ()
	 let int_month x = bad_format ()
	 let year x = bad_format ()
       end)

module CalendarPrinter = 
  Make(struct
	 include Calendar
	 let make y m d h mn s =
	   cannot_create_event "calendar" [ y; m; d; h; mn; s ];
	   make y m d h mn s
	 let default_format = ""
       end)
