#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



;///////////////////////////////////////;
;	        	Ctrl Scroll	          	;
;///////////////////////////////////////;

SysGet, Mon, Monitor, 

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