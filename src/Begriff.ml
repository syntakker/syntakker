open Sexplib

module IntMap = Map.Make(struct type t = int let compare = compare end)
module StringMap = Map.Make(struct type t = string let compare = compare end)

type zeichen = string
type atom = int
type bindung = atom * atom * atom

type blubber = int StringMap.t
type blubber2 = string IntMap.t


type plan = {
  sequence: int ref;

  zeichen_atom: int StringMap.t ref;
  atom_zeichen: string IntMap.t ref;

  func_arg_app: ((int IntMap.t) IntMap.t) ref;
  arg_func_app: ((int IntMap.t) IntMap.t) ref;
  app_bindung: bindung IntMap.t ref
}

let empty_plan = fun () ->
  {
    sequence = ref 0;

    zeichen_atom = ref StringMap.empty;
    atom_zeichen = ref IntMap.empty;

    func_arg_app = ref IntMap.empty;
    arg_func_app = ref IntMap.empty;
    app_bindung = ref IntMap.empty;
  }


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

let map_find = fun atom map ->
  if IntMap.mem atom map
  then Some (IntMap.find atom map)
  else None

let map_ref_add = fun atom value map_ref ->
  let map = !map_ref in
  map_ref := IntMap.add atom value map

let stringmap_ref_add = fun zeichen value map_ref ->
  let map = !map_ref in
  map_ref := StringMap.add zeichen value map


let map_map_ref_add = fun atom1 atom2 value map_ref ->
  let map = !map_ref in
  let secondary_map =
    if IntMap.mem atom1 map
    then IntMap.find atom1 map
    else IntMap.empty
  in
  map_ref := IntMap.add atom1 (IntMap.add atom2 value secondary_map) map

let map_map_ref_find = fun atom1 atom2 map_ref ->
  let map = !map_ref in
  if IntMap.mem atom1 map
  then map_find atom2 (IntMap.find atom1 map)
  else None


let add_zeichen = fun zeichen plan ->
  let zeichen_map =  !(plan.zeichen_atom) in 
  if StringMap.mem zeichen zeichen_map
  then
    StringMap.find zeichen zeichen_map
  else
    let next = next_atom plan in
    let _ = stringmap_ref_add zeichen next plan.zeichen_atom in
    let _ = map_ref_add next zeichen plan.atom_zeichen in
    next

let find_zeichen = fun atom plan ->
  map_find atom !(plan.atom_zeichen)


let add_new_bindung = fun bindung plan ->
  if not (app_of_bindung bindung = 0)
  then raise (Invalid_argument "app in new bindung must be 0")
  else
    let func = func_of_bindung bindung in
    let arg = arg_of_bindung bindung in
    match (map_map_ref_find func arg plan.func_arg_app) with
        Some app -> app
      | None -> let app = next_atom plan in 
                let bindung = (app, func, arg) in
                let _ = map_map_ref_add func arg app (plan.func_arg_app) in
                let _ = map_map_ref_add arg func app (plan.arg_func_app) in
                let _ = map_ref_add app bindung (plan.app_bindung) in
                app
        
let find_bindung = fun func arg plan ->
  match map_map_ref_find func arg (plan.func_arg_app) with
      None -> None
    | Some app -> map_find app !(plan.app_bindung)


let rec add_sexp = fun sexp plan ->
  match sexp with
      Sexp.Atom zeichen -> add_zeichen (zeichen_of_string zeichen) plan
    | Sexp.List [func] -> add_sexp func plan
    | Sexp.List [func; arg] -> 
      let func = add_sexp func plan in
      let arg = add_sexp arg plan in
      add_new_bindung (bindung_of_func_arg func arg) plan
    | Sexp.List (func::arg::args) -> add_sexp (Sexp.List ((Sexp.List [func; arg])::args)) plan
    | Sexp.List [] -> atom_of_int 0
