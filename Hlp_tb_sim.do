onbreak resume
onerror resume
vsim -novopt work.Hlp_tb
add wave sim:/Hlp_tb/u_lowpass/clk
add wave sim:/Hlp_tb/u_lowpass/clk_enable
add wave sim:/Hlp_tb/u_lowpass/reset
add wave sim:/Hlp_tb/u_lowpass/filter_in
add wave sim:/Hlp_tb/u_lowpass/filter_out
add wave sim:/Hlp_tb/filter_out_ref
run -all
