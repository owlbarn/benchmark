# Core operations evaluation

These scripts compare the performance of core N-dimensional array operations of Owl with NumPy and Julia. The evaluation results on one of our tested machines and detailed analysis can be seen at one [chapter](http://ocaml.xyz/chapter/perfcmp.html) of Owl's documentation. Here briefly introduce how to reproduce these results:

1. Run the three scripts (`op_eval.ml`, `op_eval.py`, and `op_eval.jl`) separately. Each will generate several csv files in current directory.

2. Run the python script `draw_figure.py`. It will create a `./fig` directory if it does not exist, and save generated figures there. 
