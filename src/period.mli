(* A period is the time passed between two events. *)

module type S = sig

  (* Type of a period *)
  type t

  (* The empty period. *)
  val empty : t

  (* Addition of periods. *)
  val add : t -> t -> t

  (* Substraction of periods. *)
  val sub : t -> t -> t

  (* Multiplication of periods. *)
  val mul : t -> t -> t

  (* Division of periods. 
     Raise [Division_by_zero] if the denominator is [empty]. *)
  val div : t -> t -> t

  (* Opposite of a period. *)
  val opp : t -> t

  (* Comparaison function between two periods. *)
  val compare : t -> t -> int
end
