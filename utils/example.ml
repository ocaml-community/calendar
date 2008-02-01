(* $Id: example.ml,v 1.1 2008-02-01 10:48:33 signoles Exp $ *)

(** Add a tag @example *)
class example = object (self)
  inherit Odoc_html.html

  method html_of_example txt = 
    let buf = Buffer.create 97 in
    self#html_of_text buf txt;
    Format.sprintf "<b>Example</b> %s<br>\n" (Buffer.contents buf)

  initializer
    tag_functions <- ("example", self#html_of_example) :: tag_functions
end

let () = 
  Odoc_args.set_doc_generator (Some ((new example) :> Odoc_args.doc_generator))
