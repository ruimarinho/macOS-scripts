##
# Inspired by the work of Armin Briegel.
# https://scriptingosx.com/2013/01/copy-link-list-from-frontmost-safari-window/
##

property filename : "Safari URLs.md"

set urlList to {}
set the currentDate to ((the current date) as string)
set title to "### Safari URLs | " & the currentDate

tell application "Safari"
	activate
	set safariWindow to window 1
	repeat with w in safariWindow
		try
			repeat with t in (tabs of w)
				set tabTitle to (name of t)
				set tabUrl to (URL of t)
				set tabInfo to ("- [" & tabTitle & "](" & tabUrl & ")")
				copy tabInfo to the end of urlList
			end repeat
		end try
	end repeat
end tell

set oldDelimiter to AppleScript's text item delimiters
set AppleScript's text item delimiters to linefeed
set urlList to (title & linefeed & linefeed & urlList) as text
set AppleScript's text item delimiters to oldDelimiter

tell application "Finder"
	activate
	set destinationFile to choose file name with prompt "Name this file:" default name filename default location (path to desktop folder)
end tell

tell application "System Events"
	set destinationFile to open for access (destinationFile as string) with write permission
	try
		write urlList to destinationFile
	end try
	close access destinationFile
end tell
