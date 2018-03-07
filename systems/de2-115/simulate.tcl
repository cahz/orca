source sim_waves.tcl

cd orca_system/simulation/mentor
do msim_setup.tcl
ld

proc reload_sim { } {
    quit -sim
    cd ../../..
    do simulate.tcl
}

proc re_run { t } {
    restart -f ;
    #Initialize clock and reset
    force -repeat 10ns /orca_system/clk_clk 1 0ns, 0 5ns
    force /orca_system/reset_reset_n 0 0ns, 1 1us
    run $t
}


add log -r /*
set DefaultRadix hex

#Initialize clock and reset
force -repeat 10ns /orca_system/clk_clk 1 0ns, 0 5ns
force /orca_system/reset_reset_n 0 0ns, 1 1us

reset_waves
