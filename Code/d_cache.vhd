library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity d_cache is
port(
    reset           : in std_logic;
    clk             : in std_logic;
    data_write      : in std_logic;
    data_address    : in std_logic_vector(4 downto 0);
    d_in            : in std_logic_vector(31 downto 0);
    d_out           : out std_logic_vector(31 downto 0)        
    );
end d_cache;

architecture d_cache_arch of d_cache is

type d_cache_array is array (0 to 31) of std_logic_vector(31 downto 0);
signal d_cache_data: d_cache_array; 

begin
    process(data_address, d_cache_data)
    begin
        d_out <= d_cache_data(conv_integer(data_address)); 
    end process;

    process(d_in, reset, clk, data_write, data_address, d_cache_data)
    begin
        if (reset = '1') then
            for i in 0 to 31 loop
                d_cache_data(i) <= (others => '0');
            end loop;
        
        elsif ((rising_edge(clk)) AND (data_write = '1')) then
            d_cache_data(conv_integer(data_address)) <= d_in;
        end if;
    end process;
end d_cache_arch;