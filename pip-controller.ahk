; Chrome Picture-in-Picture Controller - Working Version
; Professional version with system tray and essential features

#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1
SetWinDelay, -1
CoordMode, Mouse, Screen

; Application info
AppName := "PiP Controller Pro"
AppVersion := "2.0.0"

; Default settings
transparency := 80
checkInterval := 50
isEnabled := true

; Variables
pipWindow := ""
isHovering := false

; Initialize system tray
InitializeTray()

; Start main loop if enabled
if (isEnabled)
    SetTimer, CheckMouseOverPiP, %checkInterval%

; Show startup notification
TrayTip, %AppName%, %AppName% v%AppVersion% started successfully!, 3, 1

return

CheckMouseOverPiP:
    ; Get the mouse position
    MouseGetPos, mouseX, mouseY, windowUnderMouse, controlUnderMouse
    
    ; Find Picture-in-Picture window
    pipWindow := FindPiPWindow()
    
    if (pipWindow != "") {
        WinGetPos, pipX, pipY, pipWidth, pipHeight, ahk_id %pipWindow%
        
        ; Check if mouse is over the PiP window
        isMouseOverPiP := (mouseX >= pipX && mouseX <= pipX + pipWidth && mouseY >= pipY && mouseY <= pipY + pipHeight)
        
        if (isMouseOverPiP) {
            ; Check if Shift is pressed
            if (GetKeyState("Shift", "P")) {
                ; Make window fully opaque and clickable
                WinSet, Transparent, 255, ahk_id %pipWindow%
                WinSet, ExStyle, -0x20, ahk_id %pipWindow%   ; Remove click-through
            } else {
                ; Make window semi-transparent and click-through
                WinSet, Transparent, %transparency%, ahk_id %pipWindow%
                WinSet, ExStyle, +0x20, ahk_id %pipWindow%   ; Enable click-through
            }
            
            if (!isHovering) {
                isHovering := true
            }
        } else if (isHovering) {
            ; Reset to fully opaque when not hovering
            WinSet, Transparent, 255, ahk_id %pipWindow%
            WinSet, ExStyle, -0x20, ahk_id %pipWindow%   ; Remove click-through
            isHovering := false
        }
    }
return

FindPiPWindow() {
    ; Try to find Chrome's Picture-in-Picture window
    WinGet, id, ID, Picture-in-picture ahk_exe chrome.exe
    if (id)
        return id
    
    ; Try alternative names/patterns for Chrome
    WinGet, id, ID, Picture in picture ahk_exe chrome.exe
    if (id)
        return id
        
    ; Check for Edge browser PiP - multiple variations
    WinGet, id, ID, Picture-in-picture ahk_exe msedge.exe
    if (id)
        return id
        
    ; Try alternative Edge patterns
    WinGet, id, ID, Picture in picture ahk_exe msedge.exe
    if (id)
        return id
        
    ; Try with different case variations for Edge
    WinGet, id, ID, picture-in-picture ahk_exe msedge.exe
    if (id)
        return id
        
    ; Try finding any small Edge window (PiP windows are typically small)
    WinGet, windows, List, ahk_exe msedge.exe
    if (windows > 0) {
        Loop, %windows% {
            windowId := windows%A_Index%
            if (windowId) {
                WinGetPos, x, y, w, h, ahk_id %windowId%
                WinGetTitle, title, ahk_id %windowId%
                ; Check if it's a small window (likely PiP) and has video-related title
                if (w > 0 && h > 0 && w < 800 && h < 600) {
                    if (InStr(title, "YouTube") || InStr(title, "Netflix") || InStr(title, "Video") || InStr(title, "Player") || title == "") {
                        return windowId
                    }
                }
            }
        }
    }
        
    return ""
}

; Initialize system tray
InitializeTray() {
    global
    
    ; Remove default tray menu
    Menu, Tray, NoStandard
    
    ; Create transparency submenu
    Menu, TransparencyMenu, Add, Almost Invisible (25), SetTransparency25
    Menu, TransparencyMenu, Add, Very Light (64), SetTransparency64
    Menu, TransparencyMenu, Add, Medium (128), SetTransparency128
    Menu, TransparencyMenu, Add, Default (179), SetTransparency179
    Menu, TransparencyMenu, Add, Slight (230), SetTransparency230
    Menu, TransparencyMenu, Add, Opaque (255), SetTransparency255
    
    ; Create speed submenu
    Menu, SpeedMenu, Add, Ultra Fast (10ms), SetSpeed10
    Menu, SpeedMenu, Add, Very Fast (25ms), SetSpeed25
    Menu, SpeedMenu, Add, Fast (50ms), SetSpeed50
    Menu, SpeedMenu, Add, Normal (100ms), SetSpeed100
    Menu, SpeedMenu, Add, Slow (200ms), SetSpeed200
    
    ; Create browser tools submenu
    Menu, BrowserMenu, Add, Test Chrome PiP, TestChrome
    Menu, BrowserMenu, Add, Test Edge PiP, TestEdge
    Menu, BrowserMenu, Add, Reset All PiP, ForceResetPiP
    
    ; Main tray menu
    Menu, Tray, Add, About, ShowAbout
    Menu, Tray, Add
    Menu, Tray, Add, Quick Transparency, :TransparencyMenu
    Menu, Tray, Add, Response Speed, :SpeedMenu
    Menu, Tray, Add, Browser Tools, :BrowserMenu
    Menu, Tray, Add
    Menu, Tray, Add, Enable/Disable, ToggleEnabled
    Menu, Tray, Add, Show Status, ShowStatus
    Menu, Tray, Add
    Menu, Tray, Add, Exit, ExitApp
    
    ; Set default action (double-click)
    Menu, Tray, Default, About
    
    ; Set tray tip
    Menu, Tray, Tip, %AppName% v%AppVersion%
}

; Show about dialog
ShowAbout:
    aboutText := AppName . " v" . AppVersion . "`n`n"
    aboutText .= "Professional PiP Controller with enhanced features.`n`n"
    aboutText .= "Features:`n"
    aboutText .= "• Automatic transparency control`n"
    aboutText .= "• Click-through functionality`n"
    aboutText .= "• Shift key override`n"
    aboutText .= "• System tray integration`n`n"
    aboutText .= "Hotkeys:`n"
    aboutText .= "• Ctrl+Alt+P: Pause/Resume`n"
    aboutText .= "• Ctrl+Alt+X: Exit"
    
    MsgBox, 64, About %AppName%, %aboutText%
return

; Show Status
ShowStatus:
    currentPiP := FindPiPWindow()
    pipInfo := currentPiP != "" ? "PiP Window Found" : "No PiP Window Detected"
    
    statusText := AppName . " v" . AppVersion . "`n"
    statusText .= "========================`n`n"
    statusText .= "Status: " . (isEnabled ? "Enabled" : "Disabled") . "`n"
    statusText .= "Transparency: " . transparency . "/255`n"
    statusText .= "Check Interval: " . checkInterval . "ms`n"
    statusText .= "PiP Window: " . pipInfo . "`n"
    statusText .= "Mouse Hovering: " . (isHovering ? "Yes" : "No")
    
    MsgBox, 64, %AppName% Status, %statusText%
return

; Toggle enabled/disabled state
ToggleEnabled:
    if (isEnabled) {
        isEnabled := false
        SetTimer, CheckMouseOverPiP, Off
        TrayTip, %AppName%, Application disabled, 2, 2
        Menu, Tray, Rename, Enable/Disable, Enable
    } else {
        isEnabled := true
        SetTimer, CheckMouseOverPiP, %checkInterval%
        TrayTip, %AppName%, Application enabled, 2, 1
        Menu, Tray, Rename, Enable/Disable, Disable
    }
return

; Transparency settings
SetTransparency25:
    transparency := 25
    TrayTip, %AppName%, Transparency: Almost Invisible, 2, 1
return

SetTransparency64:
    transparency := 64
    TrayTip, %AppName%, Transparency: Very Light, 2, 1
return

SetTransparency128:
    transparency := 128
    TrayTip, %AppName%, Transparency: Medium, 2, 1
return

SetTransparency179:
    transparency := 179
    TrayTip, %AppName%, Transparency: Default, 2, 1
return

SetTransparency230:
    transparency := 230
    TrayTip, %AppName%, Transparency: Slight, 2, 1
return

SetTransparency255:
    transparency := 255
    TrayTip, %AppName%, Transparency: Opaque, 2, 1
return

; Speed settings
SetSpeed10:
    checkInterval := 10
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Ultra Fast, 2, 1
return

SetSpeed25:
    checkInterval := 25
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Very Fast, 2, 1
return

SetSpeed50:
    checkInterval := 50
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Fast, 2, 1
return

SetSpeed100:
    checkInterval := 100
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Normal, 2, 1
return

SetSpeed200:
    checkInterval := 200
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Slow, 2, 1
return

; Browser tools
TestChrome:
    WinGet, id, ID, Picture-in-picture ahk_exe chrome.exe
    if (id) {
        WinGetTitle, title, ahk_id %id%
        MsgBox, 64, Chrome PiP Found, Chrome PiP Window Found!`n`nTitle: %title%`nWindow ID: %id%
    } else {
        MsgBox, 48, Chrome PiP Not Found, No Chrome Picture-in-Picture window found.
    }
return

TestEdge:
    ; Use the improved detection logic
    foundWindow := ""
    
    ; Try exact title matches first
    WinGet, id, ID, Picture-in-picture ahk_exe msedge.exe
    if (id)
        foundWindow := id
    
    if (!foundWindow) {
        WinGet, id, ID, Picture in picture ahk_exe msedge.exe
        if (id)
            foundWindow := id
    }
    
    if (!foundWindow) {
        WinGet, id, ID, picture-in-picture ahk_exe msedge.exe
        if (id)
            foundWindow := id
    }
    
    ; Try finding small windows if exact match fails
    if (!foundWindow) {
        WinGet, windows, List, ahk_exe msedge.exe
        Loop, %windows% {
            windowId := windows%A_Index%
            WinGetPos, x, y, w, h, ahk_id %windowId%
            WinGetTitle, title, ahk_id %windowId%
            if (w > 0 && h > 0 && w < 800 && h < 600) {
                if (InStr(title, "YouTube") || InStr(title, "Netflix") || InStr(title, "Video") || InStr(title, "Player") || title == "") {
                    foundWindow := windowId
                    break
                }
            }
        }
    }
    
    if (foundWindow) {
        WinGetTitle, title, ahk_id %foundWindow%
        WinGetPos, x, y, w, h, ahk_id %foundWindow%
        MsgBox, 64, Edge PiP Found, Edge PiP Window Found!`n`nTitle: %title%`nWindow ID: %foundWindow%`nSize: %w%x%h%`nPosition: %x%,%y%
    } else {
        ; Show all Edge windows for debugging
        debugInfo := "No Edge PiP found. All Edge windows:`n`n"
        WinGet, windows, List, ahk_exe msedge.exe
        Loop, %windows% {
            windowId := windows%A_Index%
            WinGetTitle, title, ahk_id %windowId%
            WinGetPos, x, y, w, h, ahk_id %windowId%
            if (title != "")
                debugInfo .= "Title: " . title . "`nSize: " . w . "x" . h . "`n`n"
        }
        MsgBox, 48, Edge PiP Not Found, %debugInfo%
    }
return

ForceResetPiP:
    resetCount := 0
    
    ; Reset Chrome PiP windows
    WinGet, windows, List, Picture-in-picture ahk_exe chrome.exe
    Loop, %windows% {
        WinSet, Transparent, 255, % "ahk_id " . windows%A_Index%
        WinSet, ExStyle, -0x20, % "ahk_id " . windows%A_Index%
        resetCount++
    }
    
    ; Reset Edge PiP windows
    WinGet, windows, List, Picture-in-picture ahk_exe msedge.exe
    Loop, %windows% {
        WinSet, Transparent, 255, % "ahk_id " . windows%A_Index%
        WinSet, ExStyle, -0x20, % "ahk_id " . windows%A_Index%
        resetCount++
    }
    
    MsgBox, 64, PiP Reset Complete, Reset %resetCount% Picture-in-Picture windows.
return

; Hotkeys
^!p::
    Suspend
    if (A_IsSuspended)
        TrayTip, PiP Controller, Script paused, 2
    else
        TrayTip, PiP Controller, Script resumed, 2
return

^!x::
ExitApp

ExitApp:
