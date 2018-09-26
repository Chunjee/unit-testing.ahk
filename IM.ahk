;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
;Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Performs Start of Day on the QA systems
; 
The_ProjectName := "MovieDBClone"
The_VersionNumb = 0.3.0

;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
SetBatchLines -1 ;Go as fast as CPU will allow
#NoTrayIcon ;No tray icon
#SingleInstance Force ;Do not allow running more then one instance at a time
ComObjError(False) ; Ignore any http timeouts

;Hide CMD window
DllCall("AllocConsole")
WinHide % "ahk_id " DllCall("GetConsoleWindow", "ptr")


;Dependencies
#Include %A_ScriptDir%\functions
#Include util_misc.ahk
#Include util_arrays.ahk
#Include json.ahk

;Classes
#Include %A_ScriptDir%\classes
#Include Logging.ahk

;For Debug Only
;none

;Modules
#Include %A_ScriptDir%
#Include GUI.ahk


Sb_InstallFiles() ;Install included files and make any directories required
Sb_RemoteShutDown() ;Allows for remote shutdown

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; StartUp
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

;;Creat Logging obj
log := new Log_class(The_ProjectName "-" A_YYYY A_MM A_DD, A_ScriptDir "\LogFiles")
log.maxSizeMBLogFile_Default := 99 ;Set log Max size to 99 MB
log.application := The_ProjectName
log.preEntryString := "%A_NowUTC% -- "
; log.postEntryString := "`r"
log.initalizeNewLogFile(false, The_ProjectName " v" The_VersionNumb " log begins...`n")
log.add(The_ProjectName " launched from user " A_UserName " on the machine " A_ComputerName ". Version: v" The_VersionNumb)

;;Create a blank GUI
GUI()
log.add("GUI launched.")

; Create Excel Object
Excel_obj := ComObjCreate("Excel.Application") ; create Excel Application object
Excel_obj.Visible := false ; make Excel Application invisible
Excel_obj.Workbooks.Open(ExcelPath) ;open an existing file
Excel_obj.ActiveWorkbook.saved := true
Excel_obj.ActiveWorkbook.SaveAs(The_ArchivePath)
; Excel_obj.Workbooks.Add ; create a new workbook (oWorkbook := oExcel.Workbooks.Add)




;Read settings.JSON for global settings
FileRead, The_MemoryFile, % A_ScriptDir "\settings.json"
Settings := JSON.parse(The_MemoryFile)
The_MemoryFile := ""




;Select the appropriot script or default
ReReadFile:
; GuiControl, Text , MainDropdown_List, % scriptdropdowns
LV_Delete() ;clear the listview


;Read the specified JSON file user defined instructions
GuiControlGet, SelectedScript ,, MainDropdown_List, Text
FileRead, The_MemoryFile, %A_ScriptDir%\%SelectedScript%
AllSteps_JSON := JSON.parse(The_MemoryFile)
The_MemoryFile := ""


;;Fill GUI with whats to be done and assign index values to each item
INDEX := 0
for key, value in AllSteps_JSON { ;;- Each step
    INDEX++
    LV_Add(, INDEX, , value.title,"Not Started")

    machinenames := ""
    for key2, value2 in value.machines { ;;- Each machine
        machinenames := machinenames . value2 . " "
        ; msgbox, % AllSteps_JSON[key]
        ; LV_Modify(INDEX,,value2,,,)

        ; s .= key "=" value "`n"
        ; msgbox, %key2% %value2%. %A_Index%
    }
}
;resize columns to fit all text
LV_ModifyCol()


if (AutoMode = False) {
    log.add(The_ProjectName " was launched with a without a commandline argument. Waiting for user input")
    Return ;Require user to press start if not in auto mode
}
log.add(The_ProjectName " was launched with a commandline argument and will attempt running '" CL_Arg1 "' if it exists")



;; Process each step after user presses Start
Start:
;Grab the selected script
GuiControlGet, OutputVar ,, MainDropdown_List, Text
INDEX := 0
log.add(The_ProjectName " Running " SelectedScript " with the " A_UserName " credentials from " A_ComputerName)
;;Create new Remote_Control class
RemoteControl := New RemoteControl_Class("TOP")

for key, value in AllItems_JSON { ; - Each step
INDEX++
LV_Modify(INDEX,,,,,"IN PROGRESS")
    ;REBOOT
    if (value.action = "reboot_machines") {
        log.add("Rebooting the following machines: " JSON.stringify(value.machines))
        RemoteControl.setMachines(value)
        success_bool := RemoteControl.restartMachines(value)
    }

    ;SERVICE
    if (value.action = "restart_service") {
        log.add("Restarting the service '" value.service "' on the following machines: " JSON.stringify(value.machines))
        RemoteControl.setMachines(value)
        success_bool := RemoteControl.restartService(value)
    }
    if (value.action = "verify_service") {
        log.add("Verifying the service '" value.service "' on the following machines: " JSON.stringify(value.machines))
        RemoteControl.setMachines(value)
        success_bool := RemoteControl.verifyService(value)
    }
    

    ;APP POOL
    if (value.action = "restart_apppool") {
        log.add("Restarting the apppool '" value.apppool "' on the following machines: " JSON.stringify(value.machines))
        RemoteControl.setMachines(value)
        success_bool := RemoteControl.restartAppPool(value)
    }
    if (value.action = "check_machines_are_on") {
        log.add("Checking for responsiveness on the following machines: " JSON.stringify(value.machines))
        RemoteControl.setMachines(value)
        success_bool := RemoteControl.checkMachinesAreOn(value)
    }
    
    ;MISC
    if (value.action = "wait") {
        log.add("Waiting " value.wait " mins before proceeding")
        success_bool := RemoteControl.wait(value)
    }

    ;; update GUI if successful
    if (success_bool) {
        LV_Modify(INDEX,,,,,"Completed")
    }
    
    ; for key2, value2 in value.machines { ;;- Each machine
    ;     INDEX++
    ; }
    sleep 500
}
Return

;/--\--/--\--/--\--/--\--/--\
; Subroutines
;\--/--\--/--\--/--\--/--\--/

;Create Directory and install needed file(s)
Sb_InstallFiles()
{
    FileCreateDir, %A_ScriptDir%\data\
}
