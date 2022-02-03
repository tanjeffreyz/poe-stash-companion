#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



#Include JSON.ahk



;///////////////////////////////////////;
;	        	Variables	        	;
;///////////////////////////////////////;

autoSort := false
autoId := false
type := 2
;MyEdit := ""

;countX := 0
;countY := 0
count := 1
stupidCount := 0

coor := []
resetCoor()
/*
coor.Push(coorUnid := [])           ;1
coor.Push(coorCurrency := [])       ;2
coor.Push(coorMap := [])            ;3
coor.Push(coorDivination := [])     ;4
coor.Push(coorFragment := [])       ;5
coor.Push(coorEssence := [])        ;6
coor.Push(coorDelve := [])          ;7
*/
;MsgBox % coor[1][1]
;MsgBox % (testest := "currency\/currency")

kGear := 0.5435185185 * 1.005
kInv := 0.2435785327

guiName := "AutoSort"
;guiId := ""
;guiToggle := true

jValue := ""

ignor := []
ignor.Push([0,0])
ignor.Push([0,1])



;///////////////////////////////////////;
;		      Initialization	    	;
;///////////////////////////////////////;

SysGet, Mon, Monitor, 
;MsgBox, Left: %MonLeft% -- Right: %MonRight% -- X: %X% -- Y %Y%

WinGetPos, winX, winY, winW, winH, Path of Exile   ;get dimensions of Path of Exile window for future calcs
;MsgBox, %winW% -- %winH%

;startX := floor(winW - (winH * kInv * 12.0 / 5.0 + 16))    ;for full screen
;startY := floor(winH * kGear)
;scale := 26

startX := floor(winW - (winH * kInv * 12.0 / 5.0 + 16) + 15)     ;for windowed
startY := floor(winH * kGear + 9)
scale := 24.5

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

RemoveToolTip:
    ToolTip
return



~^`::
    autoSort := !autoSort

    ;count := 1
    
    if (autoSort == 1) {
        /*
        global coor := []
        coor.Push(coorUnid := [])           ;1
        coor.Push(coorCurrency := [])       ;2
        coor.Push(coorMap := [])            ;3
        coor.Push(coorDivination := [])     ;4
        coor.Push(coorFragment := [])       ;5
        coor.Push(coorEssence := [])        ;6
        coor.Push(coorDelve := [])          ;7
        */
        global type := 2
        resetCoor()
    
        Gui, gui:Show
        WinActivate, Path of Exile
        retrieve()
    } else {
        Gui, gui:Hide
        autoId := false     ;turn off auto identification as well
        ;ToolTip, Automatic Sorting: %autoSort%
        ;SetTimer, RemoveToolTip, -1000
        
        global count := 1
    }
    ;coor := []

    ;ToolTip, autoSort: %autoSort%
    ;SetTimer, RemoveToolTip, -1000
return


/*
~+`::
    autoId := !autoId
    ToolTip, Automatic Identification: %autoId%
    SetTimer, RemoveToolTip, -1000
return
*/


~+LButton::
    if (autoId) {
        mouseMove(1)
    }
return



~^LButton::     ;AutoSort is ctrl + left mouse button
    ;MouseGetPos, X, Y, , ,
    ;MsgBox, %X% -- %Y%
    ;coor := coorCurrency
    
    if (autoSort) {
        global type
        mouseMove(type)
    }
return



;///////////////////////////////////////;
;	        	Functions	        	;
;///////////////////////////////////////;

resetCoor() {
    global coor := []
    coor.Push(coorUnid := [])           ;1
    coor.Push(coorCurrency := [])       ;2
    coor.Push(coorMap := [])            ;3
    coor.Push(coorDivination := [])     ;4
    coor.Push(coorFragment := [])       ;5
    coor.Push(coorEssence := [])        ;6
    coor.Push(coorDelve := [])          ;7
}



mouseMove(t) {
    global count
    global startX
    global startY
    global coor
    global scale
    
    if(count > coor[t].MaxIndex()) {
        count := 1
    }
    
    ;MouseMove, startX, startY, 
    MouseMove, startX + scale * (2 * coor[t][count][1] + 1), startY + scale * (2 * coor[t][count][2] + 1), 100
    count++
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
        unid := obj.items[retCount].identified
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
        
        global ignor
        ind := ignor.MaxIndex()
        ;MsgBox, %ind%
        Loop, %ind% {
            ;MsgBox, %A_Index%
            
            if (cX == ignor[A_Index][1] && cY == ignor[A_Index][2]) {
                ;MsgBox, found at %A_Index% -- %retCount%
                retCount++      ;make up for the retCount++ that is skipped
                Continue, 2
                ;Break
            }
            
        }
        
        global coor
        global type
        
        if (!unid) {
            coor[1].Push([cX, cY])
            ;MsgBox, % coor[1].MaxIndex()
        }
        
        if (InStr(typeL, "map") > 0) {
            coor[3].Push([cX, cY])
        } else if (InStr(icon, "maps") > 0 || InStr(icon, "scarabs") > 0 || InStr(icon, "breach") > 0) {   ;fragments have a lot of variety
            coor[5].Push([cX, cY])
        } else if (InStr(icon, "divination") > 0) {
            coor[4].Push([cX, cY])
        } else if (InStr(icon, "essence") > 0) {
            coor[6].Push([cX, cY])
        } else if (InStr(icon, "delve") > 0) {
            coor[7].Push([cX, cY])
        } else if (InStr(icon, "currency") > 0) {  ;have to sort currency last because of naming inconsistencies
            coor[2].Push([cX, cY])
        }

        retCount++
    }
    
    num := obj.items.MaxIndex()
    Tooltip, %num% items found
    SetTimer, RemoveToolTip, -1000
}



checkErr(value) {
    if (InStr(value, "error") > 0 && InStr(value, "code") > 0 && InStr(value, "message") > 0 && InStr(value, "forbidden") > 0) {
        ;MsgBox, warning warning
        InputBox, newId, Error, Error retrieving inventory`. Your POESESSID is incorrect`. Please enter the correct one below:, HIDE, , 150, , , 60,
        if (StrLen(newId) > 0) {
            IniWrite, %newId%, Config.ini, Vars, poesessid
        }
        
        ;MsgBox, %value%
        jRequest()          ;if there was an error message, JSON request again with the new POESESSID
        
        global jValue
        checkErr(jValue)    ;recursive call to check for error again until there is no error anymore
    }
    return
}



jRequest() {
    IniRead, sessid, Config.ini, Vars, poesessid
    IniRead, username, Config.ini, Vars, user
        
    HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    HttpObj.SetTimeouts(6000,6000,6000,6000) ;Set timeouts to 6 seconds

    ;ToolTip, Getting json entries
    url := "https://pathofexile.com/character-window/get-items?character=" username
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
    ;global guiId
    ;global MyEdit
    
    Gui, gui:New, +AlwaysOnTop, %guiName%
    Gui, -MaximizeBox -MinimizeBox
    ;Gui, Add, Edit, vMyEdit, 
    Gui, Add, Button, h30 w150 gchangeChar, CHANGE CHARACTER
    Gui, Add, Button, h30 w150 gsortCurrency, Currency
    Gui, Add, Button, h30 w150 gsortMap, Map
    Gui, Add, Button, h30 w150 gsortDivination, Divination
    Gui, Add, Button, h30 w150 gsortFragment, Fragment
    Gui, Add, Button, h30 w150 gsortEssence, Essence
    Gui, Add, Button, h30 w150 gsortDelve, Delve
    Gui, Show, AutoSize Center Hide, 

    changeChar:
        global stupidCount
        if(stupidCount > 0) {
            changeCharacter()
        }
        stupidCount++
    return

    sortCurrency:
        global type := 2
        ;WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortMap:
        global type := 3
        ;WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortDivination:
        global type := 4
        ;WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortFragment:
        global type := 5
        ;WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortEssence:
        global type := 6
        ;WinActivate, Path of Exile
        ;MsgBox, %type%
    return

    sortDelve:
        global type := 7
        ;WinActivate, Path of Exile
        ;MsgBox, %type%
    return
}



changeCharacter() {
    IniRead, prevUser, Config.ini, Vars, user
    
    InputBox, charName, CHANGE CHARACTER, Please enter the name of your current character below:, , , 125, , , , , %prevUser%
    if (StrLen(charName) > 0) {
            IniWrite, %charName%, Config.ini, Vars, user
    }
}



guiChecker:
    global guiName
    global autoSort
    ;global guiId
    
    ;MouseGetPos, , , winId, 
    ;WinGetTitle, winTitle, ahk_id %winId%
    ;WinGetTitle, guiTitle, ahk_id %guiId%
    ;MsgBox, %guiTitle%
    leftM := GetKeyState("LButton")
    
    if (!WinActive("Path of Exile") && !WinActive(guiName)) {
        Gui, gui:Hide
        autoSort := false
    } else if (winActive(guiName) && WinExist(Path of Exile) && autoSort && leftM == 0) {
        ;Sleep 100
        WinActivate, Path of Exile
    }
    
    Sleep 10
return