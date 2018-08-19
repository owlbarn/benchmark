#!/usr/bin/python

import numpy as np
import scipy.special as sp
import scipy.linalg
import time
import math

fun_arr_arr = [np.add, np.multiply, np.divide, np.power, np.hypot, np.minimum, np.fmod]
fun_arr_arr_name = ["add", "mul", "div", "pow", "hypot", "min2", "fmod"]

def sigmoid(x): return 1 / (1 + np.exp(-x))
fun_arr = [np.copy, np.abs, np.exp, np.log, np.sqrt, np.cbrt, np.sin, np.tan, 
  np.arcsin, np.sinh, np.arcsinh, np.round, np.sort, sigmoid]
fun_arr_name = ["copy", "abs", "exp", "log", "sqrt", "cbrt", "sin", "tan", 
  "asin", "sinh", "asinh", "round", "sort", "sigmoid"]

fun_axis_arr = [np.max, np.sum, np.prod, np.cumprod, np.maximum.accumulate]
fun_axis_arr_name = ["max", "sum", "prod", "cumprod", "cummax"]

fun_axes_arr = [np.sum]
fun_axes_arr_name = ["sum_reduce"]

def rep(x, axes):
    y = x
    for a, r in enumerate(axes):
        y = np.repeat(y, r, axis=a)
    return y
fun_repeat = [np.tile, rep]
fun_repeat_name = ["tile","repeat"]

def matm(x) : return np.matmul(x, x)
fun_linalg = [matm, np.linalg.inv, np.linalg.eigvals, np.linalg.svd, 
    scipy.linalg.lu, np.linalg.qr]
fun_linalg_name = ["matmul", "inv", "eigvals", "svd", "lu", "qr"]


def time_fun(fn):
    start = time.time()
    fn()
    end = time.time()
    return (end - start) * 1000

def remove_outlier(arr):
    fp = np.percentile(arr, 25)
    tp = np.percentile(arr, 75)
    return filter(lambda x : (x >= fp) and (x <= tp), arr)

def timing(fn, msg):
    c = 30
    times = []
    for i in range(c):
        t = fn()
        times.append(t)
    times = remove_outlier(times)
    m_time = np.mean(times)
    s_time = np.std(times) 
    print "| %s :\t mean = %.5f \t std = %.5f" % (msg, m_time, s_time)
    return m_time, s_time

def uniform(sz):
    a = np.random.rand(sz)
    return a.astype('float32')
def uniform_unpack(sz):
    a = np.random.rand(*sz)
    return a.astype('float32')

def evalop_arr_arr(fn, name, sz): 
  def f(): 
    inp1 = uniform(sz)
    inp2 = uniform(sz)
    def g(): return fn(inp1, inp2)
    return time_fun(g)
  return timing(f, "%s (%d)" % (name, sz))


def evalop_arr(fn, name, sz): 
  def f(): 
    inp= uniform(sz)
    def g(): return fn(inp)
    return time_fun(g)
  return timing(f, "%s (%d)" % (name, sz))


def evalop_axis_arr(axis, fn, name, sz):
    def f ():
        inp = uniform_unpack(sz)
        def g(): return fn(inp, axis=axis)
        return time_fun(g)
    return timing(f, "%s (axis=%d, %s)" % (name, axis, str(sz)))


def evalop_axes_arr(axis, fn, name, sz):
    def f ():
        inp = uniform_unpack(sz)
        def g(): return fn(inp, axis=axis)
        return time_fun(g)
    return timing(f, "%s (axes=%s, %s)" % (name, str(axis), str(sz)))


def evalop_repeat(axes, fn, name, sz): 
    def f(): 
        inp = np.ones(sz)
        def g() : return fn(inp, axes) 
        return time_fun(g)
    return timing(f, "%s (axis=%s, %s)" % (name, str(axes), str(sz)))


def evalop_slice(idx, idx_str, sz): 
    def f(): 
        inp = uniform_unpack(sz)
        def g() : return inp[idx].copy()
        return time_fun(g)
    return timing(f, "%s (%s)" % ('get_slice', idx_str))


def evalop_linalg(fn, name, sz): 
    def f(): 
        inp = uniform_unpack(sz)
        def g(): return fn(inp)
        return time_fun(g)
    return timing(f, "%s (%d*%d)" % (name, sz[0], sz[1]))


def test_simple():
    sz = [10, 100, 1000, 10000, 100000, 200000, 400000, 600000, 800000, 1000000]
    sz_str = "10,,100,,1000,,1e4,,1e5,,2e5,,4e5,,6e5,,8e5,,1e6"

    result_str = "," + sz_str + "\n"
    for i in range(len(fun_arr)):
        result_str += fun_arr_name[i] + ","
        for j in range(len(sz)):
            mu, std = evalop_arr(fun_arr[i], fun_arr_name[i], sz[j])
            result_str += "%.4f, %.4f," % (mu, std)
        result_str += "\n"

    for i in range(len(fun_arr_arr)):
        result_str += fun_arr_arr_name[i] + ","
        for j in range(len(sz)):
            mu, std = evalop_arr_arr(fun_arr_arr[i], fun_arr_arr_name[i], sz[j])
            result_str += "%.4f, %.4f," % (mu, std)
        result_str += "\n"

    return result_str


def test_axis():
  sz = [[10, 10, 10, 10], [20, 20, 20, 20], [30, 30, 30, 30],
    [40, 40, 40, 40], [50, 50, 50, 50], [60, 60, 60, 60]]
  sz_str = "10,,20,,30,,40,,50,,60"
  axis = [0,3]
  result_str = "," + sz_str + "\n"
  for i in range(len(fun_axis_arr)):
    for k in range(len(axis)):
      result_str += "%s(axis=%d)," % (fun_axis_arr_name[i], axis[k])
      for j in range(len(sz)):
        mu, std = evalop_axis_arr(axis[k], fun_axis_arr[i], 
            fun_axis_arr_name[i], sz[j])
        result_str += "%.4f, %.4f," % (mu, std)
      result_str += "\n"
  return result_str

def test_axes():
  sz = [[10, 10, 10, 10], [20, 20, 20, 20], [30, 30, 30, 30],
    [40, 40, 40, 40], [50, 50, 50, 50], [60, 60, 60, 60],
    [70, 70, 70, 70]]
  sz_str = "10,,20,,30,,40,,50,,60,,70"
  axes = [(0,3), (0,2)]
  result_str = "," + sz_str + "\n"
  for i in range(len(fun_axes_arr)):
    for k in range(len(axes)):
      axes_str = '*'.join(map(str, axes[k]))
      result_str += "%s(axes=%s)," % (fun_axes_arr_name[i], axes_str)
      for j in range(len(sz)):
        mu, std = evalop_axes_arr(axes[k], fun_axes_arr[i], 
            fun_axes_arr_name[i], sz[j])
        result_str += "%.4f, %.4f," % (mu, std)
      result_str += "\n"
  return result_str

def test_repeat(): 
  sz = [[10, 10, 10, 10], [15, 15, 15, 15], [20, 20, 20, 20], 
    [25, 25, 25, 25], [30, 30, 30, 30], [35, 35, 35, 35]] 
  sz_str = "10,,15,,20,,25,,30,,35"
  axes = [[1,1,1,5], [1,4,4,1], [3,3,3,1]]

  result_str = "," + sz_str + "\n"
  for i in range(len(fun_repeat)):
      for k in range(len(axes)):
        axes_str = '*'.join(map(str, axes[k]))
        result_str +=  "%s(axes=%s),"  % (fun_repeat_name[i], axes_str)
        for j in range(len(sz)):
            mu, std = evalop_repeat(axes[k], fun_repeat[i], fun_repeat_name[i], sz[j])
            result_str += "%.4f, %.4f," % (mu, std)
        result_str += "\n"
  return result_str


def test_slicing (): 
    sz = [[10, 300, 3000], [3000, 300, 10]]
    sz_str = "10*300*3000,,3000*300*10"
    index = [
        [slice(0, -1), slice(None, None), slice(None, None)],
        [slice(-1, 0, -1), slice(0, 1), slice(None, None)],
        [slice(-1, 0, -1), slice(-1, 0, -1), [0]],
        [[-1], slice(-1, 0, -1), slice(None, None)],
        [slice(None, None), slice(-1, 0, -1), slice(None, None)],
        [slice(None, None), slice(0, -1), slice(-1, 0, -1)],
        [slice(None, None), slice(-1, 0, -1),  slice(0, 1)],
        [slice(None, None), slice(0, -1), slice(-1, 0, -2)]]
    index_str = [ 
        "[[0;-1]; []; []]", "[[-1;0]; [0;1]; []]",
        "[[-1;0]; [-1;0]; [0]]", "[[-1]; [-1;0];[]]",
        "[[]; [-1;0]; []]", "[[]; [0;-1]; [-1;0]]",
        "[[]; [-1;0]; [0;1]]", "[[]; [0;-1]; [-1;0;-2]]"]

    result_str = "," + sz_str + "\n"
    for i in range(len(index)):
        result_str += "%s(index=%s)," % ("get_slice", index_str[i])
        for j in range(len(sz)):
            mu, std = evalop_slice(index[i], index_str[i], sz[j]) #!
            result_str += "%.4f, %.4f," % (mu, std)  
        result_str += "\n"
    return result_str


def test_linalg ():
    sz = [[10, 10], [50, 50], [100, 100],
        [150, 150], [200, 200], [300, 300], [400, 400],
        [600, 600], [800, 800], [1000, 1000]]
    sz_str = "10,,50,,100,,150,,200,,300,,400,,600,,800,,1000"

    result_str = "," + sz_str + "\n"
    for i in range(len(fun_linalg)):
        result_str += "%s," % fun_linalg_name[i]
        for j in range(len(sz)):
            mu, std = evalop_linalg(fun_linalg[i],
                fun_linalg_name[i], sz[j])
            result_str += "%.4f, %.4f," % (mu, std)
        result_str += "\n"
    return result_str


def write_file(fname, output_str):
    with open(fname, "w") as csv:
        csv.write(output_str)

write_file('simple_np.csv', test_simple())
write_file('axis_np.csv',   test_axis())
write_file('axes_np.csv',   test_axes())
write_file('repeat_np.csv', test_repeat())
write_file('slice_np.csv',  test_slicing())
write_file('linalg_np.csv', test_linalg())
