  type t = 
    | GMT             (*r Greenwich Meridian Time              *)
    | Local           (*r Locale Time                          *)
    | GMT_Plus of int (*r Another time zone specified from GMT *)

  let tz = ref GMT

  let gap_gmt_local = 
    let t = Unix.time () in
     (Unix.localtime t).Unix.tm_hour - (Unix.gmtime t).Unix.tm_hour

  let value () = !tz

  let change t = tz := t

  let rec gap t1 t2 = 
    match t1, t2 with
      | GMT, GMT 
      | Local, Local           -> 0
      | GMT, Local             -> gap_gmt_local
      | GMT, GMT_Plus x        -> x
      | Local, GMT_Plus x      -> x - gap_gmt_local
      | GMT_Plus x, GMT_Plus y -> y - x
      | _                      -> - gap t2 t1
