; Edge PiP Diagnostic Tool
; This script helps identify Picture-in-Picture windows in Microsoft Edge

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Show diagnostic information
MsgBox, 4, Edge PiP Diagnostic, This tool will help diagnose Edge PiP issues.`n`nPlease:`n1. Open a YouTube video in Microsoft Edge`n2. Right-click the video and select "Picture in picture"`n3. Click YES to continue with the diagnostic
IfMsgBox No
    ExitApp

; Wait a moment for user to set up PiP
Sleep, 2000

; Get all Edge windows
WinGet, windows, List, ahk_exe msedge.exe
if (windows = 0) {
    MsgBox, 48, No Edge Found, No Microsoft Edge processes found. Please make sure Edge is running.
    ExitApp
}

; Analyze each window
diagnosticInfo := "Edge PiP Diagnostic Results`n"
diagnosticInfo .= "==============================`n`n"
diagnosticInfo .= "Found " . windows . " Edge windows:`n`n"

pipCandidates := 0
Loop, %windows% {
    windowId := windows%A_Index%
    WinGetTitle, title, ahk_id %windowId%
    WinGetPos, x, y, w, h, ahk_id %windowId%
    WinGetClass, class, ahk_id %windowId%
    
    windowInfo := "Window " . A_Index . ":"
    windowInfo .= "`n  Title: " . (title ? title : "[No Title]")
    windowInfo .= "`n  Size: " . w . "x" . h
    windowInfo .= "`n  Position: " . x . "," . y
    windowInfo .= "`n  Class: " . class
    windowInfo .= "`n  ID: " . windowId
    
    ; Check if this could be a PiP window
    isPiPCandidate := false
    if (InStr(title, "Picture-in-picture") || InStr(title, "Picture in picture") || InStr(title, "picture-in-picture")) {
        windowInfo .= "`n  ** EXACT PiP MATCH **"
        isPiPCandidate := true
        pipCandidates++
    } else if (w > 0 && h > 0 && w < 800 && h < 600) {
        if (InStr(title, "YouTube") || InStr(title, "Netflix") || InStr(title, "Video") || InStr(title, "Player") || title == "") {
            windowInfo .= "`n  ** POTENTIAL PiP (small video window) **"
            isPiPCandidate := true
            pipCandidates++
        }
    }
    
    windowInfo .= "`n`n"
    diagnosticInfo .= windowInfo
}

diagnosticInfo .= "Summary:`n"
diagnosticInfo .= "- Total Edge windows: " . windows . "`n"
diagnosticInfo .= "- PiP candidates found: " . pipCandidates . "`n`n"

if (pipCandidates > 0) {
    diagnosticInfo .= "✅ Edge PiP windows detected! The controller should work.`n"
} else {
    diagnosticInfo .= "❌ No Edge PiP windows found. Possible issues:`n"
    diagnosticInfo .= "  • PiP mode not enabled in Edge`n"
    diagnosticInfo .= "  • PiP window has unexpected title`n"
    diagnosticInfo .= "  • PiP window is too large`n"
    diagnosticInfo .= "  • Edge version compatibility issue`n"
}

; Save diagnostic to file
FileAppend, %diagnosticInfo%, edge-pip-diagnostic.txt
diagnosticInfo .= "`n`n(Diagnostic saved to: edge-pip-diagnostic.txt)"

; Show results
MsgBox, 0, Edge PiP Diagnostic Results, %diagnosticInfo%
ExitApp
