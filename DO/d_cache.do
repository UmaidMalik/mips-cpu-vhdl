force reset 1
force clk 0
force data_write 0
force data_address 00000
force d_in X"00000000"
run 2

force reset 0
force clk 1
force data_write 1
force data_address 00001
force d_in X"FDFEA73C"
run 2
examine reset clk data_write data_address
examine -radix X d_out

force clk 0
run 2
examine reset clk data_write data_address
examine -radix X d_out

force data_address 00010
force d_in X"FFEFBFED"
force clk 1
run 2
examine reset clk data_write data_address
examine -radix X d_out

force data_write 0
force data_address 00001
run 2 
examine reset clk data_write data_address
examine -radix X d_out

force reset 1
run 2
examine reset clk data_write data_address
examine -radix X d_out

force data_address 00010
run 2
examine reset clk data_write data_address
examine -radix X d_out






