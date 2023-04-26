----------------------------------------------------------------------------------
-- Company: StrathSDR
-- Engineer: David Northcote
-- 
-- Create Date: 09.05.2022 15:42:12
-- Design Name: axis_tkeep_pack
-- Module Name: axis_tkeep_pack_v1_0 - arch
-- Project Name: AXI4-Stream TKEEP Pack
-- Target Devices: Zynq MPSoC
-- Tool Versions: 2020.2
-- Description: Implements a TKEEP packer.
--
-- Revision 0.01 - File Created
-- Additional Comments: N/A
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_tkeep_pack_v1_0 is
	port (
		aclk	        : in std_logic;
		aresetn	        : in std_logic;
		
		s_axis_tready	: out std_logic;
		s_axis_tdata	: in std_logic_vector(127 downto 0);
		s_axis_tkeep	: in std_logic_vector(15 downto 0);
		s_axis_tlast	: in std_logic;
		s_axis_tvalid	: in std_logic;
		
		m_axis_tready	: in std_logic;
		m_axis_tdata	: out std_logic_vector(127 downto 0);
		m_axis_tvalid	: out std_logic
	);
end axis_tkeep_pack_v1_0;

architecture arch_imp of axis_tkeep_pack_v1_0 is

component tkeep_encoder is
    port (aclk         : in std_logic;
          aresetn      : in std_logic;
          last         : in std_logic;
          keep         : in std_logic_vector(7 downto 0);
          valid        : in std_logic;
          ready        : in std_logic;
          rotation      : out std_logic_vector(2 downto 0)
          );
end component tkeep_encoder;

component tkeep_rotator is
    port (aclk          : in std_logic;
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
end component tkeep_rotator;

type constant_array is array(7 downto 0) of std_logic_vector(2 downto 0);
type rotator_data_array is array(7 downto 0) of std_logic_vector(15 downto 0);
type not_empty_array is array(7 downto 0) of std_logic;
constant offset : constant_array := ("111", "110", "101", "100",
                                     "011", "010", "001", "000");
signal sig_rotator_data     : rotator_data_array;
signal sig_not_empty        : not_empty_array;
signal sig_not_empty_op     : not_empty_array;
signal sig_tlast_input_reg  : std_logic;
signal sig_tvalid_input_reg : std_logic;
signal sig_tdata_input_reg  : std_logic_vector(127 downto 0);
signal sig_tkeep_input_reg  : std_logic_vector(7 downto 0);
signal sig_tkeep_reduce     : std_logic_vector(7 downto 0);
signal sig_rotation         : std_logic_vector(2 downto 0);
signal sig_read_and         : std_logic;
signal sig_read_and_reg     : std_logic;

begin

encoder_inst : tkeep_encoder
  port map(aclk => aclk,
           aresetn => aresetn,
           last => sig_tlast_input_reg,
           keep => sig_tkeep_input_reg,
           ready => m_axis_tready,
           valid => sig_tvalid_input_reg,
           rotation => sig_rotation);
           
generate_rotators: for I in 0 to 7 generate
    rotator_inst : tkeep_rotator
      port map(aclk => aclk,
               aresetn => aresetn,
               rotation => sig_rotation,
               read => sig_read_and_reg,
               valid => sig_tvalid_input_reg,
               ready => m_axis_tready,
               data_in => sig_tdata_input_reg,
               keep => sig_tkeep_input_reg,
               offset => offset(I),
               data_out => sig_rotator_data(I),
               not_empty => sig_not_empty(I));
end generate;     

input_process : process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            sig_tvalid_input_reg <= '0';
            sig_tdata_input_reg <= (others=>'0');
            sig_tlast_input_reg <= '0';
            sig_tkeep_input_reg <= (others=>'0');
        else
            if m_axis_tready = '1' then
                sig_tvalid_input_reg <= s_axis_tvalid;
                sig_tdata_input_reg <= s_axis_tdata;
                sig_tlast_input_reg <= s_axis_tlast;
                sig_tkeep_input_reg <= sig_tkeep_reduce;
            end if;
        end if;
    end if;
end process;

output_process : process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            m_axis_tvalid <= '0';
        else
            if m_axis_tready = '1' then
                m_axis_tvalid <= sig_read_and_reg;
            end if;
        end if;
    end if;
end process;

sig_not_empty_op(0) <= sig_not_empty(0);
generate_bitwise_or : for I in 1 to 7 generate
    sig_not_empty_op(I) <= sig_not_empty_op(I-1) and sig_not_empty(I);
end generate;

generate_data_out : for I in 0 to 7 generate
    m_axis_tdata(16*(I+1)-1 downto 16*I) <= sig_rotator_data(I);
end generate;

generate_keep_out : for I in 0 to 7 generate
    sig_tkeep_reduce(I downto I) <= s_axis_tkeep(I*2 downto I*2);
end generate;

s_axis_tready <= m_axis_tready;
sig_read_and_reg <= sig_not_empty_op(7);

end arch_imp;
