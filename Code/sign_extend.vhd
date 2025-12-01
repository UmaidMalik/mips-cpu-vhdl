library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity sign_extend is 
port(
        in_16bit    : in std_logic_vector(15 downto 0);
        func        : in std_logic_vector(1 downto 0);
        out_32bit   : out std_logic_vector(31 downto 0)
    );
end sign_extend;

architecture sign_arch of sign_extend is

begin 
    process(in_16bit, func)
    begin
        case func is
            when "00" => out_32bit <= (in_16bit & (15 downto 0 => '0')); -- load upper immediate
            when "01" => out_32bit <= ((31 downto 16 => in_16bit(15)) & in_16bit(15 downto 0)); -- set less immediate
            when "10" => out_32bit <= ((31 downto 16 => in_16bit(15)) & in_16bit(15 downto 0)); -- arithmetic
            when "11" => out_32bit <= ((31 downto 16 => '0') & in_16bit); -- logical
            when others =>
        end case;
    end process;
end sign_arch;