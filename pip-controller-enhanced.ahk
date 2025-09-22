; PiP Controller Pro v2.1.1 Enhanced
; Professional Picture-in-Picture Window Controller with Enhanced Browser Support

#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1
SetWinDelay, -1
CoordMode, Mouse, Screen

; Application info
AppName := "PiP Controller Pro Enhanced"
AppVersion := "2.1.1"

; Default settings
transparency := 179
checkInterval := 50
isEnabled := true
autoStart := false
debugMode := false

; Variables
pipWindow := ""
isHovering := false
lastPiPWindow := ""
settingsFile := A_AppData . "\PiPController\settings.ini"
lastDetectionTime := 0
detectionCooldown := 500  ; 500ms cooldown to prevent excessive detection attempts

; Supported browsers list
browserList := ["chrome.exe", "msedge.exe", "firefox.exe", "brave.exe", "opera.exe", "vivaldi.exe"]

; PiP window title patterns
pipTitlePatterns := ["Picture-in-picture", "Picture in picture", "picture-in-picture", "PiP", "Mini Player"]

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
    
    ; Find Picture-in-Picture window with cooldown
    currentTime := A_TickCount
    if (currentTime - lastDetectionTime > detectionCooldown)
    {
        Gosub, FindPiPWindow
        pipWindow := FindPiPWindowResult
        lastDetectionTime := currentTime
    }
    
    if (pipWindow != "" && pipWindow)
    {
        ; Validate window still exists
        if (IsWindowValid(pipWindow))
        {
            WinGetPos, pipX, pipY, pipWidth, pipHeight, ahk_id %pipWindow%
            
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
                    if (debugMode)
                        TrayTip, Debug, Hovering over PiP window, 1
                }
            }
            else if (isHovering)
            {
                ; Reset to fully opaque when not hovering
                WinSet, Transparent, 255, ahk_id %pipWindow%
                WinSet, ExStyle, -0x20, ahk_id %pipWindow%   ; Remove click-through
                isHovering := false
                if (debugMode)
                    TrayTip, Debug, Left PiP window, 1
            }
        }
        else
        {
            ; Window no longer exists, reset hovering state
            if (isHovering)
            {
                isHovering := false
                pipWindow := ""
                if (debugMode)
                    TrayTip, Debug, PiP window closed, 1
            }
        }
    }
    else if (isHovering)
    {
        ; No PiP window found, reset hovering state
        isHovering := false
    }
return

; Function to validate if window still exists and is visible
IsWindowValid(windowId)
{
    if (!windowId || windowId == "")
        return false
        
    WinGetPos, x, y, w, h, ahk_id %windowId%
    if (ErrorLevel != 0 || w <= 0 || h <= 0)
        return false
        
    ; Check if window is visible
    WinGet, style, Style, ahk_id %windowId%
    if (ErrorLevel != 0)
        return false
        
    ; Check if WS_VISIBLE flag is set (0x10000000)
    return (style & 0x10000000) ? true : false
}

FindPiPWindow:
    global FindPiPWindowResult, browserList, pipTitlePatterns, debugMode
    FindPiPWindowResult := ""
    
    ; First, try exact title matches for all browsers
    for browserIndex, browserExe in browserList
    {
        for patternIndex, pattern in pipTitlePatterns
        {
            WinGet, id, ID, %pattern% ahk_exe %browserExe%
            if (id && id != "")
            {
                FindPiPWindowResult := id
                if (debugMode)
                    TrayTip, Debug, Found PiP: %browserExe% with pattern: %pattern%, 2
                return
            }
        }
    }
    
    ; Second pass: Look for small windows that might be PiP
    for browserIndex, browserExe in browserList
    {
        if (FindSmallVideoPiPWindow(browserExe))
            return
    }
    
    ; Third pass: Check for windows with video-related keywords
    for browserIndex, browserExe in browserList
    {
        if (FindVideoKeywordWindow(browserExe))
            return
    }
    
    FindPiPWindowResult := ""
    return

; Function to find small windows that could be PiP
FindSmallVideoPiPWindow(browserExe)
{
    global FindPiPWindowResult, debugMode
    
    WinGet, windows, List, ahk_exe %browserExe%
    if (windows && windows > 0)
    {
        Loop, %windows%
        {
            windowId := windows%A_Index%
            if (windowId && windowId != "")
            {
                WinGetPos, x, y, w, h, ahk_id %windowId%
                if (ErrorLevel = 0 && w > 100 && h > 75 && w < 1000 && h < 700)
                {
                    ; Check window style for popup/tool window characteristics
                    WinGet, exStyle, ExStyle, ahk_id %windowId%
                    WinGet, style, Style, ahk_id %windowId%
                    
                    ; Tool windows often have WS_EX_TOOLWINDOW (0x80) or are popup windows
                    if (exStyle & 0x80 || !(style & 0x40000000))  ; Tool window or not child window
                    {
                        WinGetTitle, title, ahk_id %windowId%
                        ; PiP windows often have minimal titles or video-related content
                        if (title == "" || StrLen(title) < 50)
                        {
                            FindPiPWindowResult := windowId
                            if (debugMode)
                                TrayTip, Debug, Found small window PiP: %browserExe% Title: %title%, 2
                            return true
                        }
                    }
                }
            }
        }
    }
    return false
}

; Function to find windows with video-related keywords
FindVideoKeywordWindow(browserExe)
{
    global FindPiPWindowResult, debugMode
    
    videoKeywords := ["YouTube", "Netflix", "Twitch", "Vimeo", "Prime Video", "Disney+", "Hulu", "Video", "Player", "Media"]
    
    WinGet, windows, List, ahk_exe %browserExe%
    Loop, %windows%
    {
        windowId := windows%A_Index%
        if (windowId && windowId != "")
        {
            WinGetPos, x, y, w, h, ahk_id %windowId%
            if (ErrorLevel = 0 && w > 200 && h > 150 && w < 800 && h < 600)
            {
                WinGetTitle, title, ahk_id %windowId%
                for keywordIndex, keyword in videoKeywords
                {
                    if (InStr(title, keyword) > 0)
                    {
                        ; Additional check: ensure it's not the main browser window
                        if (w < 1200 && h < 800)  ; Smaller than typical browser windows
                        {
                            FindPiPWindowResult := windowId
                            if (debugMode)
                                TrayTip, Debug, Found keyword PiP: %keyword% in %title%, 2
                            return true
                        }
                    }
                }
            }
        }
    }
    return false
}

; Load settings from file
LoadSettings:
    global transparency, checkInterval, isEnabled, autoStart, debugMode
    
    if (FileExist(settingsFile))
    {
        IniRead, transparency, %settingsFile%, Settings, Transparency, 179
        IniRead, checkInterval, %settingsFile%, Settings, CheckInterval, 50
        IniRead, isEnabled, %settingsFile%, Settings, Enabled, 1
        IniRead, autoStart, %settingsFile%, Settings, AutoStart, 0
        IniRead, debugMode, %settingsFile%, Settings, DebugMode, 0
    }
    return

; Save settings to file
SaveSettings:
    global transparency, checkInterval, isEnabled, autoStart, settingsFile, debugMode
    
    IniWrite, %transparency%, %settingsFile%, Settings, Transparency
    IniWrite, %checkInterval%, %settingsFile%, Settings, CheckInterval
    IniWrite, %isEnabled%, %settingsFile%, Settings, Enabled
    IniWrite, %autoStart%, %settingsFile%, Settings, AutoStart
    IniWrite, %debugMode%, %settingsFile%, Settings, DebugMode
    return

; Initialize system tray
InitializeTray:
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
    Menu, BrowserMenu, Add, Test All Browsers, TestAllBrowsers
    Menu, BrowserMenu, Add, Test Chrome PiP, TestChrome
    Menu, BrowserMenu, Add, Test Edge PiP, TestEdge
    Menu, BrowserMenu, Add, Test Firefox PiP, TestFirefox
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
    Menu, Tray, Add, Debug Mode, ToggleDebugMode
    Menu, Tray, Add, Auto-Start with Windows, ToggleAutoStart
    Menu, Tray, Add
    Menu, Tray, Add, Exit, ExitApp
    
    ; Set default action (double-click)
    Menu, Tray, Default, Status Dashboard
    
    ; Set tray tip
    Menu, Tray, Tip, %AppName% v%AppVersion%
    
    ; Update menu items based on current settings
    Gosub, UpdateAutoStartMenu
    Gosub, UpdateDebugMenu
    return

; Update debug mode menu item
UpdateDebugMenu:
    global debugMode
    
    if (debugMode)
    {
        Menu, Tray, Rename, Debug Mode, Disable Debug Mode
    }
    else
    {
        Menu, Tray, Rename, Disable Debug Mode, Debug Mode
    }
    return

; Toggle debug mode
ToggleDebugMode:
    if (debugMode)
    {
        debugMode := false
        TrayTip, %AppName%, Debug mode disabled, 2, 2
    }
    else
    {
        debugMode := true
        TrayTip, %AppName%, Debug mode enabled, 2, 1
    }
    Gosub, UpdateDebugMenu
    Gosub, SaveSettings
return

; Test all browsers for PiP windows
TestAllBrowsers:
    global browserList
    
    foundWindows := 0
    resultText := "PiP Detection Results:`n`n"
    
    for browserIndex, browserExe in browserList
    {
        ; Check if browser is running
        Process, Exist, %browserExe%
        if (ErrorLevel > 0)
        {
            resultText .= browserExe . ": Running`n"
            
            ; Try to find PiP for this browser
            Gosub, FindPiPWindow  ; This will check all browsers, but we'll filter
            if (FindPiPWindowResult != "")
            {
                WinGet, processName, ProcessName, ahk_id %FindPiPWindowResult%
                if (processName = browserExe)
                {
                    WinGetTitle, title, ahk_id %FindPiPWindowResult%
                    WinGetPos, x, y, w, h, ahk_id %FindPiPWindowResult%
                    resultText .= "  ✅ PiP Found: " . title . " (" . w . "x" . h . ")`n"
                    foundWindows++
                }
                else
                {
                    resultText .= "  ❌ No PiP detected`n"
                }
            }
            else
            {
                resultText .= "  ❌ No PiP detected`n"
            }
        }
        else
        {
            resultText .= browserExe . ": Not running`n"
        }
        resultText .= "`n"
    }
    
    resultText .= "Total PiP windows found: " . foundWindows
    MsgBox, 64, Browser PiP Test Results, %resultText%
return

; Enhanced browser-specific test functions
TestChrome:
    TestSpecificBrowser("chrome.exe", "Chrome")
return

TestEdge:
    TestSpecificBrowser("msedge.exe", "Edge")
return

TestFirefox:
    TestSpecificBrowser("firefox.exe", "Firefox")
return

; Generic function to test specific browser
TestSpecificBrowser(browserExe, browserName)
{
    global pipTitlePatterns
    
    Process, Exist, %browserExe%
    if (ErrorLevel = 0)
    {
        MsgBox, 48, %browserName% Not Running, %browserName% is not currently running.`n`nPlease start %browserName% and open a video in Picture-in-Picture mode.
        return
    }
    
    foundWindow := ""
    foundMethod := ""
    
    ; Try exact title matches
    for patternIndex, pattern in pipTitlePatterns
    {
        WinGet, id, ID, %pattern% ahk_exe %browserExe%
        if (id && id != "")
        {
            foundWindow := id
            foundMethod := "Exact title match: " . pattern
            break
        }
    }
    
    ; Try small window detection
    if (!foundWindow)
    {
        if (FindSmallVideoPiPWindow(browserExe))
        {
            foundWindow := FindPiPWindowResult
            foundMethod := "Small window detection"
        }
    }
    
    ; Try keyword detection
    if (!foundWindow)
    {
        if (FindVideoKeywordWindow(browserExe))
        {
            foundWindow := FindPiPWindowResult
            foundMethod := "Video keyword detection"
        }
    }
    
    if (foundWindow)
    {
        WinGetTitle, title, ahk_id %foundWindow%
        WinGetPos, x, y, w, h, ahk_id %foundWindow%
        WinGet, processName, ProcessName, ahk_id %foundWindow%
        
        resultText := "%browserName% PiP Window Found!`n`n"
        resultText .= "Detection Method: " . foundMethod . "`n"
        resultText .= "Title: " . title . "`n"
        resultText .= "Process: " . processName . "`n"
        resultText .= "Window ID: " . foundWindow . "`n"
        resultText .= "Size: " . w . "x" . h . "`n"
        resultText .= "Position: " . x . "," . y
        
        MsgBox, 64, %browserName% PiP Found, %resultText%
    }
    else
    {
        MsgBox, 48, %browserName% PiP Not Found, No %browserName% Picture-in-Picture window found.`n`nTroubleshooting:`n• Make sure %browserName% is running`n• Open a video in Picture-in-Picture mode`n• Ensure the PiP window is visible and not minimized`n• Try enabling Debug Mode for more information
    }
}

; Rest of the functions remain similar to original but with enhanced error handling...
; [Include all other original functions like ShowAbout, ToggleEnabled, etc.]

; Enhanced Show Status with more browser information
ShowStatus:
    Gosub, FindPiPWindow
    currentPiP := FindPiPWindowResult
    pipInfo := currentPiP != "" ? "PiP Window Found" : "No PiP Window Detected"
    
    ; Get current window info if PiP is found
    windowInfo := ""
    browserInfo := ""
    if (currentPiP != "")
    {
        WinGetTitle, title, ahk_id %currentPiP%
        WinGetPos, x, y, w, h, ahk_id %currentPiP%
        WinGet, processName, ProcessName, ahk_id %currentPiP%
        windowInfo := "`nTitle: " . title . "`nProcess: " . processName . "`nSize: " . w . "x" . h . "`nPosition: " . x . "," . y
    }
    
    ; Count running browsers
    runningBrowsers := 0
    for browserIndex, browserExe in browserList
    {
        Process, Exist, %browserExe%
        if (ErrorLevel > 0)
            runningBrowsers++
    }
    
    statusText := AppName . " v" . AppVersion . "`n"
    statusText .= "========================`n`n"
    statusText .= "Status: " . (isEnabled ? "✅ Enabled" : "❌ Disabled") . "`n"
    statusText .= "Debug Mode: " . (debugMode ? "✅ Enabled" : "❌ Disabled") . "`n"
    statusText .= "Transparency: " . transparency . "/255`n"
    statusText .= "Check Interval: " . checkInterval . "ms`n"
    statusText .= "Auto-Start: " . (autoStart ? "✅ Enabled" : "❌ Disabled") . "`n"
    statusText .= "Running Browsers: " . runningBrowsers . "/" . browserList.Length() . "`n"
    statusText .= "PiP Window: " . pipInfo . windowInfo . "`n"
    statusText .= "Mouse Hovering: " . (isHovering ? "✅ Yes" : "❌ No") . "`n"
    statusText .= "Settings File: " . settingsFile
    
    MsgBox, 64, %AppName% Status Dashboard, %statusText%
return

; Include other essential functions from the original script
; (ToggleEnabled, ToggleAutoStart, Transparency settings, Speed settings, etc.)
; [These would be the same as the original script]

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

^!d::
    Gosub, ToggleDebugMode
return

^!x::
    Gosub, ExitApp
return

ExitApp:
    ; Save settings before exit
    Gosub, SaveSettings
    ExitApp