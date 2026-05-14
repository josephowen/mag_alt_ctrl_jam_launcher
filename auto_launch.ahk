#Requires AutoHotkey 2.0+

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MULTI-CAB LAUNCHER for AutoHotKey 2
; based on original launcher by Andy Wallace
; adapted by josephalopod (josephalopod.itch.io)
; 
; When you run this, it will close EVERYTHING
; so save your work lol
;
; Win-Z will kill this script
;
; LAUNCHER_PATH will need to be updated if
; dream_launcher.exe is not in the same
; directory as this script.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SETUP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Game Variables
LAUNCHER_PATH := "dream_launcher.exe"

LAUNCHER_WINDOW_NAME := "dream_launcher_app"

SHOW_CURSOR_FOR_GAMES := False

cursor_visible := True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INITIALIZATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This is required so that GetWinList only returns visible windows.
DetectHiddenWindows(False)

; Win-C toggles cursor visibility
#c::ToggleCursorVisibility()

; k kills all games and launches the launcher
k::ReturnToLauncher()

; Win-Z to kill this script
#z:: {
	SetCursorVisibility(True)
	ExitApp
	return
}

OnExit OnExitCallback

; kick this thing off
ReturnToLauncher()

; Main loop. Check every 200 ms for open applications. If there is only one, focus it.
loop {
	Sleep 200
	ids := GetAllEligibleWindows()
	if (ids.length == 1) {
		if (!WinActive(ids[1])) {
			WinActivate(ids[1])
		}
		if (!cursor_visible && SHOW_CURSOR_FOR_GAMES && !WinExist(LAUNCHER_WINDOW_NAME)) {
			; If the window that is open isn't the launcher and we want to show the cursor for games, show it.
			SetCursorVisibility(True)
		}
	}
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LAUNCHER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReturnToLauncher() {
	KillAllGames()
	RestartLauncher()
}

RestartLauncher() {
	if (cursor_visible) {
		SetCursorVisibility(False)
	}
	;restart the launcher
	if (!WinExist(LAUNCHER_WINDOW_NAME)) {
		Run(LAUNCHER_PATH)
	}
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Killing Windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KillAllGames() {
	ids := GetAllEligibleWindows()
	for this_id in ids {
		WinActivate(this_id)
		this_class := WinGetClass(this_id)
		this_title := WinGetTitle(this_id)
		if (this_title != "dream_launcher_app") {
			WinClose(this_id)
		}
	}
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Utility
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetAllEligibleWindows() {
	eligble_ids := []
	ids := WinGetList(,, "Program Manager")
	for this_id in ids {
		this_class := WinGetClass(this_id)
		; Only include windows if their class is not Shell_traywnd or Button
		if (this_class != "Shell_traywnd" && this_class != "Button") {
			eligble_ids.push(this_id)
		}
	}
	return eligble_ids
}

ToggleCursorVisibility() {
	global cursor_visible := !cursor_visible
	SetCursorVisibility(cursor_visible)
}

SetCursorVisibility(desired_visibility) {
	if (desired_visibility) {
		ShowCursor()
		global cursor_visible := True
	} else {
		HideCursor()
		global cursor_visible := False
	}
}

OnExitCallback(ExitReason, ExitCode) {
	ShowCursor()
	ExitApp
}

; Based on https://github.com/steveseguin/hide-cursor/
ShowCursor() {
	return DllCall("SystemParametersInfo", "uint", SPI_SETCURSORS := 0x57, "uint", 0, "ptr", 0, "uint", 0)
}

; Based on https://github.com/steveseguin/hide-cursor/
HideCursor() {
	static SystemCursors := Map(
		"APPSTARTING", 32650,
		"ARROW", 32512,
		"CROSS", 32515,
		"HAND", 32649,
		"HELP", 32651,
		"IBEAM", 32513,
		"NO", 32648,
		"SIZEALL", 32646,
		"SIZENESW", 32643,
		"SIZENS", 32645,
		"SIZENWSE", 32642,
		"SIZEWE", 32644,
		"UPARROW", 32516,
		"WAIT", 32514
	)

	AndMask := Buffer(128, 0xFF), XorMask := Buffer(128, 0)

	for CursorName, CursorID in SystemCursors {
		CursorHandle := DllCall("CreateCursor", "ptr", 0, "int", 0, "int", 0, "int", 32, "int", 32, "ptr", AndMask, "ptr", XorMask, "ptr")
		DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
	}
}
