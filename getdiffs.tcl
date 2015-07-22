#!/usr/bin/tclsh

proc needs-merge {ticket args} { 
	global diffFolder gitFolder

	set shas $args
	puts "$diffFolder/$ticket"

	exec mkdir -p $diffFolder/$ticket

	set cwd [pwd]

	cd $gitFolder
	set idx 0
	foreach sha $shas {
		exec git format-patch --stdout -1 $sha > $diffFolder/$ticket/${idx}_$sha.patch
		incr idx
	}
}


lassign $argv mergeInfo diffFolder gitFolder
source $mergeInfo


