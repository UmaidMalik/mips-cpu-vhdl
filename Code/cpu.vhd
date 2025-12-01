library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity cpu  is 
port(
    cpu_reset                   : in std_logic;
    cpu_clk                     : in std_logic;
    rs_out , rt_out             : out std_logic_vector(31 downto 0);
    
    -- output ports from register file

    pc_out                      : out std_logic_vector(31 downto 0); -- pc reg
    cpu_overflow, cpu_zero      : out std_logic          
    );
end cpu;


architecture cpu_arch of cpu is

-- next-address component
component next_address
port(
    rt, rs          : in std_logic_vector(31 downto 0); -- two register inputs
    pc              : in std_logic_vector(31 downto 0);
    target_address  : in std_logic_vector(25 downto 0); 
    branch_type     : in std_logic_vector(1 downto 0); 
    pc_sel          : in std_logic_vector(1 downto 0); 
    next_pc         : out std_logic_vector(31 downto 0) 
    );
end component;

-- PC register component
component pc_reg
port(
        reset       : in std_logic;
        clk         : in std_logic;
        d           : in std_logic_vector(31 downto 0);
        out_pc      : out std_logic_vector(31 downto 0);
        q           : out std_logic_vector(4 downto 0)
    );
end component;

-- Instruction Cache component
component i_cache
port(
    input_address       : in std_logic_vector(4 downto 0);
    output_instruction  : out std_logic_vector(31 downto 0)        
    );
end component;

-- Register File component
component regfile
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
end component;

-- Arithemetic & Logic Unit Component
component alu
port(
    x, y       : in std_logic_vector(31 downto 0); -- two input operands 
    add_sub     : in std_logic; -- 0 = add, 1 = sub
    logic_func  : in std_logic_vector(1 downto 0 ) ; -- 00 = AND , 01 = OR , 10 = XOR , 11 = NOR
    func        : in std_logic_vector(1 downto 0 ) ; -- 00 = lui , 01 = setless , 10 = arith , 11 = logic
    output      : out std_logic_vector(31 downto 0) ;
    overflow    : out std_logic;
    zero        : out std_logic
    );
end component;

-- Data Cache component
component d_cache
port(
    reset           : in std_logic;
    clk             : in std_logic;
    data_write      : in std_logic;
    data_address    : in std_logic_vector(4 downto 0);
    d_in            : in std_logic_vector(31 downto 0);
    d_out           : out std_logic_vector(31 downto 0)        
    );
end component;

-- Sign Extend component
component sign_extend 
port(
        in_16bit    : in std_logic_vector(15 downto 0);
        func        : in std_logic_vector(1 downto 0);
        out_32bit   : out std_logic_vector(31 downto 0)
    );
end component;

signal next_pc_out, pc_out_32bit, i_cache_out, reg_in, reg_out_a, reg_out_b, alu_out, alu_in, d_cache_out, sign_extend_out : std_logic_vector(31 downto 0);
signal reg_address_in : std_logic_vector(4 downto 0) := (others => '0');
signal pc_out_5bit : std_logic_vector(4 downto 0);
signal pc_select, branch_select, alu_function, alu_logic_function : std_logic_vector(1 downto 0) := "00";
signal alu_addsub, d_cache_write, reg_write, reg_dst, alu_src, reg_in_src : std_logic := '0';

signal opcode, fnction : std_logic_vector(5 downto 0) := (others => '0');
signal control          : std_logic_vector(13 downto 0);


begin
-- control unit process
    process(i_cache_out, cpu_clk, cpu_reset, opcode, fnction, control)
    begin
        opcode  <= i_cache_out(31 downto 26);
        fnction <= i_cache_out(5 downto 0);
        case opcode is 
            when "000000" =>
                if    (fnction = "100000") then -- add
                    control <= "11100000100000";
                elsif (fnction = "100010") then -- sub
                    control <= "11101000100000";
                elsif (fnction = "101010") then -- slt
                    control <= "11100000010000";
                elsif (fnction = "100100") then -- and
                    control <= "11101000110000";
                elsif (fnction = "100101") then -- or
                    control <= "11100001110000";
                elsif (fnction = "100110") then -- xor
                    control <= "11100010110000";
                elsif (fnction = "100111") then -- nor
                    control <= "11100011110000";
                elsif (fnction = "001000") then -- jr
                    control <= "00000000000010"; 
                else end if;
            when "001111" => control <= "10110000000000"; -- lui
            when "001000" => control <= "10110000100000"; -- addi
            when "001010" => control <= "10110000010000"; -- slti
            when "001100" => control <= "10110000110000"; -- andi
            when "001101" => control <= "10110001110000"; -- ori
            when "001110" => control <= "10110010110000"; -- xori
            when "100011" => control <= "10010010100000"; -- lw
            when "101011" => control <= "00010100100000"; -- sw
            when "000010" => control <= "00000000000001"; -- j
            when "000001" => control <= "00000000001100"; -- bltz
            when "000100" => control <= "00000000000100"; -- beq
            when "000101" => control <= "00000000001000"; -- bne
            when others =>
        end case;

        reg_write           <= control(13);
        reg_dst             <= control(12);
        reg_in_src          <= control(11);
        alu_src             <= control(10);
        alu_addsub          <= control(9);
        d_cache_write       <= control(8);
        alu_logic_function  <= control(7 downto 6);
        alu_function        <= control(5 downto 4);
        branch_select       <= control(3 downto 2);
        pc_select           <= control(1 downto 0);

    end process;
    
-- component connection
NextAddress : next_address port map(
        rt => reg_out_b, 
        rs => reg_out_a, 
        pc => pc_out_32bit, 
        target_address => i_cache_out(25 downto 0), 
        branch_type => branch_select, 
        pc_sel => pc_select, 
        next_pc => next_pc_out);

ProgramCounter : pc_reg port map(
        reset => cpu_reset, 
        clk => cpu_clk, 
        d => next_pc_out, 
        out_pc => pc_out_32bit, 
        q => pc_out_5bit);

ICache : i_cache port map(
        input_address => pc_out_5bit, 
        output_instruction => i_cache_out
        );

RegisterFile : regfile port map(
        din => reg_in, 
        reset => cpu_reset, 
        clk => cpu_clk, 
        write => reg_write, 
        read_a => i_cache_out(25 downto 21), 
        read_b => i_cache_out(20 downto 16), 
        write_address => reg_address_in, 
        out_a => reg_out_a, 
        out_b => reg_out_b);

ArithmeticUnit : alu port map(
        x => reg_out_a,
        y => alu_in, 
        add_sub => alu_addsub,
        logic_func => alu_logic_function, 
        func => alu_function, 
        output => alu_out, 
        overflow => cpu_overflow, 
        zero => cpu_zero
        );

DCache : d_cache port map(
        reset => cpu_reset, 
        clk => cpu_clk, 
        data_write => d_cache_write, 
        data_address => alu_out(4 downto 0), 
        d_in => reg_out_b, d_out => d_cache_out
        );

SignExtend : sign_extend port map(
    in_16bit => i_cache_out(15 downto 0), 
    func => alu_function, 
    out_32bit => sign_extend_out
    );

reg_address_in <= i_cache_out(20 downto 16) when (reg_dst = '0')
                else i_cache_out(15 downto 11) when (reg_dst = '1');

alu_in <= reg_out_b when (alu_src = '0')
        else sign_extend_out when (alu_src = '1');

reg_in <= d_cache_out when (reg_in_src = '0')
        else alu_out when (reg_in_src = '1');


rs_out <= reg_out_a;
rt_out <= reg_out_b;
pc_out <= pc_out_32bit;
        

end cpu_arch;



