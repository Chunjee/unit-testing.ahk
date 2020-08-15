class unittesting {

	__New() {
		this.testtotal := 0
		this.failtotal := 0
		this.successtotal := 0

		this.log := []
		this.Info_Array := []

		this.labelvar := ""
		this.lastlabelvar := ""

		this.logresult_dir := A_ScriptDir "\result.tests.log"
	}


	test(para_actual, para_expected) {
		if (A_IsCompiled) {
			return 0
		}

		if (IsObject(para_actual)) {
			para_actual := this._print(para_actual)
		}
		if (IsObject(para_expected)) {
			para_expected := this._print(para_expected)
		}

		this.testtotal += 1
		if (para_actual = para_expected) {
			this.successtotal++
			return true
		} else {
			this.failtotal++
			if (this.labelvar != this.lastlabelvar) {
				this.lastlabelvar := this.labelvar
				this.log.push("`n== " this.labelvar " ==`n")
			}
			this.log.push("Test Number: " this.testtotal "`n")
			this.log.push("Expected: " para_expected "`n")
			this.log.push("Actual: " para_actual "`n")
			this.log.push("`n")
			return false
		}
	}


	true(param_actual) {
		if (A_IsCompiled) {
			return 0
		}

		if (param_actual) {
			this.test("true","true")
			return true
		} else {
			this.test("false","true")
			return false
		}
	}


	false(param_actual) {
		if (A_IsCompiled) {
			return 0
		}

		if (!param_actual) {
			this.test("false","false")
			return true
		} else {
			this.test("true","false")
			return false
		}
	}


	equal(param_actual, param_expected) {
		if (A_IsCompiled) {
			return 0
		}

		return this.test(param_actual, param_expected)
	}


	notEqual(param_actual, param_expected) {
		if (A_IsCompiled) {
			return 0
		}

		param_actual := this._print(param_actual)
		param_expected := this._print(param_expected)


		this.testtotal += 1
		if (param_actual != param_expected) {
			this.successtotal++
			return true
		} else {
			this.failtotal++
			if (this.labelvar != this.lastlabelvar) {
				this.lastlabelvar := this.labelvar
				this.log.push("`n== " this.labelvar " ==`n")
			}
			this.log.push("Test Number: " this.testtotal "`n")
			this.log.push("Input1: " param_actual "`n")
			this.log.push("Input2: " param_expected "`n")
			this.log.push("They were Expected to be DIFFERENT")
			this.log.push("`n")
			return false
		}
	}


	undefined(param_actual) {
		if (A_IsCompiled) {
			return 0
		}

		this.testtotal += 1
		if (IsObject(param_actual)) {
			param_actual := this._print(param_actual)
			if (StrLen(param_actual) > 0) {
				param_actual := "(Object)"
			}
		}
		if (param_actual != "") {
			this.failtotal++
			this.log.push("`n== " this.labelvar " ==`n")
			this.log.push("Test Number: " this.testtotal "`n")
			this.log.push("Input: " param_actual "`n")
			this.log.push("Expected to be """"")
			return false
		} else {
			this.successtotal++
			return true
		}
	}


	label(para_label) {
		if (A_IsCompiled) {
			return 0
		}

		this.labelvar :=  para_label
		return
	}


	buildReport() {
		if (A_IsCompiled) {
			return 0
		}

		this.percentsuccess := floor( ( this.successtotal / this.testtotal ) * 100 )
		returntext := this.testtotal " tests completed with " this.percentsuccess "% success (" this.failtotal " failures)"
		if (this.failtotal = 1) {
			returntext := StrReplace(returntext, "failures", "failure")
		}
		if (this.testtotal = 1) {
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
		if (this.failtotal > 0) {
			msgreport .= "`n=================================`n"
		}

		loop % this.log.Count() {
			msgreport .= this.log[A_Index]
		}
		msgbox % msgreport
		return msgreport
	}

	writeTestResultsToFile() {
		FileDelete, % this.logresult_dir
		for key, value in this.log {
			FileAppend, %Value%, % this.logresult_dir
		}
		return true
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
					output .= "[" . this._printObj(value) . "]"
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
