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

(*i $Id: fcalendar.mli,v 1.1 2008-02-01 10:48:33 signoles Exp $ i*)

(** Calendar implementation in which seconds are float.

    This module uses floating point arithmetics. 
    Then, egality over times may be erroneous (as egality over [float]).
    You should better use functions [equal] and [compare] defined in this
    module instead of [Pervasives.(=)] and [Pervasives.compare]. *)

include Calendar_sig.S with module Date = Date and module Time = Ftime
