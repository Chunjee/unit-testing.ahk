class unittesting {

	__New() {
		this.testTotal := 0
		this.failTotal := 0
		this.successTotal := 0

		this.log := []
		this.Info_Array := []

		this.labelvar := ""
		this.lastlabelvar := ""
		this.category := ""

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
		if (this.labelvar != this.lastlabelvar) {
			this.lastlabelvar := this.labelvar
			if (this.category) {
				this.log.push("`n== " this.category " - " this.labelvar " ==`n")
			} else {
				this.log.push("`n== " this.labelvar " ==`n")
			}
		}
		this.log.push("Test Number: " this.testTotal "`n")
		this.log.push("Expected: " param_expected "`n")
		this.log.push("Actual: " param_actual "`n")
		if (param_msg != "") {
			this.log.push(param_msg "`n")
		} else {
			this.log.push("`n")
		}
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


	Missing_Parameter(param_actual:="_Missing_Parameter_") {
		if (A_IsCompiled) {
			return 0
		}

		; prepare
		if (IsObject(param_actual)) {
			param_actual := this._print(param_actual)
			if (StrLen(param_actual) > 0) {
				param_actual := "(Object)"
			}
		}

		; create
		this.testTotal += 1
		if (param_actual != "") {
			this._logTestFail(param_actual, """""")
			return false
		} else {
			this.successTotal++
			return true
		}
	}


	label(param_label) {
		if (A_IsCompiled) {
			return 0
		}

		this.labelvar :=  param_label
		return
	}


	buildReport() {
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


	report() {
		if (A_IsCompiled) {
			return 0
		}

		msgbox, % this.buildreport()
		return true
	}


	fullReport() {
		if (A_IsCompiled) {
			return 0
		}

		msgreport := this.buildreport()
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
			msgbox, % l_options, unit-testing.ahk, % msgreport
		return msgreport
	}


	writeTestResultsToFile(param_filepath:="") {
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
		FileDelete, % logpath
		msgreport := this.buildreport()
		FileAppend, %msgreport%, % logpath
		for key, value in this.log {
			FileAppend, %value%, % logpath
		}
		return true
	}

	; Internal functions
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
}
