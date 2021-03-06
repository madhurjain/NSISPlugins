﻿;*********************************************************************
; Windows Installer 3.1
; 
; This script is checked on pure installation of Windows XP: works and asks no questions to the user.
;*********************************************************************

Function UpdateMSIVersion
  GetDllVersion "$SYSDIR\MSI.dll" $R0 $R1
  IntOp $R2 $R0 / 0x00010000
  IntOp $R3 $R0 & 0x0000FFFF
 
  IntCmp $R2 3 0 InstallMSI RightMSI
  IntCmp $R3 1 RightMSI InstallMSI RightMSI
 
  RightMSI:
    Push 0
    Goto ExitFunction
 
  InstallMSI:
    Push 1
    Goto ExitFunction
 
  ExitFunction:
 
FunctionEnd

!macro CheckWININST
DetailPrint "Sprawdzanie istniejącej wersji Windows Installer..."
StrCpy $8 ""
CheckBeginWININST:
  Call UpdateMSIVersion
  Pop $R0

  ${If} $R0 == 1
    DetailPrint "Nie znaleziono Windows Installer 3.1."
    ${If} $8 == ""
      Goto InvalidWININST
    ${Else}
      Goto InvalidWININSTAfterInstall
    ${EndIf}
  ${EndIf}

  Goto ValidWININST

InvalidWININST:
  MessageBox MB_YESNO|MB_ICONQUESTION \
    "Program ${PRODUCT_NAME} wymaga pakietu Windows Installer 3.1, który nie jest obecnie zainstalowany na Twoim komputerze.$\r$\n$\r$\nCzy zainstalować?" \
  IDYES InstallWININST IDNO AbortMeWININST

AbortMeWININST:
  DetailPrint "Instalacja przerwana z powodu braku Windows Installer 3.1"
  MessageBox MB_OK "Pakiet Windows Installer 3.1 jest wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

InstallWININST:
  DetailPrint "Instalowanie Windows Installer 3.1..."
  ExecWait 'additional/runWI.exe' $R1

  ; 1641 - Instalator rozpoczął ponowny rozruch.
  ; 3010 - Ukończenie instalacji wymaga ponownego uruchomienia
  ${If} $R1 == 3010
    DetailPrint "Będzie wymagane ponowne uruchomienie komputera."
    SetRebootFlag true
  ${EndIf}
  
  DetailPrint "Instalacja Windows Installer 3.1 zakończona (kod wyjścia: $R1). Sprawdzanie..."
  StrCpy $8 "AfterInstall"
  Goto CheckBeginWININST

InvalidWININSTAfterInstall:
  DetailPrint "Instalacja przerwana po nieprawidłowej instalacji Windows Installer 3.1"
  MessageBox MB_OK "Instalacja pakietu Windows Installer 3.1 nie powiodła się. Jest to element wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

ValidWININST:
  DetailPrint "Windows Installer 3.1 lub wyższy jest zainstalowany."
!macroend