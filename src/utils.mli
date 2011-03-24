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
	[abs(x-y) < p].  By default, the precision is [1e-3] (that is one
	millisecond if floats represents seconds). *)

  val round: t -> int
    (** Round a float to the nearest integer. *)

end
