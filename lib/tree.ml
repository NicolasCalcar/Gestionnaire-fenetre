open Base
    
type ('v, 'w) t =
  | Node of 'v * ('v,'w) t * ('v,'w) t
  | Leaf of 'w [@@deriving show]
    
let return w = Leaf w;;

let combine v l1 l2 = Node(v,l1,l2);;
  

let%test "n" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine 4 l1 l2 in
  let n2 = combine 5 n1 l3 in
  Stdlib.(n2 = (Node(5,Node(4, Leaf 1, Leaf 2), Leaf 3)))

let is_leaf t = match t with
	| Node _ -> false
	| Leaf _ -> true;;

let%test "leaf1" = is_leaf (Leaf 1)
let%test "leaf2" = is_leaf (Node (1, Leaf 1, Leaf 1)) |> not


let get_leaf_data t = match t with 
	| Leaf a -> Some a 
	| Node _ -> None ;;
 

let%test "gld1" =  match get_leaf_data (Leaf 1) with
  | None -> false
  | Some o -> Int.(o = 1)


let%test "gld2" = match get_leaf_data (Node (1, Leaf 2, Leaf 3)) with
  | None -> true
  | _ -> false


let get_node_data t = match t with
	| Leaf _ -> None
	| Node(a,_,_) -> Some a;; 

let%test "gnd1" =  match get_node_data (Leaf 1) with
  | None -> true
  | _ -> false


let%test "gnd2" = match get_node_data (Node (1, Leaf 2, Leaf 3)) with
  | None -> false
  | Some o -> Int.(o = 1)


let rec map (f,g) d = match d with
  | Node(v,fg,fd) -> Node ( f (v), map (f,g) fg, map (f,g) fd)
  | Leaf a -> Leaf (g (a));;

let%test "map" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let g x = x * 2 in
  let f x = x ^ x in
  let n3 = map (f,g) n2 in
  Stdlib.(n3 = (Node("fivefive",Node("fourfour", Leaf 2, Leaf 4), Leaf 6)))


let rec iter (f,g) t = match t with 
   | Leaf d -> (g d)
   | Node(a,b,c) -> (f a); (iter (f,g)b); (iter(f,g)c);;

type ('v, 'w) z = TZ of ('v,'w) context * ('v,'w) t
and ('v,'w) context =
  | Top
  | LNContext of 'v * ('v,'w) context * ('v,'w) t
  | RNContext of ('v,'w) t * 'v * ('v,'w) context [@@deriving show]

let from_tree d = TZ(Top,d);;

let change z s = match z with  
    | TZ(Top,_) -> TZ(Top,s)
    | TZ((LNContext(a,b,c), Node(v,_,_))) -> TZ(LNContext(a,b,c), Node(v,s,s))
    | TZ((RNContext(a,b,c), Node(v,_,_))) -> TZ(RNContext(a,b,c), Node(v,s,s))
    | _ -> failwith" impossible de faire le changement ";;

let change_up z v = match z with
  | TZ(LNContext(_,b,c),d) -> TZ(LNContext(v,b,c),d)
  | TZ(RNContext(a,_,c),d) -> TZ(RNContext(a,v,c),d)
  | _ -> failwith "impossible de faire le changement ";;


let go_down z = match z with
  |TZ(_,Leaf _) -> None
  |TZ(Top,Node(a,b,c)) -> Some(TZ(LNContext(a,Top,c),b))
  |TZ(LNContext(a,b,c),Node(d,e,f)) -> Some(TZ(LNContext(d,LNContext(a,b,c),f),e))
  |TZ(RNContext(a,b,c),Node(d,e,f)) -> Some(TZ(LNContext(d,RNContext(a,b,c),f),e));;
  
let%test "gd1" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let z = from_tree n2 in
  match go_down z with
  | Some z' -> Stdlib.(z' = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)))
  | None -> false

let%test "gd2" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let z = from_tree n2 in
  match Option.(Some z >>= go_down >>= go_down) with
  | Some z' -> Stdlib.(z' = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))
  | None -> false


let%test "gd3" =
  let l1 = return 1 in
  let l2 = return 2 in
  let l3 = return 3 in
  let n1 = combine "four" l1 l2 in
  let n2 = combine "five" n1 l3 in
  let z = from_tree n2 in
  match Option.(Some z >>= go_down >>= go_down >>= go_down) with
  | Some _ -> false
  | None -> true

let go_up z = match z with
  | TZ(Top,_) -> None 
  | TZ(RNContext(a,b,c),d) -> Some (TZ(c,Node(b,a,d)))
  | TZ(LNContext(a,b,c),d) -> Some (TZ(b,Node(a,d,c)));;

let%test "gu1" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match go_up z with
  | Some z' -> Stdlib.(z' = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)))
  | None -> false

let%test "gu2" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match Option.(Some z >>= go_up >>= go_up) with
  | Some z' -> Stdlib.(z' = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))
  | None -> false

let%test "gu3" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match Option.(Some z >>= go_up >>= go_up >>= go_up) with
  | Some _  -> false
  | None -> true

let go_left z =match z with
  |TZ(RNContext(a,b,c),d) -> Some (TZ(LNContext(b,c,d),a))
  |_ -> None;;

let%test "gl1" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match go_left z with
  | Some z' -> Stdlib.(z' = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))
  | None -> false

let%test "gl2" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match go_left z with
  | Some _ -> false
  | None -> true

let go_right z = match z with
  |TZ(LNContext(a,b,c),d) -> Some (TZ(RNContext(d,a,b),c))
  | _ -> None;;


let%test "gr1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match go_right z with
  | Some z' -> Stdlib.(z' = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2))
  | None -> false

let%test "gl2" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  match go_right z with
  | Some _ -> false
  | None -> true


let rec reflexive_transitive f z = match (f z) with
  |None -> z
  |Some y -> reflexive_transitive f y;;

let%test "rf1" =
  let z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2) in
  Stdlib.(reflexive_transitive go_up z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))

let%test "rf2" =
  let z =   TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  Stdlib.(reflexive_transitive go_up z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))


let%test "rf3" =
  let z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)) in
  Stdlib.(reflexive_transitive go_up z = z)

let rec focus_first_leaf_focus z = match (go_down z) with
  |Some a -> focus_first_leaf_focus  a
  |None -> z;;

let  focus_first_leaf t =
let y = from_tree t in
let x = focus_first_leaf_focus y in
x;;
 


let%test "ffl1" =
  let t = Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3) in
  Stdlib.(focus_first_leaf t = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))


let remove_leaf t = match t with
  |TZ(LNContext(a,b,c),(Leaf _)) -> Some(TZ(b,c),a)
  |TZ(LNContext(_,_,_),(Node(_,_,_))) -> None
  |TZ(RNContext(a,b,c),(Leaf _)) -> Some(TZ(c,a),b)
  |TZ(RNContext(_,_,_),(Node(_,_,_))) -> None
  | _ -> None;;

let%test "rl1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match remove_leaf z with
  | None -> false
  | Some (z, v) -> Stdlib.((z = TZ (LNContext ("five", Top, Leaf 3), Leaf 2)) && (v="four"))


let%test "rl2" =
  let z = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)) in
  match remove_leaf z with
  | None -> true
  | _ -> false


let is_left_context  z = match z with
  |TZ(LNContext(_,_,_),_) -> true
  |_ -> false;;

let is_right_context z = match z with
  |TZ(RNContext(_,_,_),_) -> true
  |_ -> false;;
let is_top_context   z = match z with
  | TZ(Top,_) -> true
  |_ -> false;;

let  rec move_until f p z = match (p z) with
  |true -> Some z
  |false ->( match (f z) with
      |Some a -> move_until f p a
      |None -> None);;             
                    


let%test "mv1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  let p = fun (TZ(_,s)) -> match get_node_data s with | None -> false | Some v -> String.(v = "five") in
  match move_until go_up p z with
  | None -> false
  | Some z -> Stdlib.(z = TZ( Top,  Node("five",Node("four", Leaf 1, Leaf 2), Leaf 3)))

let%test "mv2" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  let p = fun (TZ(_,s)) -> match get_node_data s with | None -> false | Some v -> String.(v = "four") in
  match move_until go_up p z with
  | None -> false
  | Some z -> Stdlib.(z = TZ (LNContext ("five", Top,Leaf 3),Node("four", Leaf 1, Leaf 2)))

(* Utilisé dans next_leaf et previous_leaf pour faciliter le parcours dans l'arbre*)
let supprime_option o = match o with
  |Some a -> a
  |None -> failwith "impossible car la recursion ne donneras jamais None";;

let  rec next_leaf z = match z with
  |TZ(LNContext(_,_,_),Node(_,Leaf _,_)) -> (go_down z)
  |TZ(LNContext(_,_,_),Node(_,_,_)) ->next_leaf (supprime_option (go_down z)) 
  |TZ(LNContext(_,_,Leaf _),Leaf _) -> go_right z
  |TZ(LNContext(_,_,Node(_,Node(_,_,_),_)),Leaf _) -> next_leaf (supprime_option (go_down (supprime_option (go_right z))))
  |TZ(LNContext(_,_,Node(_,Leaf _,_)),Leaf _) -> go_down(supprime_option (go_right z))
  |TZ(RNContext(_,_,Top),_) -> None
  |TZ(RNContext(_,_,LNContext(_,_,Leaf _)),_) -> go_right (supprime_option(go_up (z)))
  |TZ(RNContext(_,_,LNContext(_,_,Node(_,Node(_,_,_),_))),_) -> next_leaf (supprime_option(go_down(supprime_option( go_right (supprime_option(go_up (z)))))))
  |TZ(RNContext(_,_,LNContext(_,_,Node(_,Leaf _,_))),_) -> go_down(supprime_option( go_right (supprime_option(go_up (z)))))
  |TZ(RNContext(_,_,RNContext(_,_,_)),_) -> next_leaf (supprime_option (go_up z))
  |TZ(Top,Leaf _)->None
  |_ -> failwith "impossible";;
                                                             

let%test "nl1" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match next_leaf z with
  | None -> false
  | Some z -> Stdlib.(z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2))

let%test "nl2" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match Option.(Some z >>= next_leaf >>= next_leaf) with
  | None -> false
  | Some z -> Stdlib.(z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3))


let%test "nl3" =
  let z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1) in
  match Option.(Some z >>= next_leaf >>= next_leaf >>= next_leaf) with
  | None -> true
  | _ -> false


let rec previous_leaf z = match z with
  |TZ(RNContext(_,_,_),Node(_,_,Leaf _)) -> go_right(supprime_option(go_down z))
  |TZ(RNContext(_,_,_),Node(_,_,_)) -> previous_leaf(supprime_option(go_right(supprime_option(go_down z))))
  |TZ(RNContext(Leaf _,_,_),Leaf _) -> go_left z
  |TZ(RNContext(Node(_,_,Leaf _),_,_),_) ->go_right(supprime_option( go_down(supprime_option(go_left z))))
  |TZ(RNContext(Node(_,_,_),_,_),_) ->previous_leaf (supprime_option(go_right(supprime_option( go_down(supprime_option(go_left z))))))
  |TZ(LNContext(_,Top,_),_) ->None
  |TZ(LNContext(_,LNContext(_,_,_),_),_) -> previous_leaf(supprime_option(go_up z))
  |TZ(LNContext(_,RNContext(Leaf _,_,_),_),_) -> go_left(supprime_option(go_up z))
  |TZ(LNContext(_,RNContext(Node(_,_,Leaf _),_,_),_),_) -> go_right(supprime_option( go_down(supprime_option(go_left(supprime_option(go_up z))))))
  |TZ(LNContext(_,RNContext(Node(_,_, _),_,_),_),_) -> previous_leaf(supprime_option(go_right(supprime_option( go_down(supprime_option(go_left(supprime_option(go_up z))))))))
  |TZ(Top,_) ->None

let%test "pl1" =
  let z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3) in
  match previous_leaf z with
  | None -> false
  | Some z -> Stdlib.(z = TZ(RNContext(Leaf 1, "four", LNContext ("five", Top,Leaf 3)), Leaf 2))

let%test "pl2" =
  let z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3) in
  match Option.(Some z >>= previous_leaf >>= previous_leaf) with
  | None -> false
  | Some z -> Stdlib.(z = TZ(LNContext("four", LNContext ("five", Top,Leaf 3), Leaf 2), Leaf 1))


let%test "pl3" =
  let z = TZ (RNContext (Node ("four", Leaf 1, Leaf 2), "five", Top), Leaf 3) in
  match Option.(Some z >>= previous_leaf >>= previous_leaf >>= previous_leaf) with
  | None -> true
  | _ -> false
