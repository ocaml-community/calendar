module C = Configurator.V1

let pervasives = "module Stdlib = Pervasives"

let stdlib = "module Stdlib = Stdlib"

let () =
  C.main ~name:"make_calendar_shims" (fun c ->
      let version = C.ocaml_config_var_exn c "version" in
      let major, minor =
        Scanf.sscanf version "%u.%u" (fun maj min -> (maj, min))
      in
      let r = if (major, minor) >= (4, 8) then stdlib else pervasives in
      let out = open_out "Calendar_shims.ml" in
      output_string out r ; flush out ; close_out out )
