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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity async_fifo_control is
   port(
   aclk  : in std_logic;
   aresetn : in std_logic;
   reset : in std_logic;
   irq_enable : in std_logic;
   empty : in std_logic;
   full  : in std_logic;
   ready : out std_logic;
   underflow : out std_logic;
   status : out std_logic_vector(1 downto 0)
   );
end async_fifo_control;

architecture arch of async_fifo_control is

type control_states is (FILL, READ, ERROR, RST);

signal current_state : control_states := FILL;

begin

state_process : process(aclk)
begin
    if rising_edge(aclk) then
        if (aresetn = '0') then
            current_state <= FILL;
        else
            case current_state is
                when FILL =>
                    if full = '1' and reset = '0' then
                        current_state <= READ;
                    else
                        current_state <= FILL;
                    end if;
                
                when READ =>
                    if empty = '1' and irq_enable = '1' then
                        current_state <= ERROR;
                    elsif empty = '1' and irq_enable = '0' then
                        current_state <= FILL;
                    else
                        current_state <= READ;
                    end if;                   
                
                when ERROR =>
                    if reset = '1' then
                        current_state <= RST;
                    else
                        current_state <= ERROR;
                    end if;
                    
                when RST =>
                    current_state <= FILL;
                
                when others =>
                    current_state <= FILL;
            end case;
        end if;
    end if;
end process;

output_process : process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            ready <= '0';
            status <= "11";
        else
            case current_state is
                when FILL =>
                    ready <= '0';
                    status <= "00";
                    underflow <= '0';
                when READ =>
                    ready <= '1';
                    status <= "01";
                    underflow <= '0';
                when ERROR =>
                    ready <= '0';
                    status <= "10";
                    underflow <= '1';
                when RST =>
                    ready <= '0';
                    status <= "11";
                    underflow <= '0';
                when others =>
                    ready <= '0';
                    status <= "10";
                    underflow <= '0';
            end case;
       end if;
   end if;
end process;

end arch;
