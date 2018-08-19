#!/usr/bin/env julia

fun_arr_arr = [(+), (.*), (./), (.^), hypot, min, mod]
fun_arr_arr_name = ["add", "mul", "div", "pow", "hypot", "min2", "fmod"]

function sigmoid(z)
    return 1.0 ./ (1.0 .+ exp.(-z))
end
function sqrt_a(z)
    return sqrt.(z)
end
function exp_a(z)
    return exp.(z)
end

fun_arr = [copy, abs, exp_a, log, sqrt_a, cbrt, sin, tan, 
  asin, sinh, asinh, round, sort, sigmoid]
fun_arr_name = ["copy", "abs", "exp", "log", "sqrt", "cbrt", "sin", "tan", 
  "asin", "sinh", "asinh", "round", "sort", "sigmoid"]

fun_axis_arr = [maximum, sum, prod, cumprod, cummax]
fun_axis_arr_name = ["max", "sum", "prod", "cumprod", "cummax"]

fun_axes_arr = [sum]
fun_axes_arr_name = ["sum_reduce"]

function matm(x) return x * x end 
fun_linalg = [matm, inv, eigvals, svd, lu, qr]
fun_linalg_name = ["matmul", "inv", "eigvals", "svd", "lu", "qr"]

function rep(x, s)
  return repeat(x, inner=s)
end
function tile(x, s)
  return repeat(x, outer=s)
end
fun_repeat = [rep, tile]
fun_repeat_name = ["repeat", "tile"]


function time_fun(fn)
    return (@elapsed fn()) * 1000
end


function remove_outlier(arr)
    fp = quantile(arr, 0.25)
    tp = quantile(arr, 0.75)
    return filter(x -> (x >= fp) && (x <= tp), arr)
end


function timing(fn, msg)
    c = 30
    ts = Float32[]
    for i = 1:c
        t = fn()
        push!(ts, t)
    end
    ts = remove_outlier(ts)
    m = mean(ts)
    s = std(ts)
    @printf("| %s :\t mean = %.5f \t std = %.5f\n", msg, m, s)
    return m, s
end


function evalop_arr_arr(fn, name, sz)
    function f() 
        inp1 = rand(Float32, sz)
        inp2 = rand(Float32, sz)
        discard = fn(inp1, inp2)
        function g()
            return fn(inp1, inp2)
        end
        return time_fun(g)
    end
    return timing(f, @sprintf("%s (%d)", name, sz))
end


function evalop_arr(fn, name, sz)
    function f() 
        inp = rand(Float32, sz)
        discard = fn(inp)
        function g()
            return fn(inp)
        end
        return time_fun(g)
    end
    return timing(f, @sprintf("%s (%d)", name, sz))
end


function evalop_axis_arr(axis, fn, name, sz)
    function f()
        inp = rand(Float32, sz)
        discard = fn(inp, axis)
        function g() 
            return fn(inp, axis)
        end
        return time_fun(g)
    end
    return timing(f, @sprintf("%s (axis=%d, %s)", name, axis, string(sz)))
end


function evalop_axes_arr(axis, fn, name, sz)
    function f()
        inp = rand(Float32, sz)
        discard = fn(inp, axis)
        function g() 
            return fn(inp, axis)
        end
        return time_fun(g)
    end
    return timing(f, @sprintf("%s (axis=%s, %s)", name, string(axis), string(sz)))
end


function evalop_repeat(axes, fn, name, sz)
    function f() 
        inp = rand(Float32, sz)
        discard = fn(inp, axes)
        function g()
            return fn(inp, axes)
        end
        return time_fun(g)
    end
    return timing(f, @sprintf("%s (axis=%s, %s)", name, string(axes), string(sz)))
end


# TODO : more general unpacking
function evalop_slice(idx, idx_str, sz)
    function f()
        inp = rand(Float32, sz)
        function g()
            i1, i2, i3 = idx
            return inp[i1, i2, i3]
        end
        return time_fun(g)
    end
    return timing(f, @sprintf("%s (%s)", "get_slice", idx_str))
end


function evalop_linalg(fn, name, sz)
    function f() 
        inp = rand(Float32, sz)
        discard = fn(inp)
        function g()
            return fn(inp)
        end
        return time_fun(g)
    end
    return timing(f, @sprintf("%s (%d*%d)", name, sz[1], sz[2]))
end


function evaluate_simple()
    sz = [10, 100, 1000, 10000, 100000, 200000, 400000, 600000, 800000, 1000000]
    sz_str = "10,,100,,1000,,1e4,,1e5,,2e5,,4e5,,6e5,,8e5,,1e6"

    result_str = "," * sz_str * "\n"
    for i = 1:length(fun_arr)
        result_str *= fun_arr_name[i] * ","
        for j = 1:length(sz)
            mu, std = evalop_arr(fun_arr[i], fun_arr_name[i], sz[j])
            result_str *= @sprintf("%.4f, %.4f,", mu, std)
        end
        result_str *= "\n"
    end 

    for i = 1:length(fun_arr_arr)
        result_str *= fun_arr_arr_name[i] * ","
        for j = 1:length(sz)
            mu, std = evalop_arr_arr(fun_arr_arr[i], fun_arr_arr_name[i], sz[j])
            result_str *= @sprintf("%.4f, %.4f,", mu, std)
        end
        result_str *= "\n"
    end
    return result_str
end


function evaluate_axis()
    sz = [(10, 10, 10, 10), (20, 20, 20, 20), (30, 30, 30, 30),
        (40, 40, 40, 40), (50, 50, 50, 50), (60, 60, 60, 60)]
    sz_str = "10,,20,,30,,40,,50,,60"
    axis = [1,4]
    result_str = "," * sz_str * "\n"
    for i = 1:length(fun_axis_arr)
        for k = 1:length(axis)
            result_str *= @sprintf("%s(axis=%d),", fun_axis_arr_name[i], (axis[k] - 1))
            for j = 1:length(sz)
                mu, std = evalop_axis_arr(axis[k], fun_axis_arr[i], 
                    fun_axis_arr_name[i], sz[j])
                result_str *= @sprintf("%.4f, %.4f,", mu, std)
            end
            result_str *= "\n"
        end
    end
    return result_str
end


function test_axes()
    sz = [(10, 10, 10, 10), (20, 20, 20, 20), (30, 30, 30, 30),
        (40, 40, 40, 40), (50, 50, 50, 50), (60, 60, 60, 60), (70, 70, 70, 70)]
    sz_str = "10,,20,,30,,40,,50,,60,,70"
    axis = [(1,4), (1,3)]
    axis_for_str = [(0,3), (0,2)]
    result_str = "," * sz_str * "\n"
    for i = 1:length(fun_axes_arr)
        for k = 1:length(axis)
            axes_str = join(axis_for_str[k], '*')
            result_str *= @sprintf("%s(axes=%s),", fun_axes_arr_name[i], axes_str)
            for j = 1:length(sz)
                mu, std = evalop_axes_arr(axis[k], fun_axes_arr[i], 
                    fun_axes_arr_name[i], sz[j])
                result_str *= @sprintf("%.4f, %.4f,", mu, std)
            end
            result_str *= "\n"
        end
    end
    return result_str
end


function evaluate_repeat()
    sz = [(10, 10, 10, 10), (15, 15, 15, 15), (20, 20, 20, 20), 
        (25, 25, 25, 25), (30, 30, 30, 30), (35, 35, 35, 35)]
    sz_str = "10,,15,,20,,25,,30,,35"
    axes = [(1,1,1,5), (1,4,4,1), (3,3,3,1), (2,2,2,2)]

    result_str = "," * sz_str * "\n"
    for i = 1:length(fun_repeat)
        for k = 1:length(axes)
            axes_str = join(axes[k], '*')
            result_str *=  @sprintf("%s(axes=%s),", fun_repeat_name[i], axes_str)
            for j = 1:length(sz)
                mu, std = evalop_repeat(axes[k], fun_repeat[i], fun_repeat_name[i], sz[j])
                result_str *= @sprintf("%.4f, %.4f,", mu, std)
            end
            result_str *= "\n"
        end
    end
    return result_str
end


# TODO: use general unpack operations; the index is not flexible
function evaluate_slice()
    sz = [(10, 300, 3000), (3000, 300, 10)]
    sz_str = "10*300*3000,,3000*300*10"

    index1 = [ 
        [1:10, :, :],
        [10:-1:1, 1:2, :],
        [10:-1:1, 300:-1:1, 1],
        [10, 300:-1:1, :],
        [:, 300:-1:1, :],
        [:, 1:300, 3000:-1:1],
        [:, 300:-1:1, 1:2],
        [:, 1:300, 3000:-2:1]
    ]
    index2 = [ 
        [1:3000, :, :],
        [3000:-1:1, 1:2, :],
        [3000:-1:1, 300:-1:1, 1],
        [3000, 300:-1:1, :],
        [:, 300:-1:1, :],
        [:, 1:300, 10:-1:1],
        [:, 300:-1:1, 1:2],
        [:, 1:300, 10:-2:1]
    ]
    index = [index1, index2]

    index_str = [ 
        "[[0;-1]; []; []]", "[[-1;0]; [0;1]; []]",
        "[[-1;0]; [-1;0]; [0]]", "[[-1]; [-1;0];[]]",
        "[[]; [-1;0]; []]", "[[]; [0;-1]; [-1;0]]",
        "[[]; [-1;0]; [0;1]]", "[[]; [0;-1]; [-1;0;-2]]"]
  
    result_str = "," * sz_str * "\n"
    for i = 1:length(index[1])
        result_str *= @sprintf("%s(index=%s),", "get_slice", index_str[i])
        for j = 1:length(sz)
            mu, std = evalop_slice(index[j][i], index_str[i], sz[j]) 
            result_str *= @sprintf("%.4f, %.4f,", mu, std)
        end
        result_str *= "\n"
    end
    return result_str
end


function evaluate_linalg()
    sz = [(10, 10), (50, 50), (100, 100),
        (150, 150), (200, 200), (300, 300), (400, 400),
        (600, 600), (800, 800), (1000, 1000)]
    sz_str = "10,,50,,100,,150,,200,,300,,400,,600,,800,,1000"

    result_str = "," * sz_str * "\n"
    for i = 1:length(fun_linalg)
        result_str *= @sprintf("%s,", fun_linalg_name[i])
        for j = 1:length(sz)
            mu, std = evalop_linalg(fun_linalg[i],
                fun_linalg_name[i], sz[j])
            result_str *= @sprintf("%.4f, %.4f,", mu, std)
        end
        result_str *= "\n"
    end
    return result_str
end


function write_file(fname, output_str)
    open(fname, "w") do f 
        write(f, output_str)
    end
end    


write_file("simple_julia.csv", evaluate_simple())
write_file("axis_julia.csv",   evaluate_axis())
write_file("axes_julia.csv",   evaluate_axes())
#write_file("repeat_julia.csv", evaluate_repeat())
write_file("slice_julia.csv",  evaluate_slice())
write_file("linalg_julia.csv", evaluate_linalg())
