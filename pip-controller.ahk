; PiP Controller Pro
; Professional Picture-in-Picture Window Controller with Enhanced Features
; Version is read from the VERSION file at build time. Dev-run uses the
; hardcoded AppVersion below as a fallback.

#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1
SetWinDelay, -1
CoordMode, Mouse, Screen

; Application info
AppName := "PiP Controller Pro"
AppVersion := "2.2.1"

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

; Last-applied tray menu labels (track so Menu Rename has a known source key).
; These MUST match the initial labels passed to Menu, Tray, Add in InitializeTray.
enableMenuText := "Enable/Disable"
autoStartMenuText := "Auto-Start with Windows"

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

; Defer the update check 10s so it never blocks tray-icon visibility on a
; cold boot. Negative period = one-shot SetTimer.
SetTimer, DoStartupUpdateCheck, -10000

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

; Find a PiP window owned by a specific browser process. Returns the window ID
; or 0/empty if none. Per-browser handler so the "Test <Browser> PiP" menu
; items can each verify only their target browser, not just any PiP.
FindPiPWindowForExe(exe) {
    ; Chromium-family pattern (Chrome, Edge, Brave, Vivaldi, Opera all use this title).
    WinGet, id, ID, Picture-in-picture ahk_exe %exe%
    if (id)
        return id
    WinGet, id, ID, Picture in picture ahk_exe %exe%
    if (id)
        return id
    WinGet, id, ID, picture-in-picture ahk_exe %exe%
    if (id)
        return id

    ; Firefox uses variable titles, so "contains" match scoped to firefox.exe.
    ; Save and restore TitleMatchMode so we don't leak state to other callers.
    if (exe = "firefox.exe") {
        prevMatchMode := A_TitleMatchMode
        SetTitleMatchMode, 2
        WinGet, id, ID, Picture-in-Picture ahk_exe firefox.exe
        if (!id)
            WinGet, id, ID, Picture in Picture ahk_exe firefox.exe
        SetTitleMatchMode, %prevMatchMode%
    }
    return id
}

FindPiPWindow() {
    supportedExes := ["chrome.exe", "msedge.exe", "brave.exe", "vivaldi.exe", "opera.exe", "firefox.exe"]
    For idx, exe in supportedExes {
        id := FindPiPWindowForExe(exe)
        if (id)
            return id
    }
    return ""
}

; Shared body for the per-browser "Test <Browser> PiP" tray items.
TestPiPForBrowser(exe, browserName) {
    id := FindPiPWindowForExe(exe)
    if (id) {
        WinGetTitle, title, ahk_id %id%
        MsgBox, 64, %browserName% PiP Found, %browserName% PiP detected!`n`nWindow ID: %id%`nTitle: %title%`nProcess: %exe%
    } else {
        MsgBox, 48, %browserName% PiP Not Found, No PiP window found for %browserName% (%exe%).`n`nMake sure %browserName% is running and a video is playing in Picture-in-Picture mode.
    }
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
    
    ; Browser Tools Menu — one Test item per supported browser so each test
    ; verifies its specific target instead of "any browser with a PiP open".
    Menu, BrowserMenu, Add, Test Chrome PiP, TestChrome
    Menu, BrowserMenu, Add, Test Edge PiP, TestEdge
    Menu, BrowserMenu, Add, Test Brave PiP, TestBrave
    Menu, BrowserMenu, Add, Test Vivaldi PiP, TestVivaldi
    Menu, BrowserMenu, Add, Test Opera PiP, TestOpera
    Menu, BrowserMenu, Add, Test Firefox PiP, TestFirefox
    Menu, BrowserMenu, Add
    Menu, BrowserMenu, Add, Reset All PiP, ForceResetPiP
    
    ; Reset Menu
    Menu, ResetMenu, Add, Reset Current PiP, ResetCurrentPiP
    Menu, ResetMenu, Add, Reset All PiP Windows, ForceResetPiP
    Menu, ResetMenu, Add, Reset All Settings, ResetAllSettings
    
    ; Main Tray
    Menu, Tray, Add, About, ShowAbout
    Menu, Tray, Add, Check for Updates, CheckForUpdatesMenu
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
    Gosub, UpdateMenuState
    return

; Single source of truth for dynamic tray menu labels.
; Tracks the last-applied text in globals so Menu, Tray, Rename always has the
; correct source key — prevents the rename-drift bug where successive toggles
; would silently fail because the source label no longer matched the menu.
UpdateMenuState:
    newEnableText := isEnabled ? "Disable" : "Enable"
    if (newEnableText != enableMenuText) {
        try {
            Menu, Tray, Rename, %enableMenuText%, %newEnableText%
            enableMenuText := newEnableText
        }
    }

    newAutoStartText := autoStart ? "Disable Auto-Start" : "Auto-Start with Windows"
    if (newAutoStartText != autoStartMenuText) {
        try {
            Menu, Tray, Rename, %autoStartMenuText%, %newAutoStartText%
            autoStartMenuText := newAutoStartText
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
    }
    else
    {
        isEnabled := true
        SetTimer, CheckMouseOverPiP, %checkInterval%
        TrayTip, %AppName%, Application enabled, 2, 1
    }
    Gosub, UpdateMenuState
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
    Gosub, UpdateMenuState
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

; Browser Tools — each test handler scans only its target browser.
TestChrome:
    TestPiPForBrowser("chrome.exe", "Chrome")
return

TestEdge:
    TestPiPForBrowser("msedge.exe", "Edge")
return

TestBrave:
    TestPiPForBrowser("brave.exe", "Brave")
return

TestVivaldi:
    TestPiPForBrowser("vivaldi.exe", "Vivaldi")
return

TestOpera:
    TestPiPForBrowser("opera.exe", "Opera")
return

TestFirefox:
    TestPiPForBrowser("firefox.exe", "Firefox")
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
        ; Also drop the autostart registry entry since we just turned the flag off
        try {
            RegDelete, HKCU\Software\Microsoft\Windows\CurrentVersion\Run, PiPControllerPro
        }
        SetTimer, CheckMouseOverPiP, Off
        if (isEnabled)
            SetTimer, CheckMouseOverPiP, %checkInterval%
        Gosub, UpdateMenuState
        TrayTip, %AppName%, Settings reset, 2, 1
    }
return

; --- Update check ---
; Two entry points share one implementation: DoStartupUpdateCheck (scheduled
; 10s after boot, silent unless there's an update) and CheckForUpdatesMenu
; (tray menu item, always shows feedback). Both call RunUpdateCheck.

DoStartupUpdateCheck:
    SetTimer, DoStartupUpdateCheck, Off
    RunUpdateCheck(true)
    return

CheckForUpdatesMenu:
    RunUpdateCheck(false)
    return

RunUpdateCheck(silentIfCurrent) {
    global AppName, AppVersion
    try {
        whr := ComObjCreate("MSXML2.XMLHTTP.6.0")
        whr.Open("GET", "https://api.github.com/repos/joganubaid/pip-controller-pro/releases/latest", false)
        whr.SetRequestHeader("User-Agent", AppName . "/" . AppVersion)
        whr.SetRequestHeader("Accept", "application/vnd.github+json")
        whr.Send()
        ; Cache .Status into a plain var so we can use it in legacy TrayTip syntax.
        httpStatus := whr.Status
        if (httpStatus != 200) {
            if (!silentIfCurrent)
                TrayTip, %AppName%, Update check failed (HTTP %httpStatus%)., 4, 2
            return
        }
        if !RegExMatch(whr.ResponseText, "U)""tag_name""\s*:\s*""v?([^""]+)""", m) {
            if (!silentIfCurrent)
                TrayTip, %AppName%, Update check failed (no tag in response)., 4, 2
            return
        }
        latest := m1
        cmp := CompareSemver(latest, AppVersion)
        if (cmp > 0) {
            TrayTip, %AppName% update available, v%latest% is out (you have v%AppVersion%).`nGet it at github.com/joganubaid/pip-controller-pro/releases/latest, 10, 1
        } else if (!silentIfCurrent) {
            TrayTip, %AppName%, You're on the latest version (v%AppVersion%)., 3, 1
        }
    } catch e {
        if (!silentIfCurrent)
            TrayTip, %AppName%, Update check failed (network)., 4, 2
    }
}

; Returns 1 if a > b, -1 if a < b, 0 if equal. Compares the first 3
; dot-separated numeric components; non-numeric suffixes are ignored.
CompareSemver(a, b) {
    StringSplit, ap, a, .
    StringSplit, bp, b, .
    Loop, 3 {
        av := ap%A_Index% + 0
        bv := bp%A_Index% + 0
        if (av > bv)
            return 1
        if (av < bv)
            return -1
    }
    return 0
}

; Hotkeys
^!c::Gosub, ShowStatus
^!p::
    Suspend, Permit                    ; this hotkey survives global Suspend, otherwise un-suspend is impossible
    Suspend, Toggle
    if (A_IsSuspended) {
        SetTimer, CheckMouseOverPiP, Off   ; Suspend pauses hotkeys but not timers — toggle the timer explicitly
        TrayTip, %AppName%, Script Paused, 2
    } else {
        if (isEnabled)
            SetTimer, CheckMouseOverPiP, %checkInterval%
        TrayTip, %AppName%, Script Resumed, 2
    }
return
^!x::Gosub, ExitApp

ExitApp:
    Gosub, SaveSettings
    ExitApp