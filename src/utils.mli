(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2008 Julien Signoles                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, either version 2.1 of the Licence, or (at your option)    *)
(*  version 3.                                                            *)
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

(* $Id: utils.mli,v 1.1 2008-02-01 10:48:33 signoles Exp $ *)

(** Some utilities. 
    @since 2.0 *)

(** Interface for comparable and hashable types. 
    Modules implementing this interface can be an argument of [Map.Make],
    [Set.Make] or [Hashtbl.Make].
    @since 2.0 *)
module type Comparable = sig

  type t

  val equal: t -> t -> bool 
    (** Equality over [t]. *)

  val compare: t -> t -> int 
    (** Comparison over [t]. 
	[compare x y] returns [0] iff [equal x y = 0]. If [x] and [y] are not
	equal, it returns a negative integer iff [x] is lesser than [y] and a
	positive integer otherwise. *)

  val hash: t -> int 
    (** A hash function over [t]. *)

end

(** Integer implementation. 
    @since 2.0 *)
module Int: Comparable with type t = int

(** Float implementation. 
    @since 2.0 *)
module Float: sig

  include Comparable with type t = float

  val set_precision: float -> unit
    (** Set the precision of [equal] and [compare] for float. 
	If the precision is [p], then the floats [x] and [y] are equal iff
	[abs(x-y) < p].  By default, the precision is [1e-6]. *)

  val round: t -> int
    (** Round a float to the nearest integer. *)

end
