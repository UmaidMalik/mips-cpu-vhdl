-- 32 x 32 register file
-- two read ports, one write port with write enable

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity regfile is
port(
    din             : in std_logic_vector(31 downto 0);
    reset           : in std_logic;
    clk             : in std_logic;
    write           : in std_logic;
    read_a          : in std_logic_vector(4 downto 0);
    read_b          : in std_logic_vector(4 downto 0);
    write_address   : in std_logic_vector(4 downto 0);
    out_a           : out std_logic_vector(31 downto 0);
    out_b           : out std_logic_vector(31 downto 0)
);
end regfile;

architecture regfile_arch of regfile is 

type register_array is array (0 to 31) of std_logic_vector(31 downto 0);
signal registers: register_array; 

begin
    -- read process 
    process(read_a, read_b, registers)
    begin
        out_a <= registers(conv_integer(read_a)); 
        out_b <= registers(conv_integer(read_b)); 
    end process;

    -- write process
    process(din, reset, clk, write, write_address)
    begin
        if (reset = '1') then
            for i in 0 to 31 loop
                registers(i) <= (others => '0');
            end loop;
        
        elsif ((rising_edge(clk)) AND (write = '1')) then
            registers(conv_integer(write_address)) <= din;
        end if;
            
    end process;

end regfile_arch;