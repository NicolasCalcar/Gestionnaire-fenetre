(** Adapt the tree datatype for a tiling Window Manager*)


type direction = Vertical | Horizontal [@@deriving show]

(** a window has 3 attributes: a name and a color *)
type window = Win of string * Color.t [@@deriving show]


(** coordinates for a window (or a group of widow) : left corner is at (px,py), the size is sx,sy *)
type coordinate = Coord of {px: int; py: int; sx: int; sy: int} [@@deriving show]

(** Split a rectangle in two: *)
(** according to a direction and ratio (left/right) of (high/low)*)
type split = Split of direction * float (* ratio between 0 and 1 *) [@@deriving show]

(** draw_win w coord bc: draws the window w at coordinate coord with a 5-pixel border of color bc *)
val draw_win : window -> coordinate -> Color.t -> unit

(** all the windows a of a desktop are arranged in a wmtree *)
type wmtree = ((split * coordinate), (window * coordinate)) Tree.t [@@deriving show]

(** a desktop with the focus window information as a zipper *)
type wmzipper = ((split * coordinate), (window * coordinate)) Tree.z [@@deriving show]

(** get the coordinate of the current desktop *)
val get_coord : wmtree -> coordinate

(** change coordinate of the current desktop (not recursive) *)
val change_coord : coordinate -> wmtree -> wmtree

(** draw all the the windows in the desktop recursively *)
(** use the first parameter as border color (see draw_win) *)
val draw_wmtree : Color.t -> wmtree -> unit

(** draw all the the windows in the focused desktop recursively *)
(** use the first parameter as border color (see draw_win) *)
val draw_wmzipper : Color.t -> wmzipper -> unit

(** change coordinate of the current desktop *)
(** and recursively recompute all coordinates in subtrees from split information *)
val update_coord : coordinate -> wmtree -> wmtree
