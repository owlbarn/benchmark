#!/usr/bin/python

import csv 
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.pylab as pylab

font=13 #'x-large'
params = {'legend.fontsize': font,
         #'figure.figsize': (160, 100),
         'axes.labelsize': font,
         'axes.titlesize': font,
         'xtick.labelsize':font,
         'ytick.labelsize':font}
matplotlib.rcParams.update(params)

N = 7 # number of function
nt = 11 # number of test cases for each fucntion
n = 3 # number of test cases: no-omp, omp-thrd=2, ...
label = ['no-omp', 'omp-thrd-2', 'omp-thrd-4']
ops = ['abs', 'sin', 'erf', 'add', 'pow', 'copy', 'conv2d']
mus = [[], [], []]; stds = [[], [], []]; sizes = []
with open("openmp_cross.csv", 'rb') as csvf:
    reader = csv.reader(csvf, delimiter=',')
    for val in reader:
        sizes.append(float(val[0]))
        mus[0].append(float(val[1]))
        mus[1].append(float(val[3]))
        mus[2].append(float(val[5]))
        stds[0].append(float(val[2]))
        stds[1].append(float(val[4]))
        stds[2].append(float(val[6]))

figs = []; ax = []

fig, ax = plt.subplots(2,2)
for i in range(4):
	rects = []
	axes = ax[i / 2][i % 2]

	for j in range(n):
	    rects.append(axes.errorbar(sizes[i * nt : (i+1) * nt - 1], mus[j][i * nt : (i+1) * nt - 1],
	        yerr=stds[j][i * nt : (i + 1) * nt - 1], label=label[j]))
	axes.set_ylabel('Time(ms)')
	axes.set_xlabel('Input array size for op ' + ops[i])
	axes.set_xscale('log', nonposx='clip')
	axes.set_yscale('log')
	axes.legend()
	axes.grid(True)


fig, ax = plt.subplots(1,2)
for i in range(4,6):
	axes = ax[i - 5]
	for j in range(n):
	    rects.append(axes.errorbar(sizes[i * nt : (i+1) * nt - 1], mus[j][i * nt : (i+1) * nt - 1],
	        yerr=stds[j][i * nt : (i + 1) * nt - 1], label=label[j]))
	axes.set_ylabel('Time(ms)')
	axes.set_xlabel('Input array size for op ' + ops[i])
	axes.set_xscale('log', nonposx='clip')
	axes.set_yscale('log')
	axes.legend()
	axes.grid(True)


fig, axes = plt.subplots(1,1)
i = 6
for j in range(n):
    rects.append(axes.errorbar(sizes[i * nt : (i+1) * nt - 1], mus[j][i * nt : (i+1) * nt - 1],
        yerr=stds[j][i * nt : (i + 1) * nt - 1], label=label[j]))
axes.set_ylabel('Time(ms)')
axes.set_xlabel('Input array size for op ' + ops[i])
axes.set_xscale('log', nonposx='clip')
axes.set_yscale('log')
axes.legend()
axes.grid(True)

plt.show()
