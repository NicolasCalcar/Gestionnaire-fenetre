open Base
open Stdio

open Ocamlwm23
(* Monade option implémentation*)
module OptionMonad =
struct

  let return e = Some e

  let bind m f =
    match m with
    | None -> None
    | Some e -> f e

  let (>>=) = bind
    
end

let main () =
  let width = 640 in
  let height = 480 in
  let default_ratio = 0.5 in

  let active_color = Color.white in
  let inactive_color = Color.black in

  (* never increase ration above 0.95 or decrease below 0.05 *)
  let inc_ratio ratio = Float.min 0.95 (ratio +. 0.05) in
  let dec_ratio ratio = Float.max 0.05 (ratio -. 0.05) in

  (* create a new window *)
  let init_win count () =
    let w = Wm.Win("W" ^ (Int.to_string count), Color.random ()) in
    let c = Wm.Coord {px=0; py=0; sx=width;sy=height} in
    Tree.return  (w,c)  |> Tree.focus_first_leaf
  in

  (* creez un fond blanc*)
  let fond_blanc  () =
    let w = Wm.Win("", Color.white) in
    let c = Wm.Coord {px=0; py=0; sx=width;sy=height} in
    Tree.return  (w,c)  |> Tree.focus_first_leaf
  in
 
  let creer_split dir ratio () = Wm.Split(dir,ratio)
  in
  

  (* create the canvas to draw windows *)
  let f = Printf.sprintf " %dx%d" width height in
  let () = Graphics.open_graph f in


  (* event loop *)
  let rec loop oz autre count =
    (match oz with
     | None -> Stdio.printf "\nZERO WINDOW\n%!"
     | Some z -> Stdio.printf "\n%s\n%!" (Wm.show_wmzipper z)
    );
    
    let rec zoom oz autre count =
      match Graphics.read_key () with
      |'z' -> begin
          let oz_opt = match oz with
            |Some a -> a
            |None -> init_win count ()
          in
          let tree = match oz_opt with
            |Tree.TZ(_,a) -> a
          in
          let racine = Tree.move_until Tree.go_up (fun (Tree.TZ(a,_)) -> match a with
              |Tree.Top -> true
              |Tree.LNContext(_,Tree.Top,_) -> true
              |Tree.RNContext(_,_,Tree.Top) -> true
              |_ -> false) oz_opt in
          let resultat =match racine with
            |None -> oz_opt
            |Some a -> a
          in
          match resultat with
          |Tree.TZ(Tree.LNContext(_,_,a),b) -> Wm.draw_wmtree inactive_color a; Wm.draw_wmtree inactive_color b; Wm.draw_wmtree active_color tree;loop oz autre count
          |Tree.TZ(Tree.RNContext(a,_,_),b) ->Wm.draw_wmtree inactive_color a; Wm.draw_wmtree inactive_color b; Wm.draw_wmtree active_color tree;loop oz autre count
          |_ -> Wm.draw_wmtree active_color tree; loop oz autre count                
        end
      | c ->
        printf "cannot process command '%c'\n%!" c;
        zoom oz autre count
    in

    
    match Graphics.read_key () with
    | 'q' ->
      Stdio.printf "Total number of created windows: %d\nBye\n%!" count;
      raise Caml.Exit
    | 'h' ->
      Stdio.printf "\nhorizontal\n%!";
      begin
        let newzipoption = match oz with
          |None -> init_win count (); (* cas :Pas de fenetre coloré*)
          |Some Tree.TZ(a,b) ->Tree.TZ(a,Wm.update_coord (Wm.get_coord b) (Tree.Node( ((creer_split Wm.Horizontal default_ratio ()),Wm.get_coord b),b,Tree.return ((Wm.Win("W" ^ (Int.to_string count), Color.random ()),(Wm.Coord {px=0; py=0; sx=width;sy=height}))))))                         
        in (* compute new zipper after insertion  *)
        let fg = OptionMonad.bind (Tree.go_down newzipoption) (fun x -> Tree.go_right x) in
        (Wm.draw_wmzipper (inactive_color) newzipoption); (* update display *)
        match fg with
        |Some a -> (Wm.draw_wmzipper (active_color) a); loop fg autre (count+1)
        |_ -> (Wm.draw_wmzipper (active_color) newzipoption); loop (OptionMonad.return newzipoption) autre (count+1)
      end

    | 'v' ->
      Stdio.printf "\nvertical\n%!";
      begin
        let newzipoption = match oz with
          |None -> init_win count (); (* cas :Pas de fenetre coloré*)
          |Some Tree.TZ(a,b) ->Tree.TZ(a,Wm.update_coord (Wm.get_coord b) (Tree.Node( ((creer_split Wm.Vertical default_ratio ()),Wm.get_coord b),b,Tree.return ((Wm.Win("W" ^ (Int.to_string count), Color.random ()),(Wm.Coord {px=0; py=0; sx=width;sy=height}))))))                         
        in (* compute new zipper after insertion  *)
        let fg = OptionMonad.bind (Tree.go_down newzipoption) (fun x -> Tree.go_right x) in
        (Wm.draw_wmzipper (inactive_color) newzipoption); (* update display *)
        match fg with
        |Some a -> (Wm.draw_wmzipper (active_color) a); loop fg autre (count+1)
        |_ -> (Wm.draw_wmzipper (active_color) newzipoption); loop (OptionMonad.return newzipoption) autre (count+1)
      end

    | 'n' ->
      Stdio.printf "\nnext\n%!";
      begin
        
        let ancienzipper = match oz with
          |Some a -> a
          |None -> init_win count () (* INUTILISE POUR SATISFAIRE LE MATCH*)
        in
        let nextzipper = OptionMonad.bind oz (Tree.next_leaf)
        in
        match nextzipper with
        |None ->  Stdio.printf "\nPas de feuille suivante\n%!"; loop oz autre (count)
        |Some c -> Wm.draw_wmzipper (inactive_color) ancienzipper; Wm.draw_wmzipper (active_color) c;loop nextzipper autre (count)
      end
    | 'p' ->
      Stdio.printf "\nprevious\n%!";
      begin
        let ancienzipper = match oz with
          |Some a -> a
          |None -> init_win count () (* INUTILISE POUR SATISFAIRE LE MATCH*)
        in
        let nextzipper = OptionMonad.bind oz (Tree.previous_leaf)
        in
        match nextzipper with
        |None ->  Stdio.printf "\nPas de feuille precedente\n%!"; loop oz autre (count)
        |Some c -> Wm.draw_wmzipper (inactive_color) ancienzipper; Wm.draw_wmzipper (active_color) c;loop nextzipper autre (count)
      end
      
    | '+' ->
      Stdio.printf "\nincrement size\n%!";
      begin
        let testparent = (OptionMonad.bind oz (fun x -> Tree.go_up x)) in
        let enfant_ct = match oz with
          |Some a -> Tree.is_left_context a
          |None -> false
        in
         (* Si la feuille courante n'a pas de parent on ne change pas le ratio *)
        let reponse =  (if( Bool.equal enfant_ct  false) then
        (OptionMonad.bind testparent (fun x -> match x with
          |Tree.TZ(a,Tree.Node((Wm.Split(b,c),d),e,f)) ->Some(Tree.TZ(a,(Wm.update_coord  d (Tree.Node((Wm.Split(b,dec_ratio c),d),e,f)))))
          |Tree.TZ(a,b) -> Some(Tree.TZ(a,b))))
        else
          OptionMonad.bind testparent (fun x -> match x with
          |Tree.TZ(a,Tree.Node((Wm.Split(b,c),d),e,f)) ->Some(Tree.TZ(a,(Wm.update_coord  d (Tree.Node((Wm.Split(b,inc_ratio c),d),e,f)))))
          |Tree.TZ(a,b) -> Some(Tree.TZ(a,b))))
        in
        let fils_op = (if (Bool.equal enfant_ct true) then (OptionMonad.bind reponse (fun x -> Tree.go_down x)) else (OptionMonad.bind reponse (fun x -> OptionMonad.bind (Tree.go_down x) (fun y -> Tree.go_right y))))
        in
        let fils = match fils_op with
          |Some a ->a
          |None -> Tree.TZ (Tree.Top,(Tree.Leaf((Wm.Win ("W0", Color.black)), Wm.Coord {px = 0; py = 0; sx = 640; sy = 480})))
        in
        match reponse with
        |Some a -> Wm.draw_wmzipper inactive_color a;(match a with |Tree.TZ(_,Tree.Node(_,Tree.Leaf _,_)) -> Wm.draw_wmzipper active_color fils;loop fils_op  autre count
                                                                    |Tree.TZ(_,Tree.Node(_,_,_)) ->Wm.draw_wmzipper inactive_color fils;loop fils_op autre count
                                                                    |_ -> loop oz autre count)
        |None ->loop oz autre count
        
     end
    | '-' ->
      Stdio.printf "\ndecrement size\n%!";
      begin
        let testparent = (OptionMonad.bind oz (fun x -> Tree.go_up x)) in
         let enfant_ct = match oz with
          |Some a -> Tree.is_left_context a
          |None -> false
        in
        (* Si la feuille courante n'a pas de parent on ne change pas le ratio *)
         let reponse =  (if (Bool.equal enfant_ct true) then
        (OptionMonad.bind testparent (fun x -> match x with
          |Tree.TZ(a,Tree.Node((Wm.Split(b,c),d),e,f)) ->Some(Tree.TZ(a,(Wm.update_coord  d (Tree.Node((Wm.Split(b,dec_ratio c),d),e,f)))))
          |Tree.TZ(a,b) -> Some(Tree.TZ(a,b))))
        else
          OptionMonad.bind testparent (fun x -> match x with
          |Tree.TZ(a,Tree.Node((Wm.Split(b,c),d),e,f)) ->Some(Tree.TZ(a,(Wm.update_coord  d (Tree.Node((Wm.Split(b,inc_ratio c),d),e,f)))))
          |Tree.TZ(a,b) -> Some(Tree.TZ(a,b))))
        in
       
        let fils_op = (if (Bool.equal enfant_ct  true) then (OptionMonad.bind reponse (fun x -> Tree.go_down x)) else (OptionMonad.bind reponse (fun x -> OptionMonad.bind (Tree.go_down x) (fun y -> Tree.go_right y))))
        in
        let fils = match fils_op with
          |Some a ->a
          |None -> Tree.TZ (Tree.Top,(Tree.Leaf((Wm.Win ("W0", Color.black)), Wm.Coord {px = 0; py = 0; sx = 640; sy = 480})))
        in    
        match reponse with
        |Some a -> Wm.draw_wmzipper inactive_color a;(match a with |Tree.TZ(_,Tree.Node(_,Tree.Leaf _,_)) -> Wm.draw_wmzipper active_color fils;loop fils_op  autre count
                                                                    |Tree.TZ(_,Tree.Node(_,_,_)) ->Wm.draw_wmzipper active_color fils;loop fils_op autre count
                                                                    |_ -> loop oz autre count)
        |None ->loop oz autre count
      end

    | 'r' ->
      Stdio.printf "\nremove\n%!";
      begin
        (* On recupere l'option des coordonnées du pere*) 
        let coord_opt = match (OptionMonad.bind oz (fun x -> Tree.go_up x)) with
          |Some Tree.TZ(_,b) -> Some(Wm.get_coord b)
          |None -> None
        in
        (* On recupere les coordonnes du pere*)
        let coord = match coord_opt with
          |Some a -> a
          | _ ->  (Wm.Coord {px=0; py=0; sx=width;sy=height})
        in
        (* On supprime la feuille*)
        let arbre = OptionMonad.bind (oz)  (fun x ->Tree.remove_leaf x) in
        let arbre = match arbre with
          |Some (Tree.TZ(a,Tree.Node((b,_),c,d)),e) -> Some(Tree.TZ(a,(Wm.update_coord coord (Tree.Node((b,coord),c,d)))),e)
          |None -> None
          |_ -> arbre
        in
        (* On insere les nouvelles coordonnées au nouveau noeud*) 
        let ancienzipper = match arbre with
          |Some(Tree.TZ(a,Tree.Leaf b),_) ->Some(Tree.TZ(a, (Wm.update_coord coord (Tree.Leaf b))))
          |Some(Tree.TZ(a,(Tree.Node(b,c,d))),_) -> Some (Tree.TZ(a,(Wm.update_coord coord (Tree.Node(b,c,d)))))
          |None -> None
        in
        (* go a la feuille  la plus proche*)
        let ancienzip =  match ancienzipper with
                                                                        |Some(Tree.TZ(a,Tree.Leaf b)) ->Some(Tree.TZ(a,Tree.Leaf b))
                                                                        |Some(Tree.TZ(a,Tree.Node(b,Tree.Leaf c,d))) -> Tree.go_down(Tree.TZ(a,Node(b,Tree.Leaf c,d)))
                                                                        |Some(Tree.TZ(a,Tree.Node(b,Tree.Node(c,d,e),f))) -> OptionMonad.bind (Tree.go_down (Tree.TZ(a,Tree.Node(b,Tree.Node(c,d,e),f)))) (fun x -> Tree.next_leaf x)
                                                                        |None -> None
        in
        match ancienzipper with
        |Some Tree.TZ(a,Tree.Leaf b) ->  Wm.draw_wmzipper (active_color) (Tree.TZ(a,Tree.Leaf b)); loop (ancienzip) autre (count)
        |Some Tree.TZ(a,Tree.Node(b,c,d)) -> (match ancienzip with |Some (z) -> Wm.draw_wmzipper (inactive_color) (Tree.TZ(a,Tree.Node(b,c,d))); Wm.draw_wmzipper (active_color) z;loop (ancienzip) autre count
                                                                      |None ->loop (ancienzip) autre (count))
        |None -> (Wm.draw_wmzipper (active_color) (fond_blanc  ()));loop None autre count
      end
    |'z' ->
      Stdio.printf "\nZOOM\n%!";
      begin
        match oz with
        |Some(Tree.TZ(_,Tree.Leaf((a,_)))) -> (Wm.draw_wmtree active_color (Tree.Leaf(a,(Wm.Coord{px=0 ;py=0;sx=width;sy=height}))));zoom oz autre count
        |_ -> loop oz autre count   
      end
    |'s' ->
      Stdio.printf "\nSWITCH\n%!";
      begin
        let autre_opt = match autre with
          |Some a -> a
          |None -> init_win count ()
        in
        let tree = match autre_opt with
          |Tree.TZ(_,a) -> a
        in
        match autre with
        |Some(Tree.TZ(_,_)) ->
          (let racine = Tree.move_until Tree.go_up (fun (Tree.TZ(b,_))-> match b with
            |Tree.Top -> true
            |Tree.LNContext(_,Tree.Top,_) -> true
            |Tree.RNContext(_,_,Tree.Top) -> true
            |_ -> false ) autre_opt
           in
           let resultat =match racine with
              |None -> autre_opt
              |Some a -> a
           in
           match resultat with
           |Tree.TZ(Tree.LNContext(_,_,a),b) -> Wm.draw_wmtree inactive_color a; Wm.draw_wmtree inactive_color b; Wm.draw_wmtree active_color tree;loop autre oz count
           |Tree.TZ(Tree.RNContext(a,_,_),b) ->Wm.draw_wmtree inactive_color a; Wm.draw_wmtree inactive_color b; Wm.draw_wmtree active_color tree;loop autre oz count
           |_ -> Wm.draw_wmtree active_color tree; loop autre oz count )
        |_ -> Wm.draw_wmtree active_color tree;loop (OptionMonad.return autre_opt) oz count   
      end 
    | c ->
      printf "cannot process command '%c'\n%!" c;
      loop oz autre count
  in
  try
    loop None None 0
  with
  | Stdlib.Exit -> ()


let () = main ()
