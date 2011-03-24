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

module type Comparable = sig
  type t
  val equal: t -> t -> bool
  val compare: t -> t -> int
  val hash: t -> int
end

module Int = struct
  type t = int
  let equal = Pervasives.(=)
  let compare = Pervasives.compare
  let hash = Hashtbl.hash
end

module Float = struct

  type t = float

  let precision = ref 1e-3

  let set_precision f = precision := f

  let equal x y = abs_float (x -. y) < !precision

  let compare x y =
    if equal x y then 0
    else if x < y then -1
    else 1

  let hash = Hashtbl.hash

  let round x =
    let f, i = modf x in
    int_of_float i + (if f < 0.5 then 0 else 1)

end
