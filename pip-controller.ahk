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
Gosub, LoadSettings

; Initialize system tray
Gosub, InitializeTray

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
    
    if (pipWindow != "")
    {
        ; Check if window still exists before proceeding
        WinGetPos, pipX, pipY, pipWidth, pipHeight, ahk_id %pipWindow%
        
        ; Only proceed if WinGetPos succeeded (ErrorLevel = 0)
        if (ErrorLevel = 0 && pipWidth > 0 && pipHeight > 0)
        {
            ; Check if mouse is over the PiP window
            isMouseOverPiP := (mouseX >= pipX && mouseX <= pipX + pipWidth && mouseY >= pipY && mouseY <= pipY + pipHeight)
            
            if (isMouseOverPiP)
            {
                ; Check if Shift is pressed
                if (GetKeyState("Shift", "P"))
                {
                    ; Make window fully opaque and clickable
                    WinSet, Transparent, 255, ahk_id %pipWindow%
                    WinSet, ExStyle, -0x20, ahk_id %pipWindow%   ; Remove click-through
                }
                else
                {
                    ; Make window semi-transparent and click-through
                    WinSet, Transparent, %transparency%, ahk_id %pipWindow%
                    WinSet, ExStyle, +0x20, ahk_id %pipWindow%   ; Enable click-through
                }
                
                if (!isHovering)
                {
                    isHovering := true
                    lastPiPWindow := pipWindow
                }
            }
            else if (isHovering)
            {
                ; Reset to fully opaque when not hovering
                WinSet, Transparent, 255, ahk_id %pipWindow%
                WinSet, ExStyle, -0x20, ahk_id %pipWindow%   ; Remove click-through
                isHovering := false
            }
        }
        else
        {
            ; Window no longer exists, reset hovering state
            if (isHovering)
            {
                isHovering := false
            }
        }
    }
    else if (isHovering)
    {
        ; No PiP window found, reset hovering state
        isHovering := false
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
        
    ; Check for Edge browser PiP
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
        
    return ""
}

; Load settings from file
LoadSettings:
    if (FileExist(settingsFile))
    {
        IniRead, transparency, %settingsFile%, Settings, Transparency, 179
        IniRead, checkInterval, %settingsFile%, Settings, CheckInterval, 50
        IniRead, isEnabled, %settingsFile%, Settings, Enabled, 1
        IniRead, autoStart, %settingsFile%, Settings, AutoStart, 0
    }
    return

; Save settings to file
SaveSettings:
    IniWrite, %transparency%, %settingsFile%, Settings, Transparency
    IniWrite, %checkInterval%, %settingsFile%, Settings, CheckInterval
    IniWrite, %isEnabled%, %settingsFile%, Settings, Enabled
    IniWrite, %autoStart%, %settingsFile%, Settings, AutoStart
    return

; Initialize system tray
InitializeTray:
    Menu, Tray, NoStandard
    
    ; Transparency Menu
    Menu, TransparencyMenu, Add, Almost Invisible (25), SetTransparency25
    Menu, TransparencyMenu, Add, Very Light (64), SetTransparency64
    Menu, TransparencyMenu, Add, Medium (128), SetTransparency128
    Menu, TransparencyMenu, Add, Default (179), SetTransparency179
    Menu, TransparencyMenu, Add, Slight (230), SetTransparency230
    Menu, TransparencyMenu, Add, Opaque (255), SetTransparency255
    
    ; Speed Menu
    Menu, SpeedMenu, Add, Ultra Fast (10ms), SetSpeed10
    Menu, SpeedMenu, Add, Very Fast (25ms), SetSpeed25
    Menu, SpeedMenu, Add, Fast (50ms), SetSpeed50
    Menu, SpeedMenu, Add, Normal (100ms), SetSpeed100
    Menu, SpeedMenu, Add, Slow (200ms), SetSpeed200
    
    ; Browser Tools Menu
    Menu, BrowserMenu, Add, Test Chrome PiP, TestChrome
    Menu, BrowserMenu, Add, Test Edge PiP, TestEdge
    Menu, BrowserMenu, Add, Reset All PiP, ForceResetPiP
    Menu, BrowserMenu, Add, Show All Windows, ShowAllWindows
    
    ; Reset Menu
    Menu, ResetMenu, Add, Reset Current PiP, ResetCurrentPiP
    Menu, ResetMenu, Add, Reset All PiP Windows, ForceResetPiP
    Menu, ResetMenu, Add, Reset All Settings, ResetAllSettings
    
    ; Main Tray
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
    
    Menu, Tray, Default, Status Dashboard
    Menu, Tray, Tip, %AppName% v%AppVersion%
    Gosub, UpdateAutoStartMenu
    return

UpdateAutoStartMenu:
    Menu, Tray, Rename, Auto-Start with Windows, % (autoStart ? "✓ Auto-Start Enabled" : "Auto-Start with Windows")
    if (autoStart) {
        try {
            Menu, Tray, Rename, ✓ Auto-Start Enabled, Disable Auto-Start
        } catch {
            Menu, Tray, Rename, Auto-Start Enabled, Disable Auto-Start
        }
    } else {
        try {
            Menu, Tray, Rename, Disable Auto-Start, Auto-Start with Windows
        }
    }
    return

ShowAbout:
    aboutText := AppName . " v" . AppVersion . "`n`n"
    aboutText .= "Professional PiP Controller with enhanced features.`n`n"
    aboutText .= "Hotkeys:`n"
    aboutText .= "• Ctrl+Alt+C: Status Dashboard`n"
    aboutText .= "• Ctrl+Alt+P: Pause/Resume`n"
    aboutText .= "• Ctrl+Alt+X: Exit"
    MsgBox, 64, About %AppName%, %aboutText%
return

ShowStatus:
    ; FIXED: Call function directly, do not use Gosub
    currentPiP := FindPiPWindow()
    pipInfo := currentPiP != "" ? "PiP Window Found" : "No PiP Window Detected"
    
    windowInfo := ""
    if (currentPiP != "")
    {
        WinGetTitle, title, ahk_id %currentPiP%
        WinGetPos, x, y, w, h, ahk_id %currentPiP%
        windowInfo := "`nTitle: " . title . "`nSize: " . w . "x" . h . "`nPosition: " . x . "," . y
    }
    
    statusText := AppName . " v" . AppVersion . "`n"
    statusText .= "========================`n"
    statusText .= "Status: " . (isEnabled ? "✅ Enabled" : "❌ Disabled") . "`n"
    statusText .= "Transparency: " . transparency . "/255`n"
    statusText .= "Check Interval: " . checkInterval . "ms`n"
    statusText .= "Auto-Start: " . (autoStart ? "✅ Enabled" : "❌ Disabled") . "`n"
    statusText .= "PiP Window: " . pipInfo . windowInfo . "`n"
    statusText .= "Settings: " . settingsFile
    
    MsgBox, 64, %AppName% Status Dashboard, %statusText%
return

ToggleEnabled:
    if (isEnabled)
    {
        isEnabled := false
        SetTimer, CheckMouseOverPiP, Off
        TrayTip, %AppName%, Application disabled, 2, 2
        Menu, Tray, Rename, Enable/Disable, Enable
    }
    else
    {
        isEnabled := true
        SetTimer, CheckMouseOverPiP, %checkInterval%
        TrayTip, %AppName%, Application enabled, 2, 1
        Menu, Tray, Rename, Enable/Disable, Disable
    }
    Gosub, SaveSettings
return

ToggleAutoStart:
    if (autoStart)
    {
        autoStart := false
        try {
            RegDelete, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, PiPControllerPro
        } catch {
             ; Ignore error if key doesn't exist
        }
        TrayTip, %AppName%, Auto-start disabled, 2, 2
    }
    else
    {
        autoStart := true
        scriptPath := """" . A_ScriptFullPath . """"
        try {
            RegWrite, REG_SZ, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, PiPControllerPro, %scriptPath%
            TrayTip, %AppName%, Auto-start enabled, 2, 1
        } catch {
            autoStart := false
            TrayTip, %AppName%, Auto-start failed: Registry access denied, 3, 3
        }
    }
    Gosub, UpdateAutoStartMenu
    Gosub, SaveSettings
return

; Transparency Options
SetTransparency25:
    transparency := 25
    TrayTip, %AppName%, Transparency set to 25, 2, 1
    Gosub, SaveSettings
return
SetTransparency64:
    transparency := 64
    TrayTip, %AppName%, Transparency set to 64, 2, 1
    Gosub, SaveSettings
return
SetTransparency128:
    transparency := 128
    TrayTip, %AppName%, Transparency set to 128, 2, 1
    Gosub, SaveSettings
return
SetTransparency179:
    transparency := 179
    TrayTip, %AppName%, Transparency set to 179, 2, 1
    Gosub, SaveSettings
return
SetTransparency230:
    transparency := 230
    TrayTip, %AppName%, Transparency set to 230, 2, 1
    Gosub, SaveSettings
return
SetTransparency255:
    transparency := 255
    TrayTip, %AppName%, Transparency set to 255 (Opaque), 2, 1
    Gosub, SaveSettings
return

; Speed Options
SetSpeed10:
    checkInterval := 10
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed set to 10ms, 2, 1
    Gosub, SaveSettings
return
SetSpeed25:
    checkInterval := 25
     if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed set to 25ms, 2, 1
    Gosub, SaveSettings
return
SetSpeed50:
    checkInterval := 50
     if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed set to 50ms, 2, 1
    Gosub, SaveSettings
return
SetSpeed100:
    checkInterval := 100
     if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed set to 100ms, 2, 1
    Gosub, SaveSettings
return
SetSpeed200:
    checkInterval := 200
     if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    TrayTip, %AppName%, Speed set to 200ms, 2, 1
    Gosub, SaveSettings
return

; Browser Tools
TestChrome:
    ; FIXED: Call function
    id := FindPiPWindow() 
    if (id) {
        WinGetTitle, title, ahk_id %id%
        MsgBox, 64, PiP Found, Chrome PiP found!`nID: %id%`nTitle: %title%
    } else {
        MsgBox, 48, PiP Not Found, No Chrome PiP window found.
    }
return

TestEdge:
    ; FIXED: Call function
    id := FindPiPWindow()
    if (id) {
        WinGetTitle, title, ahk_id %id%
        MsgBox, 64, PiP Found, PiP window found!`nID: %id%`nTitle: %title%
    } else {
         MsgBox, 48, PiP Not Found, No PiP window found.
    }
return

ShowAllWindows:
    MsgBox, 64, Info, Showing debug info for windows is disabled in simple mode.
return

ResetCurrentPiP:
    if (pipWindow != "") {
        WinSet, Transparent, 255, ahk_id %pipWindow%
        WinSet, ExStyle, -0x20, ahk_id %pipWindow%
        TrayTip, %AppName%, Reset current PiP window, 2, 1
    }
return

ForceResetPiP:
    WinGet, windows, List, Picture-in-picture
    Loop, %windows%
    {
        currentId := windows%A_Index%
        WinSet, Transparent, 255, ahk_id %currentId%
        WinSet, ExStyle, -0x20, ahk_id %currentId%
    }
    TrayTip, %AppName%, Reset all PiP windows, 2, 1
return

ResetAllSettings:
    MsgBox, 4, Confirm, Reset all settings?
    IfMsgBox Yes
    {
        transparency := 179
        checkInterval := 50
        autoStart := false
        isEnabled := true
        FileDelete, %settingsFile%
        if (isEnabled) {
             SetTimer, CheckMouseOverPiP, Off
             SetTimer, CheckMouseOverPiP, 50
        }
        Gosub, UpdateAutoStartMenu
        TrayTip, %AppName%, Settings reset, 2, 1
    }
return

; Hotkeys
^!c::Gosub, ShowStatus
^!p::
    Suspend
    TrayTip, %AppName%, % (A_IsSuspended ? "Script Paused" : "Script Resumed"), 2
return
^!x::Gosub, ExitApp

ExitApp:
    Gosub, SaveSettings
    ExitApp