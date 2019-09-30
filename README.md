# macOS AppleScripts

A collection of AppleScripts to automate tasks in different macOS applications.

## Finder.app

### Change files dates

If you've been managing photos for a lot of years, you've likely suffered from incorrectly parsed dates on different photos. Maybe the origin could be an _rsync_ without the right flags or a backup restored where some metadata was missing.

Media, in general, offers pretty robust content information be it at the EXIF, Spotlight indexing or file metadata (ctime, mtime, atime) level.

Because date management is so important for photo libraries, this script will ensure that all of the selected files dates are synchronized when it comes to their different metadata source. Usually, that means reading the content creation date as provided by EXIF tags and applying the same date to file creation and modification times. This way, even if a library uses these less reliable date sources, it will still offer a consistent view. Spotlight, for instance, stores the metadata field `kMDItemContentCreationDate` based on EXIF's `Create Date` or `Date/Time Original` fields.

Date management on macOS is particularly tricky. So tricky that there are dedicated [utilities](http://www.hamsoftengineering.com/codeSharing/ChangeFileDates/ChangeFileDates.html) (32-bit only) to workaround minor quirks. Since `touch` isn't good enough for this purpose too, Apple offers an additional `SetFile` binary on their bundle of developer tools from Xcode. While this particular utility has been deprecated (but not replaced?), it still allows us to get the job done — and perfectly.

Provided you have Xcode installed, simply run the script and select all of the files you'd like to fix. Then, the content creation date will be read from Spotlight's indexes and re-written on the file as creation and modified dates. The end result is a consistent file date across all sources.

If, for some reason, even the EXIF metadata is unavailable, a manual date can be set on the file with `exiftool '-AllDates=2019:01:01 17:00:00' -m -overwrite_original [file]` (you may need to `brew install exiftool` first) before running the date script.

Under some circumstances, `exiftool` will be unable to update the file due to invalid tags. In that case, you can rewrite them with `exiftool -all= -tagsfromfile @ -all:all -unsafe -icc_profile -overwrite_original -F [file]` first.

## Photos.app

### Export albums as folders

Photos is a simple library manager which works great for Apple devices as it fully supports Portrait, Bursts and Live photos in JPEG or HEIC. This will let you have a consolidated view of a photo constituted by several distinct files. A Live photo, for example, is usually composed by a .HEIC and a .MOV file stitched together by a library manager.

As it turns out, Photo offers a very simple workflow to organize initial imports:

1. Import all photos from all of your different sources (e.g. iPhone and DSLR).
2. Group photos by selecting them and then assign them an album using ⌘N. Name the album.
3. While the photos are still selected, hide them from the main library using ⌘L.
4. When you're done, click the special "Hidden" photos menu, selected all and un-hide all using ⌘L to toggle their visibility.
5. Run this script to move all original files into seemingly named folders at the file system level.

## Safari.app

### Export open tabs to file

This script will iterate over all open Safari tabs and export the collected URLs and titles as a markdown-formatted file.
