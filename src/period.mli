(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2008 Julien Signoles                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License version 2.1 as published by the         *)
(*  Free Software Foundation.                                             *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public Licence version 2.1 for more        *)
(*  details (enclosed in the file LGPL).                                  *)
(*                                                                        *)
(**************************************************************************)

(*i $Id: period.mli,v 1.16 2008-02-05 15:36:21 signoles Exp $ i*)

(** A period represents the time passed between two events (a date, a time...).
  Only an interface defining arithmetic operations on periods is defined here.
  An implementation of this interface depends on the kind of an event (see
  module [Time.Period], [Date.Period] and [Calendar.Period]). *)

(** Common interface for all periods. *)
module type S = sig

  type t
    (** Type of a period. *)

  (** {3 Period is an additive monoid} *)

  val empty : t
    (** The empty period. *)

  val add : t -> t -> t
    (** Addition of periods. *)

  val sub : t -> t -> t
    (** Substraction of periods. *)

  val opp : t -> t
    (** Opposite of a period. *)

  (** {3 Periods are comparable} *)

  val equal: t -> t -> bool
    (** Equality function between two periods.
	@see <Utils.Comparable.html#VALequal> Utils.Comparable.equal
	@since 1.09.0 *)

  val compare : t -> t -> int
    (** Comparison function between two periods.
 	@see <Utils.Comparable.html#VALcompare> Utils.Comparable.compare *)

  val hash: t -> int
    (** Hash function for periods.
	@see <Utils.Comparable.html#VALhash> Utils.Comparable.hash 
	@since 2.0 *)

end
