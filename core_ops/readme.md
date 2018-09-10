# Core operations evaluation

These scripts compare the performance of core N-dimensional array operations with NumPy and Julia. The evaluation results on one of our tested machines and detailed analysis can be seen [here](http://ocaml.xyz/chapter/perfcmp.html). Here briefly introduce how to reproduce these results:

1. Run the three scrpits (`op_eval.ml`, `op_eval.py`, and `op_eval.jl`) seperately. Each will generate several csv files in current directory.

2. Run the python script `draw_figure.py`. It will create a `./fig` directory if it does not exist, and save generated figures there. 
