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

(*i $Id: printer.ml,v 1.2 2003-09-18 07:05:08 signoles Exp $ i*)

module type S = sig
  type t

  val fprint : string -> Format.formatter -> t -> unit
  val print : string -> t -> unit
  val dprint : t -> unit

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

let short_day_name =
  ref (function
	 | Date.Sun -> "Sun"
	 | Date.Mon -> "Mon"
	 | Date.Tue -> "Tue"
	 | Date.Wed -> "Wed"
	 | Date.Thu -> "Thu"
	 | Date.Fri -> "Fri"
	 | Date.Sat -> "Sat")

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

let short_month_name =
  ref (function
	 | Date.Jan -> "Jan"
	 | Date.Feb -> "Feb"
	 | Date.Mar -> "Mar"
	 | Date.Apr -> "Apr"
	 | Date.May -> "May"
	 | Date.Jun -> "Jun"
	 | Date.Jul -> "Jul"
	 | Date.Aug -> "Aug"
	 | Date.Sep -> "Sep"
	 | Date.Oct -> "Oct"
	 | Date.Nov -> "Nov"
	 | Date.Dec -> "Dec")

let bad_format () = raise (Invalid_argument "bad format")

module Make(X : sig
	      type t
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

  let not_match f s = 
    raise (Invalid_argument (s ^ " does not match the date format " ^ f))

  let fprint f fmt x =
    let weekday, sweekday, day_of_week =
      let dow = X.day_of_week x in
      !day_name dow, !short_day_name dow, Date.int_of_day dow (* att : histoire de decalage par rapport au dimanche qq part *) in
    let month_name, smonth_name, int_month =
      let m = X.month x in
      !month_name m, !short_month_name m, Date.int_of_month m in
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

  let from_fstring f s = assert false

  let from_string = from_fstring X.default_format
end

module DatePrinter = Make(struct 
			    include Date
			    let default_format = "%Y-%m-%d"
			  end)

module TimePrinter = Make(struct
			    include Time
			    let default_format = ""
			    let day_of_week x = bad_format ()
			    let day_of_month x = bad_format ()
			    let day_of_year x = bad_format ()
			    let week x = bad_format ()
			    let month x = bad_format ()
			    let int_month x = bad_format ()
			    let year x = bad_format ()
			  end)

module CalendarPrinter = Make(struct
				include Calendar
				let default_format = ""
			      end)
