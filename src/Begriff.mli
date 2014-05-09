open Sexplib

type zeichen
type atom
type bindung

type plan

val empty_plan: unit -> plan

val zeichen_of_string: string -> zeichen
val string_of_zeichen: zeichen -> string

val atom_of_int: int -> atom
val int_of_atom: atom -> int

val bindung_of_func_arg: atom -> atom -> bindung
val func_of_bindung: bindung -> atom
val arg_of_bindung: bindung -> atom
val app_of_bindung: bindung -> atom

val next_atom: plan -> atom
val last_atom: plan -> atom

val add_zeichen: zeichen -> plan -> atom
val find_zeichen: atom -> plan -> zeichen option

val add_new_bindung: bindung -> plan -> atom
val find_bindung: atom -> atom -> plan -> bindung option

val add_sexp: Sexp.t -> plan -> atom
val read_sexp: atom -> plan -> Sexp.t
