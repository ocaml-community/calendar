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

(*i $Id: calendar.ml,v 1.5 2003-07-07 21:01:34 signoles Exp $ i*)

(*S Introduction.

  A calendar is representing by its (exact) Julian Day -. 0.5.
  This gap of 0.5 is because the Julian period begins 
  January first, 4713 BC at MIDDAY (and then, this Julian day is 0.0). 
  But, for implementation facilities, the Julian day 0.0 is coded as
  January first, 4713 BC at MIDNIGHT. *)

(*S Datatypes. *)

type t = float

type day = Date.day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

type month = Date.month =
    Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

type field = [ Date.field | Time.field ]

(*S Conversions. *)

let convert x t1 t2 = x +. float_of_int (Time_Zone.gap t1 t2) /. 24.

let to_gmt x = convert x (Time_Zone.current ()) Time_Zone.GMT

let from_gmt x = convert x Time_Zone.GMT (Time_Zone.current ())

(* Local [from_date]: ignore time part and time zone. *)
let from_date x = float_of_int (Date.to_jd x)

(* Local [from_time]: ignore time zone. *)
let from_time x = to_gmt ((float_of_int (Time.to_seconds x)) /. 86400.) -. 0.5

(* Return the integral part of [x] as a date. *)
let to_date x = Date.from_jd (int_of_float (from_gmt x +. 0.5))

(* Return the fractional part of [x] as a time. *)
let to_time x = 
  let t, _ = modf (from_gmt (x +. 0.5)) in 
  let f, i = modf (t *. 86400.) in
  let i = if f < 0.5 then int_of_float i else int_of_float i + 1 in
  Time.from_seconds i

let build d t = 
  to_gmt (float_of_int (Date.to_jd d) +. 
	    float_of_int (Time.to_seconds t) /. 86400.) -. 0.5

(*S Constructors. *)

let is_valid x = x >= 0. && x < 2914695.

let make y m d h mn s = 
  let x = build (Date.make y m d) (Time.make h mn s) in
  if is_valid x then x else raise Date.Out_of_bounds

let now () = 
  let now = Unix.gmtime (Unix.gettimeofday ()) in
  from_gmt (make 
	      (now.Unix.tm_year + 1900) 
	      (now.Unix.tm_mon + 1) 
	      (now.Unix.tm_mday) 
	      (now.Unix.tm_hour) 
	      (now.Unix.tm_min) 
	      (now.Unix.tm_sec))

let from_jd x = to_gmt x

let from_mjd x = to_gmt x +. 2400000.5

(*S Getters. *)

let to_jd x = from_gmt x

let to_mjd x = from_gmt x -. 2400000.5

let days_in_month x = Date.days_in_month (to_date x)

let day_of_week x = Date.day_of_week (to_date x)

let day_of_month x = Date.day_of_month (to_date x)

let day_of_year x = Date.day_of_year (to_date x)

let week x = Date.week (to_date x)

let month x = Date.month (to_date x)

let year x = Date.year (to_date x)

let hour x = Time.hour (to_time x)

let minut x = Time.minut (to_time x)

let second x = Time.second (to_time x)

(*S Boolean operations on dates. *)

let is_leap_day x = Date.is_leap_day (to_date x)

let is_gregorian x = Date.is_gregorian (to_date x)

let is_julian x = Date.is_julian (to_date x)

let is_pm x = Time.is_pm (to_time x)

let is_am x = Time.is_am (to_time x)

(*S Coercions. *)

let from_string s =
  match Str.split (Str.regexp "; ") s with
    | [ d; t ] -> build (Date.from_string d) (Time.from_string t)
    | _ -> raise (Invalid_argument (s ^ " is not a calendar"))

let to_string x = 
  Date.to_string (to_date x) ^ "; " ^ Time.to_string (to_time x)

(*S Periods. *)

module Period = struct
  type t = { d : Date.Period.t; t : Time.Period.t }

  let empty = { d = Date.Period.empty; t = Time.Period.empty }

  let make y m d h mn s = 
    { d = Date.Period.make y m d; t = Time.Period.make h mn s }

  let year x = { empty with d = Date.Period.year x }

  let month x = { empty with d = Date.Period.month x }

  let week x = { empty with d = Date.Period.week x }

  let day x = { empty with d = Date.Period.day x }

  let hour x = { empty with t = Time.Period.hour x }

  let minut x = { empty with t = Time.Period.minut x }

  let second x = { empty with t = Time.Period.second x }

  let add x y = { d = Date.Period.add x.d y.d; t = Time.Period.add x.t y.t }

  let sub x y = { d = Date.Period.sub x.d y.d; t = Time.Period.sub x.t y.t }

  let opp x = { d = Date.Period.opp x.d; t = Time.Period.opp x.t }

  let compare = Pervasives.compare

  let to_date_period x = x.d

  let from_date_period x = { empty with d = x }

  let to_time_period x = x.t

  let from_time_period x = { empty with t = x }
end

(*S Arithmetic operations on calendars and periods. *)

let add x p =
  (* potentiellement bugge sur des periodes de 1 mois
     avec une date franchissant un mois par decalage horaire. *)
  from_date (Date.add (to_date x) p.Period.d) +. 
    from_time (Time.add (to_time x) p.Period.t)

let rem x p = add x (Period.opp p)

let sub x y = 
  Period.add 
    (Period.from_date_period (Date.sub (to_date x) (to_date y)))
    (Period.from_time_period (Time.sub (to_time x) (to_time y)))

let next x f = 
  let t, d = modf x in
  match f with
    | #Date.field as f -> from_date (Date.next (to_date d) f) +. t
    | #Time.field as f -> d +. from_time (Time.next (to_time t) f)
      
let prev x f =
  let t, d = modf x in
  match f with
    | #Date.field as f -> from_date (Date.prev (to_date d) f) +. t
    | #Time.field as f -> d +. from_time (Time.prev (to_time t) f)

(* Exported [from_date]. *)
let from_date x = to_gmt (from_date x) -. 0.5

let egal x y = to_string x = to_string y

let compare x y = 
  if egal x y then 0 
  else if x < y then -1
  else 1
