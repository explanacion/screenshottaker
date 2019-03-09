; ������� ������ ���������
#include <Date.au3>
#include <ScreenCapture.au3>
#include <GuiListView.au3>
; ��� ��� ������ ����� ��� ��������� ��������� ����
#include <APISysConstants.au3>
#include <GuiMenu.au3>
#include <SendMessage.au3>
#include <WinAPIGdi.au3>
#include <WinAPIMisc.au3>
#include <WinAPIProc.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
; � ��� ��� ��������� �������� ������������ �� ����������� ����� ��� ��������
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
; ����������-���������, �������� �� ������ ���������, �� �������� ����� ��������� � ini �����
; ��� ���������� �����-�� ����� �������� ����� �������������� ��������� ����������� �������� $aSection
; ----------------------------------------------------------------------------------------------------
Global $onlyActiveWindow = True
Global $showMouse = False
Global $screendirectory = @UserProfileDir & "\Downloads\"
Global $settingsFile = @ScriptName & ".ini"
; ----------------------------------------------------------------------------------------------------
; ������ � ����
Opt("TrayMenuMode", 1)
Local $scrpref = TrayCreateItem("��������")
Local $settingspref = TrayCreateItem("���������")
Local $aboutpref = TrayCreateItem("� ���������")
Local $exitpref = TrayCreateItem("�����")
TraySetState()

; ��������� ��������� �� �����
LoadSettings()
; ��������� ���������� ����������
Global $lastWindowHandle = WinGetHandle("[ACTIVE]")
; ���������� ��� ��������� ���� ��� ��������� ���������
Global $hEventProc = DllCallbackRegister('_EventProc', 'none', 'ptr;dword;hwnd;long;long;dword;dword')
; ���
OnAutoItExitRegister('OnAutoItExit')
Global $hEventHook = _WinAPI_SetWinEventHook($EVENT_SYSTEM_FOREGROUND, $EVENT_SYSTEM_FOREGROUND, DllCallbackGetPtr($hEventProc))

; ������� ��������� �� ini-����� ��������� � ����� ������� ����������
Func LoadSettings()
	  ; ���� �������� ����������, ��������� ���
	  Local $aArray = IniReadSection($settingsFile, "Settings")
	  ;_ArrayDisplay($aArray)
	  If Not @error Then
		 ; ������ ��������
		 For $i = 1 To $aArray[0][0]
			If $aArray[$i][1] == "onlyActiveWindow" And IsBool($aArray[$i][2]) Then
			   $onlyActiveWindow = $aArray[$i][2]
			ElseIf $aArray[$i][1] == "showMouse" And IsBool($aArray[$i][2]) Then
			   $showMouse = $aArray[$i][2]
			ElseIf $aArray[$i][1] == "screendirectory" Then
			   $screendirectory = $aArray[$i][2]
			ElseIf $aArray[$i][1] == "screendirectory" Then
			   $settingsFile = $aArray[$i][2]
			EndIf
		 Next
	  Else
		 ; ��������� �������� �� ���������
	  EndIf
EndFunc ;==>LoadSettings

; �������, ������������ ����� ���������������� ��������
Func ChangeSettings()
   If Not FileExists($settingsFile) Then
	  ; ���� �������� �� ����������, ������� ��� � ����������� �� ���������
	  MsgBox(0,"��������","���� �������� " & $settingsFile & "�� ������. ���� ����� ������ � ���������� � ���������� � ����������� �� ���������.")
	  ; ������ � ����������� ��� ������, 5 ���������, � ��� ����� 4 ��������� �� ���� ����-��������
	  Local $aSection[5][2] = [[4, ""],["screendirectory", $screendirectory],["settingsFile", $settingsFile],["onlyActiveWindow", $onlyActiveWindow],["showMouse", $showMouse]]
	  ;ConsoleWrite($settingsFile)
	  IniWriteSection($settingsFile, "Settings", $aSection)
   EndIf
   ; ���� �������� ����������, ��������� ���
   Local $aArray = IniReadSection($settingsFile, "Settings")
   If Not @error Then
	  ; ������ ������ ��� ��������� � �������������� ��������
	  ; ��� ���������� ������ ���� �����������, ����� � ��� ��� ������ �� ������������ WM_NOTIFY � $WM_COMMAND
	  Global $hGUI = GUICreate("��������� ���������", 400, 300)
	  GUISetBkColor(0x00E0FFFF) ; ���� ����
	  Global $hEdit, $hDC, $hBrush, $Item = -1, $SubItem = 0
	  Global $Style = BitOR($WS_CHILD, $WS_VISIBLE, $ES_AUTOHSCROLL, $ES_LEFT)
	  Global $hListView = _GUICtrlListView_Create($hGUI,"�����|��������|��������  ", 5, 5, 390, 290, BitOR($LVS_EDITLABELS, $LVS_REPORT))
	  _GUICtrlListView_SetExtendedListViewStyle($hListView, $LVS_EX_GRIDLINES)
	  ; ---
	  GUISetState(@SW_SHOW)
	  ; ��������� �������� ����������
	  For $iI = 1 To UBound($aArray) - 1
		 _GUICtrlListView_AddItem($hListView, $iI)
		 _GUICtrlListView_AddSubItem($hListView, $iI - 1, $aArray[$iI][0], 1) ; ����
		 _GUICtrlListView_AddSubItem($hListView, $iI - 1, $aArray[$iI][1], 2) ; ��������
	  Next

	  GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	  GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	  ; ���� �������� �������� �����
	  Do
	  Until GUIGetMsg() = $GUI_EVENT_CLOSE
	  ; ��������� ����������������� �������
	  ; ��������� ������ ��� ������ ��������
	  Local $aSection[5][2] = [[4,""]]
	  ; �������� ����� �����
	  $aItems = _GUICtrlListView_GetItemTextArray($hListView)
	  For $i = 0 To $aItems[0]
		 ; ����� �������� � i-� ������
		 $aItems = _GUICtrlListView_GetItemTextArray($hListView,$i)
		 ; ���������� j=1 �������, �.�. ����� ��� �� ����������
		 For $j = 2 To $aItems[0]
			;ConsoleWrite($aItems[$j] & @CRLF)
			$aSection[$i+1][$j-2] = $aItems[$j]
		 Next
	  Next
	  ;_ArrayDisplay($aSection)
	  ; ���������� ����� ��������� � ����
	  IniWriteSection($settingsFile, "Settings", $aSection)
	  GUIDelete()
   EndIf

EndFunc ;==>ChangeSettings

; ���������� ���������, ��������� ��� �������������� �����
Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    Local $tNMHDR, $hWndFrom, $iCode

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = DllStructGetData($tNMHDR, "hWndFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case $hListView
            Switch $iCode
                Case $NM_DBLCLK
                    Local $aHit = _GUICtrlListView_SubItemHitTest($hListView)

                    If ($aHit[0] <> -1) And ($aHit[1] = 0) Then
                        $Item = $aHit[0]
                        $SubItem = 0
                        Local $aRect = _GUICtrlListView_GetItemRect($hListView, $Item)
                    ElseIf ($aHit[0] <> -1) And ($aHit[1] > 0) Then
                        $Item = $aHit[0]
                        $SubItem = $aHit[1]
                        Local $aRect = _GUICtrlListView_GetSubItemRect($hListView, $Item, $SubItem)
                    Else
                        Return $GUI_RUNDEFMSG
                    EndIf

                    Local $iItemText = _GUICtrlListView_GetItemText($hListView, $Item, $SubItem)
                    Local $iLen = _GUICtrlListView_GetStringWidth($hListView, $iItemText)
                    $hEdit = _GUICtrlEdit_Create($hGUI, $iItemText, $aRect[0] + 5, $aRect[1] + 5, $iLen + 15, 17, $Style)

                    _GUICtrlEdit_SetSel($hEdit, 0, -1)
                    _WinAPI_SetFocus($hEdit)
                    $hDC = _WinAPI_GetWindowDC($hEdit)
                    $hBrush = _WinAPI_CreateSolidBrush(0x0000FF)
                    FrameRect($hDC, 0, 0, $iLen + 15, 17, $hBrush)
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
 EndFunc ;==>WM_NOTIFY

; ������� ����� ������ ���� ��������������
 Func FrameRect($hDC, $nLeft, $nTop, $nRight, $nBottom, $hBrush)
    Local $stRect = DllStructCreate("int;int;int;int")

    DllStructSetData($stRect, 1, $nLeft)
    DllStructSetData($stRect, 2, $nTop)
    DllStructSetData($stRect, 3, $nRight)
    DllStructSetData($stRect, 4, $nBottom)

    DllCall("user32.dll", "int", "FrameRect", "hwnd", $hDC, "ptr", DllStructGetPtr($stRect), "hwnd", $hBrush)
 EndFunc ;==>FrameRect

; ���������� ���������, ��������� ��� �������������� �����
 Func WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
    Local $iCode = BitShift($wParam, 16)
    Switch $lParam
        Case $hEdit
            Switch $iCode
                Case $EN_KILLFOCUS
                    Local $iText = _GUICtrlEdit_GetText($hEdit)
                    _GUICtrlListView_SetItemText($hListView, $Item, $iText, $SubItem)
                    _WinAPI_DeleteObject($hBrush)
                    _WinAPI_ReleaseDC($hEdit, $hDC)
                    _WinAPI_DestroyWindow($hEdit)

                    $Item = -1
                    $SubItem = 0
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc ;==>WM_COMMAND

; ���������, ����������� ��� ����������� ������, ��������� ���
Func OnAutoItExit()
    _WinAPI_UnhookWinEvent($hEventHook)
    DllCallbackFree($hEventProc)
EndFunc   ;==>OnAutoItExit

; ���������� ����
Func _EventProc($hEventHook, $iEvent, $hWnd, $iObjectID, $iChildID, $iThreadId, $iEventTime)
    #forceref $hEventHook, $iObjectID, $iChildID, $iThreadId, $iEventTime
	Switch $iEvent
	Case $EVENT_SYSTEM_FOREGROUND
	   ;ConsoleWrite(WinGetTitle($hWnd))
	   If WinGetTitle($hWnd) <> "" And Not StringInStr(WinGetTitle($hWnd),"AutoIt v3") Then
		  $lastWindowHandle = $hWnd
		  ;ConsoleWrite(WinGetTitle($lastWindowHandle) & @CRLF)
	   EndIf
	EndSwitch
EndFunc   ;==>_EventProc

; ������� ��������� �����
Func getDateTimeStamp()
   Return @MDAY & "." & @MON & "." & @YEAR & " " & @HOUR & "_" & @MIN & "_" & @SEC
EndFunc ;==>getDateTimeStamp

; ������� ������������ � Windows ������� �� ����� �����
Func cleanFileName($fname)
   $fname = StringReplace($fname,"\","")
   $fname = StringReplace($fname,"/","")
   $fname = StringReplace($fname,":","")
   $fname = StringReplace($fname,"*","")
   $fname = StringReplace($fname,"?","")
   $fname = StringReplace($fname,'"',"")
   $fname = StringReplace($fname,"<","")
   $fname = StringReplace($fname,">","")
   $fname = StringReplace($fname,"|","")
   $fname = StringReplace($fname,"+","")
   Return $fname
EndFunc ;==>cleanFileName

Func TakeShot()
   ; ��� ����� ������ ������������ �� ������� ��������� ����� � ��������� ��������� ����
   $activeWindow = WinGetHandle($lastWindowHandle)
   ;ConsoleWrite(WinGetTitle($lastWindowHandle) & @CRLF)
   Local $datetime = getDateTimeStamp()
   Local $curwintitle = WinGetTitle($activeWindow)
   Local $fname = "screenshot_" & StringReplace($curwintitle," ","_") & "_" & $datetime
   $fname = cleanFileName($fname)
   ; ���������� ����� ���� ����� �����������, �������� jpg
   $fname = $screendirectory & "\" & $fname & ".jpg"
   ;ConsoleWrite($fname)
   If $onlyActiveWindow Then
	  Local $activeArea = WinGetPos($activeWindow)
	  ConsoleWrite($fname)
	  Sleep(500)
	  _ScreenCapture_Capture($fname,$activeArea[0],$activeArea[1],$activeArea[0] + $activeArea[2], $activeArea[1] + $activeArea[3],$showMouse)
   Else
	  Sleep(500)
	  _ScreenCapture_Capture($fname,0,0,-1,-1,$showMouse)
   EndIf
EndFunc ;==>TakeShot

While True
   $msg = TrayGetMsg()
   If $msg = 0 Then
	  Sleep(1000)
	  ContinueLoop
   ElseIf $msg = $scrpref Then
	  TakeShot()
   ElseIf $msg = $settingspref Then
	  ChangeSettings()
   ElseIf $msg = $aboutpref Then
	  MsgBox(65536,"About","�������, �������� ������ ������ ��� ����������" & @CRLF & "����� - �������� ���������� AKA odexed" & @CRLF & "����� ������ - alecive, http://www.iconarchive.com/artist/alecive.html")
   ElseIf $msg = $exitpref Then
	  ExitLoop
   EndIf
WEnd

