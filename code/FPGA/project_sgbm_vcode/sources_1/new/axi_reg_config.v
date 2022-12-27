
`timescale 1 ns / 1 ps

	module axi_reg_config #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
		input wire [31:0] disparity,
		input wire valid,
	    /*
		output wire [31:0] reg_frame_chirp_num,
		output wire [31:0] reg_chirp_interval,
		output wire [31:0] reg_fmcw_tx_time,
		output wire [31:0] reg_fmcw_rx_time,
		output wire [31:0] reg_frame_start,
		output wire [31:0] reg_test_mode_enable,
		output wire [31:0] reg_dac_output_ratio,
		output wire [31:0] reg_0,
		output wire [31:0] reg_1,
		output wire [31:0] reg_2,
		output wire [31:0] reg_3,
		output wire [31:0] reg_pc_start_index,
		output wire [31:0] reg_pc_end_index,
		output wire [31:0] ofdm_chirp_interval,
		output wire [31:0] ofdm_chirp_num,
		*/
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	axi_reg_config_S00_AXI # (
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) axi_reg_config_S00_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		
		//user ports
		.valid(valid),
		.disparity(disparity)
		/*
		.reg_frame_chirp_num(reg_frame_chirp_num),
		.reg_chirp_interval(reg_chirp_interval),
		.reg_fmcw_tx_time(reg_fmcw_tx_time),
		.reg_fmcw_rx_time(reg_fmcw_rx_time),
		.reg_frame_start(reg_frame_start),
		.reg_test_mode_enable(reg_test_mode_enable),
		.reg_dac_output_ratio(reg_dac_output_ratio),
		.reg_0(reg_0),
		.reg_1(reg_1),
		.reg_2(reg_2),
		.reg_3(reg_3),
		.reg_pc_start_index(reg_pc_start_index),
		.reg_pc_end_index(reg_pc_end_index),
		.ofdm_chirp_interval(ofdm_chirp_interval),
		.ofdm_chirp_num(ofdm_chirp_num)
		*/
	);

	// Add user logic here

	// User logic ends

	endmodule
