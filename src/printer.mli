module type S = sig
  type t

  val fprint : string -> Format.formatter -> t -> unit
  val print : string -> t -> unit
  val dprint : t -> unit

  val from_fstring : string -> string -> t
  val from_string : string -> t
end

val day_name : (Date.day -> string) ref
val short_day_name : (Date.day -> string) ref
val month_name : (Date.month -> string) ref
val short_month_name : (Date.month -> string) ref

module DatePrinter : S with type t = Date.t
module TimePrinter : S with type t = Time.t
module CalendarPrinter : S with type t = Calendar.t
