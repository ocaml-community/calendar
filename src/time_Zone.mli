type t = 
  | GMT             (*r Greenwich Meridian Time              *)
  | Local           (*r Locale Time                          *)
  | GMT_Plus of int (*r Another time zone specified from GMT *)

val value : unit -> t

val change : t -> unit

val gap : t -> t -> int
