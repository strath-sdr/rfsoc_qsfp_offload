----------------------------------------------------------------------------------
-- Company: StrathSDR
-- Engineer: David Northcote
-- 
-- Create Date: 09.05.2022 15:42:12
-- Design Name: axis_tkeep_pack
-- Module Name: tkeep_rotator - arch
-- Project Name: AXI4-Stream TKEEP Pack
-- Target Devices: Zynq MPSoC
-- Tool Versions: 2020.2
-- Description: Implements a TKEEP rotator.
--
-- Revision 0.01 - File Created
-- Additional Comments: N/A
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tkeep_rotator is
    port (
          aclk          : in std_logic;
          aresetn       : in std_logic;
          rotation      : in std_logic_vector(2 downto 0);
          read          : in std_logic;
          valid         : in std_logic;
          ready         : in std_logic;
          data_in       : in std_logic_vector(127 downto 0);
          keep          : in std_logic_vector(7 downto 0);
          offset        : in std_logic_vector(2 downto 0);
          data_out      : out std_logic_vector(15 downto 0);
          not_empty     : out std_logic
          );
end tkeep_rotator;

architecture arch of tkeep_rotator is

COMPONENT fifo_generator_0
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

type samples_array is array(7 downto 0) of std_logic_vector(15 downto 0);
type keep_array is array(7 downto 0) of std_logic;
signal sig_samples : samples_array;
signal sig_keep : keep_array;
signal sig_accumulator : unsigned(2 downto 0);
signal sig_fifo_input : std_logic_vector(15 downto 0);
signal sig_fifo_write : std_logic;
signal sig_fifo_read : std_logic;
signal sig_fifo_keep : std_logic;
signal sig_invert_reset : std_logic;
signal sig_empty : std_logic;

begin

sig_accumulator <= unsigned(offset) - unsigned(rotation);

generate_get_samples : for I in 0 to 7 generate
    sig_samples(I) <= data_in((I+1)*16-1 downto I*16);
    sig_keep(I) <= keep(I);
end generate;

select_process : process(sig_samples, sig_keep, sig_accumulator)
begin
    case sig_accumulator is
        when "000" =>
            sig_fifo_input <= sig_samples(0);
            sig_fifo_keep <= sig_keep(0);
        when "001" =>
            sig_fifo_input <= sig_samples(1);
            sig_fifo_keep <= sig_keep(1);
        when "010" =>
            sig_fifo_input <= sig_samples(2);
            sig_fifo_keep <= sig_keep(2);
        when "011" =>
            sig_fifo_input <= sig_samples(3);
            sig_fifo_keep <= sig_keep(3);
        when "100" =>
            sig_fifo_input <= sig_samples(4);
            sig_fifo_keep <= sig_keep(4);
        when "101" =>
            sig_fifo_input <= sig_samples(5);
            sig_fifo_keep <= sig_keep(5);
        when "110" =>
            sig_fifo_input <= sig_samples(6);
            sig_fifo_keep <= sig_keep(6);
        when "111" =>
            sig_fifo_input <= sig_samples(7);
            sig_fifo_keep <= sig_keep(7);
    end case;
end process;

fifo_inst : fifo_generator_0
  PORT MAP (
    clk => aclk,
    srst => sig_invert_reset,
    din => sig_fifo_input,
    wr_en => sig_fifo_write,
    rd_en => sig_fifo_read,
    dout => data_out,
    full => open,
    empty => sig_empty,
    wr_rst_busy => open,
    rd_rst_busy => open
  );

sig_invert_reset <= not aresetn;
sig_fifo_read <= read and ready;
sig_fifo_write <= (sig_fifo_keep and valid) and ready;
not_empty <= not(sig_empty);

end arch;
