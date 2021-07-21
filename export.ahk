class unittesting {

	__New() {
		this.testTotal := 0
		this.failTotal := 0
		this.successTotal := 0

		this.log := []

		this.groupVar := ""
		this.labelVar := ""
		this.lastlabel := ""

		this.logresult_dir := A_ScriptDir "\result.tests.log"
	}


	test(param_actual:="_Missing_Parameter_", param_expected:="_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; prepare
		if (IsObject(param_actual)) {
			param_actual := this._print(param_actual)
		}
		if (IsObject(param_expected)) {
			param_expected := this._print(param_expected)
		}

		; create
		this.testTotal++
		if (param_actual != param_expected) {
			this._logTestFail(param_actual, param_expected)
			return false
		} else {
			this.successTotal++
			return true

		}
	}

	_logTestFail(param_actual, param_expected, param_msg:="") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		this.failTotal++
		if (this.labelVar != this.lastlabel) {
			this.lastlabel := this.labelVar
			if (this.groupVar) {
				this.log.push("`n== " this.groupVar " - " this.labelVar " ==`n")
			} else {
				this.log.push("`n== " this.labelVar " ==`n")
			}
		}
		this.log.push("Test Number: " this.testTotal "`n")
		this.log.push("Expected: " param_expected "`n")
		this.log.push("Actual: " param_actual "`n")
		if (param_msg != "") {
			this.log.push(param_msg "`n")
		}
		this.log.push("`n")
	}


	true(param_actual:="_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		if (param_actual == true) {
			this.test("true", "true")
			return true
		}
		if (param_actual == false){
			this.test("false", "true")
			return false
		}
		this.test(param_actual, "true")
		return false
	}


	false(param_actual:="_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		if (param_actual == false) {
			this.test("false", "false")
			return true
		}
		if (param_actual == true){
			this.test("true", "false")
			return false
		}
		this.test(param_actual, "true")
		return false
	}


	equal(param_actual:="_Missing_Parameter_", param_expected:="_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; create
		return this.test(param_actual, param_expected)
	}


	notEqual(param_actual:="_Missing_Parameter_", param_expected:="_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; prepare
		param_actual := this._print(param_actual)
		param_expected := this._print(param_expected)

		; create
		this.testTotal += 1
		if (param_actual != param_expected) {
			this.successTotal++
			return true
		} else {
			this._logTestFail(param_actual, param_expected, "They were Expected to be DIFFERENT")

			return false
		}
	}

	label(param) {
		if (A_IsCompiled) {
			return 0
		}

		this.labelVar := param
		return
	}

	group(param) {
		if (A_IsCompiled) {
			return 0
		}

		this.groupVar := param
		this.labelVar := ""
		return
	}


	report() {
		if (A_IsCompiled) {
			return 0
		}

		msgbox, % this._buildReport()
		return true
	}


	fullReport() {
		if (A_IsCompiled) {
			return 0
		}

		msgreport := this._buildReport()
		if (this.failTotal > 0) {
			msgreport .= "`n=================================`n"
		}
		loop % this.log.Count() {
			msgreport .= this.log[A_Index]
		}

		if (this.failTotal > 0) {
			l_options := 48
		} else {
			l_options := 64
		}
		this._stdOut(msgreport)
		msgbox, % l_options, unit-testing.ahk, % msgreport
		return msgreport
	}


	writeResultsToFile(param_filepath:="", openFile:=0) {
		if (A_IsCompiled) {
			return 0
		}

		; prepare
		if (param_filepath != "") {
			logpath := param_filepath
		} else {
			logpath := this.logresult_dir
		}

		; create
		try {
			FileDelete, % logpath
		} catch {
			; do nothing
		}
		
		msgreport := this._buildReport()
		FileAppend, % msgreport "`n`n", % logpath
		for key, value in this.log {
			FileAppend, % value, % logpath
		}
		if (openFile) {
			Run, % logpath
		}
		return true
	}

	; Internal functions
	_buildReport() {
		if (A_IsCompiled) {
			return 0
		}

		; create
		this.percentsuccess := floor( ( this.successTotal / this.testTotal ) * 100 )
		returntext := this.testTotal " tests completed with " this.percentsuccess "% success (" this.failTotal " failures)"
		if (this.failTotal = 1) {
			returntext := StrReplace(returntext, "failures", "failure")
		}
		if (this.testTotal = 1) {
			returntext := StrReplace(returntext, "tests", "test")
		}
		return returntext
	}


	_print(param_obj) {
		if (IsObject(param_obj)) {
			for key, value in param_obj {
				if key is not Number
				{
					output .= """" . key . """:"
				} else {
					output .= key . ":"
				}
				if (IsObject(value)) {
					output .= "[" . this._print(value) . "]"
				} else if value is not Number
				{
					output .= """" . value . """"
				}
				else {
					output .= value
				}
				output .= ", "
			}
			StringTrimRight, output, output, 2
			return output
		}
		return param_obj
	}

	_stdOut(output:="") {
		try {
			DllCall("AttachConsole", "int", -1) || DllCall("AllocConsole")
			FileAppend, % output "`n", CONOUT$
			DllCall("FreeConsole")
		} catch error {
			return false
		}
		return true
	}
}
