/*
 * Copyright (C) 2017 - 2021 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */
/***************************** Include Files UDP *********************************/
#include <stdio.h>
#include "xparameters.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"
#include "lwipopts.h"
#include "xil_printf.h"
#include "sleep.h"
#include "lwip/priv/tcp_priv.h"
#include "lwip/init.h"
#include "lwip/inet.h"
#include "xil_cache.h"
#include "main.h"


/***************************** Include Files GIC *********************************/
#include "xil_io.h"
#include "xscugic.h"


/***************************** Include Files BRAM *********************************/
#include "xbram.h"


/***************************** Constant Definitions UDP *********************************/
#if LWIP_DHCP==1
#include "lwip/dhcp.h"
extern volatile int dhcp_timoutcntr;
#endif

extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;

#define DEFAULT_IP_ADDRESS	"192.168.1.10"
#define DEFAULT_IP_MASK		"255.255.255.0"
#define DEFAULT_GW_ADDRESS	"192.168.1.1"


/************************** Function Prototypes UDP ******************************/
void platform_enable_interrupts(void);
void start_application(void);
void transfer_data(void);
void print_app_header(void);


/************************** Platform Settings UDP ******************************/
#if defined (__arm__) && !defined (ARMR5)
#if XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT == 1 || \
		 XPAR_GIGE_PCS_PMA_1000BASEX_CORE_PRESENT == 1
int ProgramSi5324(void);
int ProgramSfpPhy(void);
#endif
#endif

#ifdef XPS_BOARD_ZCU102
#ifdef XPAR_XIICPS_0_DEVICE_ID
int IicPhyReset(void);
#endif
#endif


/************************** Variable Definitions UDP ******************************/
struct netif server_netif;


/************************** Variable Definitions GIC ******************************/
#define INTC_DEVICE_ID XPAR_SCUGIC_0_DEVICE_ID
#define RAM_RW_INT_ID XPAR_FABRIC_RAM_RW_0_INTR_INTR
#define INTC_HANDLER XScuGic_InterruptHandler
XScuGic Intc;


/************************** Variable Definitions BRAM ******************************/
#define START_ADDR 0
#define BRAM_DATA_BYTE 4
#define BRAM_LEN 80000


/*****************************************************************************/
/**
*
* This function prints ip address of this device
*
* @param     None
*
* @return    None
*
* @note      None
*
******************************************************************************/
static void print_ip(char *msg, ip_addr_t *ip)
{
	print(msg);
	xil_printf("%d.%d.%d.%d\r\n", ip4_addr1(ip), ip4_addr2(ip),
			ip4_addr3(ip), ip4_addr4(ip));
}


/*****************************************************************************/
/**
*
* This function prints ip settings of this device
*
* @param     None
*
* @return    None
*
* @note      None
*
******************************************************************************/
static void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{
	print_ip("Board IP:       ", ip);
	print_ip("Netmask :       ", mask);
	print_ip("Gateway :       ", gw);
}


/*****************************************************************************/
/**
*
* This function assigns default ip to the ip you want
*
* @param     None
*
* @return    None
*
* @note      None
*
******************************************************************************/
static void assign_default_ip(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{
	int err;

	xil_printf("Configuring default IP %s \r\n", DEFAULT_IP_ADDRESS);

	err = inet_aton(DEFAULT_IP_ADDRESS, ip);
	if (!err)
		xil_printf("Invalid default IP address: %d\r\n", err);

	err = inet_aton(DEFAULT_IP_MASK, mask);
	if (!err)
		xil_printf("Invalid default IP MASK: %d\r\n", err);

	err = inet_aton(DEFAULT_GW_ADDRESS, gw);
	if (!err)
		xil_printf("Invalid default gateway address: %d\r\n", err);
}


void RAM_RW_Handler(void *Callback)
{
	xil_printf("Entering RAM_RW interrupt handler...");
	unsigned int i=0;
	unsigned int bram_read = 0;
	for (i = BRAM_DATA_BYTE * START_ADDR; i < BRAM_DATA_BYTE * (START_ADDR + BRAM_LEN); i += BRAM_DATA_BYTE)
	{
		bram_read = XBram_ReadReg(XPAR_BRAM_0_BASEADDR, i);
		xil_printf("BRAM address is: %d\t, Read data is: %08X\r\n", i/4, bram_read);
		generate_buf(bram_read);
		transfer_data();
	}
}

/*****************************************************************************/
/**
*
* Main function
*
* TBD
*
* @param	None
*
* @return
*		- XST_SUCCESS if tests pass
*		- XST_FAILURE if fails.
*
* @note		None.
*
******************************************************************************/
int main(void)
{


	/************************** UDP Section ******************************/
	struct netif *netif;

	/* the mac address of the board. this should be unique per board */
	unsigned char mac_ethernet_address[] = {
		0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };

	netif = &server_netif;
#if defined (__arm__) && !defined (ARMR5)
#if XPAR_GIGE_PCS_PMA_SGMII_CORE_PRESENT == 1 || \
		XPAR_GIGE_PCS_PMA_1000BASEX_CORE_PRESENT == 1
	ProgramSi5324();
	ProgramSfpPhy();
#endif
#endif

	/* Define this board specific macro in order perform PHY reset
	 * on ZCU102
	 */
#ifdef XPS_BOARD_ZCU102
	IicPhyReset();
#endif

	init_platform();

	xil_printf("\r\n\r\n");
	xil_printf("-----lwIP RAW Mode UDP Client Application-----\r\n");

	/* initialize lwIP */
	lwip_init();

	/* Add network interface to the netif_list, and set it as default */
	if (!xemac_add(netif, NULL, NULL, NULL, mac_ethernet_address,
				PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\r\n");
		return -1;
	}
	netif_set_default(netif);

	/* now enable interrupts */
	platform_enable_interrupts();

	/* specify that the network if is up */
	netif_set_up(netif);

#if (LWIP_DHCP==1)
	/* Create a new DHCP client for this interface.
	 * Note: you must call dhcp_fine_tmr() and dhcp_coarse_tmr() at
	 * the predefined regular intervals after starting the client.
	 */
	dhcp_start(netif);
	dhcp_timoutcntr = 24;
	while (((netif->ip_addr.addr) == 0) && (dhcp_timoutcntr > 0))
		xemacif_input(netif);

	if (dhcp_timoutcntr <= 0) {
		if ((netif->ip_addr.addr) == 0) {
			xil_printf("ERROR: DHCP request timed out\r\n");
			assign_default_ip(&(netif->ip_addr),
					&(netif->netmask), &(netif->gw));
		}
	}

	/* print IP address, netmask and gateway */
#else
	assign_default_ip(&(netif->ip_addr), &(netif->netmask), &(netif->gw));
#endif
	print_ip_settings(&(netif->ip_addr), &(netif->netmask), &(netif->gw));

	xil_printf("\r\n");

	/* print app header */
	print_app_header();

	/* start the application*/
	start_application();


	/************************** GIC Section ******************************/
	    XScuGic_Config *IntcConfig;
	    int Result;

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Lookup Configuration Processing-----\r\n");
	    IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	    if (NULL == IntcConfig) {
	    	xil_printf("ERROR: Lookup interrupt configuration failed\r\n");
	    	return XST_FAILURE;
	    }
	    xil_printf("SUCCESS: Lookup interrupt configuration completed\r\n");

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Interrupt Initialization Processing-----\r\n");
	    Result = XScuGic_CfgInitialize(&Intc, IntcConfig, IntcConfig->CpuBaseAddress);
	    if (Result != XST_SUCCESS) {
	    	xil_printf("ERROR: Interrupt initialization failed\r\n");
	    	return XST_FAILURE;
	    }
	    xil_printf("SUCCESS: Interrupt initialization completed\r\n");

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Interrupt Priority & Trigger Type Processing-----\r\n");
	    XScuGic_SetPriorityTriggerType(&Intc, RAM_RW_INT_ID, 0xA0, 0x1);
	    xil_printf("SUCCESS: Interrupt priority & trigger type completed\r\n");

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Interrupt Connection Processing-----\r\n");
	    Result = XScuGic_Connect(&Intc, RAM_RW_INT_ID, (Xil_ExceptionHandler)RAM_RW_Handler, 0);
	    if (Result != XST_SUCCESS) {
	        xil_printf("ERROR: Interrupt connection failed\r\n");
	        return XST_FAILURE;
	    }
	    xil_printf("SUCCESS: Interrupt connection completed\r\n");

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Interrupt Enable Processing-----\r\n");
	    XScuGic_Enable(&Intc, RAM_RW_INT_ID);
	    xil_printf("SUCCESS: Interrupt enable completed\r\n");

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Hardware Exception Initialization Processing-----\r\n");
	    Xil_ExceptionInit();
	    xil_printf("SUCCESS: Hardware exception initialization completed\r\n");

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Hardware Exception Registration Processing-----\r\n");
	    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)INTC_HANDLER, &Intc);
	    xil_printf("SUCCESS: Hardware exception registration completed\r\n");

	    xil_printf("\r\n\r\n");
	    xil_printf("-----Hardware Exception Enable Processing-----\r\n");
	    Xil_ExceptionEnable();
	    xil_printf("SUCCESS: Hardware exception enable completed\r\n");
	xil_printf("\r\n");
	xil_printf("\n\r------------- Startup Complete ----------------\r\n\n");

	while (1) {
		if (TcpFastTmrFlag) {
			tcp_fasttmr();
			TcpFastTmrFlag = 0;
		}
		if (TcpSlowTmrFlag) {
			tcp_slowtmr();
			TcpSlowTmrFlag = 0;
		}
		xemacif_input(netif);
		transfer_data();
	}

	/* never reached */
	cleanup_platform();

	return 0;
}
