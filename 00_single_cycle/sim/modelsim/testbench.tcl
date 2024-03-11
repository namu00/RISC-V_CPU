quit -sim
vlib work
vdel -all
vlib work
vlog -f run.f
#vsim work.tb_IF_stage
vsim work.tb_ID_stage
run -a