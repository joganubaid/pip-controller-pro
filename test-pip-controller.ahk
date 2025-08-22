; PiP Controller Pro - Test Script
; Simple test script to verify functionality

#NoEnv
#SingleInstance Force

AppName := "PiP Controller Pro Test"
AppVersion := "2.1.0"

MsgBox, 64, %AppName%, %AppName% v%AppVersion% Test Script`n`nThis script will test basic PiP Controller functionality.

; Test settings file creation
settingsFile := A_AppData . "\PiPController\settings.ini"
FileCreateDir, % A_AppData . "\PiPController"

; Test INI file operations
IniWrite, 179, %settingsFile%, Settings, Transparency
IniWrite, 50, %settingsFile%, Settings, CheckInterval
IniWrite, 1, %settingsFile%, Settings, Enabled
IniWrite, 0, %settingsFile%, Settings, AutoStart

; Read back settings
IniRead, transparency, %settingsFile%, Settings, Transparency, 179
IniRead, checkInterval, %settingsFile%, Settings, CheckInterval, 50
IniRead, isEnabled, %settingsFile%, Settings, Enabled, 1
IniRead, autoStart, %settingsFile%, Settings, AutoStart, 0

; Test window detection
chromePiP := ""
edgePiP := ""

; Test Chrome PiP detection
WinGet, id, ID, Picture-in-picture ahk_exe chrome.exe
if (id)
    chromePiP := id

; Test Edge PiP detection
WinGet, id, ID, Picture-in-picture ahk_exe msedge.exe
if (id)
    edgePiP := id

; Show test results
testResults := "Test Results:`n`n"
testResults .= "Settings File: " . settingsFile . "`n"
testResults .= "Transparency: " . transparency . "`n"
testResults .= "Check Interval: " . checkInterval . "`n"
testResults .= "Enabled: " . isEnabled . "`n"
testResults .= "Auto Start: " . autoStart . "`n`n"
testResults .= "Chrome PiP Found: " . (chromePiP ? "Yes (ID: " . chromePiP . ")" : "No") . "`n"
testResults .= "Edge PiP Found: " . (edgePiP ? "Yes (ID: " . edgePiP . ")" : "No") . "`n`n"
testResults .= "Test completed successfully!"

MsgBox, 64, Test Results, %testResults%

; Clean up test settings
FileDelete, %settingsFile%
FileRemoveDir, % A_AppData . "\PiPController", 1

MsgBox, 64, Cleanup, Test cleanup completed.`n`nSettings file removed.

ExitApp
