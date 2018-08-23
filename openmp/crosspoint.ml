open Owl
module N = Dense.Ndarray.S

let dummy_zero = N.zeros [|1|]
let copy_mutable ?(out=dummy_zero) x y = 
	N.copy_ ~out:y x 

let dummy_conv2d out inp kern stride = 
	N.conv2d_ ~out ~padding:SAME inp kern stride

let funarr1 = [|N.abs_; N.sin_; N.erf_;|]
let funarr2 = [|N.add_; N.pow_; copy_mutable|]
let funarr3 = [|dummy_conv2d|]

let test_len = [|10; 100; 1000; 10000; 100000; 200000; 400000; 600000; 800000; 1000000; 2000000|]
let n = Array.length test_len 
let test_len_f = Array.map float_of_int test_len 
let test_len_sqrt = N.(of_array test_len_f [|n|] |> sqrt |> to_array |> Array.map int_of_float)

let remove_outlier arr = 
  let first_perc = Owl_stats.percentile arr 25. in
  let third_perc = Owl_stats.percentile arr 75. in 
  let lst = Array.to_list arr in 
  List.filter (fun x -> (x >= first_perc) && (x <= third_perc)) lst 
  	|> Array.of_list 

let timing fn msg = 
	let c = 40 in 
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

let f_timing_wrapper1 fn sz = 
	let f () = 
		let inp = N.uniform [|sz|] in 
		let g () = fn inp in
		Owl_utils.time g
	in
	timing f (string_of_int sz)


let f_timing_wrapper2 fn sz = 
	let f () = 
		let inp1 = N.uniform [|sz|] in
		let inp2 = N.uniform [|sz|] in
		let g () = fn inp1 inp2 in
		Owl_utils.time g
	in
	timing f (string_of_int sz)


let f_timing_wrapper3 fn sz = 
	let f () = 
		let inp  = N.uniform [|1; sz; sz; 1|] in
		let ker  = N.ones [|3;3;1;1|] in
		let os   = Owl_utils_infer_shape.conv2d [|1; sz; sz; 1|] SAME [|3;3;1;1|] [|1;1|] in 
		let out  = N.uniform os in
		let g () = fn out inp ker [|1;1|] in
		Owl_utils.time g
	in
	timing f (string_of_int sz)

let main () = 
	let result_str = ref "" in

	for i = 0 to Array.length funarr1 - 1 do
		let fn = funarr1.(i) in
		for j = 0 to Array.length test_len - 1 do
			let sz = test_len.(j) in 
			let mu, std = f_timing_wrapper1 fn sz in
			result_str := !result_str ^ (Printf.sprintf "%d, %.4f, %.4f\n" sz mu std)
		done
	done;

	for i = 0 to Array.length funarr2 - 1 do
		let fn = funarr2.(i) in
		for j = 0 to Array.length test_len - 1 do
			let sz = test_len.(j) in 
			let mu, std = f_timing_wrapper2 fn sz in
			result_str := !result_str ^ (Printf.sprintf "%d, %.4f, %.4f\n" sz mu std)
		done
	done;
  
	for i = 0 to Array.length funarr3 - 1 do
		let fn = funarr3.(i) in
		for j = 0 to Array.length test_len_sqrt - 1 do
			let sz = test_len_sqrt.(j) in 
			let mu, std = f_timing_wrapper3 fn sz in
			result_str := !result_str ^ (Printf.sprintf "%d, %.4f, %.4f\n" (test_len.(j)) mu std)
		done
	done;

	Owl_io.write_file "eval_omp_cross.csv" !result_str;
	()

let _ = main ()

