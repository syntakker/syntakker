open Kaputt.Abbreviations
open Test
;;

Test.add_simple_test ~title:"testing works..." (fun () ->
  Assert.equal_int 2 2)

;;
launch_tests ()
;;
