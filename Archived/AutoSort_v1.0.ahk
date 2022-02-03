#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#Include JSON.ahk
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



;///////////////////////////////////////;
;		Variables		;
;///////////////////////////////////////;

autoSort = false;

;countX := 0
;countY := 0
count := 1
coor := []

kGear := 0.5435185185 * 1.005
kInv := 0.2435785327



;///////////////////////////////////////;
;		Initialization		;
;///////////////////////////////////////;

SysGet, Mon, Monitor, 
;MsgBox, Left: %MonLeft% -- Right: %MonRight% -- X: %X% -- Y %Y%

WinGetPos, winX, winY, winW, winH, Path of Exile   ;get dimensions of Path of Exile window for future calcs`
;MsgBox, %winW% -- %winH%

startX := floor(winW - (winH * kInv * 12.0 / 5.0 + 16))
startY := floor(winH * kGear)

;just a test, adding elements to the coordinate array
coor.Push([0, 0])
coor.Push([1, 0])

;max := coor.MaxIndex()
;MsgBox, %max%



;///////////////////////////////////////;
;		Ctrl Scroll		;
;///////////////////////////////////////;

~^Wheelup::
MouseGetPos, X, Y, , ,
if (X > (MonLeft + MonRight) / 2) {
	Send {Left}
}
return

~^Wheeldown::
MouseGetPos, X, Y, , ,
if (X > (MonLeft + MonRight) / 2) {
	Send {Right}
}
return



;///////////////////////////////////////;
;		Auto Sort		;
;///////////////////////////////////////;

~`::
autoSort := !autoSort
count := 1
ToolTip, autoSort: %autoSort%
SetTimer, RemoveToolTip, -1000
return



RemoveToolTip:
ToolTip
return



~LButton::   ;reset any sorting variables
count := 1
return



~^LButton::
;MouseGetPos, X, Y, , ,
;MsgBox, %X% -- %Y%
if (autoSort) {
	MouseMove, startX + 26 * (2 * coor[count][1] + 1), startY + 26 * (2 * coor[count][2] + 1)
	count++

	if(count > coor.MaxIndex()) {
		count := 1
	}
}
return



~^RButton::   ;JSON Request, search for "https:\/\/web.poecdn.com\/image\/Art\/2DItems\/Currency" for currency items
Retrieve()
return



Retrieve() {
IniRead, sessid, POESESSID.ini, Id, poesessid
	
HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
HttpObj.SetTimeouts(6000,6000,6000,6000) ;Set timeouts to 6 seconds

;ToolTip, Getting json entries
url := "https://pathofexile.com/character-window/get-items?character=IHaveZumbies"
HttpObj.Open("GET", url)
HttpObj.SetRequestHeader("Cookie", "POESESSID=" sessid)
HttpObj.Send()
sleep 200

value := HttpObj.ResponseText
MsgBox, %value%

if (InStr(value, "error") > 0 & InStr(value, "code") > 0 & InStr(value, "message") > 0 & InStr(value, "forbidden") > 0) {
	;MsgBox, warning warning
	InputBox, newId, Error, Error retrieving inventory`. Your POESESSID might have changed`. Please enter the new one below:, HIDE, , 150, , , 60,
	if (StrLen(newId) > 0) {
		IniWrite, %newId%, POESESSID.ini, Id, poesessid
	}
}

;IniRead, test1231, POESESSID.ini, Id, poesessid
;MsgBox, %test1231%
}