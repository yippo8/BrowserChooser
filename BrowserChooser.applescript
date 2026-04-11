on open location theURL
	set theChoice to button returned of (display dialog "Open with which browser?" & return & return & theURL buttons {"Cancel", "Edge (E)", "Chrome (C)"} default button "Chrome (C)" with title "Browser Chooser" with icon note giving up after 30)

	if theChoice is "Chrome (C)" then
		do shell script "open -a '/Applications/Google Chrome.app' " & quoted form of theURL
	else if theChoice is "Edge (E)" then
		set edgePath to (POSIX path of (path to home folder)) & "Applications (Parallels)/{a4a395d4-559f-468c-bff0-6dac0fb6faba} Applications.localized/Microsoft Edge.app"
		do shell script "open -a " & quoted form of edgePath & " " & quoted form of theURL
	end if
end open location

on run
	display dialog "Browser Chooser is installed!" & return & return & "To use it, set it as your default browser in:" & return & "System Settings > Desktop & Dock > Default web browser" buttons {"OK"} default button "OK" with title "Browser Chooser" with icon note
end run
