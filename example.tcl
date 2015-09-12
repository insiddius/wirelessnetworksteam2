set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf
set topo  [new Topography];                # Create a Topography object   
$topo load_flatgrid  500  500;		   # Make a 500x500 grid topology
$ns node-config -llType         LL
                -ifqType        "DropTail"
                -ifqLen         50
                -macType        Mac/802_11
                -phyType        Phy/WirelessPhy

		-addressingType flat 
                -adhocRouting   DSR or DSDV
                -propType       Propagation
                -antType        Antenna
                -channelType    WirelessChannel
                -topoInstance   $topo

                -agentTrace     ON 
                -routerTrace    ON 
                -macTrace       OFF
                -movementTrace  OFF
proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam out.nam &
        exit 0
}
$node_(0) set X_ 50.0
$node_(0) set Y_ 50.0

$node_(1) set X_ 250.0
$node_(1) set Y_ 50.0

$node_(2) set X_ 450.0
$node_(2) set Y_ 50.0

$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n2 $n1 1Mb 10ms DropTail

#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

#Create a UDP agent and attach it to node n2
set udp2 [new Agent/UDP]
$ns attach-agent $n2 $udp2

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0   

# Create a CBR traffic source and attach it to udp2
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp2

set null0 [new Agent/Null] 
$ns attach-agent $n1 $null0

$ns connect $udp0 $null0
$ns connect $udp2 $null0

$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

$ns at 0.5 "$cbr1 start"
$ns at 4.5 "$cbr1 stop"


$ns at 5.0 "finish"
$ns run
