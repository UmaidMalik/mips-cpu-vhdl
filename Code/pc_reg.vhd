library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity pc_reg is 
port(
        reset       : in std_logic;
        clk         : in std_logic;
        d           : in std_logic_vector(31 downto 0);
        out_pc      : out std_logic_vector(31 downto 0);
        q           : out std_logic_vector(4 downto 0)
    );
end pc_reg;

architecture pc_reg_arch of pc_reg is

begin
    process(reset, clk, d)
    begin
        if (reset = '1') then
            out_pc <= (others => '0');
            q <= (others => '0');
        elsif (rising_edge(clk)) then
            out_pc <= d;
            q <= d(4 downto 0);
        end if;
    end process;


end pc_reg_arch;