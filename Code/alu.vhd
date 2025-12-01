library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity alu is 
port(
    x, y       : in std_logic_vector(31 downto 0); -- two input operands 
    
    add_sub     : in std_logic ; -- 0 = add, 1 = sub
    
    logic_func  : in std_logic_vector(1 downto 0 ) ; -- 00 = AND , 01 = OR , 10 = XOR , 11 = NOR
    
    func        : in std_logic_vector(1 downto 0 ) ; -- 00 = lui , 01 = setless , 10 = arith , 11 = logic

    output      : out std_logic_vector(31 downto 0) ;
    overflow    : out std_logic;
    zero        : out std_logic
    );
end alu ;


architecture alu_arch of alu is

signal result, logic_unit, less: std_logic_vector(31 downto 0); 
signal overflow_check : std_logic_vector(2 downto 0);

begin

    process(x, y, func, logic_func, add_sub, result, logic_unit, overflow_check, less)
    begin

        overflow_check <= result(result'high) & x(x'high) & y(y'high);


        case add_sub is
            when '0' => result <= x + y;
                    if ((overflow_check = "100") OR (overflow_check = "011")) then
                        overflow <= '1';
                    else
                        overflow <= '0';
                    end if;

            when '1' => result <= x - y;
                    if ((overflow_check = "010") OR (overflow_check = "101")) then
                        overflow <= '1';
                    else
                        overflow <= '0';
                    end if ;
            when others =>
        end case;

        case logic_func is 
            when "00" => logic_unit <= x AND y;

            when "01" => logic_unit <= x OR y;

            when "10" => logic_unit <= x XOR y;

            when "11" => logic_unit <= x NOR y;

            when others =>
        end case;

        if (result = x"00000000") then
            zero <= '1';
        else
            zero <= '0';
        end if;

        less <= x - y;

        case func is
            when "00" => output <= y;

            when "01" => output <= "0000000000000000000000000000000" & less(less'high);

            when "10" => output <= result;

            when "11" => output <= logic_unit;

            when others =>
        end case;

    end process;
end alu_arch;



