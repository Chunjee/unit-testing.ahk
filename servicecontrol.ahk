; Get-WmiObject Win32_NetworkConnection -NJAOPSSVC01 sbs01 | select user, pass

Class RemoteControl_Class {
	
	__New(para_Name) {
		global log

		this.log := log
		this.Info_Array := []
		this.Label := para_Name
		this.maxattempts := 20
		X := 0
	}
	

	setMachines(para_object) {
		this.Info_Array := [] ;clear the old object
		loop, % para_object.machines.MaxIndex() {
			this.Info_Array[A_Index,"machine"] := para_object.machines[A_Index]
		}
		; Array_GUI(this.Info_Array)
	}


	checkMachinesAreOn(para_object) {
		doneflag := 0
		while (doneflag != 1) {
			loop, % this.Info_Array.MaxIndex() {
				ps_TestOn := "Test-Connection -Computername """ this.Info_Array[A_Index,"machine"] """ -BufferSize 16 -Count 1"
				RunWait PowerShell.exe -Command &{%ps_TestOn%},, hide
				;ErrorLevel will be set to the program's exit code
				this.Info_Array[A_Index,"runningstatus"] := ErrorLevel
				; if (this.Info_Array[A_Index,"runningstatus"] != "1") {
					
				; }
				if (Fn_MultiArray_FieldAre(this.Info_Array,"runningstatus","0")) {
					doneflag := 1
				}
			}
		}
		return true
	}


	restartMachines(para_object) {
		doneflag := 0
		;Keep trying to restart the computer till success is encountered
		loop, % this.Info_Array.MaxIndex() {
			if (this.Info_Array[A_Index,"returncode"] != "0") {
				this.log.add("Attempting remote restart on the following machine: " this.Info_Array[A_Index,"machine"])
				ps_RestartScript := "Restart-Computer -ComputerName """ this.Info_Array[A_Index,"machine"] """ -Force"
				RunWait PowerShell.exe -Command &{%ps_RestartScript%},, hide
				;ErrorLevel will be set to the program's exit code
				this.Info_Array[A_Index,"returncode"] := ErrorLevel
			}
		}
		sleep, 360000 ;wait [6] mins for windows to shutting down sequence

		;Keep checking all systems till they are accessible again
		doneflag := 0
		while (doneflag != 1) {
			loop, % this.Info_Array.MaxIndex() {
				this.log.add("Checking for response from: " this.Info_Array[A_Index,"machine"])
				ps_TestOn := "Test-Connection -Computername """ this.Info_Array[A_Index,"machine"] """ -BufferSize 16 -Count 1"
				RunWait PowerShell.exe -Command &{%ps_TestOn%},, hide
				;ErrorLevel will be set to the program's exit code
				this.Info_Array[A_Index,"runningstatus"] := ErrorLevel
				; if (this.Info_Array[A_Index,"runningstatus"] != "1") {
					
				; }
				if (Fn_MultiArray_FieldAre(this.Info_Array,"runningstatus","0")) {
					doneflag := 1
				}
			}
		}
		return true
	}


	restartService(para_object) {
		;Get-Service -Name $ServiceName | Stop-Service -ErrorAction SilentlyContinue
		doneflag := 0
		attempts := 0
		while (doneflag != 1) {
			attempts++
			loop, % this.Info_Array.MaxIndex() {
				if (this.Info_Array[A_Index,"stopsuccess"] != "1") {
					this.log.add("Attempting service control on : " para_object.service " on the machine: " this.Info_Array[A_Index,"machine"])
					ps_StopService := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Get-Service -Name """ para_object.service """ | Stop-Service }"
					Fn_StdOutToVar("powershell " ps_StopService) ;Response is BLANK so we don't save

					ps_CheckService := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Get-Service -Name """ para_object.service """ }"
					this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_CheckService)
					this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG")
					
					if (InStr(this.Info_Array[A_Index,"powershelloutput"], "Stopped")) {
						this.Info_Array[A_Index,"stopsuccess"] := "1"
					} else {
						this.Info_Array[A_Index,"stopsuccess"] := "0"
					}


					if (Fn_MultiArray_FieldAre(this.Info_Array,"stopsuccess","1")) {
						doneflag := 1
					}
					;quit after max attempts
					if (attempts > this.maxattempts) {
						this.log.add("Exceeded attempts to stop " para_object.service " on " this.Info_Array[A_Index,"machine"] ". Moving on. Machine could be off or decomissioned,  review and remove from config if needed.", "WARN")
						this.Info_Array[A_Index,"stopsuccess"] := "0"
						this.log.add(this.Info_Array,"DEBUG")
						doneflag := 1
					}
				}
			}
		}
		Sleep, 6000 ; leave the service not running for [6] seconds

		doneflag := 0
		attempts := 0
		while (doneflag != 1) {
			attempts++
			loop, % this.Info_Array.MaxIndex() {
				if (this.Info_Array[A_Index,"startsuccess"] != "1") {
					this.log.add("Sending start service script to " this.Info_Array[A_Index,"machine"])
					ps_StartService := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Get-Service -Name """ para_object.service """ | Start-Service }"
					Fn_StdOutToVar("powershell " ps_StartService) ;Response is BLANK so we don't save
					
					this.log.add("Checking the status of " para_object.service " on " this.Info_Array[A_Index,"machine"])
					ps_CheckService := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Get-Service -Name """ para_object.service """ }"
					this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_CheckService)
					this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG")

					if (InStr(this.Info_Array[A_Index,"powershelloutput"], "Running")) {
						this.Info_Array[A_Index,"startsuccess"] := "1"
					} else {
						this.Info_Array[A_Index,"startsuccess"] := "0"
					}


					if (Fn_MultiArray_FieldAre(this.Info_Array,"startsuccess","1")) {
						doneflag := 1
					}
					;quit after max attempts
					if (attempts > this.maxattempts) {
						this.log.add("Exceeded max attempts to start " para_object.service " on " this.Info_Array[A_Index,"machine"] ". Moving on. Machine could be off or decomissioned,  review and remove from config if needed.", "WARN")
						this.Info_Array[A_Index,"startsuccess"] := "0"
						this.log.add(this.Info_Array,"DEBUG")
						doneflag := 1
					}
				}
			}
		}
		;Verify service is still running if user specified "verifytime"
		if(para_object.verifytime) {
			sleep, % para_object.verifytime * 1000 * 60
			this.verifyService(para_object)
		}
		return true
	}


	verifyService(para_object) {
		;; NOTE: this.Info_Array may not be cleared before running this so fields should be unique
		doneflag := 0
		attempts := 0
		while (doneflag != 1) {
			sleep, 2000 ;wait 2 second between attempts
			attempts++
			loop, % this.Info_Array.MaxIndex() {
				if (this.Info_Array[A_Index,"verifiedrunning"] != "1") {
					ps_VerifyService := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Get-Service -Name """ para_object.service """ }"
					this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_VerifyService)
					this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG")

					; check if StdOut says service is still running
					if (InStr(this.Info_Array[A_Index,"powershelloutput"],"Running")) {
						this.Info_Array[A_Index,"verifiedrunning"] := "1"
					} else {
						this.log.add("FAILED to verify " para_object.service " is running on " this.Info_Array[A_Index,"machine"] ", retrying...")
						; Run Start script again (note ps_StartService)
						ps_StartService := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Get-Service -Name """ para_object.service """ | Start-Service }"
						this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_StartService)
						this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG")
					}


					;set doneflag to 1 if every machine verified with success
					if (Fn_MultiArray_FieldAre(this.Info_Array,"verifiedrunning","1")) {
						doneflag := 1
					}
					;quit after max attempts
					if (attempts > this.maxattempts) {
						this.log.add("Exceeded attempts verifying " para_object.service " on " this.Info_Array[A_Index,"machine"] ". Moving on. Machine could be off or decomissioned,  review and remove from config if needed.", "WARN")
						this.Info_Array[A_Index,"verifiedrunning"] := "0"
						this.log.add(this.Info_Array,"DEBUG")
						doneflag := 1
					}
				}
			}
		}
		return true
	}


	restartAppPool(para_object) {
		doneflag := 0
		attempts := 0
		while (doneflag != 1) {
			loop, % this.Info_Array.MaxIndex() {
				attempts++
				if (this.Info_Array[A_Index,"stopsuccess"] != "1") {
					ps_StopAppPool := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Import-Module WebAdministration; Stop-WebAppPool -Name """ para_object.apppool """ }"
					this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_StopAppPool) ;Object on target path is already stopped.\r\n    + CategoryInfo          : InvalidOperation: (:) [Stop-WebAppPool], Invalid \r\n   OperationException\r\n    + FullyQualifiedErrorId : InvalidOperation,Microsoft.IIs.PowerShell.Provid \r\n   er.StopAppPoolCommand\r\n \r\n
					this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG")

					;Get-WebAppPoolState
					ps_CheckAppPool := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Import-Module WebAdministration; Get-WebAppPoolState -Name """ para_object.apppool """ }"
					this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_CheckAppPool)
					this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG")
					if (InStr(this.Info_Array[A_Index,"powershelloutput"],"Stopped")) {
						this.Info_Array[A_Index,"stopsuccess"] := "1"
					}


					if (Fn_MultiArray_FieldAre(this.Info_Array,"stopsuccess","1")) {
						doneflag := 1
					}
					;quit after max attempts
					if (attempts > this.maxattempts) {
						this.log.add("Exceeded attempts verifying " para_object.service " on " this.Info_Array[A_Index,"machine"] ". Moving on. Machine could be off or decomissioned,  review and remove from config if needed.", "WARN")
						this.Info_Array[A_Index,"verifiedrunning"] := "0"
						this.log.add(this.Info_Array,"DEBUG")
						doneflag := 1
					}
				}
			}
		}
		Sleep, 6000 ;Let the App pool stay off completely for [6] seconds
		;Do the same thing but this time we turn the service back on
		doneflag := 0
		attempts := 0
		while (doneflag != 1) {
			loop, % this.Info_Array.MaxIndex() {
				attempts++
				if (this.Info_Array[A_Index,"startsuccess"] != "1") {
					ps_StartAppPool := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Import-Module WebAdministration; Start-WebAppPool -Name """ para_object.apppool """ }"
					this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_StartAppPool)
					this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG")

					ps_CheckAppPool := "Invoke-Command -ComputerName """ this.Info_Array[A_Index,"machine"] """ -ScriptBlock { Import-Module WebAdministration; Get-WebAppPoolState -Name """ para_object.apppool """ }"
					this.Info_Array[A_Index,"powershelloutput"] := Fn_StdOutToVar("powershell " ps_CheckAppPool)
					this.log.add(this.Info_Array[A_Index,"powershelloutput"],"DEBUG2")
					if (InStr(this.Info_Array[A_Index,"powershelloutput"],"Running")) {
						this.Info_Array[A_Index,"startsuccess"] := "1"
					}
					
					if (Fn_MultiArray_FieldAre(this.Info_Array,"startscript","0")) {
						doneflag := 1
					}
					;quit after max attempts
					if (attempts > this.maxattempts) {
						this.log.add("Exceeded attempts to start AppPool " para_object.apppool " on " this.Info_Array[A_Index,"machine"] ". Moving on. Machine could be off or decomissioned,  review and remove from config if needed.", "WARN")
						this.Info_Array[A_Index,"startsuccess"] := "0"
						this.log.add(this.Info_Array,"DEBUG")
						doneflag := 1
					}
				}
			}
		}
		;return success
		return true
	}


	wait(para_object) {
		Sleep, % para_object.wait * 60 * 1000
		return true
	}	
}


Fn_ExecutePowerShell(para_Command)
{	;Returns StdOut text

	;Open cmd.exe with echoing of commands disabled
	shell := ComObjCreate("WScript.Shell")
	
	;Send the commands to execute, separated by newline
	exec := shell.Exec(ComSpec " /Q echo on")
	commands := " powershell.exe " . para_Command
	
	;Always exit at the end!
	exec.StdIn.WriteLine(commands "`nexit")  
	
	;Read and return the output of all commands
	return % exec.StdOut.ReadAll()
}



Fn_ParseServiceResponse(para_Reponse)
{
	ServiceStatus := Fn_QuickRegEx(para_Reponse,"STATE\s+: (\d+)")

	If (ServiceStatus != "null") {
		Return %ServiceStatus%
	}
	Return "000"

	/*
	If (ServiceStatus = 1) {
		Return "Stopped"
	}
	If (ServiceStatus = 2) {
		Return "Start Pending"
	}
	If (ServiceStatus = 3) {
		Return "Stop Pending"
	}
	If (ServiceStatus = 4) {
		Return "Running"
	}
	Return "Not Understood"
	*/
}


Fn_ServiceResponseHumanReadable(para_Reponse)
{
	If (para_Reponse = 1) {
		Return "Stopped"
	}
	If (para_Reponse = 2) {
		Return "Start Pending"
	}
	If (para_Reponse = 3) {
		Return "Stop Pending"
	}
	If (para_Reponse = 4) {
		Return "Running"
	}

	If (para_Reponse = 000) {
		Return "Query UnSuccessful"
	}

	Return "Not Understood"
}



Fn_StdOutToVar(cmd) {
	DllCall("CreatePipe", "PtrP", hReadPipe, "PtrP", hWritePipe, "Ptr", 0, "UInt", 0)
	DllCall("SetHandleInformation", "Ptr", hWritePipe, "UInt", 1, "UInt", 1)

	VarSetCapacity(PROCESS_INFORMATION, (A_PtrSize == 4 ? 16 : 24), 0)    ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms684873(v=vs.85).aspx
	cbSize := VarSetCapacity(STARTUPINFO, (A_PtrSize == 4 ? 68 : 104), 0) ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms686331(v=vs.85).aspx
	NumPut(cbSize, STARTUPINFO, 0, "UInt")                                ; cbSize
	NumPut(0x100, STARTUPINFO, (A_PtrSize == 4 ? 44 : 60), "UInt")        ; dwFlags
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 60 : 88), "Ptr")    ; hStdOutput
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 64 : 96), "Ptr")    ; hStdError
	
	if !DllCall(
	(Join Q C
		"CreateProcess",             ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms682425(v=vs.85).aspx
		"Ptr",  0,                   ; lpApplicationName
		"Ptr",  &cmd,                ; lpCommandLine
		"Ptr",  0,                   ; lpProcessAttributes
		"Ptr",  0,                   ; lpThreadAttributes
		"UInt", true,                ; bInheritHandles
		"UInt", 0x08000000,          ; dwCreationFlags
		"Ptr",  0,                   ; lpEnvironment
		"Ptr",  0,                   ; lpCurrentDirectory
		"Ptr",  &STARTUPINFO,        ; lpStartupInfo
		"Ptr",  &PROCESS_INFORMATION ; lpProcessInformation
	)) {
		DllCall("CloseHandle", "Ptr", hWritePipe)
		DllCall("CloseHandle", "Ptr", hReadPipe)
		return ""
	}

	DllCall("CloseHandle", "Ptr", hWritePipe)
	VarSetCapacity(buffer, 4096, 0)
	while DllCall("ReadFile", "Ptr", hReadPipe, "Ptr", &buffer, "UInt", 4096, "UIntP", dwRead, "Ptr", 0)
		sOutput .= StrGet(&buffer, dwRead, "CP0")

	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, 0))         ; hProcess
	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize)) ; hThread
	DllCall("CloseHandle", "Ptr", hReadPipe)
	return sOutput
}
