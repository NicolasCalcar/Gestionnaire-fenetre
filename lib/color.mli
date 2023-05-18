(** Color abstraction for our window manager.
    Can provide back and forth operations with RGB and internal representations
*)


(* opaque type *)
type t [@@deriving show]


(** Return a color from 3 components RGB in [0;255] *)
(** https://en.wikipedia.org/wiki/RGB_color_model *)
(** https://fr.wikipedia.org/wiki/Rouge_vert_bleu *)
val from_rgb : int -> int -> int -> t

(** Return a triplet of components RGB*)
val to_rgb : t -> (int*int*int)

(** Conversion to int *)
val to_int : t -> int

(** Inverse each component  of the color: *)
(**  new_component = 255 - component*)
val inverse : t -> t

(** return a valid random color *)
val random : unit -> t

(** Predefined colors *)
val white : t
val black : t
val red : t
val green : t
val blue : t
