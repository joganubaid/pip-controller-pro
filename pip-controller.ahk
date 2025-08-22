; PiP Controller Pro v2.1.0
; Professional Picture-in-Picture Window Controller with Enhanced Features

#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1
SetWinDelay, -1
CoordMode, Mouse, Screen

; Application info
AppName := "PiP Controller Pro"
AppVersion := "2.1.0"

; Default settings
transparency := 179
checkInterval := 50
isEnabled := true
autoStart := false

; Variables
pipWindow := ""
isHovering := false
lastPiPWindow := ""
settingsFile := A_AppData . "\PiPController\settings.ini"

; Create settings directory
FileCreateDir, % A_AppData . "\PiPController"

; Load settings
LoadSettings()

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
    
    if (pipWindow != "" && pipWindow) {
        ; Check if window still exists before proceeding
        WinGetPos, pipX, pipY, pipWidth, pipHeight, ahk_id %pipWindow%
        
        ; Only proceed if WinGetPos succeeded (ErrorLevel = 0)
        if (ErrorLevel = 0 && pipWidth > 0 && pipHeight > 0) {
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
                    lastPiPWindow := pipWindow
                }
            } else if (isHovering) {
                ; Reset to fully opaque when not hovering
                WinSet, Transparent, 255, ahk_id %pipWindow%
                WinSet, ExStyle, -0x20, ahk_id %pipWindow%   ; Remove click-through
                isHovering := false
            }
        } else {
            ; Window no longer exists, reset hovering state
            if (isHovering) {
                isHovering := false
            }
        }
    } else if (isHovering) {
        ; No PiP window found, reset hovering state
        isHovering := false
    }
return

FindPiPWindow() {
    ; Try to find Chrome's Picture-in-Picture window
    WinGet, id, ID, Picture-in-picture ahk_exe chrome.exe
    if (id && id != "")
        return id
    
    ; Try alternative names/patterns for Chrome
    WinGet, id, ID, Picture in picture ahk_exe chrome.exe
    if (id && id != "")
        return id
        
    ; Check for Edge browser PiP - multiple variations
    WinGet, id, ID, Picture-in-picture ahk_exe msedge.exe
    if (id && id != "")
        return id
        
    ; Try alternative Edge patterns
    WinGet, id, ID, Picture in picture ahk_exe msedge.exe
    if (id && id != "")
        return id
        
    ; Try with different case variations for Edge
    WinGet, id, ID, picture-in-picture ahk_exe msedge.exe
    if (id && id != "")
        return id
        
    ; Try finding any small Edge window (PiP windows are typically small)
    ; Only do this expensive operation if simple detection failed
    WinGet, windows, List, ahk_exe msedge.exe
    if (windows && windows > 0) {
        Loop, %windows% {
            windowId := windows%A_Index%
            ; Add null check for windowId
            if (windowId && windowId != "") {
                ; Use ErrorLevel to check if WinGetPos succeeded
                WinGetPos, x, y, w, h, ahk_id %windowId%
                if (ErrorLevel = 0) {
                    WinGetTitle, title, ahk_id %windowId%
                    ; Check if it's a reasonably sized window (likely PiP)
                    if (w > 50 && h > 50 && w < 800 && h < 600) {
                        ; Check for video-related keywords or empty title (common for PiP)
                        if (InStr(title, "YouTube") || InStr(title, "Netflix") || InStr(title, "Video") 
                            || InStr(title, "Player") || InStr(title, "Twitch") 
                            || InStr(title, "Vimeo") || title == "" || InStr(title, "Picture") || InStr(title, "picture")) {
                            return windowId
                        }
                    }
                }
            }
        }
    }
        
    return ""
}

; Load settings from file
LoadSettings() {
    global transparency, checkInterval, isEnabled, autoStart
    
    if (FileExist(settingsFile)) {
        IniRead, transparency, %settingsFile%, Settings, Transparency, 179
        IniRead, checkInterval, %settingsFile%, Settings, CheckInterval, 50
        IniRead, isEnabled, %settingsFile%, Settings, Enabled, 1
        IniRead, autoStart, %settingsFile%, Settings, AutoStart, 0
    }
}

; Save settings to file
SaveSettings() {
    global transparency, checkInterval, isEnabled, autoStart, settingsFile
    
    IniWrite, %transparency%, %settingsFile%, Settings, Transparency
    IniWrite, %checkInterval%, %settingsFile%, Settings, CheckInterval
    IniWrite, %isEnabled%, %settingsFile%, Settings, Enabled
    IniWrite, %autoStart%, %settingsFile%, Settings, AutoStart
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
    Menu, BrowserMenu, Add, Show All Windows, ShowAllWindows
    
    ; Create reset submenu
    Menu, ResetMenu, Add, Reset Current PiP, ResetCurrentPiP
    Menu, ResetMenu, Add, Reset All PiP Windows, ForceResetPiP
    Menu, ResetMenu, Add, Reset All Settings, ResetAllSettings
    
    ; Main tray menu
    Menu, Tray, Add, About, ShowAbout
    Menu, Tray, Add
    Menu, Tray, Add, Status Dashboard, ShowStatus
    Menu, Tray, Add
    Menu, Tray, Add, Quick Transparency, :TransparencyMenu
    Menu, Tray, Add, Response Speed, :SpeedMenu
    Menu, Tray, Add, Browser Tools, :BrowserMenu
    Menu, Tray, Add, Reset Options, :ResetMenu
    Menu, Tray, Add
    Menu, Tray, Add, Enable/Disable, ToggleEnabled
    Menu, Tray, Add, Auto-Start with Windows, ToggleAutoStart
    Menu, Tray, Add
    Menu, Tray, Add, Exit, ExitApp
    
    ; Set default action (double-click)
    Menu, Tray, Default, Status Dashboard
    
    ; Set tray tip
    Menu, Tray, Tip, %AppName% v%AppVersion%
    
    ; Update auto-start menu item
    UpdateAutoStartMenu()
}

; Update auto-start menu item
UpdateAutoStartMenu() {
    global autoStart
    
    if (autoStart) {
        Menu, Tray, Rename, Auto-Start with Windows, Disable Auto-Start
    } else {
        Menu, Tray, Rename, Disable Auto-Start, Auto-Start with Windows
    }
}

; Show about dialog
ShowAbout:
    aboutText := AppName . " v" . AppVersion . "`n`n"
    aboutText .= "Professional PiP Controller with enhanced features.`n`n"
    aboutText .= "Features:`n"
    aboutText .= "• Automatic transparency control`n"
    aboutText .= "• Click-through functionality`n"
    aboutText .= "• Shift key override`n"
    aboutText .= "• Professional system tray integration`n"
    aboutText .= "• Status dashboard and monitoring`n"
    aboutText .= "• Settings persistence`n"
    aboutText .= "• Multi-browser support (Chrome & Edge)`n`n"
    aboutText .= "Hotkeys:`n"
    aboutText .= "• Ctrl+Alt+C: Status Dashboard`n"
    aboutText .= "• Ctrl+Alt+P: Pause/Resume`n"
    aboutText .= "• Ctrl+Alt+X: Exit`n`n"
    aboutText .= "Settings saved to:`n"
    aboutText .= settingsFile
    
    MsgBox, 64, About %AppName%, %aboutText%
return

; Show Status Dashboard
ShowStatus:
    currentPiP := FindPiPWindow()
    pipInfo := currentPiP != "" ? "PiP Window Found" : "No PiP Window Detected"
    
    ; Get current window info if PiP is found
    windowInfo := ""
    if (currentPiP != "") {
        WinGetTitle, title, ahk_id %currentPiP%
        WinGetPos, x, y, w, h, ahk_id %currentPiP%
        windowInfo := "`nTitle: " . title . "`nSize: " . w . "x" . h . "`nPosition: " . x . "," . y
    }
    
    statusText := AppName . " v" . AppVersion . "`n"
    statusText .= "========================`n`n"
    statusText .= "Status: " . (isEnabled ? "✅ Enabled" : "❌ Disabled") . "`n"
    statusText .= "Transparency: " . transparency . "/255`n"
    statusText .= "Check Interval: " . checkInterval . "ms`n"
    statusText .= "Auto-Start: " . (autoStart ? "✅ Enabled" : "❌ Disabled") . "`n"
    statusText .= "PiP Window: " . pipInfo . windowInfo . "`n"
    statusText .= "Mouse Hovering: " . (isHovering ? "✅ Yes" : "❌ No") . "`n"
    statusText .= "Settings File: " . settingsFile
    
    MsgBox, 64, %AppName% Status Dashboard, %statusText%
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
    SaveSettings()
return

; Toggle auto-start
ToggleAutoStart:
    if (autoStart) {
        autoStart := false
        RegDelete, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, PiPControllerPro
        TrayTip, %AppName%, Auto-start disabled, 2, 2
    } else {
        autoStart := true
        RegWrite, REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, PiPControllerPro, %A_ScriptFullPath%
        TrayTip, %AppName%, Auto-start enabled, 2, 1
    }
    UpdateAutoStartMenu()
    SaveSettings()
return

; Transparency settings
SetTransparency25:
    transparency := 25
    TrayTip, %AppName%, Transparency: Almost Invisible, 2, 1
    SaveSettings()
return

SetTransparency64:
    transparency := 64
    TrayTip, %AppName%, Transparency: Very Light, 2, 1
    SaveSettings()
return

SetTransparency128:
    transparency := 128
    TrayTip, %AppName%, Transparency: Medium, 2, 1
    SaveSettings()
return

SetTransparency179:
    transparency := 179
    TrayTip, %AppName%, Transparency: Default, 2, 1
    SaveSettings()
return

SetTransparency230:
    transparency := 230
    TrayTip, %AppName%, Transparency: Slight, 2, 1
    SaveSettings()
return

SetTransparency255:
    transparency := 255
    TrayTip, %AppName%, Transparency: Opaque, 2, 1
    SaveSettings()
return

; Speed settings
SetSpeed10:
    checkInterval := 10
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Ultra Fast, 2, 1
    SaveSettings()
return

SetSpeed25:
    checkInterval := 25
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Very Fast, 2, 1
    SaveSettings()
return

SetSpeed50:
    checkInterval := 50
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Fast, 2, 1
    SaveSettings()
return

SetSpeed100:
    checkInterval := 100
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Normal, 2, 1
    SaveSettings()
return

SetSpeed200:
    checkInterval := 200
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed: Slow, 2, 1
    SaveSettings()
return

; Browser tools
TestChrome:
    WinGet, id, ID, Picture-in-picture ahk_exe chrome.exe
    if (id) {
        WinGetTitle, title, ahk_id %id%
        WinGetPos, x, y, w, h, ahk_id %id%
        MsgBox, 64, Chrome PiP Found, Chrome PiP Window Found!`n`nTitle: %title%`nWindow ID: %id%`nSize: %w%x%h%`nPosition: %x%,%y%
    } else {
        MsgBox, 48, Chrome PiP Not Found, No Chrome Picture-in-Picture window found.`n`nMake sure:`n• Chrome is running`n• A video is playing in Picture-in-Picture mode`n• The PiP window is visible
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
                if (InStr(title, "YouTube") || InStr(title, "Netflix") || InStr(title, "Video") || InStr(title, "Player") || title == "" || InStr(title, "Picture") || InStr(title, "picture")) {
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

ShowAllWindows:
    debugInfo := "All Chrome and Edge windows:`n`n"
    
    ; Chrome windows
    debugInfo .= "=== CHROME WINDOWS ===`n"
    WinGet, windows, List, ahk_exe chrome.exe
    Loop, %windows% {
        windowId := windows%A_Index%
        WinGetTitle, title, ahk_id %windowId%
        WinGetPos, x, y, w, h, ahk_id %windowId%
        if (title != "")
            debugInfo .= "Title: " . title . "`nSize: " . w . "x" . h . "`n`n"
    }
    
    ; Edge windows
    debugInfo .= "=== EDGE WINDOWS ===`n"
    WinGet, windows, List, ahk_exe msedge.exe
    Loop, %windows% {
        windowId := windows%A_Index%
        WinGetTitle, title, ahk_id %windowId%
        WinGetPos, x, y, w, h, ahk_id %windowId%
        if (title != "")
            debugInfo .= "Title: " . title . "`nSize: " . w . "x" . h . "`n`n"
    }
    
    MsgBox, 64, All Windows, %debugInfo%
return

ResetCurrentPiP:
    if (pipWindow != "") {
        WinSet, Transparent, 255, ahk_id %pipWindow%
        WinSet, ExStyle, -0x20, ahk_id %pipWindow%
        TrayTip, %AppName%, Current PiP window reset, 2, 1
    } else {
        TrayTip, %AppName%, No PiP window to reset, 2, 2
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
    
    ; Reset alternative Edge patterns
    WinGet, windows, List, Picture in picture ahk_exe msedge.exe
    Loop, %windows% {
        WinSet, Transparent, 255, % "ahk_id " . windows%A_Index%
        WinSet, ExStyle, -0x20, % "ahk_id " . windows%A_Index%
        resetCount++
    }
    
    MsgBox, 64, PiP Reset Complete, Reset %resetCount% Picture-in-Picture windows.
return

ResetAllSettings:
    MsgBox, 4, Reset Settings, Are you sure you want to reset all settings to default values?`n`nThis will:`n• Reset transparency to 179`n• Reset check interval to 50ms`n• Disable auto-start`n• Delete settings file
    
    IfMsgBox Yes
    {
        transparency := 179
        checkInterval := 50
        autoStart := false
        isEnabled := true
        
        ; Delete settings file
        FileDelete, %settingsFile%
        
        ; Update timer
        if (isEnabled) {
            SetTimer, CheckMouseOverPiP, Off
            SetTimer, CheckMouseOverPiP, %checkInterval%
        }
        
        ; Update menu
        UpdateAutoStartMenu()
        
        TrayTip, %AppName%, All settings reset to default, 2, 1
    }
return

; Hotkeys
^!c::
    Gosub, ShowStatus
return

^!p::
    Suspend
    if (A_IsSuspended)
        TrayTip, %AppName%, Script paused, 2
    else
        TrayTip, %AppName%, Script resumed, 2
return

^!x::
ExitApp

ExitApp:
    ; Save settings before exit
    SaveSettings()
    ExitApp
