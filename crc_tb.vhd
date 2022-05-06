library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc_tb is
end entity;

architecture  foo of crc_tb is

    signal data_in:  std_logic_vector (31 downto 0);
    signal crc_en:   std_logic := '0';
    signal rst:      std_logic;
    signal clk:      std_logic := '0';
    signal crc_out:  std_logic_vector (31 downto 0);

begin

DUT:
    entity work.crc_seq
        port map (
            data_in => data_in,
            crc_en => crc_en,
            rst => rst,
            clk => clk,
            crc_out => crc_out
        );

CLOCK:
    process 
    begin
        wait for 5 ns; -- half the clock period
        clk <= not clk;
        if now > 1000 ns then
            wait;
        end if;
    end process;
STIMULI:
     process
    begin
        rst <= '1';
		data_in <= std_logic_vector(to_unsigned (0,32));
        for i in 0 to 9 loop
            wait until rising_edge(clk);
        end loop;
        rst <= '0';
        crc_en <= '1';
        for i in 1 to 8 loop
            data_in <= std_logic_vector(to_unsigned (i,32));
            wait until rising_edge(clk);
        end loop;
        crc_en <= '0';
        wait until rising_edge(clk);
        wait;
    end process; 
		
end architecture;
