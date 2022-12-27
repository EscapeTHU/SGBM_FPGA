# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\zty\Desktop\xilinx_project\project_image\vitis_image\design_sgbm_wrapper\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\zty\Desktop\xilinx_project\project_image\vitis_image\design_sgbm_wrapper\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {design_sgbm_wrapper}\
-hw {C:\Users\zty\Desktop\xilinx_project\project_image\design_sgbm_wrapper.xsa}\
-arch {64-bit} -fsbl-target {psu_cortexa53_0} -out {C:/Users/zty/Desktop/xilinx_project/project_image/vitis_image}

platform write
domain create -name {standalone_psu_cortexa53_0} -display-name {standalone_psu_cortexa53_0} -os {standalone} -proc {psu_cortexa53_0} -runtime {cpp} -arch {64-bit} -support-app {lwip_udp_perf_client}
platform generate -domains 
platform active {design_sgbm_wrapper}
domain active {zynqmp_fsbl}
domain active {zynqmp_pmufw}
domain active {standalone_psu_cortexa53_0}
platform generate -quick
platform generate
platform generate
platform config -updatehw {C:/Users/zty/Desktop/xilinx_project/project_image/design_sgbm_wrapper.xsa}
platform generate -domains 
platform config -updatehw {C:/Users/zty/Desktop/xilinx_project/project_image/design_sgbm_wrapper.xsa}
platform generate -domains 
