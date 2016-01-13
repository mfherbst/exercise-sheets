#!/bin/bash
#
# Set some defaults to be overwritten in the file common.sh.
#
# Prefix to use for the local uebung directories 
# and resulting pdf files
SHEETPREFIX="exercise"
#
# Prefix to use for the exam directories and pdf
# files
EXAMPREFIX="exam"
#
# When the sheet is ususally given out:
# Could be anything "date" understands. The author
# usually uses something like "next Thursday"
SHEETOUT="today"
#
# When the sheet is to be returned:
# Same format as SHEETOUT. 
SHEETIN="today + 1 week 12am"
#
# Place to put the uebung pdfs on the net:
# Could be something like www.example.com:/path/to/actual/folder
# The machine will ssh there and push the student pdf there
REMOTE="/tmp/"
#
# Default length of an exam
EXAMLENGHT="2 hours"
#
# 
# Overwrite in common.sh:
if [ -f common.sh ]; then
	if  ! . common.sh; then
		echo "Error: Could not load common.sh" >&2
		exit 1
	fi
fi

####################################################

current_number() {
	local NUM=$(echo "$FILEPREFIX"[0-9]* | tr ' ' '\n' | sort -V -r | head -n1)
	NUM=${NUM##${FILEPREFIX}}
	# Remove leading zero (confuses arithmetic expansion: It thinks that the number is an octal value)
	NUM=${NUM##0}  
	if [[ -z "$NUM" || "$NUM" == "[0-9]*" ]]; then
		echo 0
		return
	fi
	echo "${NUM}"
}

next_number_guess() {
	local NUM=$(current_number)
	echo $((NUM+1))	
}

sheet_name() {
	# $1: input number possibly ill-formatted
	printf "$FILEPREFIX%02i" $1
}

sheet_exists() {
	# $1: sheet number or sheet name
	[ -d "$1" ] && return 0
	[ -d "$(sheet_name "$1")" ] && return 0
	return 1
}

####################################################

print_makefile() {
	# $1: Sheet number:
	# $2: Extra options for zettel.cls
	local NUM="$1"
	local NAME=$(sheet_name "$NUM")
	local EXTRAOPTS="$2"

	cat << EOF
#File name of the main file without .tex ending
FILE=$NAME

#Host to publish 
HOST=$REMOTE

#default mode to build
DEFAULTMODE="showsolutions"

# all tex files giving the pdf
PDFSOURCE=\$(FILE).tex header.tex

#---------------------------------------------------------

.PHONY : clean pdf default_points switch_default switch_solutions switch_students pdf_solutions pdf_students cleanall upload_pdf help

all: pdf

#---------------------------------------------------------
# switch between teacher and student version

switch_default:
	{ [ ! -f header.tex ] && echo "\\\\documentclass[\$(DEFAULTMODE),$EXTRAOPTS]{zettel}" > header.tex; } | true

switch_solutions:
	echo "\\\\documentclass[showsolutions,$EXTRAOPTS]{zettel}" > header.tex

switch_students:
	echo "\\\\documentclass[$EXTRAOPTS]{zettel}" > header.tex

#----------------------------------------------------------
# create exercises.points file if not present:
default_points:
	{ [ ! -f exercises.points ] && echo "1\n1" > exercises.points; } | true

#---------------------------------------------------------
# make the pdf
\$(FILE).pdf: \$(PDFSOURCE)
	pdflatex \$(FILE) && pdflatex \$(FILE) && touch \$(FILE).pdf

# target \\ll from vim needs
pdf: default_points switch_default \$(FILE).pdf

clean:
	rm -f \$(FILE).pdf \$(FILE).log \$(FILE).idx \$(FILE).aux solution??.tex solution?.tex

cleanall: clean
	rm -f \$(FILE)_students.pdf \$(FILE)_solutions.pdf header.tex

#---------------------------------------------------------
# switch and make pdf

pdf_students: switch_students pdf
	cp \$(FILE).pdf \$(FILE)_students.pdf

pdf_solutions: switch_solutions pdf
	cp \$(FILE).pdf \$(FILE)_solutions.pdf

#---------------------------------------------------------
# upload

upload_pdf: pdf_students
	scp \$(FILE)_students.pdf \$(HOST)/\$(FILE).pdf

#---------------------------------------------------------
# help

help:
	@echo "The following makefile targets are available: \n\\
	   upload_pdf     run pdf_students and upload student pdf to \$(HOST)\n\\
	   pdf_students   make student version \$(FILE)_students.pdf \n\\
	   pdf_solutions  make teacher version with solutions (\$(FILE)_solutions.pdf) \n\\
	   all            Remake the version of the two above which has most recently been made\n\\
	                  and save it in \$(FILE).pdf"
EOF
}

print_datevars() {
	# $1: Sheet number
	local NUM="$1"
	cat << EOF
\\renewcommand{\\dateout}{$(date --date="$FILEOUT" +"$DATEOUTFORMAT")}
\\renewcommand{\\dateback}{$(date --date="$FILEIN" +"$DATEINFORMAT")}
\\renewcommand{\\sheetno}{$NUM}
EOF
}

print_tex() {
	# $1: Datevars filename
	local DATEVARS="$1"

	if [ ! -f "common.tex" ]; then
		{
			cat <<- EOF
			\\renewcommand{\\course}{Name of the course taught}
			\\renewcommand{\\semester}{Semester of the course}
			\\renewcommand{\\lecturer}{People giving the course}
			EOF
		} > common.tex

		echo "WARNING: You should probably edit the \"common.tex\" file  that defines the following latex commands" >&2
		< common.tex sed "s/^/         /" >&2
	fi

	cat <<EOF
\\input{header}

\\input{../common.tex}
\\input{$DATEVARS}

\\begin{document}
\\begin{zettel}
	\\begin{ex}[\\pntadd{2}]
		Example question where the points are added to the total
	\\begin{sol}
		Example solution this question
	\\end{sol}
	\\end{ex}

	\\begin{ex}[\\pnt{2}]
		Example question where the points are not added to the total (Bonus question)
	\\begin{sol}
		Example solution this question
	\\end{sol}
	\\end{ex}
\\end{zettel}
\\end{document}
EOF
}


####################################################

ask_for_number() {
	local NUM="$(next_number_guess)"
	read -e -p "Enter sheet / exam number to generate:   " -i "$NUM" NUM
	echo "$NUM"
}

ask_for_extra() {
	local EXTRA=
	read -e -p "Enter extra options for zettel.cls (e.g. \"nopoints\")    " EXTRA
	echo "$EXTRA"
}

ask_for_exam_start() {
	local START="$(date +"%Y-%m-%d %H:%M")"
	read -i "$START" -e -p "Enter start date and time of the exam in the format yyyy-mm-dd hh:mm   " START
	date --date="$START" +"%Y-%m-%d +%H hours +%M minutes"
}

dir_of_myself() {
	# echo the directory in which this script is contained
	# try to do it in two ways
	#   a) using a realative location
	#   b) using an absolute location
	# return 1 if it fails (will echo some message to stderr)

	# Path to myself:
	local ME="$0"

	# If this is not the real path try the absolute one from the bash
	if [ -f "$ME" ]; then
		ME=${BASH_SOURCE[0]}
	fi

	# If we are a link: Undo that
	if [ -h "$ME" ]; then
		if ! ME=$(readlink "$ME"); then
			echo "Could not read the link \"$ME\"." >&2
			return 1
		fi
	fi

	# get the dir I am located in
	local MYDIR=$(dirname "$ME")

	# checking: My basename:
	local BN=$(basename "$0")

	if ! [ -f "$MYDIR/$BN" ]; then
		echo "Tryed to guess the location of the $BN script at \"$MYDIR/$BN\", but this turned out to be wrong." >&2
		return 1
	fi
	echo "$MYDIR"
	return 0	
}

generate_sheet() {
	# $1: sheet number
	# $2: Extra options for zettel.cls
	# $3: is this sheet an exam?
	local NUM="$1"
	local NAME=$(sheet_name "$NUM")
	local ISEXAM="$3"

	# filename of the file containing the zettel latex class
	ZETTELFILE="zettel.cls"

	# find the actual location of this very script
	local MYDIR
	if ! MYDIR=$(dir_of_myself); then
		echo "Something went wrong when determining the location of zettel.cls." >&2
		exit 1
	fi

	# an extra check
	if [ ! -f "${MYDIR}/${ZETTELFILE}" ]; then
		echo "Could not determine location of ${ZETTELFILE}." >&2
		echo "We guessed \"${MYDIR}/${ZETTELFILE}\", but it did not work." >&2
		exit 1
	fi

	if [ "${MYDIR:0:1}" != "/" ]; then
		# We are relative:
		MYDIR="../$MYDIR"
	fi

	mkdir "$NAME"
	print_makefile "$NUM" "$2" > "$NAME/Makefile"
	DATEVARS="date_vars.tex"
	print_datevars "$NUM" > "$NAME/$DATEVARS"
	print_tex "$DATEVARS" > "$NAME/$NAME.tex"
	ln -t "$NAME" -s "${MYDIR}/${ZETTELFILE}"

	[ "$ISEXAM" == "1" ] && ln -t "$NAME" -s "$MYDIR/extra_exam_sheets.tex" || true
}

usage() {
	cat <<- EOF
		Generate a new exercise sheet or a new exam.
		If --exam is present we create an exam, else an exercise sheet is
		generated.
	EOF
}

####################################################

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
	usage
	exit 0
fi

ISEXAM=0
if [ "$1" == "--exam" ]; then
	ISEXAM=1
elif [ "$1" ]; then
	echo "Unrecognised option: $1" >&2
	exit 1
fi

if [ "$ISEXAM" == "1" ]; then
	FILEPREFIX="$EXAMPREFIX"

	if ! FILEOUT=$(ask_for_exam_start); then
		echo "Invalid exam start date" >&2
		exit 1
	fi
	FILEIN="$FILEOUT + $EXAMLENGHT"

	# 
	# Change date to display date and time
	# 
	# Format for the out date output:
	DATEOUTFORMAT="%a %d.%m.%Y  %H:%M"
	# Format for the in date output:
	DATEINFORMAT="%a %d.%m.%Y  %H:%M"

	ISEXAM=1
else
	FILEPREFIX="$SHEETPREFIX"
	FILEOUT="$SHEETOUT"
	FILEIN="$SHEETIN"

	# 
	# Change date to display time only for
	# the time the sheet is in for
	# 
	# Format for the out date output:
	DATEOUTFORMAT="%a %d.%m.%Y"
	# Format for the in date output:
	DATEINFORMAT="%a %d.%m.%Y %H:%M"
fi

# Ask for number and extra
NUM=$(ask_for_number)
EXTRAOPTS=$(ask_for_extra)
[ -z "$NUM" ] && exit 1 

if [ "$ISEXAM" == "1" ]; then
	# make sure we build an exam sheet.
	EXTRAOPTS="$EXTRAOPTS,exam"
fi

if sheet_exists "$NUM"; then 
	echo "This sheet already exists" >&2
	exit 1
fi

generate_sheet "$NUM" "$EXTRAOPTS" "$ISEXAM"
exit $?
