#!/usr/bin/env owl

open Owl
module N = Dense.Ndarray.S
module M = Dense.Matrix.S
module L = Linalg.S

(* Unary vectorised math operations *)

(* to make comparison fair *)
let sort_immutable x = 
  let y = N.copy x in 
  N.sort y
let fun_arr = N.([|copy; abs; exp; log; sqrt; cbrt; sin; tan; 
  asin; sinh; asinh; round; sort_immutable; sigmoid|])
let fun_arr_name = [|"copy"; "abs"; "exp"; "log"; "sqrt"; "cbrt"; "sin"; "tan"; 
  "asin"; "sinh"; "asinh"; "round"; "sort"; "sigmoid"|]

(* Binary vectorised math operations *)

let fun_arr_arr = N.([|add; mul; div; pow; hypot; min2; fmod|])
let fun_arr_arr_name = [|"add";  "mul"; "div"; "pow"; "hypot"; "min2"; "fmod"|]

(* Fold and scan operations *)
  
let max_a ~axis = N.max ~axis
let sum_a ~axis = N.sum ~axis
let prod_a ~axis = N.prod ~axis
let cumprod_a ~axis = N.cumprod ~axis
let cummax_a  ~axis = N.cummax ~axis
let fun_axis_arr = [|max_a; sum_a; prod_a; cumprod_a; cummax_a|]
let fun_axis_arr_name = [|"max"; "sum"; "prod"; "cumprod"; "cummax"|]

let sum_reduce_a ~axis = N.sum_reduce ~axis
let fun_axes_arr = [|sum_reduce_a|]
let fun_axes_arr_name = [|"sum_reduce"|]

(* Repeat operations *)

let fun_repeat = N.([|repeat; tile|])
let fun_repeat_name = [|"repeat"; "tile"|]

(* Slicing operation *)

let fun_slicing = [|N.get_slice|]

(* Linear Algebra operation *)

let matmul x = M.(x *@ x) |> ignore
let inv x = M.inv x |> ignore
let eigvals x = L.eigvals x |> ignore
let svd x = L.svd x |> ignore
let lu x  = L.lu x  |> ignore
let qr x  = L.qr x  |> ignore
let fun_linalg = [|matmul; inv; eigvals; svd; lu; qr|]
let fun_linalg_name = [|"matmul"; "inv"; "eigvals"; "svd"; "lu"; "qr"|]


(* Timing function *)

let remove_outlier arr = 
  let first_perc = Owl_stats.percentile arr 25. in
  let third_perc = Owl_stats.percentile arr 75. in 
  let lst = Array.to_list arr in 
  List.filter (fun x -> (x >= first_perc) && (x <= third_perc)) lst
    |> Array.of_list 


let timing fn msg = 
  let c = 30 in 
  let times = Owl.Utils.Stack.make () in
  for i = 1 to c do
    let t = fn () in 
    Owl.Utils.Stack.push times t
  done;
  let times = Owl.Utils.Stack.to_array times in
  let times = remove_outlier(times) in
  let m_time = Owl.Stats.mean times in
  let s_time = Owl.Stats.std times in
  Printf.printf "| %s :\t mean = %.5f \t std = %.5f \n" msg m_time s_time;
  flush stdout;
  m_time, s_time


let evalop_arr_arr fn name sz = 
  let f () = 
    let inp1 = N.uniform [|sz|] in
    let inp2 = N.uniform [|sz|] in
    let g () = fn inp1 inp2 in
    Owl_utils.time g
  in 
  timing f (Printf.sprintf "%s (%d)" name sz)


let evalop_arr fn name sz = 
  let f () = 
    let inp = N.uniform [|sz|] in
    let g () = fn inp in
    Owl_utils.time g
  in 
  timing f (Printf.sprintf "%s (%d)" name sz)


let evalop_axis_arr axis fn name sz =
  let f () = 
    let inp = N.uniform sz in
    let g () = fn ~axis inp in
    Owl_utils.time g
  in
  let sz_str = Owl_utils_array.to_string string_of_int sz in
  timing f (Printf.sprintf "%s (axis=%d, %s)" name axis sz_str)


let evalop_axes_arr axis fn name sz =
  let f () = 
    let inp = N.uniform sz in
    let g () = fn ~axis inp in
    Owl_utils.time g
  in
  let sz_str = Owl_utils_array.to_string string_of_int sz in
  let ax_str = Owl_utils_array.to_string string_of_int axis in
  timing f (Printf.sprintf "%s (axis=%s, %s)" name ax_str sz_str)


let evalop_repeat axes fn name sz = 
  let f () = 
    let inp = N.ones sz in
    let g () = fn inp axes in 
    Owl_utils.time g
  in
  let sz_str = Owl_utils_array.to_string string_of_int sz in
  let ax_str = Owl_utils_array.to_string string_of_int axes in
  timing f (Printf.sprintf "%s (axis=%s, %s)" name ax_str sz_str)


let evalop_slice fn name idx idx_str sz = 
  let f () = 
    let inp = N.uniform sz in
    let g () = fn idx inp in
    Owl_utils.time g
  in
  timing f (Printf.sprintf "%s (%s)" name idx_str)


let evalop_linalg fn name sz = 
  let f () = 
    let h = sz.(0) in
    let w = sz.(1) in
    let inp = M.uniform h w in
    let inp = M.mul_scalar inp 2. in
    let inp = M.sub_scalar inp 1. in
    let g () = fn inp in
    Owl_utils.time g
  in
  let sz_str = Printf.sprintf "%d*%d" sz.(0) sz.(1) in
  timing f (Printf.sprintf "%s (%s)" name sz_str)


(* Evaluate simple arr and arr_arr operations *)

let evaluate_simple () = 
  let sz = [|10; 100; 1000; 10000; 100000; 200000; 400000; 600000; 800000; 1000000|] in
  let sz_str = "10,,100,,1000,,1e4,,1e5,,2e5,,4e5,,6e5,,8e5,,1e6" in

  let result_str = ref ("," ^ sz_str ^ "\n") in
  (* evaluate_arr op *)
  for i = 0 to (Array.length fun_arr - 1) do
    result_str := !result_str ^ fun_arr_name.(i) ^ ",";
    for j = 0 to (Array.length sz - 1) do  
      let mu, std = evalop_arr fun_arr.(i) fun_arr_name.(i) sz.(j) in
      result_str := !result_str ^ (Printf.sprintf "%.4f, %.4f," mu std)
    done;
    result_str := !result_str ^ "\n"
  done;
  (* evaluate_arr_arr op *)
  for i = 0 to (Array.length fun_arr_arr - 1) do
    result_str := !result_str ^ fun_arr_arr_name.(i) ^ ",";
    for j = 0 to (Array.length sz - 1) do  
      let mu, std = evalop_arr_arr fun_arr_arr.(i) fun_arr_arr_name.(i) sz.(j) in
      result_str := !result_str ^ (Printf.sprintf "%.4f, %.4f," mu std)
    done;
    result_str := !result_str ^ "\n"
  done;
  !result_str


(* Evaluate axis operations *)

let evaluate_axis () = 
  let sz = [|[|10; 10; 10; 10|]; [|20; 20; 20; 20|]; [|30; 30; 30; 30|];
    [|40; 40; 40; 40|]; [|50; 50; 50; 50|]; [|60; 60; 60; 60|]|] in
  let sz_str = "10,,20,,30,,40,,50,,60" in
  let axis = [|0; 3|] in

  let result_str = ref ("," ^ sz_str ^ "\n") in
  for i = 0 to (Array.length fun_axis_arr - 1) do
    for k = 0 to (Array.length axis - 1) do
      result_str := !result_str ^ (Printf.sprintf "%s(axis=%d)," 
        fun_axis_arr_name.(i) axis.(k));
      for j = 0 to (Array.length sz - 1) do 
        let mu, std = evalop_axis_arr axis.(k) fun_axis_arr.(i) 
          fun_axis_arr_name.(i) sz.(j) in
        result_str := !result_str ^ (Printf.sprintf "%.4f, %.4f," mu std)
      done;
      result_str := !result_str ^ "\n"
    done;
  done;
  !result_str


let test_axes () = 
  let sz = [|[|10; 10; 10; 10|]; [|20; 20; 20; 20|]; 
    [|30; 30; 30; 30|]; [|40; 40; 40; 40|]; 
    [|50; 50; 50; 50|]; [|60; 60; 60; 60|];
    [|70; 70; 70; 70|]|] in
  let sz_str = "10,,20,,30,,40,,50,,60,,70" in
  let axes = [|[|0;3|]; [|0;2|]|] in

  let result_str = ref ("," ^ sz_str ^ "\n") in
  for i = 0 to (Array.length fun_axes_arr - 1) do
    for k = 0 to (Array.length axes - 1) do
      let axes_str = Owl_utils_array.to_string ~sep:"*" string_of_int axes.(k) in
      result_str := !result_str ^ (Printf.sprintf "%s(axes=%s)," 
        fun_axes_arr_name.(i) axes_str);
      for j = 0 to (Array.length sz - 1) do 
        let mu, std = evalop_axes_arr axes.(k) fun_axes_arr.(i) 
          fun_axes_arr_name.(i) sz.(j) in
        result_str := !result_str ^ (Printf.sprintf "%.4f, %.4f," mu std)
      done;
      result_str := !result_str ^ "\n"
    done;
  done;
  !result_str

(* Evaluate axes operations *)

let evaluate_repeat () = 
  let sz = [|[|10; 10; 10; 10|]; [|15; 15; 15; 15|]; [|20; 20; 20; 20|]; 
    [|25; 25; 25; 25|]; [|30; 30; 30; 30|]; [|35; 35; 35; 35|]|] in
  let sz_str = "10,,15,,20,,25,,30,,35" in
  let axes = [|[|1;1;1;5|]; [|1;4;4;1|]; [|3;3;3;1|]|] in 

  let result_str = ref ("," ^ sz_str ^ "\n") in
  for i = 0 to (Array.length fun_repeat - 1) do
    for k = 0 to (Array.length axes - 1) do
      let axes_str = Owl_utils_array.to_string ~sep:"*" string_of_int axes.(k) in
      result_str := !result_str ^ (Printf.sprintf "%s(axes=%s)," 
        fun_repeat_name.(i) axes_str);
      for j = 0 to (Array.length sz - 1) do 
        let mu, std = evalop_repeat axes.(k) fun_repeat.(i) 
          fun_repeat_name.(i) sz.(j) in
        result_str := !result_str ^ (Printf.sprintf "%.4f, %.4f," mu std)
      done;
      result_str := !result_str ^ "\n"
    done;
  done;
  !result_str


let evaluate_slicing () = 
  let sz = [|[|10; 300; 3000|]; [|3000; 300; 10|]|] in
  let sz_str = "10*300*3000,,3000*300*10" in
  let index = [|
    [[0;-1]; []; []]; 
    [[-1;0]; [0;1]; []];
    [[-1;0]; [-1;0]; [0]];
    [[-1]; [-1;0];[]];
    [[]; [-1;0]; []];
    [[]; [0;-1]; [-1;0]];
    [[]; [-1;0]; [0;1]];
    [[]; [0;-1]; [-1;0;-2]]
  |] in 
  let index_str = [|
    "[[0;-1]; []; []]"; 
    "[[-1;0]; [0;1]; []]";
    "[[-1;0]; [-1;0]; [0]]";
    "[[-1]; [-1;0];[]]";
    "[[]; [-1;0]; []]";
    "[[]; [0;-1]; [-1;0]]";
    "[[]; [-1;0]; [0;1]]";
    "[[]; [0;-1]; [-1;0;-2]]"
  |] in
  let result_str = ref ("," ^ sz_str ^ "\n") in
  for i = 0 to (Array.length index - 1) do
    result_str := !result_str ^ (Printf.sprintf "%s(index=%s)," 
        "get_slice" index_str.(i));
    for j = 0 to (Array.length sz - 1) do
      let mu, std = evalop_slice N.get_slice "get_slice" 
        index.(i) index_str.(i) sz.(j) in
      result_str := !result_str ^ (Printf.sprintf "%.4f, %.4f," mu std);
    done;
    result_str := !result_str ^ "\n"
  done;
  !result_str

(* Evaluate linear algebra operations *)

let evaluate_linalg () = 
  let sz = [|[|10; 10|]; [|50; 50|]; [|100; 100|];
    [|150; 150|]; [|200; 200|]; [|300; 300|]; [|400; 400|]; [|600; 600|]; 
    [|800; 800|]; [|1000; 1000|]|] in
  let sz_str = "10,,50,,100,,150,,200,,300,,400,,600,,800,,1000" in

  let result_str = ref ("," ^ sz_str ^ "\n") in
  for i = 0 to (Array.length fun_linalg - 1) do
    result_str := !result_str ^ (Printf.sprintf "%s," fun_linalg_name.(i));
    for j = 0 to (Array.length sz - 1) do 
      let mu, std = evalop_linalg fun_linalg.(i) 
          fun_linalg_name.(i) sz.(j) in
      result_str := !result_str ^ (Printf.sprintf "%.4f, %.4f," mu std)
    done;
    result_str := !result_str ^ "\n"
  done;
  !result_str


let _ = 
  evaluate_simple  () |> Owl_io.write_file "simple_owl.csv";
  evaluate_axis    () |> Owl_io.write_file "axis_owl.csv" ;
  evaluate_axes    () |> Owl_io.write_file "axes_owl.csv" ;
  evaluate_repeat  () |> Owl_io.write_file "repeat_owl.csv";
  evaluate_slicing () |> Owl_io.write_file "slice_owl.csv";
  evaluate_linalg  () |> Owl_io.write_file "linalg_owl.csv"
