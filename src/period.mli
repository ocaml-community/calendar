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

(** A period represents the time passed between two events (a date, a time...).
  Only an interface defining arithmetic operations on periods is defined here.
  An implementation of this interface depends on the kind of an event (see
  module [Time.Period], [Date.Period] and [Calendar.Period]). *)

type date_field = [ `Year | `Month | `Week | `Day ]

(** Common interface for all periods. *)
module type S = sig

  type +'a period constraint 'a = [< date_field ]
  type t = date_field period
    (** Type of a period. *)

  (** {3 Period is an additive monoid} *)

  val empty : 'a period
    (** The empty period. *)

  val add : 'a period -> 'a period -> 'a period
    (** Addition of periods. *)

  val sub : 'a period -> 'a period -> 'a period
    (** Substraction of periods. *)

  val opp : 'a period -> 'a period
    (** Opposite of a period. *)

  (** {3 Periods are comparable} *)

  val equal: 'a period -> 'b period -> bool
    (** Equality function between two periods.
	@see <Utils.Comparable.html#VALequal> Utils.Comparable.equal
	@since 1.09.0 *)

  val compare : 'a period -> 'b period -> int
    (** Comparison function between two periods.
 	@see <Utils.Comparable.html#VALcompare> Utils.Comparable.compare *)

  val hash: 'a period -> int
    (** Hash function for periods.
	@see <Utils.Comparable.html#VALhash> Utils.Comparable.hash
	@since 2.0 *)

end
