(*
 * Date
 * Copyright (C) 2003 Julien SIGNOLES
 * 
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License version 2, as published by the Free Software Foundation.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * See the GNU Library General Public License version 2 for more details
 *)

(*i $Id: date.ml,v 1.1.1.1 2003-06-26 16:09:30 signoles Exp $ i*)

(*S Introduction.

  This module implements operations on dates representing by their Julian day.
  Most of the algorithms implemented in this module come from the FAQ 
  available at~:
  \begin{center}http://www.tondering.dk/claus/calendar.html\end{center} *)

(*S Datatypes. *)

type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

type month = 
    Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

type t = int (*r representing the Julian day *)

(*S Locale coercions.

  These coercions are used in the algorithms and do not respect ISO-8601.
  The exported coercions are defined at the end of the module. *)

(* pre: 0 <= n < 7 *)
external day_of_int : int -> day = "%identity"
external int_of_day : day -> int = "%identity"

(* pre: 0 <= n < 12 *)
external month_of_int : int -> month = "%identity"
external int_of_month : month -> int = "%identity"

(*S Constructors. *)

let lt (d1 : int * int * int) (d2 : int * int * int) = compare d1 d2 < 0

(* [date_ok] returns [true] is the date belongs to the Julian period. *)
let date_ok y m d = lt (-4713, 12, 31) (y, m, d) && lt (y, m, d) (3268, 1, 23)

let make y m d = 
  if date_ok y m d then
    let a = (14 - m) / 12 in
    let y' = y + 4800 - a in
    let m' = m + 12 * a - 3 in
    if lt (1582, 10, 14) (y, m, d) then
      (* Gregorian calendar *)
      d + (153 * m' + 2) / 5 + y' * 365 + y' / 4 - y' / 100 + y' / 400 - 32045
    else if lt (y, m, d) (1582, 10, 5) then
      (* Julian calendar *)
      d + (153 * m' + 2) / 5 + y' * 365 + y' / 4 - 32083
    else raise (Invalid_argument 
		  "the dates in [1582-10-5; 1582-10-14] do not exist")
  else raise (Invalid_argument "the date is not in [4713 BC-1-1; 3268-1-22]")

let today () = 
  let today = Unix.gmtime (Unix.gettimeofday ()) in
  make (today.Unix.tm_year + 1900) (today.Unix.tm_mon + 1) today.Unix.tm_mday

let from_jd n = n

let to_jd d = d

let from_mjd x = int_of_float (x +. 240000.5)

let to_mjd d = float_of_int d -. 240000.5

(*S Useful operations. *)

let is_leap_year y = 
  if y > 1582 then (* Gregorian calendar *)
    y mod 4 = 0 && (y mod 100 <> 0 || y mod 400 = 0)
  else (* Julian calendar *)
    if y > (- 45) && y <= (- 8) then 
      (* every year divisible by 3 is a leap year between 45 BC and 9 BC *)
      y mod 3 = 0
    else if y <= (- 45) || y >= 8 then y mod 4 = 0
    else (* no leap year between 8 BC and 7 AD *) false

(*S Boolean operations on dates. *)

let in_julian_calendar d = d < 2299161

let in_gregorian_calendar d = d >= 2299161

let compare = (-)

(*S Getters. *)

(* [a] and [e] are auxiliary functions for [day_of_month], [month] 
   and [year]. *)
let a d = d + 32044

let e d = 
  let c =   
    if in_julian_calendar d then d + 32082 
    else let a = a d in a - (((4 * a + 3) / 146097) * 146097) / 4
  in c - (1461 * ((4 * c + 3) / 1461)) / 4

let day_of_month d = 
  let e = e d in
  let m = (5 * e + 2) / 153 in
  e - (153 * m + 2) / 5 + 1

let int_month d = let m = (5 * e d + 2) / 153 in m + 3 - 12 * (m / 10)

let month d = month_of_int (int_month d - 1)

let year d = 
  let a = a d in
  let b, c = 
    if in_julian_calendar d then 0, d + 32082
    else 
      let b = (4 * a + 3) / 146097 in
      b, a - (b * 146097) / 4 in
  let d = (4 * c + 3) / 1461 in
  let e = c - (1461 * d) / 4 in
  b * 100 + d - 4800 + ((5 * e + 2) / 153) / 10

let day_of_week d = day_of_int ((d + 1) mod 7)

let day_of_year d = d - make (year d - 1) 12 31

(* [week] implements an algorithm coming from Stefan Potthast. *)
let week d =
  let d4 = (d + 31741 - (d mod 7)) mod 146097 mod 36524 mod 1461 in
  let l = d4 / 1460 in
  (((d4 - l) mod 365) + l) / 7 + 1

let days_in_month d =
  match month d with
    | Jan | Mar | May | Jul | Aug | Oct | Dec -> 31
    | Apr | Jun | Sep | Nov -> 30
    | Feb -> if is_leap_year (year d) then 29 else 28

let is_leap_day d = is_leap_year d && month d = Feb && day_of_month d = 24

(*S Arithmetic operations on dates. *)

let add d n = d + n

let remove d n = d - n

let next d = d + 1

let previous d = d - 1

(*S Operations on years. *)

let same_calendar y1 y2 =
  let d = y1 - y2 in
  let aux = 
    if is_leap_year y1 then true
    else if is_leap_year (y1 - 1) then d mod 6 = 0 || d mod 17 = 0
    else if is_leap_year (y1 - 2) then d mod 11 = 0 || d mod 17 = 0
    else if is_leap_year (y1 - 3) then d mod 11 = 0 || d mod 22 = 0
    else false
  in d mod 28 = 0 || aux

let days_in_year y = if is_leap_year y then 366 else 365

let weeks_in_year y =
  let first_day = day_of_week (make y 1 1) in
  match first_day with
    | Tue -> if is_leap_year y then 52 else 53
    | Wed -> if is_leap_year y then 53 else 52
    | _   -> 52

let century y = if y mod 100 = 0 then y / 100 else y / 100 + 1

let millenium y = if y mod 1000 = 0 then y / 1000 else y / 1000 + 1

let solar_number y = (y + 8) mod 28 + 1

let indiction y = (y + 2) mod 15 + 1

let golden_number y = y mod 19 + 1

let epact y =
  let julian_epact = (11 * (golden_number y - 1)) mod 30 in
  if y <= 1582 then julian_epact (* Julian calendar *)
  else (* Gregorian calendar *)
    let c = y / 100 + 1 (* century *) in
    (* 1900 belongs to the 20th century for this algorithm *) 
    abs ((julian_epact - (3 * c) / 4 + (8 * c + 5) / 25 + 8) mod 30)

(* [eastern] implements the algorithm of Oudin (1940) *)
let eastern y = 
  let g = y mod 19 in
  let i, j = 
    if y <= 1582 then (* Julian calendar *)
      let i = (19 * g + 15) mod 30 in
      i, (y + y / 4 + i) mod 7
    else (* Gregorian calendar *)
      let c = y / 100 in
      let h = (c - c / 4 - (8 * c + 13) / 25 + 19 * g + 15) mod 30 in
      let i = h - (h / 28) * (1 - (h / 28) * (29 / (h + 1)) * ((21 - g) / 11))
      in i, (y + y / 4 + i + 2 - c + c / 4) mod 7
  in
  let l = i - j in
  let m = 3 + (l + 40) / 44 in
  make y m (l + 28 - 31 * (m / 4))

(*S Exported Coercions. 

  These coercions redefined those defined at the beginning of the module.
  They respect ISO-8601. *)

let to_string d = 
  string_of_int (year d) ^ "-" ^ string_of_int (int_month d) 
  ^ "-" ^ string_of_int (day_of_month d)

let from_string s = 
  match List.map int_of_string (Str.split (Str.regexp "-") s) with
    | [ y; m; d ] -> make (if s.[0] = '-' then - y else y) m d
    | _ -> raise (Invalid_argument (s ^ " is not a date"))

let int_of_day d = let n = int_of_day d in if n = 0 then 7 else n

let day_of_int n = 
  if n > 0 && n < 7 then day_of_int n
  else if n = 7 then day_of_int 0
  else raise (Invalid_argument "Not a day")

let int_of_month m = int_of_month m + 1

let month_of_int n =
  if n > 0 && n < 13 then month_of_int (n - 1) 
  else raise (Invalid_argument "Not a month")
