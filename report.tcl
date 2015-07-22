#!/usr/bin/tclsh

package require sqlite3

#
# 	query for all ticket names
#
proc ticket'all-names {} {

	return [db eval {
		select distinct(ticket) as t from ticket_commit_assoc order by t
	}]

}

#
#	query for the revisions that belong to a ticket
#
proc ticket'all-revisions {ticket} {
	set revShaList [
		db eval {
			select 
				distinct(c.revision),
				c.sha
			from `commit` as c
			join ticket_commit_assoc as tca on c.revision = tca.revision
			where tca.ticket = $ticket
			order by c.revision desc
		}
	]

	lappend shas
	foreach {rev sha} $revShaList {
		lappend shas $sha
	}

	return $shas
}

#
#	determine if the ticket is merged by reading its last revision and seeing if
#	it contains references to 'trunk'
#
proc ticket'is-merged {ticket} {
	set result [db eval {
			select filename from commit_file where sha = (
				select sha from `commit` where revision = (
					select 
						c.revision		
					from `commit` as c
					join ticket_commit_assoc as tca on c.revision = tca.revision
					where tca.ticket = $ticket
					order by c.revision desc
					limit 1
				)
			)
			and filename like '%trunk%'
			limit 1
			;
		}]

	if {$result == {}} then {
		return false
	}
	return true
}

#
#	Open database and output
#

sqlite3 db [lindex $argv 0] -create false 

foreach ticket [ticket'all-names] {
	if {![ticket'is-merged $ticket]} then {
		puts "needs-merge $ticket [ticket'all-revisions $ticket]"
	}
}

db close


# TODO: find tickets that have changes after they have been 'trunked'