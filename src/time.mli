(*
 * Time
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

(*i $Id: time.mli,v 1.2 2003-07-04 12:15:52 signoles Exp $ i*)

type t

type field = [ `Hour | `Minut | `Second ]

module Period : sig
  include Period.S

  val make : int -> int -> int -> t

  val hour : int -> t

  val minut : int -> t

  val second : int -> t
end

(* hour-minuts-seconds *)
val make : int -> int -> int -> t

(* UTC/GMT time *)
val now : unit -> t

val normalize : t -> t * int

val compare : t -> t -> int

val add : t -> Period.t -> t

val sub : t -> t -> Period.t

val rem : t -> Period.t -> t

val next : t -> field -> t

val prev : t -> field -> t

val to_string : t -> string

val from_string : string -> t

module type S = sig

(* [convert t tz]. [t] est une heure exprimee dans [Time_Zone.value ()].
   Retourne l'heure de [t] dans [tz]. *)
val convert : t -> Time_Zone.t -> t

val to_gmt : t -> t

val from_gmt : t -> t

(* midnight et midday donne 0h et 12h dans la zone courante *)
val midnight : unit -> t

val midday : unit -> t

val hour : t -> int

val minut : t -> int

val second : t -> int

val to_seconds : t -> int

val to_minuts : t -> float

val to_hours : t -> float

val from_seconds : int -> t

val from_minuts : float -> t

val from_hours : float -> t

val is_pm : t -> bool

val is_am : t -> bool
end

include S
