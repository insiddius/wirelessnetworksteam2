# Copyright (c) 1999 Regents of the University of Southern California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# A simple example for wireless simulation
# Specially written for csci 694 on Sept. 10th, 1999
# Ya Xu, yaxu@isi.edu, 1999

#$ns node-config -IncomingErrProc UniformErr -OutgoingErrProc UniformErr

	

# ======================================================================
# Define options
# ======================================================================

set opt(chan)	Channel/WirelessChannel
set opt(prop)	Propagation/TwoRayGround
set opt(netif)	Phy/WirelessPhy
set opt(mac)	Mac/802_11
set opt(ifq)	Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)        Antenna/OmniAntenna
set opt(x)		500   ;# X dimension of the topography
set opt(y)		500   ;# Y dimension of the topography
set opt(ifqlen)	50	      ;# max packet in ifq
set opt(seed)	0.0
set opt(tr)		694demo.tr    ;# trace file
set opt(nam)            694demo.nam   ;# nam trace file
set opt(adhocRouting)   DSDV
set opt(nn)             3             ;# how many nodes are simulated
set opt(cp)		"cbr-3-test" 
set opt(sc)		"scen-3-test" 
set opt(stop)		100.0		;# simulation time
set val(stats_file)     wireless-demo-csci694.stats

# =====================================================================
# Other default settings

#LL set mindelay_		50us
#LL set delay_			25us
#LL set bandwidth_		0	;# not used

#Agent/Null set sport_		0
#Agent/Null set dport_		0

#Agent/CBR set sport_		0
#Agent/CBR set dport_		0

#Agent/TCPSink set sport_	0
#Agent/TCPSink set dport_	0

#Agent/TCP set sport_		0
#Agent/TCP set dport_		0
#Agent/TCP set packetSize_	1460

#Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
#Antenna/OmniAntenna set X_ 0
#Antenna/OmniAntenna set Y_ 0
#Antenna/OmniAntenna set Z_ 1.5
#Antenna/OmniAntenna set Gt_ 1.0
#Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
#Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.7615e-10
#Phy/WirelessPhy set RXThresh_ 3.652e-10
#Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.282
#Phy/WirelessPhy set freq_ 914e+6 
#Phy/WirelessPhy set L_ 1.0


# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#

# create simulator instance

set ns_		[new Simulator]

# set wireless channel, radio-model and topography objects

#set wchan	[new $opt(chan)]
#set wprop	[new $opt(prop)]
set wtopo	[new Topography]

# create trace object for ns and nam

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
		set tmp0 [new ErrorModel/Uniform 0.00 pkt]
		set tmp1 [new ErrorModel/Uniform 0.01 pkt]
		set tmp2 [new ErrorModel/Uniform 0.02 pkt]
		set tmp3 [new ErrorModel/Uniform 0.03 pkt]
		set tmp4 [new ErrorModel/Uniform 0.04 pkt]
		set tmp5 [new ErrorModel/Uniform 0.05 pkt]
		set tmp6 [new ErrorModel/Uniform 0.06 pkt]
		set tmp7 [new ErrorModel/Uniform 0.07 pkt]
		set tmp8 [new ErrorModel/Uniform 0.08 pkt]
		set tmp9 [new ErrorModel/Uniform 0.09 pkt]
		set tmp10 [new ErrorModel/Uniform 0.10 pkt]

		set m_states [list $tmp0 $tmp1 $tmp2 $tmp3 $tmp4 $tmp5 $tmp6 $tmp7 $tmp8 $tmp9 $tmp10]

		# Durations for each of the states, tmp, tmp1 and tmp2, respectively
		set m_periods [list 9.0909 9.0909 9.0909  9.0909  9.0909  9.0909  9.0909  9.0909  9.0909  9.0909  9.0909]

		# Transition state model matrix
		set m_transmx { {0 1 0 0 0 0 0 0 0 0 0}
			{0 0 1 0 0 0 0 0 0 0 0}
			{0 0 0 1 0 0 0 0 0 0 0}
			{0 0 0 0 1 0 0 0 0 0 0}
			{0 0 0 0 0 1 0 0 0 0 0}
			{0 0 0 0 0 0 1 0 0 0 0}
			{0 0 0 0 0 0 0 1 0 0 0}
			{0 0 0 0 0 0 0 0 1 0 0}
			{0 0 0 0 0 0 0 0 0 1 0}
			{0 0 0 0 0 0 0 0 0 0 1}
			{0 0 0 0 0 0 0 0 0 0 1} }
		
		set m_trunit pkt
       		# Use time-based transition
        	set m_sttype time
        	set m_nstates 11
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

set null_(0) [new Agent/LossMonitor]
$ns_ attach-agent $node_(1) $null_(0)

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
$ns_ connect $udp_(0) $null_(0)
$ns_ connect $udp_(1) $null_(0)
$ns_ at 0.0001 "$cbr_(0) start"
$ns_ at 0.0001 "$cbr_(1) start"
$ns_ at 100.0 "$cbr_(0) stop"
$ns_ at 100.0 "$cbr_(1) stop"




# Define node initial position in nam

for {set i 0} {$i < $opt(nn)} {incr i} {
    
   # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}

proc stop {} {
    global ns tracefd namtrace stats val null_(0)

    set bytes [$null_(0) set bytes_]
    set losts  [$null_(0) set nlost_]
    set pkts [$null_(0) set npkts_]
    puts $stats "bytes losts pkts"
    puts $stats "$bytes $losts $pkts"

	$ns flush-trace
    close $nam
    close $tracefd
    close $stats
}


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
# tell nam the simulation stop time
$ns_ at  $opt(stop)	"$ns_ nam-end-wireless $opt(stop)"

$ns_ at  $opt(stop).000000001 "puts \"NS EXITING...\" ; $ns_ halt"


puts "Starting Simulation..."
$ns_ run




