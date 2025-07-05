[Setup]
; Basic app information
AppName=PiP Controller Pro
AppVersion=2.0.0
AppVerName=PiP Controller Pro 2.0.0
AppPublisher=Your Name
AppPublisherURL=https://github.com/yourusername/pip-controller
AppSupportURL=https://github.com/yourusername/pip-controller/issues
AppUpdatesURL=https://github.com/yourusername/pip-controller/releases
DefaultDirName={autopf}\PiP Controller Pro
DefaultGroupName=PiP Controller Pro
AllowNoIcons=yes
LicenseFile=
InfoBeforeFile=
InfoAfterFile=
OutputDir=dist
OutputBaseFilename=PiPControllerPro-v2.0.0-Setup
SetupIconFile=
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64

; Uninstall display information
UninstallDisplayName=PiP Controller Pro
UninstallDisplayIcon={app}\pip-controller.exe

; Directory and file operations
CreateAppDir=yes
UsePreviousAppDir=yes

; Start menu and desktop
CreateUninstallRegKey=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1
Name: "startup"; Description: "Start with Windows"; GroupDescription: "Startup Options"; Flags: unchecked

[Files]
Source: "pip-controller.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion skipifsourcedoesntexist

[Icons]
Name: "{group}\PiP Controller Pro"; Filename: "{app}\pip-controller.exe"
Name: "{group}\README"; Filename: "{app}\README.md"
Name: "{group}\{cm:UninstallProgram,PiP Controller Pro}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\PiP Controller Pro"; Filename: "{app}\pip-controller.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\PiP Controller Pro"; Filename: "{app}\pip-controller.exe"; Tasks: quicklaunchicon

[Registry]
; Add to Windows startup if user selected the option
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "PiPControllerPro"; ValueData: "{app}\pip-controller.exe"; Flags: uninsdeletevalue; Tasks: startup

[Run]
Filename: "{app}\pip-controller.exe"; Description: "{cm:LaunchProgram,PiP Controller Pro}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\PiPController"

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Custom post-install actions can go here
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Clean up any remaining files
    DelTree(ExpandConstant('{userappdata}\PiPController'), True, True, True);
  end;
end;

[Messages]
; Custom messages
WelcomeLabel2=This will install [name/ver] on your computer.%n%nPiP Controller Pro is a professional utility for controlling Chrome Picture-in-Picture windows with transparency and click-through features.
FinishedLabel=Setup has finished installing [name] on your computer.%n%nThe application features:%n• Automatic transparency control%n• Click-through functionality%n• Professional system tray integration%n• Multiple preset configurations%n• Status monitoring dashboard
