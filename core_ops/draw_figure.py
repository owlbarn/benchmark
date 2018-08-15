import csv 
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.pylab as pylab
import collections

font=16 #'x-large'
params = {'legend.fontsize': font,
         'figure.figsize': (1000, 500),
         'axes.labelsize': font,
         'axes.titlesize': font,
         'xtick.labelsize':font,
         'ytick.labelsize':font}

figs = []; axes = []
linestyle = ['-','--','-.']
markers   = ['^','o','s']

"""
1. Draw simple operations
"""


def draw_simple():
    simple_data = []
    for f in ['simple_owl.csv', 'simple_np.csv', 'simple_julia.csv']:
        simple_owl_dict = {}
        simple_owl = open(f, 'rb')
        reader_owl = csv.reader(simple_owl, delimiter=',')
        header_owl = reader_owl.next()
        header_owl = header_owl[1:len(header_owl):2]
        header_owl = [int(float((x))) for x in header_owl]
        for val in reader_owl:
            name = val[0]
            mean = []; std  = []
            for i in xrange(1, len(val) - 1, 2):
                mean.append(float(val[i].strip()))
                std.append(float(val[i+1].strip()))
            simple_owl_dict[name] = (mean, std)
        simple_owl.close()
        simple_data.append(simple_owl_dict)


    keys = simple_data[0].keys()#[0:9]
    for i, op in enumerate(keys):
        fig, axis = plt.subplots(1,1)
        rects = []
        for j, lib in enumerate(['Owl', 'Numpy', 'Julia']):
            rects.append(axis.errorbar(header_owl, simple_data[j][op][0], 
                yerr=simple_data[j][op][1], linestyle=linestyle[j], 
                marker=markers[j], label=lib))
        axis.set_xscale('log')
        axis.legend()
        axis.set_ylabel('Time(ms)')
        axis.set_xlabel('Input array size')
        axis.set_title(op)
        figs.append(fig)
        axes.append(axis)


"""
2. Draw axis operations
"""

def draw_axis():
    axis_data = []
    for f in ['axis_owl.csv', 'axis_np.csv', 'axis_julia.csv']:
        axis_owl_dict = collections.defaultdict(dict)
        axis_owl = open(f, 'rb')
        reader_owl_ax = csv.reader(axis_owl, delimiter=',')
        header_owl_ax = reader_owl_ax.next()
        header_owl_ax = header_owl_ax[1:len(header_owl_ax):2]
        for val in reader_owl_ax:
            name = val[0].split('(')[0]
            axis = val[0][-2]; 
            mean = []; std  = []
            for i in xrange(1, len(val) - 1, 2):
                mean.append(float(val[i].strip()))
                std.append(float(val[i+1].strip()))
            axis_owl_dict[name][int(axis)] = (mean, std)
        axis_owl.close()
        axis_data.append(axis_owl_dict)


    figs_axis= []; axes_axis = []
    keys = axis_data[0].keys()
    for i, op in enumerate(keys):
        fig, axis = plt.subplots(1,1)
        rects = []
        for a in axis_data[0][op].keys():
            for j, lib in enumerate(['Owl', 'Numpy', 'Julia']):
                rects.append(axis.errorbar(header_owl_ax, axis_data[j][op][a][0], 
                    yerr=axis_data[j][op][a][1], linestyle=linestyle[j], marker=markers[j],
                    label=lib + ', axis=' + str(a)))
        #axis.set_xscale('log')
        axis.legend()
        axis.set_ylabel('Time(ms)')
        axis.set_xlabel('Input array size')
        axis.set_title(op)
        figs.append(fig)
        axes.append(axis)

"""
3. Draw repeat operations
"""

def draw_repeat():
    repeat_data = []
    for f in ['repeat_owl.csv', 'repeat_np.csv']:
        repeat_dict = collections.defaultdict(dict)
        repeat_file = open(f, 'rb')
        reader_repeat = csv.reader(repeat_file, delimiter=',')
        header_repeat = reader_repeat.next()
        header_repeat = header_repeat[1:len(header_repeat):2]
        header_repeat = [int(float((x))) for x in header_repeat]
        for val in reader_repeat:
            name = val[0].split('(')[0]
            ax   = val[0].split('=')[1][:-1]; 
            mean = []; std  = []
            for i in xrange(1, len(val) - 1, 2):
                mean.append(float(val[i].strip()))
                std.append(float(val[i+1].strip()))
            repeat_dict[name][ax] = (mean, std)
        repeat_file.close()
        repeat_data.append(repeat_dict)


    keys = repeat_data[0].keys()
    for i, op in enumerate(keys):
        fig, axis = plt.subplots(1,1)
        rects = []
        for a in repeat_data[0][op].keys():
            rects.append(axis.errorbar(header_repeat, repeat_data[0][op][a][0], 
                yerr=repeat_data[0][op][a][1], linestyle=linestyle[0], 
                marker=markers[0], label='Owl, axis=' + a))
            rects.append(axis.errorbar(header_repeat, repeat_data[1][op][a][0], 
                yerr=repeat_data[1][op][a][1], linestyle=linestyle[1], 
                marker=markers[1], label='Numpy, axis=' + a))
        axis.legend()
        axis.set_ylabel('Time(ms)')
        axis.set_xlabel('Single dimension size for a 4d array input')
        axis.set_title(op)
        figs.append(fig)
        axes.append(axis)

"""
4. Draw slicing operations
"""

def draw_slice():
    slice_data = []
    for f in ['slice_owl.csv', 'slice_np.csv', 'slice_julia.csv']:
        slice_dict = collections.defaultdict(dict)
        slice_file = open(f, 'rb')
        reader_slice = csv.reader(slice_file, delimiter=',')
        header_slice = reader_slice.next()
        header_slice = header_slice[1:len(header_slice):2]
        for val in reader_slice:
            print val
            name = 'get_slice'
            idx  = val[0].split('=')[1][:-1]; 
            mean = []; std  = []
            for i in xrange(1, len(val) - 1, 2):
                mean.append(float(val[i].strip()))
                std.append(float(val[i+1].strip()))
            slice_dict[name][idx] = (mean, std)
        slice_file.close()
        slice_data.append(slice_dict)


    slice_alter = collections.defaultdict(dict)
    keys = slice_data[0]['get_slice'].keys()

    for i, key in enumerate(keys):
        for j, lib in enumerate(['Owl','Numpy', 'Julia']):
            m, s = slice_data[j]['get_slice'][key]
            for k, sz in enumerate(header_slice):
                try:
                    slice_alter[lib][sz][0].append(m[k])
                    slice_alter[lib][sz][1].append(s[k])
                except KeyError as e:
                    slice_alter[lib][sz] = [[m[k]], [s[k]]]

    bar_width = 0.13
    fig, axis = plt.subplots(1,1)
    rects = []
    ind = np.arange(len(keys))
    counter = 0
    for j, sz in enumerate(slice_alter[lib].keys()):
        for i, lib in enumerate(['Owl', 'Numpy', 'Julia']):
            m, s = slice_alter[lib][sz]
            rects.append(axis.bar(ind + bar_width * counter, m,
                bar_width, 
                yerr=s,
                label=lib + ', ' + sz))
            counter += 1
        plt.xticks(ind + (counter / 2) * bar_width, keys, rotation='344')
        axis.legend()
        axis.set_ylabel('Time(ms)')
        axis.set_xlabel('Index')
        axis.set_title('get_slice')
    figs.append(fig)
    axes.append(axis)


"""
5. Draw linalg operations
"""

def draw_linalg():
    linalg_data = []
    for f in ['linalg_owl.csv', 'linalg_np.csv', 'linalg_julia.csv']:
        linalg_owl_dict = {}
        linalg_owl = open(f, 'rb')
        reader_owl = csv.reader(linalg_owl, delimiter=',')
        header_owl = reader_owl.next()
        header_owl = header_owl[1:len(header_owl):2]
        header_owl = [int(float((x))) for x in header_owl]
        for val in reader_owl:
            name = val[0]
            mean = []; std  = []
            for i in xrange(1, len(val) - 1, 2):
                mean.append(float(val[i].strip()))
                std.append(float(val[i+1].strip()))
            linalg_owl_dict[name] = (mean, std)
        linalg_owl.close()
        linalg_data.append(linalg_owl_dict)


    keys = linalg_data[0].keys()[0:9]
    for i, op in enumerate(keys):
        fig, axis = plt.subplots(1,1)
        rects = []
        for j, lib in enumerate(['Owl', 'Numpy', 'Julia']):
            rects.append(axis.errorbar(header_owl, linalg_data[j][op][0], 
                yerr=linalg_data[j][op][1], linestyle=linestyle[j],
                marker=markers[j],label=lib))
        axis.set_xscale('log')
        axis.legend()
        axis.set_ylabel('Time(ms)')
        axis.set_xlabel('Height and width size of input matrix')
        axis.set_title(op)
        figs.append(fig)
        axes.append(axis)

draw_simple()
draw_axis()
draw_repeat()
draw_slice()
draw_linalg()

#plt.show()

counter = 0
prefix = 'fig/'
for fig in figs:
    fig.savefig(prefix +'op_eval' + str(counter) + '.png', dpi=500)
    counter += 1
