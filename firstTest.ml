open Kaputt.Abbreviations
open Test
;;

Test.add_simple_test ~title:"write and read a zeichen ..." (fun () ->
  let plan = Begriff.empty in
  let zeichen = Begriff.zeichen_of_string "test" in
  let _ = Begriff.add_zeichen zeichen plan in
  let found = Begriff.find_zeichen (Begriff.atom_of_int 1) plan in
  Assert.is_some found;
  Assert.equal (Some (Begriff.zeichen_of_string "test")) found); 
;;

launch_tests ()
;;
