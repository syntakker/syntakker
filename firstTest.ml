open Kaputt.Abbreviations
open Test
;;

Test.add_simple_test ~title:"write and read a zeichen" (fun () ->
  let plan = Begriff.empty_plan () in
  let zeichen = Begriff.zeichen_of_string "test" in
  let _ = Begriff.add_zeichen zeichen plan in
  let found = Begriff.find_zeichen (Begriff.atom_of_int 1) plan in
  Assert.is_some found;
  Assert.equal (Some (Begriff.zeichen_of_string "test")) found
) 
;;

Test.add_simple_test ~title:"generate next atom" (fun () ->
  let plan = Begriff.empty_plan () in
  let atom1 = Begriff.next_atom plan in
  let atom2 = Begriff.next_atom plan in
  Assert.equal (Begriff.atom_of_int 1) atom1;
  Assert.equal (Begriff.atom_of_int 2) atom2
)
;;

Test.add_simple_test ~title:"generate next atom on different plans" (fun () ->
  let plan1 = Begriff.empty_plan () in
  let atom1 = Begriff.next_atom plan1 in
  let plan2 = Begriff.empty_plan () in
  let atom2 = Begriff.next_atom plan2 in
  Assert.equal (Begriff.atom_of_int 1) atom1;
  Assert.equal (Begriff.atom_of_int 1) atom2
)
;;

Test.add_simple_test ~title:"write and read a bindung" (fun () ->
  let plan = Begriff.empty_plan () in
  let func = Begriff.next_atom plan in
  let arg = Begriff.next_atom plan in
  Assert.equal (Begriff.atom_of_int 1) func;
  Assert.equal (Begriff.atom_of_int 2) arg;
  let app = Begriff.add_new_bindung (Begriff.bindung_of_func_arg func arg) plan in
  Assert.equal (Begriff.atom_of_int 3) app;
  let found = Begriff.find_bindung func arg plan in
  Assert.is_some found;
  let Some bindung = found in
  let app_found = Begriff.app_of_bindung bindung in
  let func_found = Begriff.func_of_bindung bindung in
  let arg_found = Begriff.arg_of_bindung bindung in
  Assert.equal (Begriff.atom_of_int 1) func_found;
  Assert.equal (Begriff.atom_of_int 2) arg_found;
  Assert.equal (Begriff.atom_of_int 3) app_found;
)
;;


launch_tests ()
;;
