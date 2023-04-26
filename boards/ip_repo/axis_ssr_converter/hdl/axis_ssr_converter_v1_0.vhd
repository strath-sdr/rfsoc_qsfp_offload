----------------------------------------------------------------------------------
-- Company: StrathSDR
-- Engineer: David Northcote
-- 
-- Create Date: 10.05.2022 16:00:01
-- Design Name: axis_ssr_converter
-- Module Name: axis_ssr_converter_v1_0 - arch
-- Project Name: AXI4-Stream SSR Converter
-- Target Devices: Zynq MPSoC
-- Tool Versions: 2020.2
-- Description: Implements an SSR doubler.
--
-- Revision 0.01 - File Created
-- Additional Comments: N/A
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_ssr_converter_v1_0 is
	generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 128
	);
	port (
		aclk	        : in std_logic;
		aresetn	        : in std_logic;
		s_axis_tready	: out std_logic;
		s_axis_tdata	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		s_axis_tvalid	: in std_logic;
		m_axis_tready	: in std_logic;
		m_axis_tdata	: out std_logic_vector(C_S_AXIS_TDATA_WIDTH*2-1 downto 0);
		m_axis_tvalid	: out std_logic
	);
end axis_ssr_converter_v1_0;

architecture arch_imp of axis_ssr_converter_v1_0 is

signal sig_xor_out : std_logic := '0';
signal sig_tdata_0_en : std_logic := '0';
signal sig_tdata_1_en : std_logic := '0';
signal sig_xor_out_reg : std_logic := '0';
signal sig_tvalid_reg  : std_logic := '0';
signal sig_tdata_0_reg : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
signal sig_tdata_1_reg : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);

begin

ssr_process : process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            sig_tvalid_reg  <= '0';
            sig_xor_out_reg <= '0';
            sig_tdata_0_reg <= (others=>'0');
            sig_tdata_1_reg <= (others=>'0');
            
        else
            if m_axis_tready = '1' then
                sig_xor_out_reg <= sig_xor_out;
                sig_tvalid_reg  <= sig_tdata_1_en;
                if sig_tdata_0_en = '1' then
                    sig_tdata_0_reg <= s_axis_tdata;
                end if;
                if sig_tdata_1_en = '1' then
                    sig_tdata_1_reg <= s_axis_tdata;
                end if;
            end if;
        end if;
    end if;
end process;

sig_xor_out <= s_axis_tvalid xor sig_xor_out_reg;
sig_tdata_1_en <= s_axis_tvalid and sig_xor_out_reg;
sig_tdata_0_en <= s_axis_tvalid and (not(sig_xor_out_reg));

m_axis_tdata <= sig_tdata_1_reg & sig_tdata_0_reg;
m_axis_tvalid <= sig_tvalid_reg;
s_axis_tready <= m_axis_tready;

end arch_imp;
