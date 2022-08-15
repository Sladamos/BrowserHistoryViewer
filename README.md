# Hist - browser history viewer
A simple shell script with a manual written for my undergraduate course - "Operating Systems". You can use it to browse history in Firefox and Chromium.
## Functionalities
- Display the entire browsing history, each record consists of a date of search and a URL address
- Add additional phrases and view records containing:
	1. all of the phrases
	2. at least one phrase
- Save the displayed history to a file with a given path (both ./ and ~/ work)
<br/>:warning: If the history has too many records, it can be viewed by saving the records to a file.
## Optional arguments
- -f : add Firefox to viewed browsers
- -c : add Chromium to viewed browsers
- -p=PHRASES : add specific phrases separated by **'^'**
## Used programs
`zenity` `sqlite3`
## Your ideas
:envelope_with_arrow: If you have any ideas for new features, feel free to create a pull request or issue.

