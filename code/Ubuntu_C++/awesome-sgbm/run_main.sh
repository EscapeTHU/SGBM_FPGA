cd build
cmake ..&& make
cd ..
# ./bin/semi_global_matching ./Data/Cloth3/left.png ./Data/Cloth3/right.png 0 128 7

#./bin/semi_global_matching ./Data/cone_big/left.png         ./Data/cone_big/right.png 0 128 5 
./bin/cencus_in ./Data/FPGA_proc/cencus/census_left_X.txt   ./Data/FPGA_proc/cencus/census_right_X.txt 0 128 5

# ./bin/semi_global_matching ./Data/Reindeer/left.png     .Data/Reindeer/right.png 0 128

# ./bin/semi_global_matching ./Data/Wood2/left.png        .Data/Wood2/right.png 0 128

# ./bin/semi_global_matching ./Data/grass/1/left.png      .Data/grass/1/right.png 0 180

# ./bin/semi_global_matching ./Data/grass/2/left.png      .Data/grass/2/right.png 0 180




