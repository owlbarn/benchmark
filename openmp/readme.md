# Using OpenMP in Owl

Owl provides an option of using OpenMP in compiling. The script here briefly evaluates the impact of using OpenMP on several core N-dimensional array operations. In this doc we briefly introduce how to reproduce the results. 
**Note:** The current script selects only a few operations, and is not well-automated. It will be updated.

1. Compile and install Owl without the OpenMP option, and then run the script `crosspoint.ml`. It will generate a file `eval_omp_cross.csv`. Then run `cp eval_omp_cross.csv openmp_cross.csv`.

2. Compile and install Owl with the OpenMP option, setting the number of threads using `omp_set_num_threads` in source code `owl/core/openmp/owl_ndarray_maths_map_omp.h` (or change the environment variable) to two. And then run the script again. Manually copy the generated data (two columns) from `eval_omp_cross.csv` and append them to `openmp_cross.csv`.

3. Repeat step 2 with number of threads set to four. 

4. Now we have an `openmp_cross.csv` file with seven columns. Run the script `draw_fig.py` to visualise these data.