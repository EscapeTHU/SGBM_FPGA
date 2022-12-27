# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\Users\zty\Desktop\xilinx_project\project_image\vitis_image\vitis_image_system\_ide\scripts\systemdebugger_vitis_image_system_2_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\Users\zty\Desktop\xilinx_project\project_image\vitis_image\vitis_image_system\_ide\scripts\systemdebugger_vitis_image_system_2_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
source C:/Xilinx/Vitis/2021.2/scripts/vitis/util/zynqmp_utils.tcl
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Xilinx ZCU208 FT4232H 832204143211A" && level==0 && jtag_device_ctx=="jsn-ZCU208 FT4232H-832204143211A-147fb093-0"}
fpga -file C:/Users/zty/Desktop/xilinx_project/project_image/vitis_image/vitis_image/_ide/bitstream/design_sgbm_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Users/zty/Desktop/xilinx_project/project_image/vitis_image/design_sgbm_wrapper/export/design_sgbm_wrapper/hw/design_sgbm_wrapper.xsa -mem-ranges [list {0x80000000 0xbfffffff} {0x400000000 0x5ffffffff} {0x1000000000 0x7fffffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
set mode [expr [mrd -value 0xFF5E0200] & 0xf]
targets -set -nocase -filter {name =~ "*A53*#0"}
rst -processor
dow C:/Users/zty/Desktop/xilinx_project/project_image/vitis_image/design_sgbm_wrapper/export/design_sgbm_wrapper/sw/design_sgbm_wrapper/boot/fsbl.elf
set bp_27_46_fsbl_bp [bpadd -addr &XFsbl_Exit]
con -block -timeout 60
bpremove $bp_27_46_fsbl_bp
targets -set -nocase -filter {name =~ "*A53*#0"}
rst -processor
dow C:/Users/zty/Desktop/xilinx_project/project_image/vitis_image/vitis_image/Release/vitis_image.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A53*#0"}
con
