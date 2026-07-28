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

; Menu presets — single source of truth for the tray submenus, their click
; handlers, and the current-selection checkmarks.
transparencyPresets := [{name: "Almost Invisible (25)", value: 25}
                       ,{name: "Very Light (64)", value: 64}
                       ,{name: "Medium (128)", value: 128}
                       ,{name: "Default (179)", value: 179}
                       ,{name: "Slight (230)", value: 230}
                       ,{name: "Opaque (255)", value: 255}]
speedPresets := [{name: "Ultra Fast (10ms)", value: 10}
                ,{name: "Very Fast (25ms)", value: 25}
                ,{name: "Fast (50ms)", value: 50}
                ,{name: "Normal (100ms)", value: 100}
                ,{name: "Slow (200ms)", value: 200}]

; Variables
pipWindow := ""
isHovering := false
lastPiPWindow := ""
pipState := ""         ; "", "transparent", or "opaque" — last state applied to the PiP window
pipAppliedValue := -1  ; transparency value last applied, so preset changes re-apply live
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

    ; If detection moved to a different window (or none), restore the previous
    ; one first — otherwise it stays transparent AND click-through forever, and
    ; a click-through window can't even be clicked to recover it.
    if (lastPiPWindow != "" && pipWindow != lastPiPWindow) {
        RestorePiPWindow(lastPiPWindow)
        isHovering := false
        pipState := ""
    }

    if (pipWindow != "")
    {
        ; Check if window still exists before proceeding
        WinGetPos, pipX, pipY, pipWidth, pipHeight, ahk_id %pipWindow%

        ; Only proceed if WinGetPos succeeded (ErrorLevel = 0)
        if (ErrorLevel = 0 && pipWidth > 0 && pipHeight > 0)
        {
            ; Check if mouse is over the PiP window. A geometric hit alone is not
            ; enough before click-through is applied — another window stacked on
            ; top of the PiP would falsely trigger transparency — so also require
            ; the window under the cursor to be the PiP itself. Once click-through
            ; is active the PiP is invisible to MouseGetPos, so the geometric test
            ; is all we have in that state.
            isInRect := (mouseX >= pipX && mouseX <= pipX + pipWidth && mouseY >= pipY && mouseY <= pipY + pipHeight)
            isMouseOverPiP := isInRect && (windowUnderMouse = pipWindow || pipState = "transparent")

            if (isMouseOverPiP)
            {
                ; Only call WinSet on state transitions (or when the transparency
                ; preset changed) — not on every timer tick.
                if (GetKeyState("Shift", "P"))
                {
                    ; Make window fully opaque and clickable
                    if (pipState != "opaque" || lastPiPWindow != pipWindow) {
                        WinSet, Transparent, 255, ahk_id %pipWindow%
                        WinSet, ExStyle, -0x20, ahk_id %pipWindow%   ; Remove click-through
                        pipState := "opaque"
                    }
                }
                else
                {
                    ; Make window semi-transparent and click-through
                    if (pipState != "transparent" || pipAppliedValue != transparency || lastPiPWindow != pipWindow) {
                        WinSet, Transparent, %transparency%, ahk_id %pipWindow%
                        WinSet, ExStyle, +0x20, ahk_id %pipWindow%   ; Enable click-through
                        pipState := "transparent"
                        pipAppliedValue := transparency
                    }
                }

                isHovering := true
                lastPiPWindow := pipWindow
            }
            else if (isHovering)
            {
                ; Reset to fully opaque when not hovering
                RestorePiPWindow(pipWindow)
                isHovering := false
                pipState := ""
            }
        }
        else if (isHovering)
        {
            ; Window no longer exists, reset hovering state
            isHovering := false
            pipState := ""
            lastPiPWindow := ""
        }
    }
    else if (isHovering)
    {
        ; No PiP window found, reset hovering state
        isHovering := false
        pipState := ""
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

; Restore a PiP window to fully opaque and interactive. No-op for empty IDs
; and windows that have already closed.
RestorePiPWindow(id) {
    if (id = "")
        return
    if (WinExist("ahk_id " . id)) {
        WinSet, Transparent, 255, ahk_id %id%
        WinSet, ExStyle, -0x20, ahk_id %id%
    }
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
    
    ; Transparency Menu — built from the preset table at the top of the script
    For i, p in transparencyPresets
        Menu, TransparencyMenu, Add, % p.name, SetTransparencyPreset

    ; Speed Menu — same pattern
    For i, p in speedPresets
        Menu, SpeedMenu, Add, % p.name, SetSpeedPreset
    
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
    UpdateMenuChecks("TransparencyMenu", transparencyPresets, transparency)
    UpdateMenuChecks("SpeedMenu", speedPresets, checkInterval)
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
        ; Restore the window we were controlling — otherwise it stays
        ; transparent and click-through while the app is disabled.
        RestorePiPWindow(lastPiPWindow)
        isHovering := false
        pipState := ""
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

; Transparency preset handler — one handler for the whole submenu. The value
; is looked up from the preset table by menu item name (no per-item labels).
SetTransparencyPreset:
    For i, p in transparencyPresets
        if (A_ThisMenuItem = p.name)
            transparency := p.value
    UpdateMenuChecks("TransparencyMenu", transparencyPresets, transparency)
    TrayTip, %AppName%, Transparency set to %transparency%, 2, 1
    Gosub, SaveSettings
return

; Response speed preset handler.
SetSpeedPreset:
    For i, p in speedPresets
        if (A_ThisMenuItem = p.name)
            checkInterval := p.value
    if (isEnabled) {
        SetTimer, CheckMouseOverPiP, Off
        SetTimer, CheckMouseOverPiP, %checkInterval%
    }
    UpdateMenuChecks("SpeedMenu", speedPresets, checkInterval)
    TrayTip, %AppName%, Speed set to %checkInterval%ms, 2, 1
    Gosub, SaveSettings
return

; Check the active preset and uncheck the rest (radio-button behavior).
UpdateMenuChecks(menuName, presets, currentValue) {
    For i, p in presets {
        if (p.value = currentValue)
            Menu, %menuName%, Check, % p.name
        else
            Menu, %menuName%, Uncheck, % p.name
    }
}

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
        ; Clear the applied-state so the hover loop re-applies transparency on
        ; the next tick instead of leaving the window stuck opaque.
        pipState := ""
        pipAppliedValue := -1
        TrayTip, %AppName%, Reset current PiP window, 2, 1
    } else {
        TrayTip, %AppName%, No PiP window currently detected, 2, 2
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
        UpdateMenuChecks("TransparencyMenu", transparencyPresets, transparency)
        UpdateMenuChecks("SpeedMenu", speedPresets, checkInterval)
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
        ; Bound the blocking call: Send() is synchronous and runs on the script's
        ; only thread, so the XMLHTTP defaults (60s connect, 30s send/receive)
        ; could freeze the tray and the transparency loop for minutes on a bad
        ; network. Order: resolve, connect, send, receive — in milliseconds.
        whr.SetTimeouts(3000, 5000, 5000, 10000)
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
        ; The regex above operates on raw response bytes, not parsed JSON, so a
        ; MitM (TLS proxy, compromised CA) could stuff control chars into the
        ; tag and have them rendered in the TrayTip. Validate before display.
        if !RegExMatch(latest, "^\d+\.\d+\.\d+$") {
            if (!silentIfCurrent)
                TrayTip, %AppName%, Update check failed (unexpected tag format)., 4, 2
            return
        }
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
        RestorePiPWindow(lastPiPWindow)    ; don't leave the PiP stuck transparent + click-through
        isHovering := false
        pipState := ""
        TrayTip, %AppName%, Script Paused, 2
    } else {
        if (isEnabled)
            SetTimer, CheckMouseOverPiP, %checkInterval%
        TrayTip, %AppName%, Script Resumed, 2
    }
return
^!x::Gosub, ExitApp

ExitApp:
    ; Restore the window we were controlling — otherwise exit strands it
    ; transparent + click-through with no process left to recover it.
    RestorePiPWindow(lastPiPWindow)
    Gosub, SaveSettings
    ExitApp