(*
 * Calendar library
 * Copyright (C) 2003 Julien SIGNOLES
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License version 2, as published by the Free Software Foundation.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * See the GNU Library General Public License version 2 for more details
 *)

(*i $Id: version.mli,v 1.1 2004-10-25 15:16:28 signoles Exp $ i*)

(** Information about calendar *)

val version: string
  (** Version of the calendar library which is used *)

val compile_at: Calendar.t
  (** When the calendar library has been compiled *)
