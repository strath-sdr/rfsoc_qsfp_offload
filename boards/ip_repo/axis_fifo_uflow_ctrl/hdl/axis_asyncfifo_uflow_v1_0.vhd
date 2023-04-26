----------------------------------------------------------------------------------
-- Company: StrathSDR
-- Engineer: David Northcote
-- 
-- Create Date: 29.05.2022 12:00:00
-- Design Name: axis_asyncfifo_uflow
-- Module Name: axis_asyncfifo_uflow_v1_0 - arch
-- Project Name: AXI4-Stream FIFO Controller
-- Target Devices: Zynq MPSoC
-- Tool Versions: 2020.2
-- Description: Implements a FIFO controller for underflow detection.
--
-- Revision 0.01 - File Created
-- Additional Comments: N/A
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_asyncfifo_uflow_v1_0 is
    generic (
        C_S_AXIS_DATA_WIDTH : integer := 256
    );
	port (
		aclk	: in std_logic;
		aresetn	: in std_logic;
		s_axi_lite_awaddr	: in std_logic_vector(4-1 downto 0);
		s_axi_lite_awprot	: in std_logic_vector(2 downto 0);
		s_axi_lite_awvalid	: in std_logic;
		s_axi_lite_awready	: out std_logic;
		s_axi_lite_wdata	: in std_logic_vector(32-1 downto 0);
		s_axi_lite_wstrb	: in std_logic_vector((32/8)-1 downto 0);
		s_axi_lite_wvalid	: in std_logic;
		s_axi_lite_wready	: out std_logic;
		s_axi_lite_bresp	: out std_logic_vector(1 downto 0);
		s_axi_lite_bvalid	: out std_logic;
		s_axi_lite_bready	: in std_logic;
		s_axi_lite_araddr	: in std_logic_vector(4-1 downto 0);
		s_axi_lite_arprot	: in std_logic_vector(2 downto 0);
		s_axi_lite_arvalid	: in std_logic;
		s_axi_lite_arready	: out std_logic;
		s_axi_lite_rdata	: out std_logic_vector(32-1 downto 0);
		s_axi_lite_rresp	: out std_logic_vector(1 downto 0);
		s_axi_lite_rvalid	: out std_logic;
		s_axi_lite_rready	: in std_logic;
		
		s_axis_tvalid       : in std_logic;
		s_axis_tdata        : in std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
		s_axis_tready       : out std_logic;
		
		m_axis_tvalid       : out std_logic;
		m_axis_tdata        : out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
		m_axis_tready       : in std_logic;
		
		empty               : in std_logic;
		prog_empty          : in std_logic;
		
		irq_underflow       : out std_logic
	);
end axis_asyncfifo_uflow_v1_0;

architecture arch_imp of axis_asyncfifo_uflow_v1_0 is

	component axis_asyncfifo_uflow_v1_0_S_AXI_Lite is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		reset      : out std_logic;
		irq_enable : out std_logic;
		fsm_status     : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component axis_asyncfifo_uflow_v1_0_S_AXI_Lite;
	
	component async_fifo_control is
	   port(
	   aresetn : in std_logic;
	   aclk : in std_logic;
	   reset : in std_logic;
	   irq_enable : in std_logic;
	   empty : in std_logic;
	   full  : in std_logic;
	   ready : out std_logic;
	   underflow : out std_logic;
	   status : out std_logic_vector(1 downto 0)
	   );
	end component async_fifo_control;
	
	signal sig_reset : std_logic;
	signal sig_irq_enable : std_logic;
	signal sig_status : std_logic_vector(31 downto 0);
	signal sig_ready : std_logic;
	signal sig_prog_empty : std_logic;
	
begin

axis_asyncfifo_uflow_v1_0_S_AXI_Lite_inst : axis_asyncfifo_uflow_v1_0_S_AXI_Lite
	port map (
	    reset => sig_reset,
	    irq_enable => sig_irq_enable,
	    fsm_status => sig_status,
		S_AXI_ACLK	=> aclk,
		S_AXI_ARESETN	=> aresetn,
		S_AXI_AWADDR	=> s_axi_lite_awaddr,
		S_AXI_AWPROT	=> s_axi_lite_awprot,
		S_AXI_AWVALID	=> s_axi_lite_awvalid,
		S_AXI_AWREADY	=> s_axi_lite_awready,
		S_AXI_WDATA	=> s_axi_lite_wdata,
		S_AXI_WSTRB	=> s_axi_lite_wstrb,
		S_AXI_WVALID	=> s_axi_lite_wvalid,
		S_AXI_WREADY	=> s_axi_lite_wready,
		S_AXI_BRESP	=> s_axi_lite_bresp,
		S_AXI_BVALID	=> s_axi_lite_bvalid,
		S_AXI_BREADY	=> s_axi_lite_bready,
		S_AXI_ARADDR	=> s_axi_lite_araddr,
		S_AXI_ARPROT	=> s_axi_lite_arprot,
		S_AXI_ARVALID	=> s_axi_lite_arvalid,
		S_AXI_ARREADY	=> s_axi_lite_arready,
		S_AXI_RDATA	=> s_axi_lite_rdata,
		S_AXI_RRESP	=> s_axi_lite_rresp,
		S_AXI_RVALID	=> s_axi_lite_rvalid,
		S_AXI_RREADY	=> s_axi_lite_rready
	);
	
async_fifo_control_inst : async_fifo_control
	port map (
	   aclk => aclk,
	   aresetn => aresetn,
	   reset => sig_reset,
	   irq_enable => sig_irq_enable,
	   empty => empty,
	   full => sig_prog_empty,
	   ready => sig_ready,
	   underflow => irq_underflow,
	   status => sig_status(1 downto 0)
	   );
	   
sig_prog_empty <= not prog_empty;
s_axis_tready <= m_axis_tready and sig_ready;
m_axis_tdata <= s_axis_tdata;
m_axis_tvalid <= s_axis_tvalid and m_axis_tready and sig_ready;

end arch_imp;
