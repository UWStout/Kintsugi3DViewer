; Kintsugi 3D Viewer NSIS Installer script

;Include Modern UI

!include "MUI2.nsh"
!include "LangFile.nsh"

Name "Kintsugi 3D Viewer"
RequestExecutionLevel admin
Unicode True
ManifestDPIAware True
SetCompress off
OutFile "export/Kintsugi3DViewer-setup.exe"

InstallDir $PROGRAMFILES\Kintsugi3DViewer

InstallDirRegKey HKLM "Software\Kintsugi3DViewer" "Install_Dir"

; MUI Settings
!define MUI_ICON "Kintsugi3DViewer.ico"
!define MUI_UNICON "Kintsugi3DViewer.ico"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Start Kintsugi 3D Viewer"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.md"

; ---------------------------

; Installer Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "README.md"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller Pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Language Files
!insertmacro MUI_LANGUAGE "English"

; ---------------------------

; Main installation
Section "Kintsugi 3D Viewer (required)" SectionApp

    SectionIn RO

    SetOutPath $INSTDIR
    File "export\Kintsugi3DViewer.exe"
    File "export\Kintsugi3DViewer.console.exe"
    File "export\Kintsugi3DViewer.pck"
    File "README.md"

    ; Write install directory registry key
    WriteRegStr HKLM "SOFTWARE\Kintsugi3DViewer" "Install_Dir" "$INSTDIR"

    ; Write uninstall keys to registry
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kintsugi3DViewer" "DisplayName" "Kintsugi 3D Viewer"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kintsugi3DViewer" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kintsugi3DViewer" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kintsugi3DViewer" "NoRepair" 1
    WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

; Optional File Type associations
Section "File Type Associations" SectionAssociation

    ; Associate .ibr files as Kintsugi 3D Viewer Projects
    ;Use QtPro... to maintain compatibility with other glTF software (Gestaltor)
    WriteRegStr HKCR ".glb" "" "QtProject.QtInstallerFramework.glb"
    WriteRegStr HKCR ".glb" "Content Type" "model/gltf+binary"
    WriteRegStr HKCR ".glb" "OpenWithList" "Kintsugi3DViewer.exe"
    
    WriteRegStr HKCR ".gltf" "" "QtProject.QtInstallerFramework.gltf"
    WriteRegStr HKCR ".gltf" "Content Type" "model/gltf+json"
    WriteRegStr HKCR ".gltf" "OpenWithList" "Kintsugi3DViewer.exe"

    WriteRegStr HKCR "QtProject.QtInstallerFramework.glb" "" "glb file"
    WriteRegStr HKCR "QtProject.QtInstallerFramework.gltf" "" "glTF file"
    
    ;WriteRegStr HKCR "Applications\Kintsugi3DViewer.exe\DefaultIcon" "" "$INSTDIR\Kintsugi3DViewer.exe,0"
    WriteRegStr HKCR "Applications\Kintsugi3DViewer.exe\Shell\Open\Command" "" '"$INSTDIR\Kintsugi3DViewer.exe" "%1"'

SectionEnd

; Optional start menu shortcuts
Section "Start Menu Shortcuts" SectionShortcut

    CreateDirectory "$SMPROGRAMS\Kintsugi3DViewer"
    CreateShortcut "$SMPROGRAMS\Kintsugi3DViewer\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    CreateShortcut "$SMPROGRAMS\Kintsugi3DViewer\Kintsugi 3D Viewer.lnk" "$INSTDIR\Kintsugi3DViewer.exe"

SectionEnd

; Optional and default disabled Desktop shortcut
Section /o "Desktop Shortcut" SectionDesktop

    CreateShortcut "$DESKTOP\Kintsugi 3D Viewer.lnk" "$INSTDIR\Kintsugi3DViewer.exe"

SectionEnd

; Uninstaller
Section "Uninstall"

    ; Remove directories
    RMDir /r "$SMPROGRAMS\Kintsugi3DViewer"
    RMDir /r "$INSTDIR"

    ; Remove Desktop Shortcut
    Delete "$DESKTOP\Kintsugi 3D Viewer.lnk"

    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Kintsugi3DViewer"
    DeleteRegKey HKLM "SOFTWARE\Kintsugi3DViewer"

    ; Remove file type associations
    DeleteRegKey HKCR "Kintsugi3DViewer.Model"

SectionEnd

; Run the application if requested after installation
Function LaunchLink

  ExecShell "" "$INSTDIR\Kintsugi3DViewer.exe"

FunctionEnd

LangString DESC_SectionApp ${LANG_ENGLISH} "The main Kintsugi 3D Viewer Application"
LangString DESC_SectionAssociation ${LANG_ENGLISH} "Set up Kintsugi 3D Viewer Project file associations (.glb and .gltf)"
LangString DESC_SectionShortcut ${LANG_ENGLISH} "Install shortcuts so the application can be launched from the start menu"
LangString DESC_SectionDesktop ${LANG_ENGLISH} "Add a shortcut to Kintsugi 3D Viewer to the desktop"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SectionApp} $(DESC_SectionApp)
!insertmacro MUI_DESCRIPTION_TEXT ${SectionAssociation} $(DESC_SectionAssociation)
!insertmacro MUI_DESCRIPTION_TEXT ${SectionShortcut} $(DESC_SectionShortcut)
!insertmacro MUI_DESCRIPTION_TEXT ${SectionDesktop} $(DESC_SectionDesktop)
!insertmacro MUI_FUNCTION_DESCRIPTION_END