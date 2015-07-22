GIT_FOLDER=~/tmp/central/git/uoa-cms
INPUT=all-logs.txt
OUTPUT=graph-out.tcl
DBLOCATION=dbimport.sql
UNMERGED_REPORT=unmerged.tcl
DIFF_FOLDER=diffs/
CWD=$(shell pwd)

%.PHONY: all setup getlog parselog dbimport report getdiffs

all: setup getlog parselog dbimport report getdiffs

getlog:
	cd ${GIT_FOLDER} && git log --name-status > ${CWD}/output/${INPUT}

parselog:
	./parse.tcl ${CWD}/output/${INPUT} > ${CWD}/output/${OUTPUT}

dbimport:
	cp skeleton.sql ${CWD}/output/${DBLOCATION}
	./dbimport.tcl ${CWD}/output/${OUTPUT} ${CWD}/output/${DBLOCATION}

report:
	./report.tcl ${CWD}/output/${DBLOCATION} > ${CWD}/output/${UNMERGED_REPORT}

getdiffs:
	rm -rf ${CWD}/output/${DIFF_FOLDER}
	./getdiffs.tcl ${CWD}/output/${UNMERGED_REPORT} ${CWD}/output/${DIFF_FOLDER} ${GIT_FOLDER}

setup:
	rm -rf output/ && mkdir output/
