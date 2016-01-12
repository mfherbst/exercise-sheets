# Set some defaults to be overwritten in the file common.sh.
#
# Prefix to use for the local uebung directories 
# and resulting pdf files
SHEETPREFIX="sheet"
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
