(**************************************************************************)
(*                                                                        *)
(*  This file is part of Calendar.                                        *)
(*                                                                        *)
(*  Copyright (C) 2003-2009 Julien Signoles                               *)
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

(*i $Id: calendar_builder.mli,v 1.3 2008-02-05 15:36:21 signoles Exp $ i*)

(** Generic calendar implementation. 
    @since 2.0 *)

(** Implement a calendar from a date implementation and a time implementation.

    This module uses float. Then results may be very unprecise.
    @since 2.0 *) 
module Make(D:Date_sig.S)(T:Time_sig.S) 
  : Calendar_sig.S with module Date = D and module Time = T

(** Similar to {!Make} but results are more precise. The counterpart is that
    some operations are less efficient.
    @since 2.0 *) 
module Make_Precise(D:Date_sig.S)(T:Time_sig.S) 
  : Calendar_sig.S with module Date = D and module Time = T
