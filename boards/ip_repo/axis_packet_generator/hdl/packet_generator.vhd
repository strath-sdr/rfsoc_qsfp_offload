----------------------------------------------------------------------------------
-- Company: StrathSDR
-- Engineer: David Northcote
-- 
-- Create Date: 30.05.2022 15:42:12
-- Design Name: packet_generator
-- Module Name: axis_packet_generator_v1_0 - arch
-- Project Name: AXI4-Stream Packet Generator
-- Target Devices: Zynq MPSoC
-- Tool Versions: 2021.1
-- Description: Implements a packet generator.
--
-- Revision 0.01 - File Created
-- Additional Comments: N/A
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity packet_generator is
    generic(
	   C_S_AXIS_DATA_WIDTH : integer := 32
	);
	port(
	   aclk : in std_logic;
	   aresetn : in std_logic;
	   enable : in std_logic;
	   count : in std_logic_vector(31 downto 0);
	   state : out std_logic_vector(1 downto 0);
	   s_axis_tdata : in std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
	   s_axis_tvalid : in std_logic;
	   s_axis_tready : out std_logic;
	   m_axis_tdata : out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
	   m_axis_tvalid : out std_logic;
	   m_axis_tlast  : out std_logic;
	   m_axis_tready : in std_logic
    );
end packet_generator;

architecture arch of packet_generator is

type states is (IDLE, INCR, LAST);
signal current_state : states := IDLE;
signal sig_count_lock : std_logic_vector(31 downto 0) := (others=>'0');

begin

state_process : process(aclk)
variable counter : unsigned(31 downto 0) := (others=>'0');
begin
if rising_edge(aclk) then
    if aresetn = '0' then
        current_state <= IDLE;
    else
        case current_state is
            when IDLE =>
                if enable = '1' and (unsigned(sig_count_lock) >= 2) then
                    current_state <= INCR;
                else
                    current_state <= IDLE;
                end if;
            when INCR =>
                if s_axis_tvalid = '1' and m_axis_tready = '1' then
                    counter := counter + 1;
                    if counter >= unsigned(sig_count_lock) - 1 then
                        counter := (others=>'0');
                        current_state <= LAST;
                    else
                        current_state <= INCR;
                    end if;
                end if;
            when LAST =>
                if s_axis_tvalid = '1' and m_axis_tready = '1' then
                    if enable = '1' then
                        current_state <= INCR;
                    else
                        current_state <= IDLE;
                    end if;
                else
                    current_state <= LAST;
                end if; 
            when others =>
                current_state <= IDLE;
                counter := (others=>'0');
        end case;
    end if;
end if;
end process;

output_process : process(aclk)
begin
if rising_edge(aclk) then
    if aresetn = '0' then
        m_axis_tdata <= (others=>'0');
        m_axis_tvalid <= '0';
        m_axis_tlast <= '0';
    else
        case current_state is
            when IDLE =>
                m_axis_tdata <= (others=>'0');
                m_axis_tvalid <= '0';
                m_axis_tlast <= '0';
                state <= "00";
            when INCR =>
                m_axis_tdata <= s_axis_tdata;
                m_axis_tvalid <= s_axis_tvalid;
                m_axis_tlast <= '0';
                state <= "01";
            when LAST =>
                m_axis_tdata <= s_axis_tdata;
                m_axis_tvalid <= s_axis_tvalid;
                m_axis_tlast <= s_axis_tvalid;
                state <= "10";
            when others =>
                m_axis_tdata <= (others=>'0');
                m_axis_tvalid <= '0';
                m_axis_tlast <= '0';
                state <= "11";
        end case;
    end if;
end if;
end process;

input_process : process(aclk)
begin
if rising_edge(aclk) then
    if aresetn <= '0' then
        sig_count_lock <= (others=>'0');
    else
        sig_count_lock <= count;
    end if;
end if;
end process;

s_axis_tready <= m_axis_tready;

end arch;
