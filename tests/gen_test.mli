(*i $Id: gen_test.mli,v 1.1 2003-07-09 07:17:08 signoles Exp $ i*)

(* Generic functions used in the tests. *)

val reset : unit -> unit

val nb_ok : unit -> int

val nb_bug : unit -> int

val test : bool -> string -> unit

val test_exn : 'a Lazy.t -> string -> unit
