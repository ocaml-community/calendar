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

(*i $Id: period.mli,v 1.3 2003-07-04 13:59:42 signoles Exp $ i*)

(* A period represents the time passed between two events (a date, a time...). 
   Only an interface defining arithmetic operations on periods is defined here.
   An implementation of this interface depends on the kind of an event. *)

module type S = sig

  (* Type of a period. *)
  type t

  (* The empty period. *)
  val empty : t

  (* Addition of periods. *)
  val add : t -> t -> t

  (* Substraction of periods. *)
  val sub : t -> t -> t

  (* Multiplication of periods. *)
  val mul : t -> t -> t

  (* Division of periods. 
     Raise [Division_by_zero] if the denominator is [empty]. *)
  val div : t -> t -> t

  (* Opposite of a period. *)
  val opp : t -> t

  (* Comparaison function between two periods.
     Same behaviour than [Pervasives.compare]. *)
  val compare : t -> t -> int
end
