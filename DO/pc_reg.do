force reset 1
force clk 0
force d X"00000000"
run 2
examine reset clk out_pc q
examine -radix X out_pc

force reset 0
force clk 1
force d X"FF330317"
run 2
examine reset clk out_pc q
examine -radix X out_pc

force reset 1
run 2
examine reset clk out_pc q
examine -radix X out_pc