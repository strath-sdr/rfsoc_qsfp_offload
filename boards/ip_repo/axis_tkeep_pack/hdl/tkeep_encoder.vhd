----------------------------------------------------------------------------------
-- Company: StrathSDR
-- Engineer: David Northcote
-- 
-- Create Date: 09.05.2022 15:42:12
-- Design Name: axis_tkeep_pack
-- Module Name: tkeep_encoder - arch
-- Project Name: AXI4-Stream TKEEP Pack
-- Target Devices: Zynq MPSoC
-- Tool Versions: 2020.2
-- Description: Implements a TKEEP encoder.
--
-- Revision 0.01 - File Created
-- Additional Comments: N/A
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tkeep_encoder is
    port (
          aclk         : in std_logic;
          aresetn      : in std_logic;
          last         : in std_logic;
          keep         : in std_logic_vector(7 downto 0);
          valid        : in std_logic;
          ready        : in std_logic;
          rotation      : out std_logic_vector(2 downto 0)
      );
end tkeep_encoder;

architecture arch of tkeep_encoder is

signal sig_q2 : std_logic;
signal sig_q1 : std_logic;
signal sig_q0 : std_logic;
signal sig_rotation : std_logic_vector(2 downto 0);
signal sig_rotation_reg : std_logic_vector(2 downto 0);
signal sig_accumulator : std_logic_vector(2 downto 0);
signal sig_enable_out : std_logic;

begin

sig_q2 <= (keep(3) and (not keep(7)));
sig_q1 <= (keep(1) and (not keep(3))) or (keep(5) and (not keep(7)));
sig_q0 <= (keep(0) and (not keep(1))) or (keep(2) and (not keep(3)))
       or (keep(4) and (not keep(5))) or (keep(6) and (not keep(7)));
sig_rotation <= sig_q2 & sig_q1 & sig_q0;
sig_enable_out <= valid and last;
sig_accumulator <= std_logic_vector(unsigned(sig_rotation) + unsigned(sig_rotation_reg));
rotation <= sig_rotation_reg;

accumulator_process : process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            sig_rotation_reg <= (others=>'0');
        else
            if ready = '1' then
                if sig_enable_out = '1' then
                    sig_rotation_reg <= sig_accumulator;
                end if;
            end if;
        end if;
    end if;
end process;

end arch;
