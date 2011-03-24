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

  A calendar is representing by its (exact) Julian Day -. 0.5.
  This gap of 0.5 is because the Julian period begins
  January first, 4713 BC at MIDDAY (and then, this Julian day is 0.0).
  But, for implementation facilities, the Julian day 0.0 is coded as
  January first, 4713 BC at MIDNIGHT. *)

module Make(D: Date_sig.S)(T: Time_sig.S) = struct

  (*S Datatypes. *)

  include Utils.Float

  module Date = D
  module Time = T

  type day = D.day = Sun | Mon | Tue | Wed | Thu | Fri | Sat

  type month = D.month =
      Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

  type year = int

  type second = T.second

  type field = [ D.field | T.field ]

  (*S Conversions. *)

  let convert x t1 t2 = x +. float (Time_Zone.gap t1 t2) /. 24.

  let to_gmt x = convert x (Time_Zone.current ()) Time_Zone.UTC
  let from_gmt x = convert x Time_Zone.UTC (Time_Zone.current ())

  let from_date x = to_gmt (float (D.to_jd x)) -. 0.5

  (* Return the integral part of [x] as a date. *)
  let to_date x = D.from_jd (int_of_float (from_gmt x +. 0.5))

  (* Return the fractional part of [x] as a time. *)
  let to_time x =
    let t, _ = modf (from_gmt x +. 0.5) in
    let i = t *. 86400. in
    assert (i < 86400.);
    T.from_seconds (T.Second.from_float i)

  (*S Constructors. *)

  let is_valid x = x >= 0. && x < 2914695.

  let create d t =
    to_gmt
      (float (D.to_jd d)
       +. T.Second.to_float (T.to_seconds t) /. 86400.) -. 0.5

  let make y m d h mn s =
    let x = create (D.make y m d) (T.make h mn s) in
    if is_valid x then x else raise D.Out_of_bounds

  let lmake ~year ?(month=1) ?(day=1) ?(hour=0) ?(minute=0)
      ?(second=T.Second.from_int 0) () =
    make year month day hour minute second

  let now () =
    let now = Unix.gettimeofday () in
    let gmnow = Unix.gmtime now in
    let frac, _ = modf now in
    from_gmt (make
		(gmnow.Unix.tm_year + 1900)
		(gmnow.Unix.tm_mon + 1)
		gmnow.Unix.tm_mday
		gmnow.Unix.tm_hour
		gmnow.Unix.tm_min
		(T.Second.from_float (float gmnow.Unix.tm_sec +. frac)))

  let from_jd x = to_gmt x
  let from_mjd x = to_gmt x +. 2400000.5

  (*S Getters. *)

  let to_jd x = from_gmt x
  let to_mjd x = from_gmt x -. 2400000.5

  let days_in_month x = D.days_in_month (to_date x)
  let day_of_week x = D.day_of_week (to_date x)
  let day_of_month x = D.day_of_month (to_date x)
  let day_of_year x = D.day_of_year (to_date x)

  let week x = D.week (to_date x)
  let month x = D.month (to_date x)
  let year x = D.year (to_date x)

  let hour x = T.hour (to_time x)
  let minute x = T.minute (to_time x)
  let second x = T.second (to_time x)

  (*S Coercions. *)

  let from_unixtm x =
    make
      (x.Unix.tm_year + 1900) (x.Unix.tm_mon + 1) x.Unix.tm_mday
      x.Unix.tm_hour x.Unix.tm_min (T.Second.from_int x.Unix.tm_sec)

  let to_unixtm x =
    let tm = D.to_unixtm (to_date x)
    and t = to_time x in
    { tm with
	Unix.tm_sec = T.Second.to_int (T.second t);
	Unix.tm_min = T.minute t;
	Unix.tm_hour = T.hour t }

  let jan_1_1970 = 2440587.5
  let from_unixfloat x = to_gmt (x /. 86400. +. jan_1_1970)
  let to_unixfloat x = (from_gmt x -. jan_1_1970) *. 86400.

  (*S Boolean operations on dates. *)

  let is_leap_day x = D.is_leap_day (to_date x)
  let is_gregorian x = D.is_gregorian (to_date x)
  let is_julian x = D.is_julian (to_date x)

  let is_pm x = T.is_pm (to_time x)
  let is_am x = T.is_am (to_time x)

  (*S Period. *)

  module Period = struct

    type +'a p = { d : 'a D.Period.period; t : 'a T.Period.period }
    constraint 'a = [< Period.date_field ]

    type +'a period = 'a p
    type t = Period.date_field period

    let split x =
      let rec aux s =
	if s < 86400. then 0, s else let d, s = aux (s -. 86400.) in d + 1, s
      in
      let s = T.Second.to_float (T.Period.length x.t) in
      let d, s =
	if s >= 0. then aux s
	else let d, s = aux (-. s) in - (d + 1), -. s +. 86400.
      in
      assert (s >= 0. && s < 86400.);
      D.Period.day d, T.Period.second (T.Second.from_float s)

    let normalize x =
      let days, seconds = split x in
      { d = D.Period.add x.d days; t = seconds }

    let empty = { d = D.Period.empty; t = T.Period.empty }

    let make y m d h mn s =
      normalize { d = D.Period.make y m d; t = T.Period.make h mn s }

    let lmake ?(year=0) ?(month=0) ?(day=0) ?(hour=0) ?(minute=0)
	?(second=T.Second.from_int 0) () =
      make year month day hour minute second

    let year x = { empty with d = D.Period.year x }
    let month x = { empty with d = D.Period.month x }
    let week x = { empty with d = D.Period.week x }
    let day x = { empty with d = D.Period.day x }

    let hour x = normalize { empty with t = T.Period.hour x }
    let minute x = normalize { empty with t = T.Period.minute x }
    let second x = normalize { empty with t = T.Period.second x }

    let add x y =
      normalize { d = D.Period.add x.d y.d; t = T.Period.add x.t y.t }

    let sub x y =
      normalize { d = D.Period.sub x.d y.d; t = T.Period.sub x.t y.t }

    let opp x = normalize { d = D.Period.opp x.d; t = T.Period.opp x.t }

    let compare x y =
      let n = D.Period.compare x.d y.d in
      if n = 0 then T.Period.compare x.t y.t else n

    let equal x y = D.Period.equal x.d y.d && T.Period.equal x.t y.t

    let hash = Hashtbl.hash

    let to_date x = x.d
    let from_date x = { empty with d = x }
    let from_time x = { empty with t = x }

    exception Not_computable = D.Period.Not_computable

    let gen_to_time f x = T.Period.add (T.Period.hour (f x.d * 24)) x.t
    let to_time x = gen_to_time D.Period.nb_days x (* eta-expansion required *)
    let safe_to_time x = gen_to_time D.Period.safe_nb_days x

    let ymds x =
      let y, m, d = D.Period.ymd x.d in
      y, m, d, T.Period.to_seconds x.t

  end

  (*S Arithmetic operations on calendars and periods. *)

  let split x =
    let t, d = modf (from_gmt (x +. 0.5)) in
    let t, d = t *. 86400., int_of_float d in
    let t, d = if t < 0. then t +. 86400., d - 1 else t, d in
    assert (t >= 0. && t < 86400.);
    D.from_jd d, T.from_seconds (T.Second.from_float t)

  let unsplit d t =
    to_gmt
      (float (D.to_jd d)
       +. (T.Second.to_float (T.to_seconds t) /. 86400.)) -. 0.5

  let add x p =
    let d, t = split x in
    unsplit (D.add d (p.Period.d :> D.Period.t)) (T.add t p.Period.t)

  let rem x p = add x (Period.opp (p :> Period.t))

  let sub x y =
    let d1, t1 = split x in
    let d2, t2 = split y in
    Period.normalize { Period.d = D.sub d1 d2; Period.t = T.sub t1 t2 }

  let precise_sub x y =
    let d1, t1 = split x in
    let d2, t2 = split y in
    Period.normalize { Period.d = D.precise_sub d1 d2; Period.t = T.sub t1 t2 }

  let next x f =
    let d, t = split x in
    match f with
    | #D.field as f -> unsplit (D.next d f) t
    | #T.field as f -> unsplit d (T.next t f)

  let prev x f =
    let d, t = split x in
    match f with
    | #D.field as f -> unsplit (D.prev d f) t
    | #T.field as f -> unsplit d (T.prev t f)

end

(* ************************************************************************* *)
(* ************************************************************************* *)
(* ************************************************************************* *)

module Make_Precise(D: Date_sig.S)(T: Time_sig.S) = struct

  module Date = D
  module Time = T

  type t = { date: D.t; time: T.t }

  type day = D.day = Sun | Mon | Tue | Wed | Thu | Fri | Sat
  type month = D.month =
      Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

  type year = int

  type second = T.second

  type field = [ D.field | T.field ]

  (*S Comparison *)

  let equal x y = D.equal x.date y.date && T.equal x.time y.time

  let compare x y =
    let n = D.compare x.date y.date in
    if n = 0 then T.compare x.time y.time else n

  let hash = Hashtbl.hash

  (*S Conversions. *)

  let normalize d t =
    let t, days = T.normalize t in
    { date = D.add d (D.Period.day days); time = t }

  let convert x t1 t2 =
    let gap = T.Period.hour (Time_Zone.gap t1 t2) in
    normalize x.date (T.add x.time gap)

  let to_gmt x = convert x (Time_Zone.current ()) Time_Zone.UTC
  let from_gmt x = convert x Time_Zone.UTC (Time_Zone.current ())

  let from_date d = to_gmt { date = d; time = T.make 0 0 (T.Second.from_int 0) }
  let to_date x = (from_gmt x).date
  let to_time x = (from_gmt x).time

  (*S Constructors. *)

  let create d t = to_gmt { date = d; time = t }

  let lower_bound, upper_bound =
    let compute () =
      let midday = T.midday () in
      let low, up =
	create (D.make (-4712) 1 1) midday, create (D.make 3268 1 22) midday
      in
      low, up
    in
    Time_Zone.on compute Time_Zone.UTC ()

  let is_valid x = compare x lower_bound >= 0 && compare x upper_bound <= 0

  let make y m d h mn s =
    let x = create (D.make y m d) (T.make h mn s) in
    if is_valid x then x else raise D.Out_of_bounds

  let lmake ~year ?(month=1) ?(day=1) ?(hour=0) ?(minute=0)
      ?(second=T.Second.from_int 0) () =
    make year month day hour minute second

  let now () =
    let now = Unix.gettimeofday () in
    let gmnow = Unix.gmtime now in
    let frac, _ = modf now in
    from_gmt (make
		(gmnow.Unix.tm_year + 1900)
		(gmnow.Unix.tm_mon + 1)
		gmnow.Unix.tm_mday
		gmnow.Unix.tm_hour
		gmnow.Unix.tm_min
		(T.Second.from_float (float gmnow.Unix.tm_sec +. frac)))

  let from_jd x =
    let frac, intf = modf x in
    to_gmt
      { date = D.from_jd (int_of_float intf);
	time = T.from_seconds (T.Second.from_float (frac *. 86400. +. 43200.)) }

  let from_mjd x = from_jd (x +. 2400000.5)

  (*S Getters. *)

  let to_jd x =
    let x = from_gmt x in
    float (D.to_jd x.date) +. T.Second.to_float (T.to_seconds x.time) /. 86400.
    -. 0.5

  let to_mjd x = to_jd x -. 2400000.5

  let days_in_month x = D.days_in_month (to_date x)
  let day_of_week x = D.day_of_week (to_date x)
  let day_of_month x = D.day_of_month (to_date x)
  let day_of_year x = D.day_of_year (to_date x)

  let week x = D.week (to_date x)
  let month x = D.month (to_date x)
  let year x = D.year (to_date x)

  let hour x = T.hour (to_time x)
  let minute x = T.minute (to_time x)
  let second x = T.second (to_time x)

  (*S Coercions. *)

  let from_unixtm x =
    make
      (x.Unix.tm_year + 1900) (x.Unix.tm_mon + 1) x.Unix.tm_mday
      x.Unix.tm_hour x.Unix.tm_min (T.Second.from_int x.Unix.tm_sec)

  let to_unixtm x =
    let tm = D.to_unixtm (to_date x)
    and t = to_time x in
    { tm with
	Unix.tm_sec = T.Second.to_int (T.second t);
	Unix.tm_min = T.minute t;
	Unix.tm_hour = T.hour t }

  let jan_1_1970 = 2440587.5
  let from_unixfloat x = from_jd (x /. 86400. +. jan_1_1970)
  let to_unixfloat x = (to_jd x -. jan_1_1970) *. 86400.

  (*S Boolean operations on dates. *)

  let is_leap_day x = D.is_leap_day (to_date x)
  let is_gregorian x = D.is_gregorian (to_date x)
  let is_julian x = D.is_julian (to_date x)

  let is_pm x = T.is_pm (to_time x)
  let is_am x = T.is_am (to_time x)

  (*S Period. *)

  module Period = struct

    type +'a p = { d : 'a D.Period.period; t : 'a T.Period.period }
    constraint 'a = [< Period.date_field ]

    type +'a period = 'a p
    type t = Period.date_field period

    let split x =
      let rec aux s =
	if s < 86400. then 0, s else let d, s = aux (s -. 86400.) in d + 1, s
      in
      let s = T.Second.to_float (T.Period.length x.t) in
      let d, s =
	if s >= 0. then aux s
	else let d, s = aux (-. s) in - (d + 1), -. s +. 86400.
      in
      assert (s >= 0. && s < 86400.);
      D.Period.day d, T.Period.second (T.Second.from_float s)

    let normalize x =
      let days, seconds = split x in
      { d = D.Period.add x.d days; t = seconds }

    let empty = { d = D.Period.empty; t = T.Period.empty }

    let make y m d h mn s =
      normalize { d = D.Period.make y m d; t = T.Period.make h mn s }

    let lmake ?(year=0) ?(month=0) ?(day=0) ?(hour=0) ?(minute=0)
	?(second=T.Second.from_int 0) () =
      make year month day hour minute second

    let year x = { empty with d = D.Period.year x }
    let month x = { empty with d = D.Period.month x }
    let week x = { empty with d = D.Period.week x }
    let day x = { empty with d = D.Period.day x }

    let hour x = normalize { empty with t = T.Period.hour x }
    let minute x = normalize { empty with t = T.Period.minute x }
    let second x = normalize { empty with t = T.Period.second x }

    let add x y =
      normalize { d = D.Period.add x.d y.d; t = T.Period.add x.t y.t }

    let sub x y =
      normalize { d = D.Period.sub x.d y.d; t = T.Period.sub x.t y.t }

    let opp x = normalize { d = D.Period.opp x.d; t = T.Period.opp x.t }

    let compare x y =
      let n = D.Period.compare x.d y.d in
      if n = 0 then T.Period.compare x.t y.t else n

    let equal x y = D.Period.equal x.d y.d && T.Period.equal x.t y.t

    let hash = Hashtbl.hash

    let to_date x = x.d
    let from_date x = { empty with d = x }
    let from_time x = { empty with t = x }

    exception Not_computable = D.Period.Not_computable

    let gen_to_time f x = T.Period.add (T.Period.hour (f x.d * 24)) x.t
    let to_time x = gen_to_time D.Period.nb_days x (* eta-expansion required *)
    let safe_to_time x = gen_to_time D.Period.safe_nb_days x

    let ymds x =
      let y, m, d = D.Period.ymd x.d in
      y, m, d, T.Period.to_seconds x.t

  end

  (*S Arithmetic operations on calendars and periods. *)

  let add x p =
    normalize
      (D.add x.date (p.Period.d :> D.Period.t)) (T.add x.time p.Period.t)

  let rem x p = add x (Period.opp (p :> Period.t))

  let sub x y =
    Period.normalize
      { Period.d = D.sub x.date y.date; Period.t = T.sub x.time y.time }

  let precise_sub x y =
    Period.normalize
      { Period.d = D.precise_sub x.date y.date;
	Period.t = T.sub x.time y.time }

  let next x = function
    | #D.field as f -> normalize (D.next x.date f) x.time
    | #T.field as f -> normalize x.date (T.next x.time f)

  let prev x = function
    | #D.field as f -> normalize (D.prev x.date f) x.time
    | #T.field as f -> normalize x.date (T.prev x.time f)

end

