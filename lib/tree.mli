(** Binary Tree with different data types in leaves and internal nodes *)
(** Zipper on binary trees *)


type ('v, 'w) t =
  | Node of 'v * ('v,'w) t * ('v,'w) t
  | Leaf of 'w [@@deriving show]

(** from a 'w build a leaf *)
val return : 'w -> ('v, 'w) t

(** from a 'v and 2 subtrees build a new node *)
val combine : 'v -> ('v, 'w) t -> ('v, 'w) t -> ('v, 'w) t

(** return true if applied to a leaf, false otherwise *)
val is_leaf : ('v, 'w) t -> bool

(** return Some value if applied to a leaf, otherwise none *)
val get_leaf_data : ('v, 'w) t -> 'w option

(** return Some value if applied to a node, otherwise none *)
val get_node_data : ('v, 'w) t -> 'v option

(** map (f,g) t returns a new tree with the same structure as t *)
(** where all node data have been transformed via f *)
(** where all leaf data have been transformed via g *)
val map :  (('v1 ->'v2) * ('w1->'w2)) -> ('v1,'w1) t -> ('v2,'w2) t

(** iter (f,g) t applies *)
(** f to all node data *)
(** g to all leaf data *)
(** via preorder traversal (recursive root-left-right)*)
val iter : (('v -> unit) * ('w -> unit)) -> ('v,'w) t -> unit


type ('v, 'w) z = TZ of ('v,'w) context * ('v,'w) t
and ('v,'w) context =
  | Top
  | LNContext of 'v * ('v,'w) context * ('v,'w) t
  | RNContext of ('v,'w) t * 'v * ('v,'w) context [@@deriving show]



(** from a tree t return a zipper focused on the left-most leaf*)
val focus_first_leaf : ('v,'w) t -> ('v,'w) z

(** change z s return zipper like z where we replace the substructure of z by s *)
val change: ('v,'w) z -> ('v,'w) t -> ('v,'w) z

(** change_up z v return zipper like z where we replace the data above the focus by v *)
val change_up: ('v,'w) z -> 'v -> ('v,'w) z

(** go_down z return optional zipper like z where the focus is the left subtree *)
val go_down : ('v,'w) z -> ('v,'w) z option

(** go_up z return optional zipper like z where the focus is the the mother node of the substructure *)
val go_up : ('v,'w) z -> ('v,'w) z option

(** go_left z return optional zipper like z where the focus is the the left sister node of the substructure *)
val go_left : ('v,'w) z -> ('v,'w) z option

(** go_left z return optional zipper like z where the focus is the the right sister node of the substructure *)
val go_right : ('v,'w) z -> ('v,'w) z option

(** reflexive_transitive f z: apply f z repeatedly until the application is not possible (when f returns None) *)
(** return the last valid zipper *)
val reflexive_transitive : (('v,'w) z -> ('v,'w) z option) -> ('v,'w) z -> ('v,'w) z


(** move_until f p z: apply f z  repeatedly until f returns None or (p z) is true *)
val move_until : (('v,'w) z -> ('v,'w) z option) -> (('v,'w) z -> bool) -> ('v,'w) z -> ('v,'w) z option

(** return an option on the closest leaf on the right *)
val next_leaf : ('v,'w) z -> ('v,'w) z option

(** return an option on the closest leaf on the left *)
val previous_leaf : ('v,'w) z -> ('v,'w) z option

(** remove_leaf z: return an option on a pair (z',v) where *)
(** z' is zipper like z where the focused substructure is removed *)
(** v is the value of the mother node of the focused substructure in z *)
val remove_leaf : ('v,'w) z -> (('v,'w) z * 'v) option

(** true if the focus is a left subtree *)
val is_left_context : ('v,'w) z -> bool

(** true if the focus is right subtree *)
val is_right_context : ('v,'w) z -> bool

(** true if the focus is the root *)
val is_top_context : ('v,'w) z -> bool
