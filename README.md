# SGBM_FPGA
## Before Start
ALL CODE HAS BEEN UPDATED TO MAIN BRANCH!
## Introduction
This repository contains code and pdf tutorial of how I've implemented binocular camera matching algorithm, SGBM, with FPGA using verilog. Code in this repo contains both C++ SGBM simulation code and PS-PL vitis-vivado project. Tutorial and the video attached thoroughly explain my designation in detail, although made in Chinese hhhhh.
## Code Explanation
Under the "code" directory, there are 2 directories called "FPGA" and "Ubuntu_C++" respectively. Under "FPGA", 5 directories can be found.
-census_vcode
This directory contains all verilog code that has been used in realizing census transforming. Under this directory, there are 2 directories, each called source and sim. Under source directory, finally you'll find census.v, and this file is the main verilog file which realizes census transforming. Under sim directory, finally you'll find tb_census.v and tb_census_zty.v, and these files are used as testbench for census.v.
- origin_cost_vcode
This directory contains all verilog code that has been used in realizing origin cost calculation. Under this directory, there are 2 directories, each called source and sim. Under source directory, finally you'll find origin_cost.v, and this file is the main verilog file which realizes origin cost calculation. Under sim directory, finally you'll find several verilog files as testbench, and among them, tb_origin_cost.v should be set as top file when you do behaverial simulations.
- aggregate_cost_vcode
This directory contains all verilog code that has been used in realizing aggregate cost calculation. Under this directory, there are 2 directories, each called source and sim. Under source directory, finally you'll find aggregate.v, and this file should be set as top file when you set up your own vivado aggregate cost project! This aggregate.v calls several other auxiliary modules to implement cost aggregation! Under sim directory, finally you'll find several verilog files as testbench, and among them, tb_aggr_cost.v should be set as top file when you do behaverial simulations.
- project_sgbm_vcode
This directory contains all verilog code that has been used in the overall PL part of SGBM project. Under this directory, there are 2 directories, each called source and sim. Under source directory, finally you'll find bd directory, bd directory contains all block design files as top files! I've wrapped other verilog files as RTL IP kernel so that I'm able to use them in block design.
- project_image
This directory contains both code of PS part and code of PL part. Under this directory, there are 2 directories, project_image_c for vitis C code and project_image_vcode for verilog code! Under ./vitis_image/vitis_image/src/, I've mainly written main.c, main.h, udp_perf_client.c and udp_perf_client.h. If you'd like to run these vitis code yourself, firstly you're supposed to set up the PL part in vivado with code under project_image_vcode, simulation, implementation and generate bitstream finally. Secondly, you're supposed to export hardware with bitstream to get .xsa file. Thirdly, create your own vitis project using .xsa which has just been generated in the second step. I have to mention that please create your vitis project using the template named "LWIP UDP Client" that has been offered by vitis software. Finally, change the code in main.c, main.h, udp_perf_client.c and udp_perf_client.h into my code, and there you go!
## Tutorial and Video
You're greatly welcomed to follow my bilibili account, which is https://space.bilibili.com/341561358. Hopefully you can find SGBM video explanation there at https://www.bilibili.com/video/BV1kR4y1S7TJ !
## Start
```
# initial project
cd STEREO_MATCH_SGBM/code/Ubuntu_C++/awesome-sgbm
rm -rf build && mkdir build
# install opencv dependence for cmake
git clone git@github.com:opencv/opencv.git

```
## TODO
A new video will be made in a couple of days illustrating the usage of this repository in detail!
