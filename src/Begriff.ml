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

  func_arg_bindung: (int IntMap.t) IntMap.t ref;
  arg_func_bindung: (int IntMap.t) IntMap.t ref;
  atom_bindung: bindung IntMap.t ref
}

let empty = {
  sequence = ref 0;

  zeichen_atom = ref StringMap.empty;
  atom_zeichen = ref IntMap.empty;

  func_arg_bindung = ref IntMap.empty;
  arg_func_bindung = ref IntMap.empty;
  atom_bindung = ref IntMap.empty;
}


let zeichen_of_string = fun x -> x

let string_of_zeichen = fun x -> x


let atom_of_int = fun x -> x

let int_of_atom = fun x -> x


let bindung_of_func_arg = fun func arg -> (0, func, arg)

let func_of_bindung = fun (_,func,_) -> func

let arg_of_bindung = fun (_,_,arg) -> arg

let app_of_bindung = fun (app,_,_) -> app


let add_zeichen = fun zeichen plan ->
  if StringMap.mem zeichen !(plan.zeichen_atom)
  then
    StringMap.find zeichen !(plan.zeichen_atom)
  else
    let next = 1 + (!(plan.sequence)) in
    let _ = print_int next in
    plan.sequence := next;
    let _ = plan.zeichen_atom := StringMap.add zeichen next !(plan.zeichen_atom) in
    let _ = plan.atom_zeichen := IntMap.add next zeichen !(plan.atom_zeichen) in
    next

let find_zeichen = fun atom plan ->
  if IntMap.mem atom !(plan.atom_zeichen)
  then Some (IntMap.find atom !(plan.atom_zeichen))
  else None
