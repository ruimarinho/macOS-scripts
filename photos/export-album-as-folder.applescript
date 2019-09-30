------------------------------------------------
-- Settings Start: Change these as needed
global gDest
set gDest to "/Users/ruimarinho/Pictures/Imports/" as POSIX file as text -- the destination folder (use a valid path)

global gLogFile
set gLogFile to gDest & "ExportAlbumToFolders.log"

global gKeywordOnSuccess
set gKeywordOnSuccess to "exported"

-- Name of our special unsorted/catch-all album. We'll group images within into YYYY-MM folders
-- if needed use 'smart albums' to create an album with this name (tip: try the 'album is not any' rule)
global gUnsortedAlbum
set gUnsortedAlbum to "unsorted"

set allowUserToSelectAlbums to false as boolean
-- Settings End
------------------------------------------------
my makeFolder(gDest)
tell application "Photos"
	set allAlbumNames to name of albums
	if allowUserToSelectAlbums then
		set albumNames to choose from list allAlbumNames with prompt "Select some albums" with multiple selections allowed
		-- DEBUGGING
		--set albumNames to {gUnsortedAlbum}
	else
		set albumNames to allAlbumNames
	end if
	
	-- Sort for some deterministic pattern we as humans can follow
	set albumNames to my sortList(albumNames)
	
	if albumNames is not false then -- not cancelled 
		repeat with albumName in albumNames
			if albumName starts with gUnsortedAlbum then
				-- special case: noalbum needs each image processed with it's own timestamp
				-- because they can span many months/years and not just the first image
				-- in an album
				set allPhotos to (get media items of album albumName)
				repeat with mediaItem in allPhotos
					-- Extract Album date
					set albumFirstMediaDate to date of mediaItem
					
					-- Create list of media items
					set mediaItems to {mediaItem}
					
					-- Export the list of media items 
					my exportThisAlbum(albumName, mediaItems, albumFirstMediaDate)
				end repeat
			else
				-- usual case: all other albums processed as single unit each
				-- Extract Album date
				set albumYear to 1900 as integer
				repeat with mediaItem in (get media items of album albumName)
					set albumFirstMediaDate to date of mediaItem
					exit repeat -- only need first
				end repeat
				
				-- Create list of media items
				set mediaItems to (get media items of album albumName)
				
				-- Export the list of media items
				my exportThisAlbum(albumName, mediaItems, albumFirstMediaDate)
			end if
		end repeat
	end if -- main block
end tell

on exportThisAlbum(albumName, mediaItems, albumFirstMediaDate)
	tell application "Photos"
		with timeout of 1200 seconds -- give 20 mins instead of 2 minutes ...
			-- filter raw list based on "already processed" tag/keyword ...
			set mediaItemsToAttempt to {}
			repeat with mediaItem in mediaItems
				if keywords of mediaItem does not contain gKeywordOnSuccess then
					set end of mediaItemsToAttempt to mediaItem
				end if
			end repeat
			
			-- Any work to do?
			if (count of mediaItemsToAttempt) = 0 then
				set logMsg to "Skipping album name: " & albumName & ". All it's media items already have the " & gKeywordOnSuccess & " keyword."
				my logThis(logMsg)
				return
			end if
			
			
			-- Generate destination folder name
			set albumYear to (text -4 thru -1 of ("0000" & (year of albumFirstMediaDate)))
			-- set leafFolderName to my generateLeafFolderName(albumFirstMediaDate, albumName)
			set destFolder to gDest & albumYear & ":" & albumName -- path separator is : instead of \ ... weird
			
			set logMsg to "Exporting album name: " & albumName & " to " & destFolder
			my logThis(logMsg)
			
			-- Create the destination folder
			my makeFolder(destFolder)
			
			-- export this filtered list
			export mediaItemsToAttempt to (destFolder as alias) with using originals
		end timeout
		
		-- if successful add the gKeywordOnSuccess keyword/tag
		repeat with mediaItem in mediaItemsToAttempt
			set existingKeywords to keywords of mediaItem
			if existingKeywords is missing value then
				set existingKeywords to {}
			end if
			
			if existingKeywords does not contain gKeywordOnSuccess then
				set (keywords of mediaItem) to existingKeywords & gKeywordOnSuccess
			end if
		end repeat
		
	end tell
end exportThisAlbum

on generateLeafFolderName(theDate, albumName)
	set yyyy to text -4 thru -1 of ("0000" & (year of theDate))
	set mm to text -2 thru -1 of ("00" & ((month of theDate) as integer))
	set dd to text -2 thru -1 of ("00" & (day of theDate))
	set hh to text -2 thru -1 of ("00" & (hours of theDate))
	set mins to text -2 thru -1 of ("00" & (minutes of theDate))
	set ss to text -2 thru -1 of ("00" & (seconds of theDate))
	
	set datePrefix to yyyy & "-" & mm & "-" & dd
	
	-- special case: unsorted album which may contain images spanning 
	-- years/months in some random order" 
	if albumName starts with gUnsortedAlbum then
		--drop dd, cluster into months to avoid too many folders with too few files
		return yyyy & "-" & mm
	end if
	
	--special case: legacy iPhoto imported events auto-prefixed by months
	set monthsList to {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
	if my textStartsWith(albumName, monthsList) then
		return datePrefix
	end if
	
	-- special case: album name already has a decent date prefix
	if albumName starts with (yyyy & "-" & mm) then
		return albumName
	else
		return datePrefix & " " & albumName
	end if
end generateLeafFolderName


-- ///////////////////////////////////////////
-- // LOGGING
-- ///////////////////////////////////////////
on getCurrentTimestamp(theDate)
	set yyyy to text -4 thru -1 of ("0000" & (year of theDate))
	set mm to text -2 thru -1 of ("00" & ((month of theDate) as integer))
	set dd to text -2 thru -1 of ("00" & (day of theDate))
	set hh to text -2 thru -1 of ("00" & (hours of theDate))
	set mins to text -2 thru -1 of ("00" & (minutes of theDate))
	set ss to text -2 thru -1 of ("00" & (seconds of theDate))
	
	return yyyy & ":" & mm & ":" & dd & ":" & hh & ":" & mins & ":" & ss
end getCurrentTimestamp

on logThis(theText)
	set theText to (my getCurrentTimestamp((current date))) & ": " & theText
	log theText --to console
	my writeToFile(theText, gLogFile, true) -- and persist to log file
end logThis

on writeToFile(thisData, targetFile, shouldAppend) -- (string, file path as string, boolean)
	try
		set the targetFile to the targetFile as text
		set the openTargetFile to open for access file targetFile with write permission
		if shouldAppend is false then set eof of the openTargetFile to 0
		-- write the line and a \n character .. 
		write thisData & return to the openTargetFile starting at eof
		close access the openTargetFile
		return true
	on error errorMessage number errorNumber
		log "Exception logging. Details: " & errorMessage & " Error number " & errorNumber & ". Data to be written was: " & thisData
		try
			close access file targetFile
		end try
		return false
	end try
end writeToFile

-- ///////////////////////////////////////////
-- // GENERAL UTILITY
-- ///////////////////////////////////////////

on makeFolder2(tPath)
	my logThis("make folder via finder:" & "gDest:" & gDest & " and tPath:" & tPath)
	tell application "Finder"
		make new folder at gDest with properties {name:tPath}
	end tell
end makeFolder2

on makeFolder(tPath)
	do shell script "mkdir -p " & quoted form of POSIX path of tPath
end makeFolder

on textStartsWith(inputText, listOfStrings)
	repeat with listItem in listOfStrings
		if inputText starts with listItem then return true
	end repeat
	false
end textStartsWith

on sortList(theList)
	set theIndexList to {}
	set theSortedList to {}
	repeat (length of theList) times
		set theLowItem to ""
		repeat with a from 1 to (length of theList)
			if a is not in theIndexList then
				set theCurrentItem to item a of theList as text
				if theLowItem is "" then
					set theLowItem to theCurrentItem
					set theLowItemIndex to a
				else if theCurrentItem comes before theLowItem then
					set theLowItem to theCurrentItem
					set theLowItemIndex to a
				end if
			end if
		end repeat
		set end of theSortedList to theLowItem
		set end of theIndexList to theLowItemIndex
	end repeat
	return theSortedList
end sortList