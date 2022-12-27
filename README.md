# SGBM_FPGA
## Before Start
FOR THE REASON THAT GITHUB DOES NOT SUPPORT BIG ZIP FILE UPLOAD, PLEASE FIND THIS REPO at https://cloud.tsinghua.edu.cn/d/2e439d7f04b8494a9ba5/
## Introduction
This repository contains code and pdf tutorial of how I've implemented binocular camera matching algorithm, SGBM, with FPGA using verilog. Code in this repo contains both C++ SGBM simulation code and PS-PL vitis-vivado project. Tutorial and the video attached thoroughly explain my designation in detail, although made in Chinese hhhhh.
## Code Explanation
Under the "code" directory, there are 2 directories called "FPGA" and "Ubuntu_C++" respectively. Under "FPGA", 5 zip files can be found.
- project_census.zip
This project is used to test census verilog results.
- origin_cost.zip
This project is used to test origin_cost calculation results.
- aggregate_cost.zip
This project is used to test aggregate_cost calculation results.
- project_sgbm.zip
This project contains all PL designation, with no PS designation, and is used to verify the PL functions only.
- project_image.zip
This project is the overall SGBM project, with PS, PL, etc all elements covered. Under its vitis_image directory lies the PS designation.
## Tutorial and Video
You're greatly welcomed to follow my bilibili account, which is https://space.bilibili.com/341561358. Hopefully you can find SGBM video explanation there at https://www.bilibili.com/video/BV1kR4y1S7TJ !
