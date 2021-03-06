//------------------------------------------------------------------------------
// File       : eth_block.v
// Author     : Xilinx Inc.
// -----------------------------------------------------------------------------
// (c) Copyright 2004-2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
// -----------------------------------------------------------------------------
// Description: This is the block level Verilog design for the Tri-Mode
//              Ethernet MAC Example Design.
//
//              This block level:
//
//              * instantiates all clock enable logic required to operate the
//                TEMAC and its example design;
//
//              * instantiates the axi4-lite ipif module to convert to the core IPIC
//                interface
//
//              * instantiates appropriate PHY interface module (GMII/MII/RGMII)
//                as required based on the user configuration;
//
//              Please refer to the Datasheet, Getting Started Guide, and
//              the Tri-Mode Ethernet MAC User Gude for further information.
//
//
//              -----------------------------------------|
//              | BLOCK LEVEL WRAPPER                    |
//              |                                        |
//              |    ---------------------               |
//              |    | ETHERNET MAC      |               |
//              |    | CORE              |  ---------    |
//              |    |                   |  |       |    |
//            --|--->| Tx            Tx  |--|       |--->|
//              |    | AXI           PHY |  |       |    |
//              |    | I/F           I/F |  |       |    |
//              |    |                   |  | PHY   |    |
//              |    |                   |  | I/F   |    |
//              |    |                   |  |       |    |
//              |    | Rx            Rx  |  |       |    |
//              |    | AXI           PHY |  |       |    |
//            <-|----| I/F           I/F |<-|       |<---|
//              |    |                   |  ---------    |
//              |    |                   |               |
//              |    ---------------------               |
//              |            |  |                        |
//              |       --------------------             |
//              |       |                  |             |
//            --|------>|  AXI4-Lite IPIF  |             |
//            <-|-------|                  |             |
//              |       |                  |             |
//              |       --------------------             |
//              |                                        |
//              |     clock enable logic                 |
//              |                                        |
//              -----------------------------------------|
//

`timescale 1 ps/1 ps


//------------------------------------------------------------------------------
// The entity declaration for the block level example design.
//------------------------------------------------------------------------------

module eth_block  #(
      parameter               C_BASE_ADDRESS = 32'h00
   ) (
      input                gtx_clk,
      input                gtx_clk90,
      // asynchronous reset
      input                glbl_rstn,
      input                rx_axi_rstn,
      input                tx_axi_rstn,

      // Receiver Interface
      //--------------------------
      output      [27:0]   rx_statistics_vector,
      output               rx_statistics_valid,

      output               rx_mac_aclk,
      output               rx_reset,
      output      [7:0]    rx_axis_mac_tdata,
      output               rx_axis_mac_tvalid,
      output               rx_axis_mac_tlast,
      output               rx_axis_mac_tuser,

      // Transmitter Interface
      //-----------------------------
      input       [7:0]    tx_ifg_delay,
      output      [31:0]   tx_statistics_vector,
      output               tx_statistics_valid,

      output               tx_mac_aclk,
      output               tx_reset,
      input       [7:0]    tx_axis_mac_tdata,
      input                tx_axis_mac_tvalid,
      input                tx_axis_mac_tlast,
      input                tx_axis_mac_tuser,
      output               tx_axis_mac_tready,
      // MAC Control Interface
      //----------------------
      input                pause_req,
      input       [15:0]   pause_val,

      // Reference clock for IDELAYCTRL's
      input                refclk,

      // RGMII Interface
      //----------------
      output      [3:0]    rgmii_txd,
      output               rgmii_tx_ctl,
      output               rgmii_txc,
      input       [3:0]    rgmii_rxd,
      input                rgmii_rx_ctl,
      input                rgmii_rxc,
      output               inband_link_status,
      output      [1:0]    inband_clock_speed,
      output               inband_duplex_status,

      // MDIO Interface
      //---------------
      inout                mdio,
      output               mdc,

      // AXI-Lite Interface
      //---------------
      input                s_axi_aclk,
      input                s_axi_resetn,

      input       [31:0]   s_axi_awaddr,
      input                s_axi_awvalid,
      output               s_axi_awready,

      input       [31:0]   s_axi_wdata,
      input                s_axi_wvalid,
      output               s_axi_wready,

      output      [1:0]    s_axi_bresp,
      output               s_axi_bvalid,
      input                s_axi_bready,

      input       [31:0]   s_axi_araddr,
      input                s_axi_arvalid,
      output               s_axi_arready,

      output      [31:0]   s_axi_rdata,
      output      [1:0]    s_axi_rresp,
      output               s_axi_rvalid,
      input                s_axi_rready
      );


   //---------------------------------------------------------------------------
   // internal signals used in this block level wrapper.
   //---------------------------------------------------------------------------

   // MDIO Interface
   wire           mdio_i;
   wire           mdio_o;
   wire           mdio_t;
   wire           mdc_i;

   wire           idelayctrl_reset_sync;     // Used to create a reset pulse in the IDELAYCTRL refclk domain.
   reg   [3:0]    idelay_reset_cnt;          // Counter to create a long IDELAYCTRL reset pulse.
   reg            idelayctrl_reset;          // The reset pulse for the IDELAYCTRL.

   wire           gmii_tx_en_int;            // Internal gmii_tx_en signal.
   wire           gmii_tx_er_int;            // Internal gmii_tx_er signal.
   wire  [7:0]    gmii_txd_int;              // Internal gmii_txd signal.
   wire           gmii_rx_dv_int;            // gmii_rx_dv registered in IOBs.
   wire           gmii_rx_er_int;            // gmii_rx_er registered in IOBs.
   wire  [7:0]    gmii_rxd_int;              // gmii_rxd registered in IOBs.

   reg            rx_enable = 0;             // rx_enable signal to throttle data
   wire           tx_enable;

   wire           speedis100;            // Asserted when speed is 100Mb/s.
   wire           speedis10100;          // Asserted when speed is 10Mb/s or 100Mb/s.

   (* KEEP = "TRUE" *)
   wire           rx_mac_aclk_int;       // Internal receive gmii/mii clock signal.

   (* KEEP = "TRUE" *)
   wire           tx_mac_aclk_int;       // Internal transmit gmii/mii clock signal.
   wire           rxspeedis10100;            // MAC speed setting resampled on the transmitter clock
   wire           txspeedis10100;            // MAC speed setting resampled on the receiver clock


   wire           glbl_rst;
   wire           tx_reset_int;         // Synchronous reset in the MAC and gmii Tx domain
   wire           rx_reset_int;         // Synchronous reset in the MAC and gmii Rx domain

   wire           phy_tx_enable;
   wire           phy_tx_enable_falling;
   wire           clk_div5;
   wire           clk_div5_shift;


   wire  [27:0]   rx_statistics_vector_int;
   wire           rx_statistics_valid_int;
   wire  [31:0]   tx_statistics_vector_int;
   wire           tx_statistics_valid_int;
   wire           bus2ip_clk;
   wire           bus2ip_reset;

   wire  [31:0]   bus2ip_addr;
   wire           bus2ip_cs;
   wire           bus2ip_rdce;
   wire           bus2ip_wrce;
   wire  [31:0]   bus2ip_data;
   wire  [31:0]   ip2bus_data;
   wire           ip2bus_wrack;
   wire           ip2bus_rdack;
   wire           ip2bus_error;

   // assign outputs
   assign rx_reset = rx_reset_int;
   assign tx_reset = tx_reset_int;
   // Assign the internal clock signals to output ports.
   assign tx_mac_aclk = gtx_clk;
   assign rx_mac_aclk = rx_mac_aclk_int;

   assign glbl_rst = !glbl_rstn;

   //---------------------------------------------------------------------------
   // An IDELAYCTRL primitive needs to be instantiated for the Fixed Tap Delay
   // mode of the IDELAY.
   // All IDELAYs in Fixed Tap Delay mode and the IDELAYCTRL primitives have
   // to be LOC'ed in the UCF file.
   //---------------------------------------------------------------------------
   IDELAYCTRL dlyctrl (
      .RDY              (),
      .REFCLK           (refclk),
      .RST              (idelayctrl_reset)
   );


   // Create a synchronous reset in the IDELAYCTRL refclk clock domain.
   eth_reset_sync idelayctrl_reset_gen (
      .clk              (refclk),
      .enable           (1'b1),
      .reset_in         (glbl_rst),
      .reset_out        (idelayctrl_reset_sync)
   );


   // Reset circuitry for the IDELAYCTRL reset.

   // The IDELAYCTRL must experience a pulse which is at least 50 ns in
   // duration.  This is ten clock cycles of the 200MHz refclk.  Here we
   // drive the reset pulse for 12 clock cycles.
   always @(posedge refclk)
   begin
      if (idelayctrl_reset_sync) begin
         idelay_reset_cnt     <= 4'b0000;
         idelayctrl_reset     <= 1'b1;
      end
      else begin
         case (idelay_reset_cnt)
            4'b0000 : idelay_reset_cnt <= 4'b0001;
            4'b0001 : idelay_reset_cnt <= 4'b0010;
            4'b0010 : idelay_reset_cnt <= 4'b0011;
            4'b0011 : idelay_reset_cnt <= 4'b0100;
            4'b0100 : idelay_reset_cnt <= 4'b0101;
            4'b0101 : idelay_reset_cnt <= 4'b0110;
            4'b0110 : idelay_reset_cnt <= 4'b0111;
            4'b0111 : idelay_reset_cnt <= 4'b1000;
            4'b1000 : idelay_reset_cnt <= 4'b1001;
            4'b1001 : idelay_reset_cnt <= 4'b1010;
            4'b1010 : idelay_reset_cnt <= 4'b1011;
            4'b1011 : idelay_reset_cnt <= 4'b1100;
            default : idelay_reset_cnt <= 4'b1100;
         endcase
         if (idelay_reset_cnt === 4'b1100) begin
            idelayctrl_reset  <= 1'b0;
         end
         else begin
            idelayctrl_reset  <= 1'b1;
         end
      end
   end



   //---------------------------------------------------------------------------
   // Transmitter Clock Enable generation circuit. These circuits produce the
   // clock enables for 10/100/1000 operation.
   //---------------------------------------------------------------------------

   eth_clk_en_gen enable_gen (
      .reset            (tx_reset_int),
      .speed_is_10_100  (speedis10100),
      .speed_is_100     (speedis100),
      .clk              (gtx_clk),
      .clk90            (gtx_clk90),
      .client_tx_enable (tx_enable),
      .phy_tx_enable    (phy_tx_enable),
      .phy_tx_enable_falling (phy_tx_enable_falling),
      .clk_div5         (clk_div5),
      .clk_div5_shift   (clk_div5_shift)
   );



   //---------------------------------------------------------------------------
   // Clock Enable circuitry
   //---------------------------------------------------------------------------

   // Resynchronise the speed selection signal in the receiver clock domain
   eth_sync_block rxspeedis10100gen (
      .clk              (rx_mac_aclk_int),
      .data_in          (speedis10100),
      .data_out         (rxspeedis10100)
   );

   // Resynchronise the speed selection signal in the transmitter clock domain
   eth_sync_block txspeedis10100gen (
      .clk              (gtx_clk),
      .data_in          (speedis10100),
      .data_out         (txspeedis10100)
   );

   // Create the receiver clock enable
   always @(posedge rx_mac_aclk_int)
   begin
      if (rx_reset_int == 1'b1) begin
         rx_enable        <= 1'b0;
      end
      else begin
         if (rxspeedis10100 == 1'b1)
            rx_enable     <= ~(rx_enable);
         else
            rx_enable     <= 1'b1;
      end
   end





   //---------------------------------------------------------------------------
   // Instantiate RGMII Interface
   //---------------------------------------------------------------------------

   // Instantiate the RGMII physical interface logic
   eth_rgmii_v2_0_if rgmii_interface (
      // Synchronous resets
      .tx_reset         (tx_reset_int),
      .rx_reset         (rx_reset_int),

      //----------------------------------------------
      // MDIO Interface
      .mdio             (mdio),
      .mdc              (mdc),
      .mdc_i            (mdc_i),
      .mdio_i           (mdio_i),
      .mdio_o           (mdio_o),
      .mdio_t           (mdio_t),

      // Current operating speed is 10/100
      .speedis10100     (speedis10100),

      // The following ports are the RGMII physical interface: these will be at
      // pins on the FPGA
      .rgmii_txd        (rgmii_txd),
      .rgmii_tx_ctl     (rgmii_tx_ctl),
      .rgmii_txc        (rgmii_txc),
      .rgmii_rxd        (rgmii_rxd),
      .rgmii_rx_ctl     (rgmii_rx_ctl),
      .rgmii_rxc        (rgmii_rxc),

      // The following signals are in the RGMII in-band status signals
      .link_status      (inband_link_status),
      .clock_speed      (inband_clock_speed),
      .duplex_status    (inband_duplex_status),

      // The following ports are the internal GMII connections from IOB logic
      // to the TEMAC core
      .phy_tx_enable    (phy_tx_enable),
      .phy_tx_enable_falling (phy_tx_enable_falling),
      .txd_from_mac     (gmii_txd_int),
      .tx_en_from_mac   (gmii_tx_en_int),
      .tx_er_from_mac   (gmii_tx_er_int),
      .tx_clk           (gtx_clk),
      .tx_clk90         (gtx_clk90),
      .clk_div5         (clk_div5),
      .clk_div5_shift   (clk_div5_shift),
      .rxd_to_mac       (gmii_rxd_int),
      .rx_dv_to_mac     (gmii_rx_dv_int),
      .rx_er_to_mac     (gmii_rx_er_int),

      // Receiver clock for the MAC and Client Logic
      .rx_clk           (rx_mac_aclk_int)
      );



   //---------------------------------------------------------------------------
   // Instantiate the axi_ipif block
   //---------------------------------------------------------------------------
   eth_axi4_lite_ipif_wrapper #(
      .C_BASE_ADDRESS      (C_BASE_ADDRESS)
    ) axi4_lite_ipif (
      // System signals
      .s_axi_aclk          (s_axi_aclk),
      .s_axi_aresetn       (s_axi_resetn),
      .s_axi_awaddr        (s_axi_awaddr),
      .s_axi_awvalid       (s_axi_awvalid),
      .s_axi_awready       (s_axi_awready),
      .s_axi_wdata         (s_axi_wdata),
      .s_axi_wvalid        (s_axi_wvalid),
      .s_axi_wready        (s_axi_wready),
      .s_axi_bresp         (s_axi_bresp),
      .s_axi_bvalid        (s_axi_bvalid),
      .s_axi_bready        (s_axi_bready),
      .s_axi_araddr        (s_axi_araddr),
      .s_axi_arvalid       (s_axi_arvalid),
      .s_axi_arready       (s_axi_arready),
      .s_axi_rdata         (s_axi_rdata),
      .s_axi_rresp         (s_axi_rresp),
      .s_axi_rvalid        (s_axi_rvalid),
      .s_axi_rready        (s_axi_rready),
      // controls to the ipif
      .bus2ip_clk          (bus2ip_clk),
      .bus2ip_reset        (bus2ip_reset),
      .bus2ip_addr         (bus2ip_addr),
      .bus2ip_cs           (bus2ip_cs),
      .bus2ip_rdce         (bus2ip_rdce),
      .bus2ip_wrce         (bus2ip_wrce),
      .bus2ip_data         (bus2ip_data),
      .ip2bus_data         (ip2bus_data),
      .ip2bus_wrack        (ip2bus_wrack),
      .ip2bus_rdack        (ip2bus_rdack),
      .ip2bus_error        (ip2bus_error)
   );



   assign rx_statistics_vector = rx_statistics_vector_int;
   assign rx_statistics_valid  = rx_statistics_valid_int;
   assign tx_statistics_vector = tx_statistics_vector_int;
   assign tx_statistics_valid  = tx_statistics_valid_int;


   //---------------------------------------------------------------------------
   // Instantiate the TEMAC core
   //---------------------------------------------------------------------------
   eth trimac_core(
      //----------------------------------------------
      // asynchronous reset
      .glbl_rstn              (glbl_rstn),
      .rx_axi_rstn            (rx_axi_rstn),
      .tx_axi_rstn            (tx_axi_rstn),

      //----------------------------------------------
      // Receiver Interface
      .rx_axi_clk             (rx_mac_aclk_int),
      .rx_reset_out           (rx_reset_int),
      .rx_axis_mac_tdata      (rx_axis_mac_tdata),
      .rx_axis_mac_tvalid     (rx_axis_mac_tvalid),
      .rx_axis_mac_tlast      (rx_axis_mac_tlast),
      .rx_axis_mac_tuser      (rx_axis_mac_tuser),
      .rx_enable              (rx_enable),

      //----------------------------------------------
      // Receiver Statistics
      .rx_statistics_vector   (rx_statistics_vector_int),
      .rx_statistics_valid    (rx_statistics_valid_int),

      //----------------------------------------------
      // Transmitter Interface
      .tx_axi_clk             (gtx_clk),
      .tx_reset_out           (tx_reset_int),
      .tx_axis_mac_tdata      (tx_axis_mac_tdata),
      .tx_axis_mac_tvalid     (tx_axis_mac_tvalid),
      .tx_axis_mac_tlast      (tx_axis_mac_tlast),
      .tx_axis_mac_tuser      (tx_axis_mac_tuser),
      .tx_axis_mac_tready     (tx_axis_mac_tready),

      .tx_ifg_delay           (tx_ifg_delay),
      .tx_enable              (tx_enable),

      //----------------------------------------------
      // Transmitter Statistics
      .tx_statistics_vector   (tx_statistics_vector_int),
      .tx_statistics_valid    (tx_statistics_valid_int),

      //----------------------------------------------
      // MAC Control Interface
      .pause_req              (pause_req),
      .pause_val              (pause_val),

      //----------------------------------------------
      // Current Speed Indication
      .speed_is_100           (speedis100),
      .speed_is_10_100        (speedis10100),

      //----------------------------------------------
      // Physical Interface of the core
      .gmii_tx_clken          (phy_tx_enable),
      .gmii_txd               (gmii_txd_int),
      .gmii_tx_en             (gmii_tx_en_int),
      .gmii_tx_er             (gmii_tx_er_int),
      .gmii_rxd               (gmii_rxd_int),
      .gmii_rx_dv             (gmii_rx_dv_int),
      .gmii_rx_er             (gmii_rx_er_int),

      //----------------------------------------------
      // MDIO Interface
      .mdc_out                (mdc_i),
      .mdio_in                (mdio_i),
      .mdio_out               (mdio_o),
      .mdio_tri               (mdio_t),


      //----------------------------------------------
      // IPIC Interface
      .bus2ip_clk             (bus2ip_clk),
      .bus2ip_reset           (bus2ip_reset),
      .bus2ip_addr            (bus2ip_addr),
      .bus2ip_cs              (bus2ip_cs),
      .bus2ip_rdce            (bus2ip_rdce),
      .bus2ip_wrce            (bus2ip_wrce),
      .bus2ip_data            (bus2ip_data),
      .ip2bus_data            (ip2bus_data),
      .ip2bus_wrack           (ip2bus_wrack),
      .ip2bus_rdack           (ip2bus_rdack),
      .ip2bus_error           (ip2bus_error),

      .mac_irq                ()


   );


endmodule
