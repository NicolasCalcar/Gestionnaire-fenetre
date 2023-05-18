
type direction = Vertical | Horizontal [@@deriving show]
type window = Win of string * Color.t [@@deriving show]


type coordinate = Coord of {px: int; py: int; sx: int; sy: int} [@@deriving show]
type split = Split of direction * float (* ratio between 0 and 1 *) [@@deriving show]

(* recuperer les elements de coordinate*)
let get_coord_values (Coord {px; py; sx; sy}) = (px, py, sx, sy)

let draw_win w coord bc = match w with
  | Win(a,color) ->let (px,py,sx,sy) = get_coord_values coord in
    Graphics.set_color (Color.to_int(color));
    Graphics.fill_rect (px + 5) (py + 5) (sx - 10) (sy - 10);
    Graphics.set_color (Color.to_int(bc));
    Graphics.draw_rect px py (sx - 1) (sy - 1);
    Graphics.draw_rect (px + 1) (py + 1) (sx - 3) (sy - 3);
    Graphics.draw_rect (px + 2) (py + 2) (sx - 5) (sy - 5);
    Graphics.draw_rect (px + 3) (py + 3) (sx - 7) (sy - 7);
    Graphics.draw_rect (px + 4) (py + 4) (sx - 9) (sy - 9);
    Graphics.moveto (px +sx /2) (py + sy /2);
    Graphics.set_color (Color.to_int(Color.black));
    Graphics.draw_string a
  
type wmtree = ((split * coordinate), (window * coordinate)) Tree.t [@@deriving show]
type wmzipper = ((split * coordinate), (window * coordinate)) Tree.z [@@deriving show]

let get_coord wt = match wt with
  |Tree.Leaf(_,b) ->b
  |Tree.Node((_,b),_,_) -> b;;

let change_coord  coord wt  =  match wt with
  |Tree.Leaf(a,_) -> (Tree.Leaf(a,coord))
  |Tree.Node((a,_),c,d) -> (Tree.Node((a,coord),c,d));;

let rec draw_wmtree bc wt = match wt with
  |Tree.Leaf(a,coord) -> draw_win a coord bc
  |Tree.Node(_,a,b) -> draw_wmtree bc a; draw_wmtree bc b;;

let draw_wmzipper bc wz = match wz with
  |Tree.TZ(_,a) -> draw_wmtree bc a;;

                                                
let rec update_coord c t =
  match t with
  | Tree.Leaf (win, _) -> Tree.Leaf (win, c)
  | Tree.Node ((split, _), left, right) ->
     let (oldpx,oldpy,oldsx,oldsy) = get_coord_values c  in
    let new_coord_left, new_coord_right =
      match split with
      | Split (Horizontal, ratio) ->
        let new_sx_left = int_of_float (float_of_int oldsx *. ratio) in
        let new_sx_right = oldsx - new_sx_left in
        let new_coord_left = Coord {px = oldpx; py = oldpy; sx = new_sx_left; sy = oldsy} in
        let new_coord_right = Coord {px = oldpx + new_sx_left; py = oldpy; sx = new_sx_right; sy = oldsy} in
        (new_coord_left, new_coord_right)
      | Split (Vertical, ratio) ->
        let new_sy_top = int_of_float (float_of_int oldsy *. ratio) in
        let new_sy_bottom = oldsy - new_sy_top in
        let new_coord_top = Coord {px = oldpx; py = oldpy; sx = oldsx; sy = new_sy_top} in
        let new_coord_bottom = Coord {px = oldpx; py = oldpy + new_sy_top; sx = oldsx; sy = new_sy_bottom} in
        (new_coord_top, new_coord_bottom)
    in
    Tree.Node ((split, c), (update_coord new_coord_left left), (update_coord new_coord_right right))

          

