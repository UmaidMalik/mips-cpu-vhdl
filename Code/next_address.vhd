library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity next_address  is 
port(
    rt, rs          : in std_logic_vector(31 downto 0); -- two register inputs
    
    pc              : in std_logic_vector(31 downto 0);
    
    target_address  : in std_logic_vector(25 downto 0); 
    
    branch_type     : in std_logic_vector(1 downto 0); 

    pc_sel          : in std_logic_vector(1 downto 0); 

    next_pc         : out std_logic_vector(31 downto 0) 
    );
end next_address;


architecture pc_arch of next_address is


begin
    process(rt, rs, pc, target_address, branch_type, pc_sel)
    begin
        case pc_sel is
            -- no unconditional jump
            when "00" =>
                case branch_type is
                    when "00" =>
                        next_pc <= pc + x"00000001"; -- no branch
                    when "01" =>
                        if (rs = rt) then
                            next_pc <= pc + x"00000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0)); 
                        else
                            next_pc <= pc + x"00000001"; -- no branch, rs /= rt
                        end if;

                    when "10" =>
                        if (rs /= rt) then
                            next_pc <= pc + x"00000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
                        else
                            next_pc <= pc + x"00000001"; -- no branch, rs = rt
                        end if;

                    when "11" =>
                        if (rs < 0) then
                            next_pc <= pc + x"00000001" + ((31 downto 16 => target_address(15)) & target_address(15 downto 0));
                        else
                            next_pc <= pc + x"00000001"; -- no branch, rs >= 0
                        end if;
                    when others =>
                end case;

            -- jump
            when "01" =>
                next_pc <= "000000" & target_address;

            -- jump register
            when "10" =>
                next_pc <= rs;

            when others =>
        end case;
    end process;
end pc_arch;



