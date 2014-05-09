open Kaputt.Abbreviations
open Test
open Sexplib
;;

Test.add_simple_test ~title:"write and read a zeichen" (fun () ->
  let plan = Begriff.empty_plan () in
  let zeichen = Begriff.zeichen_of_string "test" in
  let _ = Begriff.add_zeichen zeichen plan in
  let found = Begriff.find_zeichen (Begriff.atom_of_int 1) plan in
  Assert.is_some ~msg:"begriff not found" found;
  Assert.equal ~msg:"wrong name for begriff" (Some (Begriff.zeichen_of_string "test")) found
) 
;;

Test.add_simple_test ~title:"generate next atom" (fun () ->
  let plan = Begriff.empty_plan () in
  let atom1 = Begriff.next_atom plan in
  let atom2 = Begriff.next_atom plan in
  Assert.equal ~msg:"wrong number for atom 1" (Begriff.atom_of_int 1) atom1;
  Assert.equal ~msg:"wrong number for atom 2" (Begriff.atom_of_int 2) atom2
)
;;

Test.add_simple_test ~title:"generate next atom on different plans" (fun () ->
  let plan1 = Begriff.empty_plan () in
  let atom1 = Begriff.next_atom plan1 in
  let plan2 = Begriff.empty_plan () in
  let atom2 = Begriff.next_atom plan2 in
  Assert.equal ~msg:"wrong number for atom 1" (Begriff.atom_of_int 1) atom1;
  Assert.equal ~msg:"wrong number for atom 2" (Begriff.atom_of_int 1) atom2
)
;;

Test.add_simple_test ~title:"write and read a bindung" (fun () ->
  let plan = Begriff.empty_plan () in
  let func = Begriff.next_atom plan in
  let arg = Begriff.next_atom plan in
  Assert.equal ~msg:"wrong number for atom 1" (Begriff.atom_of_int 1) func;
  Assert.equal ~msg:"wrong number for atom 2" (Begriff.atom_of_int 2) arg;
  let app = Begriff.add_new_bindung (Begriff.bindung_of_func_arg func arg) plan in
  Assert.equal ~msg:"wrong number for bindung" (Begriff.atom_of_int 3) app;
  let found = Begriff.find_bindung func arg plan in
  Assert.is_some ~msg:"no bindung found" found;
  match found with
      None -> Assert.fail_msg "bindung not found"
    | Some bindung ->
      let app_found = Begriff.app_of_bindung bindung in
      let func_found = Begriff.func_of_bindung bindung in
      let arg_found = Begriff.arg_of_bindung bindung in
      Assert.equal ~msg:"wrong node for function" (Begriff.atom_of_int 1) func_found;
      Assert.equal ~msg:"wrong node for argument" (Begriff.atom_of_int 2) arg_found;
      Assert.equal ~msg:"wrong node for application" (Begriff.atom_of_int 3) app_found
)
;;

Test.add_simple_test ~title:"write and read s-expression" (fun () ->
  let plan = Begriff.empty_plan () in
  let added_sexp1 = Begriff.add_sexp (Sexp.of_string "((all cops) are bastards)") plan in
  Assert.equal 7 ~msg:"wrong number of nodes" (Begriff.int_of_atom (Begriff.last_atom plan));
  Assert.equal 7 ~msg:"wrong node for expression" (Begriff.int_of_atom added_sexp1);
  let added_sexp2 = Begriff.add_sexp (Sexp.of_string "((all cops) are bastards)") plan in
  Assert.equal 7 ~msg:"no new node should have been created here" (Begriff.int_of_atom (Begriff.last_atom plan));
  Assert.equal 7 ~msg:"same expression should result in same node" (Begriff.int_of_atom added_sexp2);
  let added_sexp3 = Begriff.add_sexp (Sexp.of_string "(all cops)") plan in
  Assert.equal 7 ~msg:"no new node should have been created for existent sub-expression" (Begriff.int_of_atom (Begriff.last_atom plan));
  Assert.equal 3 ~msg:"wrong node number, nodes should be numbered in strict left-to-right-order" (Begriff.int_of_atom added_sexp3);
  let read_sexp1 = Begriff.read_sexp (Begriff.atom_of_int 7) plan in
  Assert.equal ~msg:"expression not correctly rendered" "(((all cops)are)bastards)" (Sexp.to_string read_sexp1);
  let read_sexp2 = Begriff.read_sexp (Begriff.atom_of_int 5) plan in
  Assert.equal ~msg:"sub-expression not correctly rendered" "((all cops)are)" (Sexp.to_string read_sexp2)
)
;;

Test.add_simple_test ~title:"abstract nodes as s-expression" (fun () ->
  let plan = Begriff.empty_plan () in
  let func = Begriff.next_atom plan in
  let arg = Begriff.next_atom plan in
  let _ = Begriff.add_new_bindung (Begriff.bindung_of_func_arg func arg) plan in
  let read_sexp = Begriff.read_sexp (Begriff.atom_of_int 3) plan in
  Assert.equal ~msg:"expression not correctly rendered" "(($$node 1)($$node 2))" (Sexp.to_string read_sexp);
)
;;

Test.add_simple_test ~title:"no reserved words can be inserted" (fun () ->
  Assert.make_raises
    (function Begriff.Reserved_word _ -> true | _ -> false)
    Printexc.to_string
    ~msg:"Exception Reserved_word should be raised on insertion of '$$node'"
    (fun () ->
      let plan = Begriff.empty_plan () in
      Begriff.add_sexp (Sexp.of_string "($$node 1)") plan)
)
;;

Test.add_simple_test ~title:"Read s-expresion" (fun () ->
  let plan = Begriff.empty_plan () in
  let sexp = Begriff.of_string
    "((doctype)
 (html
     (head
          (title \"Nuki!\")
          (meta (http-equiv: \"Content-Type\" content:\"text-html\")))
    (body
        (div (id:\"main\")
             (div (id:\"header\")
                \"I'm a header!\")))))"
    plan
  in
  Assert.equal
    "(doctype((html((head(title Nuki!))(meta(((http-equiv: Content-Type)content:)text-html))))(body((div(id: main))((div(id: header))\"I'm a header!\")))))" 
    (Begriff.to_string sexp plan);
  Assert.equal 33 (Begriff.int_of_atom sexp)
)
;;

launch_tests ()
;;
