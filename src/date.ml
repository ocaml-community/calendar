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

(*S Introduction.

  This module implements operations on dates representing by their Julian day.
  Most of the algorithms implemented in this module come from the FAQ
  available at~:
  \begin{center}http://www.tondering.dk/claus/calendar.html\end{center} *)

(*S Datatypes. *)

type field = Period.date_field

(* the integer represents the Julian day *)
type -'a date = int constraint 'a = [< field ]

type t = field date

type day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

type month =
    Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

type year = int

(*S Exceptions. *)

exception Out_of_bounds
exception Undefined

(*S Locale coercions.

  These coercions are used in the algorithms and do not respect ISO-8601.
  The exported coercions are defined at the end of the module. *)

(* pre: 0 <= n < 7 *)
external day_of_int : int -> day = "%identity"
external int_of_day : day -> int = "%identity"

(* pre: 0 <= n < 12 *)
external month_of_int : int -> month = "%identity"
external int_of_month : month -> int = "%identity"

(* Dates are comparable *)

let compare = Utils.Int.compare
let equal = Utils.Int.equal
let ( > ) x y = compare x y = 1
let ( >= ) x y = compare x y > -1
let ( < ) x y = compare x y = -1
let ( <= ) x y = compare x y < 1
let ( <?> ) c (ord, x, y) =
  if c = 0 then ord x y else c
let cmp_date (y1, m1, d1) (y2, m2, d2) =
  compare y1 y2 <?> (compare, m1, m2) <?> (compare, d1, d2)


let hash = Utils.Int.hash

(* Constructors. *)

let lt d1 d2 = (cmp_date d1 d2) < 0

(* [date_ok] returns [true] is the date belongs to the Julian period;
   [false] otherwise. *)
let date_ok y m d = lt (-4713, 12, 31) (y, m, d) && lt (y, m, d) (3268, 1, 23)

(* Coerce month to the interval ]-oo; 12].
   Note that the used algorithm of [make] does not require any coercion for
   negative months *)
let coerce_month y m =
  if m < 0 then
    y, m
(*       (* the below commented lines coerce [m] inside the interval [1;12]
	 instead of ]-oo;12]*)
   let diff_y = (m + 1) / 12 - 1 in
    y + diff_y, - 12 * diff_y + m*)
  else
    let pred_m = pred m in
    y + pred_m / 12, pred_m mod 12 + 1

let make y m d =
  let y, m = coerce_month y m in
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
    else
      raise Undefined
  else
    raise Out_of_bounds

let lmake ~year ?(month = 1) ?(day = 1) () = make year month day

let make_year y = make y 1 1
let make_year_month y m = make y m 1

let current_day day gmt_hour =
  let hour = Time_Zone.from_gmt () + gmt_hour in
  (* change the day according to the time zone *)
  if hour < 0 then begin
    assert (hour > - 13);
    day - 1
  end else if hour >= 24 then begin
    assert (hour < 36);
    day + 1
  end else
    day

let jan_1_1970 = 2440588

let from_unixfloat x =
  let d = int_of_float (x /. 86400.) + jan_1_1970 in
  current_day d (Unix.gmtime x).Unix.tm_hour

let from_day_of_year y d = make y 1 d

let today () = from_unixfloat (Unix.time ())

let from_jd n = n
let to_jd d = d

let from_mjd x = x + 2400001
let to_mjd d = d - 2400001

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

let is_julian d = d < 2299161
let is_gregorian d = d >= 2299161

(*S Getters. *)

(* [a] and [e] are auxiliary functions for [day_of_month], [month]
   and [year]. *)
let a d = d + 32044

let e d =
  let c =
    if is_julian d then d + 32082
    else let a = a d in a - (((4 * a + 3) / 146097) * 146097) / 4
  in c - (1461 * ((4 * c + 3) / 1461)) / 4

let day_of_month d =
  let e = e d in
  let m = (5 * e + 2) / 153 in
  e - (153 * m + 2) / 5 + 1

let int_month d = let m = (5 * e d + 2) / 153 in m + 3 - 12 * (m / 10)

let month d = month_of_int (int_month d - 1)

let year d =
  let b, c =
    if is_julian d then 0, d + 32082
    else
      let a = a d in
      let b = (4 * a + 3) / 146097 in
      b, a - (b * 146097) / 4 in
  let d = (4 * c + 3) / 1461 in
  let e = c - (1461 * d) / 4 in
  b * 100 + d - 4800 + ((5 * e + 2) / 153) / 10

let int_day_of_week d = (d + 1) mod 7

let day_of_week d = day_of_int (int_day_of_week d)

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

(* Boolean operation using some getters. *)
let is_leap_day d =
  is_leap_year (year d) && month d = Feb && day_of_month d = 24

let is_valid_date y m d =
  try
    let t = make y m d in
    year t = y && int_month t = m && day_of_month t = d
  with Out_of_bounds | Undefined ->
    false

(*S Period. *)

module Period = struct

  (* Cannot use an [int] : periods on months and years have not a constant
     number of days.
     For example, if we add a "one year" period [p] to the date 2000-3-12,
     [p] corresponds to 366 days (because 2000 is a leap year) and the
     resulting date is 2001-3-12 (yep, one year later). But if we add [p] to
     the date 1999-3-12, [p] corresponds to 365 days and the resulting date is
     2000-3-12 (yep, one year later too). *)
  type +'a period = { m (* month *) : int; d (* day *) : int }
  constraint 'a = [< field ]

  type +'a p = 'a period
  type t = field period

  let empty = { m = 0; d = 0 }

  let make y m d = { m = 12 * y + m; d = d }
  let lmake ?(year = 0) ?(month = 0) ?(day = 0) () = make year month day

  let day n = { empty with d = n }
  let week n = { empty with d = 7 * n }
  let month n = { empty with m = n }
  let year n = { empty with m = 12 * n }

  let add x y = { m = x.m + y.m; d = x.d + y.d }
  let sub x y = { m = x.m - y.m; d = x.d - y.d }
  let opp x = { m = - x.m; d = - x.d }

  (* exactly equivalent to [Pervasives.compare] but more flexible typing *)
  let compare x y =
    let n = compare x.m y.m in
    if n = 0 then compare x.d y.d else n
  let equal x y = compare x y = 0
  let hash = Hashtbl.hash

  exception Not_computable

  let nb_days p = if p.m <> 0 then raise Not_computable else p.d

  let safe_nb_days p = p.d

  let ymd p = p.m / 12, p.m mod 12, p.d

end

(*S Arithmetic operations on dates and periods. *)

let add d p =
  let y,m,day = Period.ymd p in
  make
    (year d         + y)
    (int_month d    + m)
    (day_of_month d + day)

let sub x y = { Period.empty with Period.d = x - y }

let precise_sub y x =
  let rec aux m =
    if x + 31 * m < y then
      aux (m + 1)
    else
      let y' = add x (Period.month m) in
      let d = y - y' in
      if d < 0 then
	let m = m - 1 in
	(* don't use [y'] below: [m] changes *)
	m, d + days_in_month (add x (Period.month m))
      else if d >= days_in_month y' then
	aux (m + 1)
      else
	m, d
  in
  let m, d = aux ((y - x) / 31) in
  { Period.m = m; d = d }

let rem d p = add d (Period.opp p)

let next d = function
  | `Year  -> add d (Period.year 1)
  | `Month -> add d (Period.month 1)
  | `Week  -> add d (Period.day 7)
  | `Day   -> add d (Period.day 1)

let prev d = function
  | `Year  -> add d (Period.year (- 1))
  | `Month -> add d (Period.month (- 1))
  | `Week  -> add d (Period.day (- 7))
  | `Day   -> add d (Period.day (- 1))

(*S Operations on years. *)

let same_calendar y1 y2 =
  let d = y1 - y2 in
  let aux =
    if is_leap_year y1 then true
    else if is_leap_year (y1 - 1) then d mod 6 = 0 || d mod 17 = 0
    else if is_leap_year (y1 - 2) then d mod 11 = 0 || d mod 17 = 0
    else if is_leap_year (y1 - 3) then d mod 11 = 0
    else false
  in d mod 28 = 0 || aux

let days_in_year =
  let days = [| 31; 59; 90; 120; 151; 181; 212; 243; 273; 304; 334; 365 |] in
  fun ?(month=Dec) y ->
    let m = int_of_month month in
    let res = days.(m) in
    if is_leap_year y && m > 0 then res + 1 else res

let weeks_in_year y =
  let first_day = day_of_week (make y 1 1) in
  match first_day with
    | Thu -> 53
    | Wed -> if is_leap_year y then 53 else 52
    | _   -> 52

let week_first_last w y =
  let d = make y 1 4 in (* January 4th must be in the first week (ISO 8601) *)
  let d = d - d mod 7 in
  let b = d + 7 * (w - 1) in
  b, 6 + b

let nth_weekday_of_month y m d n =
  let first = make y (int_of_month m + 1) 1 in
  let gap =
    let diff = int_of_day d - int_day_of_week first in
    if diff >= 0 then diff - 7 else diff
  in
  first + 7 * n + gap

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

(* [easter] implements the algorithm of Oudin (1940) *)
let easter y =
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

let carnaval y = easter y - 48
let mardi_gras y = easter y - 47
let ash y = easter y - 46
let palm y = easter y - 7
let easter_friday y = easter y - 2
let easter_saturday y = easter y - 1
let easter_monday y = easter y + 1
let ascension y = easter y + 39
let withsunday y = easter y + 49
let withmonday y = easter y + 50
let corpus_christi y = easter y + 60

(*S Exported Coercions. *)

let from_unixtm x =
  let d = (* current day at GMT *)
    make (x.Unix.tm_year + 1900) (x.Unix.tm_mon + 1) x.Unix.tm_mday
  in
  current_day d x.Unix.tm_hour

let to_unixtm d =
  { Unix.tm_sec = 0; Unix.tm_min = 0; Unix.tm_hour = 0;
    Unix.tm_mday = day_of_month d;
    Unix.tm_mon = int_month d - 1;
    Unix.tm_year = year d - 1900;
    Unix.tm_wday = int_day_of_week d;
    Unix.tm_yday = day_of_year d - 1;
    Unix.tm_isdst = false }

let to_unixfloat x = float_of_int (x - jan_1_1970) *. 86400.
  (* do not replace [*.] by [*]: the result is bigger than [max_int] ! *)

let to_business d =
  let w = week d in
  let y =
    let y = year d in
    match int_month d with
    | 1 -> let x = y - 1 in if w = weeks_in_year x then x else y
    | 12 -> if w = 1 then y + 1 else y
    | _ -> y
  in
  y, w, day_of_week d

let int_of_day d = let n = int_of_day d in if n = 0 then 7 else n
  (* Used by [from_business] *)

let from_business y w d =
  if w < 1 || w > weeks_in_year y then invalid_arg "from_business: bad week";
  let first =
    try make y 1 1
    with Out_of_bounds | Undefined -> invalid_arg "from_business: bad date"
  in
  let first_day = int_day_of_week first in
  let w = if first_day > 4 then w else w - 1 in
  first + w * 7 + int_of_day d - first_day

(* These coercions redefine those defined at the beginning of the module.
   They respect ISO-8601. *)

let int_of_day = int_of_day

let day_of_int n =
  if n > 0 && n < 7 then day_of_int n
  else if n = 7 then day_of_int 0
  else invalid_arg "Not a day"

let int_of_month m = int_of_month m + 1

let month_of_int n =
  if n > 0 && n < 13 then month_of_int (n - 1) else invalid_arg "Not a month"
