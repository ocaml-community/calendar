(* $Id: example.ml,v 1.2 2008-02-01 15:51:05 signoles Exp $ *)

(** Add a tag @example *)
class example = object (self)
  inherit Odoc_html.html as super

  method html_of_example txt = 
    let buf = Buffer.create 97 in
    self#html_of_text buf txt;
    Format.sprintf "%s<br>\n" (Buffer.contents buf);

  method html_of_examples = function
  | [] -> ""
  | [ txt ] -> Format.sprintf "<b>Example:</b> %s" (self#html_of_example txt)
  | examples ->
      let s = Format.sprintf "<b>Examples:</b><ul>" in
      let s =
	List.fold_left
	  (fun acc txt ->
	     Format.sprintf "%s<li>%s</li>" 
	       acc 
	       (self#html_of_example txt))
	  s
	  examples;
      in
      Format.sprintf "%s</ul>" s

  (** Redefine [html_of_custom] *)
  method html_of_custom b l =
    let examples = ref [] in
    List.iter
      (fun (tag, text) ->
         try
	   if tag = "example" then examples := text :: !examples
	   else assert false
         with
           Not_found ->
             Odoc_info.warning (Odoc_messages.tag_not_handled tag))
      l;
    Buffer.add_string b (self#html_of_examples !examples)

  initializer
    tag_functions <- ("example", self#html_of_example) :: tag_functions
end

let () = 
  Odoc_args.set_doc_generator (Some ((new example) :> Odoc_args.doc_generator))
