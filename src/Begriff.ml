open Core.Std

type zeichen = string
type atom = int
type bindung = atom * atom * atom
type atomSet = 
    All
  | Atoms of Int.Set.t

type plan = {
  sequence: int ref;

  zeichen_atom: int String.Map.t ref;
  atom_zeichen: string Int.Map.t ref;

  func_arg_app: ((int Int.Map.t) Int.Map.t) ref;
  arg_func_app: ((int Int.Map.t) Int.Map.t) ref;
  app_bindung: bindung Int.Map.t ref
}

exception Reserved_word of string


let keyword_node = "$$node"

let reserved_words = [keyword_node]

let is_reserved_word = fun word -> List.mem reserved_words word 

let empty_plan = fun () ->
  {
    sequence = ref 0;

    zeichen_atom = ref (Map.add String.Map.empty ~key:"_" ~data:0);
    atom_zeichen = ref (Map.add Int.Map.empty ~key:0 ~data:"_");

    func_arg_app = ref Int.Map.empty;
    arg_func_app = ref Int.Map.empty;
    app_bindung = ref Int.Map.empty;
  }

let intersect_atoms = fun atoms1 atoms2 ->
  match atoms1, atoms2
  with All, All -> All
    | All, _ -> atoms2
    | _, All -> atoms1
    | (Atoms set1), (Atoms set2) -> Atoms (Int.Set.inter set1 set2)

let atoms_size = fun atoms ->
  match atoms
  with All -> -1
    | Atoms set -> Set.length set


let zeichen_of_string = fun x -> x

let string_of_zeichen = fun x -> x


let atom_of_int = fun x -> x

let int_of_atom = fun x -> x


let bindung_of_func_arg = fun func arg -> (0, func, arg)

let func_of_bindung = fun (_,func,_) -> func

let arg_of_bindung = fun (_,_,arg) -> arg

let app_of_bindung = fun (app,_,_) -> app


let next_atom = fun plan ->
  let next = 1 + (!(plan.sequence)) in
  let _ = plan.sequence := next in
  next

let last_atom = fun plan -> !(plan.sequence)

let plan_size = last_atom

let map_ref_add = fun atom value map_ref ->
  let map = !map_ref in
  map_ref := Map.add map ~key:atom ~data:value

let stringmap_ref_add = fun zeichen value map_ref ->
  let map = !map_ref in
  map_ref := Map.add map ~key:zeichen ~data:value


let map_map_ref_add = fun atom1 atom2 value map_ref ->
  let map = !map_ref in
  let secondary_map =
    match Map.find map atom1
    with None -> Int.Map.empty
      | Some map -> map
  in
  map_ref := Map.add map ~key:atom1 ~data:(Map.add secondary_map ~key:atom2 ~data:value)

let map_map_ref_find = fun atom1 atom2 map_ref ->
  let map = !map_ref in
  match Map.find map atom1
  with None -> None
    | Some map -> Map.find map atom2


let add_zeichen = fun ?(create=true) zeichen plan ->
  if is_reserved_word zeichen
  then raise (Reserved_word zeichen)
  else
    let zeichen_map =  !(plan.zeichen_atom) in
    match Map.find zeichen_map zeichen
    with Some atom -> atom
      | None ->
	if create
	then
          let next = next_atom plan in
          let _ = stringmap_ref_add zeichen next plan.zeichen_atom in
          let _ = map_ref_add next zeichen plan.atom_zeichen in
          next
	else
	  raise Not_found

let find_zeichen = fun atom plan ->
  Map.find !(plan.atom_zeichen) atom


let find_bindung_app = fun app plan ->
  Map.find !(plan.app_bindung) app
    
let find_bindung_func_arg = fun func arg plan ->
  match map_map_ref_find func arg (plan.func_arg_app)
  with None -> None
    | Some app -> find_bindung_app app plan

let add_bindung = fun ?(create=true) func arg plan ->
  match find_bindung_func_arg func arg plan
  with Some bindung -> app_of_bindung bindung
    | None -> if create
      then
	let app = next_atom plan in 
        let bindung = (app, func, arg) in
        let _ = map_map_ref_add func arg app (plan.func_arg_app) in
        let _ = map_map_ref_add arg func app (plan.arg_func_app) in
        let _ = map_ref_add app bindung (plan.app_bindung) in
        app
      else
	raise Not_found


let rec of_sexp = fun ?(create=true) sexp plan ->
  match sexp
  with Sexp.Atom zeichen  -> add_zeichen ~create:create (zeichen_of_string zeichen) plan
    | Sexp.List [func] -> of_sexp ~create:create func plan
    | Sexp.List [func; arg] -> 
      let func = of_sexp ~create:create func plan in
      let arg = of_sexp ~create:create arg plan in
      add_bindung func ~create:create arg plan
    | Sexp.List (func::arg::args) -> of_sexp ~create:create (Sexp.List ((Sexp.List [func; arg])::args)) plan
    | Sexp.List [] -> atom_of_int 0

let rec to_sexp = fun atom plan ->
  match Map.find !(plan.atom_zeichen) atom
  with Some zeichen -> Sexp.Atom (string_of_zeichen zeichen)
    | None -> match Map.find !(plan.app_bindung) atom
      with None -> Sexp.List [Sexp.Atom "$$node";Sexp.Atom (string_of_int (int_of_atom atom))]
        | Some bindung ->
          let func = func_of_bindung bindung in
          let arg = arg_of_bindung bindung in
          Sexp.List [to_sexp func plan ;to_sexp arg plan]
	    

let of_string = fun ?(create=true) sexp_string plan ->
  of_sexp ~create:create (Sexp.of_string sexp_string) plan

let to_string = fun atom plan ->
  Sexp.to_string (to_sexp atom plan)     


let with_func = fun atom plan ->
  match Map.find !(plan.func_arg_app) atom
  with Some map -> Atoms (Int.Set.of_list (Map.data map))
    | None -> Atoms (Int.Set.empty)

let with_arg = fun atom plan ->
  match Map.find !(plan.arg_func_app) atom
  with Some map -> Atoms (Int.Set.of_list (Map.data map))
    | None -> Atoms (Int.Set.empty)


