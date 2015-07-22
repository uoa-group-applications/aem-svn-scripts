#!/usr/bin/tclsh

package require sqlite3

#
#	Move all dict keys into local variables. Assumes dict keys start with a dash
#
proc dict'make-local {dict at_least} {

	# make sure that at least they variables in at_least are empty
	# if they are not in the dict
	foreach key $at_least {
		if {![dict exists $dict $key]} {
			uplevel 1 [subst {set $key {}}]
		}
	}

	# read the key 
	foreach key [dict keys $dict] {
		set niceKey [string range $key 1 end]
		set value [dict get $dict $key]
		if {$value == {}} then {
			continue
		}

		uplevel 1 [subst -nocommands {
			set {$niceKey} {$value}
		}]
	}
}

#
#	Insert the files
#
proc insert-files {sha operation files} {
	foreach file $files {
		db eval {
			INSERT INTO `commit_file` (sha, filename, operation) 
				VALUES(
					$sha, $file, $operation
				)
		}
	}
}

#
#	Insert ticket information
#
proc insert-tickets {sha revision tickets} {
	foreach ticket $tickets {
		db eval {
			INSERT INTO `ticket_commit_assoc` (sha, revision, ticket) VALUES ($sha, $revision, $ticket)
		}
	}
}

#
#	Insert the merge information
#
proc insert-merge-information {sha from revs} {

	foreach rev $revs {
		db eval {
			INSERT INTO `merge_commit_assoc` (sha, `from`, revision) 
				VALUES (
					$sha, $from, $rev
				)
		}
	}

}

#
#	Parse a log element
#
proc insert-log-element {logElement} {
	dict'make-local $logElement {tickets added modified deleted merge merge-revisions}

	db eval {
		INSERT INTO `commit` 
			(sha, revision, author, date, comment)
			VALUES($sha, $revision, $author, $date, $comment)
	}

	insert-files $sha added $added
	insert-files $sha modified $modified
	insert-files $sha deleted $deleted

	insert-tickets $sha $revision $tickets

	if {$merge != {}} then {
		insert-merge-information $sha $merge ${merge-revisions}
	}
}

# load parameters
lassign $argv inputFile dbFile

# sets 'log' variable
source $inputFile

# sqlite
sqlite3 db $dbFile -create false

db eval {PRAGMA synchronous = OFF}
db eval {PRAGMA journal_mode = MEMORY}


foreach logElement $log {
	insert-log-element $logElement
}


db close
