(*
 * Calendar library
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

(*i $Id: calendar.mli,v 1.2 2003-07-04 13:59:42 signoles Exp $ i*)

include Date.S

include Time.S

module Period : sig
  include Period.S

  val make : int -> int -> int -> int -> int -> int -> t

  val year : int -> t

  val month : int -> t

  val week : int -> t

  val day : int -> t

  val hour : int -> t

  val minut : int -> t

  val second : int -> t
end

type t

type field = [ Date.field | Time.field ]
val add : t -> Period.t -> t
val sub : t -> t -> Period.t
val rem : t -> Period.t -> t
val next : t -> field -> t
val prev : t -> field -> t

val make : int -> int -> int -> int -> int -> int -> t
val compare : t -> t -> int
val to_string : t -> string
val from_string : string -> t

val from_date : Date.t -> t
val to_date : t -> Date.t

(*i val from_time : Time.t -> t i*)
val to_time : t -> Time.t

val now : unit -> t
