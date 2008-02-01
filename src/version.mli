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

(*i $Id: version.mli,v 1.7 2008-02-01 15:51:05 signoles Exp $ i*)

(** Information about version of calendar. 
    @since 2.0 *)

val version: string
  (** Name of this version. *)

val date: string
  (** Date of compilation. *)
