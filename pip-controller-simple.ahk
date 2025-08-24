; PiP Controller Pro v2.1.0 - Simplified Version
#NoEnv
#SingleInstance Force
#Persistent

; Application info
AppName := "PiP Controller Pro"
AppVersion := "2.1.0"

; Default settings
transparency := 179
checkInterval := 50
isEnabled := true

; Variables
pipWindow := ""
isHovering := false

; Initialize system tray
Menu, Tray, NoStandard
Menu, Tray, Add, About, ShowAbout
Menu, Tray, Add, Exit, ExitApp
Menu, Tray, Default, About
Menu, Tray, Tip, %AppName% v%AppVersion%

; Start main loop
SetTimer, CheckMouseOverPiP, %checkInterval%

; Show startup notification
TrayTip, %AppName%, %AppName% v%AppVersion% started!, 3, 1

return

CheckMouseOverPiP:
    ; Get the mouse position
    MouseGetPos, mouseX, mouseY
    
    ; Find Chrome PiP window
    WinGet, id, ID, Picture-in-picture ahk_exe chrome.exe
    if (id)
    {
        pipWindow := id
        WinGetPos, pipX, pipY, pipWidth, pipHeight, ahk_id %pipWindow%
        
        if (ErrorLevel = 0 && pipWidth > 0 && pipHeight > 0)
        {
            ; Check if mouse is over the PiP window
            isMouseOverPiP := (mouseX >= pipX && mouseX <= pipX + pipWidth && mouseY >= pipY && mouseY <= pipY + pipHeight)
            
            if (isMouseOverPiP)
            {
                ; Make window semi-transparent and click-through
                WinSet, Transparent, %transparency%, ahk_id %pipWindow%
                WinSet, ExStyle, +0x20, ahk_id %pipWindow%
                isHovering := true
            }
            else if (isHovering)
            {
                ; Reset to fully opaque when not hovering
                WinSet, Transparent, 255, ahk_id %pipWindow%
                WinSet, ExStyle, -0x20, ahk_id %pipWindow%
                isHovering := false
            }
        }
    }
return

ShowAbout:
    MsgBox, 64, About %AppName%, %AppName% v%AppVersion%`n`nSimplified PiP Controller for Chrome
return

ExitApp:
    ExitApp