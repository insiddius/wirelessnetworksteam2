
##### Code for NS-2 Simulation in Group-2   #####
	
set si 1.0;				# Interval to calculate throughput			
set myerror 0.0;			# Loss Rate, it is varied from 0% to 10% 

# ======================================================================
# Define options
# ======================================================================

set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)		Mac/802_11
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)    	Antenna/OmniAntenna
set opt(x)		500   	;# X dimension of the topography
set opt(y)		500   	;# Y dimension of the topography
set opt(ifqlen)		50	;# max packet in ifq
set opt(seed)		0.0
set opt(tr)		694demo.tr    ;# trace file
set opt(nam)            694demo.nam   ;# nam trace file
set opt(adhocRouting)   DSDV
set opt(nn)             3             ;# how many nodes are simulated
set opt(cp)		"cbr-3-test" 
set opt(sc)		"scen-3-test" 
set opt(stop)		100.0		;# simulation time
set val(stats_file)     wireless-demo-csci694.stats

# =====================================================================
# Other settings

Mac/802_11 set RTSThreshold_   3000;			# Uncommenting this line to disable RTS/CTS


Phy/WirelessPhy set CSThresh_ 1.7615e-10;		# Setting the Carrier Sense Threshold as instructed in (a)
Phy/WirelessPhy set Pt_ 0.282;				# Setting the Tx Power as instructed in (a)


# ======================================================================
# Main Program
# ======================================================================


set ns_		[new Simulator];				# create simulator instance

set wtopo	[new Topography];				# set topography object

### create trace object for ns and nam and storing throughput
set tracefd	[open $opt(tr) w]
set namtrace    [open $opt(nam) w]
set stats       [open $val(stats_file) w]


$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace 500 500

# use new trace file format

#$ns_ use-newtrace 

# define topology
$wtopo load_flatgrid $opt(x) $opt(y)

#$wprop topography $wtopo

#
# Create God
#
set god_ [create-god $opt(nn)]

#
# define how node should be created
#


$ns_ node-config -adhocRouting $opt(adhocRouting) \
		 -llType $opt(ll) \
		 -macType $opt(mac) \
		 -ifqType $opt(ifq) \
		 -ifqLen $opt(ifqlen) \
		 -antType $opt(ant) \
		 -propType $opt(prop) \
		 -phyType $opt(netif) \
		 -channelType $opt(chan) \
    -topoInstance $wtopo \
    -agentTrace ON \
    -routerTrace OFF \
    -macTrace ON \
	-IncomingErrProc MarkovErr \
	-OutgoingErrProc MarkovErr

proc MarkovErr {} {
		global myerror
		set tmp0 [new ErrorModel/Uniform $myerror pkt]
		set tmp1 [new ErrorModel/Uniform $myerror pkt]

		set m_states [list $tmp0 $tmp1]

		# Durations for each of the states, tmp, tmp1 and tmp2, respectively
		set m_periods [list 10.0 10.0]

		# Transition state model matrix
		set m_transmx { {0 1}
			{1 0} }
		
		set m_trunit pkt
       		# Use time-based transition
        	set m_sttype time
        	set m_nstates 2
        	set m_nstart [lindex $m_states 0]
		
		set em [new ErrorModel/MultiState $m_states $m_periods $m_transmx $m_trunit $m_sttype $m_nstates $m_nstart]
		return $em
	}

#
#  Create the specified number of nodes [$opt(nn)] and "attach" them
#  to the channel. 

for {set i 0} {$i < $opt(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}

$node_(2) set Y_ 50.0
$node_(2) set X_ 450.0
$node_(1) set Y_ 50.0
$node_(1) set X_ 250.0
$node_(0) set Y_ 50.0
$node_(0) set X_ 50.0

$god_ set-dist 2 1 1
$god_ set-dist 0 1 1


set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp_(0)
set udp_(1) [new Agent/UDP]
$ns_ attach-agent $node_(2) $udp_(1)

set sink0 [new Agent/LossMonitor]
$ns_ attach-agent $node_(1) $sink0

set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 1500
$cbr_(0) set interval_ 0.024
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$cbr_(0) attach-agent $udp_(0)
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) set packetSize_ 1500
$cbr_(1) set interval_ 0.024
$cbr_(1) set random_ 1
$cbr_(1) set maxpkts_ 10000
$cbr_(1) attach-agent $udp_(1)
$ns_ connect $udp_(0) $sink0
$ns_ connect $udp_(1) $sink0




# Define node initial position in nam

for {set i 0} {$i < $opt(nn)} {incr i} {
    
   # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}

proc record {} {
	global sink0 ns_ stats si
	set bytes [$sink0 set bytes_] 
	set now [$ns_ now]
	puts $stats $bytes
	$sink0 set bytes_ 0
	$ns_ at [expr $now+$si] record
}

proc finish {} {
    global ns_ tracefd namtrace
	$ns_ flush-trace
	
	close $tracefd
	close $namtrace

	#exec nam 694demo.nam
	#exit 0
}

$ns_ at 2.0 record
$ns_ at 1.0 "$cbr_(0) start"
$ns_ at 1.1 "$cbr_(1) start"
$ns_ at 101.0 "$cbr_(0) stop"
$ns_ at 101.1 "$cbr_(1) stop"

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
# tell nam the simulation stop time
$ns_ at  $opt(stop)	"$ns_ nam-end-wireless $opt(stop)"

$ns_ at  $opt(stop).000000001 "puts \"NS EXITING...\" ; $ns_ halt"

#$ns_ at 105.0 finish
puts "Starting Simulation..."
$defaultRNG seed 0
$ns_ run


## Command to calculate average throughput for a experiment
## awk '{ total += $1; count++ } END { print total/count }' wireless-demo-csci694.stats 



