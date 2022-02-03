#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include JSON.ahk


;///////////////////////////////////////;
;		Variables		;
;///////////////////////////////////////;

autoSort := false
type := 6

;countX := 0
;countY := 0
count := 1

coor := []
coor.Push(coorCurrency := [])       ;1
coor.Push(coorMap := [])            ;2
coor.Push(coorDivination := [])     ;3
coor.Push(coorFragment := [])       ;4
coor.Push(coorEssence := [])        ;5
coor.Push(coorDelve := [])          ;6
;MsgBox % coor[1][1]
;MsgBox % (testest := "currency\/currency")

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
;coor.Push([0, 0])
;coor.Push([1, 0])

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
    ;coor := []

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
    ;coor := coorCurrency
    
    if (autoSort) {
        global type
        MouseMove, startX + 26 * (2 * coor[type][count][1] + 1), startY + 26 * (2 * coor[type][count][2] + 1)
        count++

        if(count > coor[type].MaxIndex()) {
            count := 1
        }
    }
return



~^RButton::   ;JSON Request, search for "https:\/\/web.poecdn.com\/image\/Art\/2DItems\/Currency" for currency items
    Retrieve()
return



Retrieve() {
    ToolTip, Retrieving inventory...
    
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
    obj := JSON.Load(HttpObj.ResponseText)

    ;ListVars

    ;MsgBox, %value%
    ;MsgBox % (testestes := "currency\/currency")

    if (InStr(value, "error") > 0 & InStr(value, "code") > 0 & InStr(value, "message") > 0 & InStr(value, "forbidden") > 0) {
        ;MsgBox, warning warning
        InputBox, newId, Error, Error retrieving inventory`. Your POESESSID might have changed`. Please enter the new one below:, HIDE, , 150, , , 60,
        if (StrLen(newId) > 0) {
            IniWrite, %newId%, POESESSID.ini, Id, poesessid
        }
    }
    
    retCount := 1
    while (retCount <= obj.items.MaxIndex()) {
        icon := obj.items[retCount].icon
        ;MsgBox, %retCount%
        ;MsgBox, %icon%
        ;MsgBox % (var := obj.items[retCount].icon)
        ;MsgBox % (var := obj.items[retCount].x) 		
        ;MsgBox % (var := obj.items[retCount].y)
        ;test := obj.items[retCount].x + obj.items[retCount].y
        ;MsgBox, %test%
        ;MsgBox % InStr(icon, "currency")
        cX := obj.items[retCount].x
        cY := obj.items[retCount].y
        
        global coor
        global type
        
        if (InStr(icon, "maps/atlas2maps") > 0) {
            coor[2].Push([cX, cY])
        } else if (InStr(icon, "maps") > 0 || InStr(icon, "scarabs") > 0 || InStr(icon, "breach") > 0) {   ;fragments have a lot of variety
            coor[4].Push([cX, cY])
        } else if (InStr(icon, "divination") > 0) {
            coor[3].Push([cX, cY])
        } else if (InStr(icon, "essence") > 0) {
            coor[5].Push([cX, cY])
        } else if (InStr(icon, "delve") > 0) {
            coor[6].Push([cX, cY])
        } else if (InStr(icon, "currency") > 0) {  ;have to sort currency last because of naming inconsistencies
            coor[1].Push([cX, cY])
        }

        retCount++
    }
    
    num := obj.items.MaxIndex()
    Tooltip, %num% items found
    SetTimer, RemoveToolTip, -2000
}