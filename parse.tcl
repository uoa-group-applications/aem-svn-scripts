#!/usr/bin/tclsh

#
#	Parses the output of: git log --name-status > cms-log-2.txt into a tcl datastructure
#


#
#	Initial global variables
#

set default_commit {
	-sha {}
	-revision {} 
	-author {} 
	-date {} 
	-comment {} 
	-tickets {}
	-merge {}
	-merge-revisions {}
	
	-files {}
	-added {}
	-deleted {}
	-modified {}
}

set current_commit {}
lappend commits 



#
#	Some util functions
#
namespace eval util {

	proc read_file {filename} {
		set fp [open $filename r]
		set content {}
		while {![eof $fp]} {
			gets $fp line

			if {[string range $line 0 3] == "    "} then {
				set line "comment {[string range $line 4 end]}"
			}
			append content "$line\n"
		}
		close $fp
		return $content
	}


	#
	#	Do any 'after the fact' parsing
	#
	proc parse_commit {} {
	}


	#
	#	Store a commit
	#
	proc store_commit {} {
		global current_commit commits default_commit


		if {$current_commit != {}} then {
			parse_commit
			lappend commits $current_commit
		}

	}

	proc commit'get {key} {
		global current_commit
		return [dict get $current_commit $key]
	}

	proc commit'set {key val} {
		global current_commit
		dict set current_commit $key $val
	}

	proc commit'lappend {key val} {
		global current_commit

		set current_value [dict get $current_commit $key]
		lappend current_value $val
		dict set current_commit $key $current_value
	}

	proc commit'append {key val} {
		global current_commit

		set current_value [dict get $current_commit $key]
		append current_value "$val\n"
		dict set current_commit $key $current_value
	}

	proc commit'file {type filename} {
		global current_commit

		dict lappend current_commit -files $filename
		dict lappend current_commit $type $filename
	}

}





#
#	Store the commit
#
proc commit {sha} {
	global default_commit current_commit

	util::store_commit
	set current_commit $default_commit

	util::commit'set -sha $sha
}


proc M {file} {
	util::commit'file -modified $file
}

proc A {file} {
	util::commit'file -added $file
}

proc D {file} {
	util::commit'file -deleted $file
}

#
#	Set author
#
proc Author: {author user_id} {
	util::commit'set -author $author
	util::commit'set -userid $user_id
}

#
#	Set date
#
proc Date: {args} {
	util::commit'set -date "$args"
}

proc comment'find-merge {content} {

	set searchFor "Merged from "

	set length [string length $searchFor]
	if {[string first $searchFor $content] == 0} then {
		util::commit'set -merge [string range $content $length end]
	}

}

proc comment'find-ticket {content} {
	set results [regexp -all -inline {[A-Z]+\-\d+} $content]
	foreach result $results {
		if {$result != {}} then {
			util::commit'lappend -tickets $result
		}
	}
}

proc comment'find-revision {content} {
	set searchFor "\[from revision"
	set foundAt [string first $searchFor $content]
	if {$foundAt > 0} then {
		util::commit'lappend -merge-revisions \
				[string range $content \
					[expr {$foundAt +[string length $searchFor] + 1}] \
					end-1\
				]
	}
}

#
#	Line of comments
#
proc comment {content} {

	comment'find-merge $content
	comment'find-revision $content
	comment'find-ticket $content

	if {[string first git-svn-id $content] == 0} then {
		set space_split [split $content " "]
		set at_split [split [lindex $space_split 1] "@"]
		set revision [lindex $at_split end]
		util::commit'set -revision $revision
	} else {
		util::commit'append -comment $content
	}
}


set content [util::read_file [lindex $argv 0]]
eval $content
util::store_commit

puts "set log {"
puts $commits
puts "}"