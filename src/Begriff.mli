(** Module [Begriff] aims at a maximally reduced representation of a
    syntax tree. The implementation is focused on simplicity to avoid
    the obscurity of side-effects and to allow for a concise formal
    description of operations on the data structure.

    Roughly, [Begriff] implements a representation of sets of
    s-expressions with perfect sharing. Unlike standard s-expressions,
    however, associativity is left, i.e. [(a b c)] actually is
    interpreted as [((a b) c)] as in application of a function to its
    arguments with currying, and not as [(a (b c))] as for lists with
    cons.

    The term "Begriff" is of German origin and might be familiar to
    logicians, as it is part of the composed word "Begriffsschrift" (a
    formal system at the border between language and formal
    mathematics, developed by Gottlob Frege). It roughly means "word",
    but the subtle associations do also refer to something which
    translates to "handle" in English. This describes an important
    aspect of all kind of information: it provides a "handle" on the
    world to work with.
*)

open Sexplib

type zeichen
(** A [zeichen] is the type of labels for nodes. The [zeichen] type
    is currently a mere abstraction for [string], but different
    kinds of labels might be considered in the future. 

    Note that labels of type [zeichen] are unique identifiers, i.e.,
    two distinct nodes cannot be labeled by the same [zeichen].

    A special role is assumed by the string "_", the label of node
    0. The semantic is, like in OCaml, that of a placeholder with
    unspecified value.
*)

type atom
(** [atom] is a unique identifier of a node, its current implementation
    is type [int].

    Node 0, the placeholder node, is labeled by "_".
*)

type bindung
(** [bindung] is the base element of any structure. It
    connects three nodes: [(app, func, arg):bindung]. Note that
    there is no constructor to connect only two nodes, as the
    connection of two nodes automatically introduces an additional
    node, which represents this connection. [app] is the reference
    to a node constructed by applying [func] to [arg].

    Note that the combination of [func] and [arg] is as well a unique
    identifier for a node as [app].
*)

type plan
(** A graph over nodes of type [atom], whose structure is
    established by associations of type [bindung] and whose nodes
    may have labels of type [zeichen].
*)

type atomSet
(** A set of [atom] elements *)

exception Reserved_word of string
(** [Reserved_word] is raised if trying to label a node by a keyword
    of module [Begriff] (currently only [$$node]):
*)

val intersect_atoms: atomSet -> atomSet -> atomSet
(** intersection of two Sets of atoms *)

val atoms_size: atomSet -> int
(** cardinality of a [atomSet] *)


val is_reserved_word: string -> bool
(** tests if a [string] is a keyword of module [Begriff] *)


val empty_plan: unit -> plan
(** returns an empty graph of type [plan] *)


val zeichen_of_string: string -> zeichen
(** constructs a [zeichen] from a [string] *)

val string_of_zeichen: zeichen -> string
(** returns the [string] representation of a [zeichen] *)

val atom_of_int: int -> atom
(** constructs an [atom] from an [int] *)

val int_of_atom: atom -> int
(** returns the [int] representation of an [atom] *)


val bindung_of_func_arg: atom -> atom -> bindung
(** constructs the (not yet introduced) application of two [atom]s
    [func] and [arg] 
*)

val func_of_bindung: bindung -> atom
(** returns the function [atom] of a [bindung] *)

val arg_of_bindung: bindung -> atom
(** returns the argument [atom] of a [bindung] *)

val app_of_bindung: bindung -> atom
(** returns the application [atom] of a [bindung] *)


val next_atom: plan -> atom
(** introduces a new [atom] in a [plan] *)

val last_atom: plan -> atom
(** returns the [atom] that has been introduced last in a [plan] *)

val plan_size: plan -> int
(** returns the number of nodes in a [plan] *)


val add_zeichen: zeichen -> plan -> atom
(** returns the node labeled by a [zeichen] if one exists, and
    introduces a new node if there is none *)

val find_zeichen: atom -> plan -> zeichen option
(** returns the label of a node if it has one *)


val add_bindung: atom -> atom -> plan -> atom
(** [add_bindung func arg plan] adds a new [bindung] with function
    [func] and argument [arg] in [plan], if it does not exist yet. *)

val find_bindung_app: atom -> plan -> bindung option
(** returns the [bindung] the node [app] refers to, if there is one. *)

val find_bindung_func_arg: atom -> atom -> plan -> bindung option
(** returns the [bindung] with function [func] and argument [arg], if there is one. *)

val add_sexp: Sexp.t -> plan -> atom
(** Adds an s-expression to a plan *)
 
val read_sexp: atom -> plan -> Sexp.t
(** returns the expression an [atom] refers to as s-expression *)


val of_string: string -> plan -> atom
(** like [add_sexp], but the s-expression is supplied as [string]
    which is parsed before insertion *)

val to_string: atom -> plan -> string
(** like [read_sexp], but the s-expression is rendered to a [string] *)


val with_func: atom -> plan -> atomSet
(** [with_func func plan] returns the list of all nodes with function
    [func] *)

val with_func: atom -> plan -> atomSet
(** [with_arg arg plan] returns the list of all nodes with argument
    [arg] *)
