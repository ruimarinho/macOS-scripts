property metadate : "kMDItemContentCreationDate"

set sourceFiles to choose file with multiple selections allowed
log (count sourceFiles)
set counter to 0
repeat with sourceFile in sourceFiles
	set tPath to quoted form of (POSIX path of sourceFile) -- this could be done 'inline'
	tell application "System Events" to copy the (name of sourceFile) to tName
	--ChangeFileDates (http://www.hamsoftengineering.com/codeSharing/ChangeFileDates/ChangeFileDates.html) format
	--tell current application to copy (do shell script ("mdls -name " & metadate & " " & tPath & " | awk -F ' ' '{print $3,$4};' | xargs -0 -I indate date -j -f '%Y-%m-%d %H:%M:%S' indate +'%Y-%m-%dT%H:%M:%SZ'")) to dateInfo
	--
	--touch format
	--tell current application to copy (do shell script ("mdls -name " & metadate & " " & tPath & " | awk -F ' ' '{print $3,$4};' | xargs -0 -I indate date -j -f '%Y-%m-%d %H:%M:%S' indate +'%Y%m%d%H%M.%S'")) to dateInfo
	--
	--SetFile format
	tell current application to copy (do shell script ("mdls -name " & metadate & " " & tPath & " | awk -F ' ' '{print $3,$4};' | xargs -0 -I indate date -j -f '%Y-%m-%d %H:%M:%S' indate +'%m/%d/%Y %H:%M:%S'")) to dateInfo
	log sourceFile & dateInfo & counter
	--Uncomment the next line to display dialog with date information
	--display dialog "The Content Creation Date of the file \"" & tName & "\" is as follows:" & return & return & dateInfo with title "Content Creation Date Result"

	--Change date using ChangeFileDates 32-bit binary
	--do shell script quoted form of POSIX path of "/usr/local/bin/ChangeFileDates" & " -cDate " & quoted form of dateInfo & " -mDate " & quoted form of dateInfo & " -file " & quoted form of POSIX path of sourceFile

	--Change date using touch
	--do shell script quoted form of POSIX path of "/usr/bin/touch" & " -t " & quoted form of dateInfo & " " & quoted form of POSIX path of sourceFile

	--Change date using SetFile (from Xcode, deprecated)
	do shell script quoted form of POSIX path of "/usr/bin/SetFile" & " -d " & quoted form of dateInfo & " " & " -m " & quoted form of dateInfo & " " & quoted form of POSIX path of sourceFile

	set counter to counter + 1
end repeat
