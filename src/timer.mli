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

(*i $Id: timer.mli,v 1.1 2003-07-04 07:11:07 signoles Exp $ i*)

type field = Hour | Minut | Second

type t

val create : unit -> t

val reset : t -> unit



val now : unit -> t

(* hour-minuts-seconds *)
val make : int -> int -> float -> t

val compare : t -> t -> int

val add : t -> t -> t

val remove : t -> t -> t

val mul : t -> t -> t

val div : t -> t -> t

(* +1 second *)
val next : t -> field -> t

(* -1 second *)
val previous : t -> field -> t

val to_float : t -> float

val from_float : float -> t

val to_string : t -> string

val from_string : string -> t
