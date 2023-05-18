(** Color abstraction for our window manager.
    Can provide back and forth operations with RGB and internal representations
*)

open Base

type t = Int.t [@@deriving show]

let from_rgb r g b =( r lsl 16) lor (g lsl 8) lor  b

let to_rgb t =  let r = t / 65536 in
  let g = (t / 256) % 256 in
  let b = t % 256 in
  (r, g, b);;

let to_int t  = t;;

let inverse t = let (a,b,c) = to_rgb t in
  from_rgb (255-a) (255-b) (255-c);;

let random () = Random.int 16777215;;


(** add 2 color component-wise: *)
(** the result is a valid color  *)
let (+) c1 c2 = let (r1,g1,b1) = to_rgb c1 in
  let (r2,g2,b2) = to_rgb c2 in
  let r3 =  (if r1 +r2 > 255 then 255 else r1+r2) in
  let g3 =( if g1 + g2  > 255 then 255 else g1+g2) in
  let b3 = (if b1 + b2 > 255 then 255 else b1 + b2)in
from_rgb r3 g3 b3;;

let white = 16777215;;
let black = 0;;
let red   = 16711680;;
let green = 65280;;
let blue  = 255;;

let%test "idint" =
  let c = random () in
  to_int c = c

let%test "idrgb" =
  let c = random () in
  let (r,g,b) = to_rgb c in
  from_rgb  r g b = c

let%test "white" =
  let (r,g,b) = to_rgb white in
  (r = 255) && (g=255) && (b=255)

let%test "black/white" = white = inverse black

let%test "whitecolors" = (red + green + blue) = white

let%test "addwhite" =
  white = white + white
