include Date.S

include Time.S

module Period : sig
  include Period.S

  val make : int -> int -> int -> int -> int -> int -> t

  val year : int -> t

  val month : int -> t

  val week : int -> t

  val day : int -> t

  val hour : int -> t

  val minut : int -> t

  val second : int -> t
end

type t

type field = [ Date.field | Time.field ]
val add : t -> Period.t -> t
val sub : t -> t -> Period.t
val rem : t -> Period.t -> t
val next : t -> field -> t
val prev : t -> field -> t

val make : int -> int -> int -> int -> int -> int -> t
val compare : t -> t -> int
val to_string : t -> string
val from_string : string -> t

val from_date : Date.t -> t
val to_date : t -> Date.t

(*val from_time : Time.t -> t*)
val to_time : t -> Time.t

val now : unit -> t
