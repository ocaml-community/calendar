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

(*i $Id: printer.mli,v 1.2 2003-09-18 07:05:08 signoles Exp $ i*)

module type S = sig
  type t

  val fprint : string -> Format.formatter -> t -> unit
  val print : string -> t -> unit
  val dprint : t -> unit

  val from_fstring : string -> string -> t
  val from_string : string -> t
end

val day_name : (Date.day -> string) ref
val short_day_name : (Date.day -> string) ref
val month_name : (Date.month -> string) ref
val short_month_name : (Date.month -> string) ref

module DatePrinter : S with type t = Date.t
module TimePrinter : S with type t = Time.t
module CalendarPrinter : S with type t = Calendar.t
