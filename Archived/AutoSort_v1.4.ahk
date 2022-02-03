#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



#Include JSON.ahk



;///////////////////////////////////////;
;	        	Variables	        	;
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

guiName := "AutoSort"
;guiToggle := true

jValue := ""



;///////////////////////////////////////;
;		      Initialization	    	;
;///////////////////////////////////////;

SysGet, Mon, Monitor, 
;MsgBox, Left: %MonLeft% -- Right: %MonRight% -- X: %X% -- Y %Y%

WinGetPos, winX, winY, winW, winH, Path of Exile   ;get dimensions of Path of Exile window for future calcs
;MsgBox, %winW% -- %winH%

startX := floor(winW - (winH * kInv * 12.0 / 5.0 + 16))
startY := floor(winH * kGear)

;just a test, adding elements to the coordinate array
;coor.Push([0, 0])
;coor.Push([1, 0])

;max := coor.MaxIndex()
;MsgBox, %max%

createGUI()
SetTimer, guiChecker, On



;///////////////////////////////////////;
;	        	Auto Sort	        	;
;///////////////////////////////////////;

~^`::
    autoSort := !autoSort

    ;count := 1
    
    if (autoSort == 1) {
        global coor := []
        coor.Push(coorCurrency := [])       ;1
        coor.Push(coorMap := [])            ;2
        coor.Push(coorDivination := [])     ;3
        coor.Push(coorFragment := [])       ;4
        coor.Push(coorEssence := [])        ;5
        coor.Push(coorDelve := [])          ;6
    
        Gui, gui:Show
        retrieve()
    } else {
        Gui, gui:Hide
        
        global count := 1
    }
    ;coor := []

    ;ToolTip, autoSort: %autoSort%
    ;SetTimer, RemoveToolTip, -1000
return



RemoveToolTip:
    ToolTip
return



~^LButton::
    ;MouseGetPos, X, Y, , ,
    ;MsgBox, %X% -- %Y%
    ;coor := coorCurrency
    
    if (autoSort) {
        global type
        mouseMove(type)
    }
return


mouseMove(t) {
    global count
    global startX
    global startY
    global coor
    MouseMove, startX + 26 * (2 * coor[t][count][1] + 1), startY + 26 * (2 * coor[t][count][2] + 1), 10
    count++
    
    if(count > coor[type].MaxIndex()) {
        count := 1
    }
}



retrieve() {
    ToolTip, Retrieving inventory...
    
    jRequest()
    
    global jValue
    obj := JSON.Load(jValue)
    
    checkErr(jValue)
    
    retCount := 1
    while (retCount <= obj.items.MaxIndex()) {
        icon := obj.items[retCount].icon
        typeL := obj.items[retCount].typeLine
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
        
        if (InStr(typeL, "map") > 0) {
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



checkErr(value) {
    if (InStr(value, "error") > 0 && InStr(value, "code") > 0 && InStr(value, "message") > 0 && InStr(value, "forbidden") > 0) {
        ;MsgBox, warning warning
        InputBox, newId, Error, Error retrieving inventory`. Your POESESSID is incorrect`. Please enter the correct one below:, HIDE, , 150, , , 60,
        if (StrLen(newId) > 0) {
            IniWrite, %newId%, POESESSID.ini, Id, poesessid
        }
        
        ;MsgBox, %value%
        jRequest()          ;if there was an error message, JSON request again with the new POESESSID
        
        global jValue
        checkErr(jValue)    ;recursive call to check for error again until there is no error anymore
    }
    return
}



jRequest() {
    IniRead, sessid, POESESSID.ini, Id, poesessid
        
    HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    HttpObj.SetTimeouts(6000,6000,6000,6000) ;Set timeouts to 6 seconds

    ;ToolTip, Getting json entries
    url := "https://pathofexile.com/character-window/get-items?character=IHaveZumbies"
    HttpObj.Open("GET", url)
    HttpObj.SetRequestHeader("Cookie", "POESESSID=" sessid)
    HttpObj.Send()
    sleep 200

    global jValue := HttpObj.ResponseText
    
    ;MsgBox, %jValue%
}



;///////////////////////////////////////;
;	        User Interface	        	;
;///////////////////////////////////////;

createGUI() {
    global guiName
    
    Gui, gui:New, +AlwaysOnTop, %guiName%
    Gui, -MaximizeBox -MinimizeBox
    Gui, Add, Button, h30 w150 gsortCurrency, Currency
    Gui, Add, Button, h30 w150 gsortMap, Map
    Gui, Add, Button, h30 w150 gsortDivination, Divination
    Gui, Add, Button, h30 w150 gsortFragment, Fragment
    Gui, Add, Button, h30 w150 gsortEssence, Essence
    Gui, Add, Button, h30 w150 gsortDelve, Delve
    Gui, Show, AutoSize Center Hide, 

    sortCurrency:
        global type := 1
        WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortMap:
        global type := 2
        WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortDivination:
        global type := 3
        WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortFragment:
        global type := 4
        WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortEssence:
        global type := 5
        WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortDelve:
        global type := 6
        WinActivate, Path of Exile
        ;MsgBox, %type%
    return
}



guiChecker:
    global guiName
    global autoSort
    
    if (!WinActive("Path of Exile") && !WinActive(guiName)) {
        Gui, gui:Hide
        autoSort := false
    }
    
    Sleep 10
return