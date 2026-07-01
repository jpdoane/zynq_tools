######################################################################
# Automatically inserts a single ILA core in a batch flow and calls
# "implement_debug_core".  Should be invoked after synthesis (open_run
# synth_1) and before opt_design, so that MARK_DEBUG nets still exist.
#
# Simplifying assumptions:
#   - All debug nets share the same clock.
#   - All debug nets use the same ILA properties (single ILA core).
######################################################################

if {![info exists ila_clk]} { set ila_clk clk_fpga_1}
if {![info exists ila_depth]} { set ila_depth 1024}
if {![info exists ila_name]} { set ila_name ila_0}

# Find all nets marked for debug
set net_list [get_nets -hierarchical -filter {MARK_DEBUG}]
if {[llength $net_list] == 0} {
    puts "No nets have the MARK_DEBUG attribute.  No ILA core created."
    return
}

# ILA capture clock.  All debug nets are assumed to use this clock.
# set ila_clk_net [get_nets -of_objects [get_pins -filter {IS_CLOCK} -of_objects [get_clocks $clk]]]
set ila_clk_net [get_nets -of_objects [get_pins -of_objects [get_clocks $ila_clk]]]

##################################################################
# Determine probe names from net/bus names.
# name  = root name of a bus (with the [index] suffix stripped)
# index = bit index within the bus
# max($name) == -1 marks a single-bit (scalar) net.
foreach d $net_list {
    set name  [regsub {\[[[:digit:]]+\]$} $d {}]
    set index [regsub {^.*\[([[:digit:]]+)\]$} $d {\1}]
    if {[string is integer -strict $index]} {
        if {![info exists max($name)]} {
            set max($name) $index
            set min($name) $index
        } elseif {$index > $max($name)} {
            set max($name) $index
        } elseif {$index < $min($name)} {
            set min($name) $index
        }
    } else {
        set max($name) -1
    }
}

##################################################################
# Create the ILA core
set ila_inst $ila_name
create_debug_core $ila_inst ila
set_property C_DATA_DEPTH          $ila_depth [get_debug_cores $ila_inst]
set_property C_TRIGIN_EN           false  [get_debug_cores $ila_inst]
set_property C_TRIGOUT_EN          false  [get_debug_cores $ila_inst]
set_property C_ADV_TRIGGER         false  [get_debug_cores $ila_inst]
set_property C_INPUT_PIPE_STAGES   1      [get_debug_cores $ila_inst]
set_property C_EN_STRG_QUAL        true   [get_debug_cores $ila_inst]
set_property ALL_PROBE_SAME_MU     true   [get_debug_cores $ila_inst]
set_property ALL_PROBE_SAME_MU_CNT 2      [get_debug_cores $ila_inst]
set_property port_width 1 [get_debug_ports $ila_inst/clk]
connect_debug_port $ila_inst/clk $ila_clk_net

##################################################################
# Add one probe per net/bus
set nprobes 0
foreach n [lsort [array names max]] {
    set nets {}
    if {$max($n) < 0} {
        lappend nets [get_nets $n]
    } else {
        for {set i $min($n)} {$i <= $max($n)} {incr i} {
            lappend nets [get_nets $n\[$i\]]
        }
    }
    set prb probe$nprobes
    if {$nprobes > 0} {
        create_debug_port $ila_inst probe
    }
    set_property port_width [llength $nets] [get_debug_ports $ila_inst/$prb]
    connect_debug_port $ila_inst/$prb $nets
    incr nprobes
}

# save_constraints
implement_debug_core
write_debug_probes -force probes.ltx
write_xdc -force debug_cores.xdc
