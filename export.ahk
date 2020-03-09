class unittesting {
	
	__New() {
		this.testtotal := 0
		this.failtotal := 0
		this.successtotal := 0

		this.log := []
		this.Info_Array := []

		this.labelvar := ""
		this.lastlabelvar := ""

        this.logresult_dir := A_ScriptDir "\testresults.log"
	}


	test(para_actual, para_expected) {
        global JSON

        if ( A_IsCompiled ) {
            return 0
        }
        if (IsObject(para_actual)) {
            para_actual := JSON.stringify(para_actual)
        }
        if (IsObject(para_expected)) {
            para_expected := JSON.stringify(para_expected)
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

    true(para_1) {
        if (para_1) {
            this.test("true","true")
            return true
        } else {
            this.test("false","true")
            return false
        }
    }

    false(para_1) {
        if (!para_1) {
            this.test("false","false")
            return true
        } else {
            this.test("true","false")
            return false
        }
    }

    notEqual(para_1, para_2) {
        global JSON

        if ( A_IsCompiled ) {
            return 0
        }
	
        para_1 := JSON.stringify(para_1)
        para_2 := JSON.stringify(para_2)

        
        this.testtotal += 1
        if (para_1 != para_2) {
            this.successtotal++
            return true
        } else {
            this.failtotal++
            if (this.labelvar != this.lastlabelvar) {
                this.lastlabelvar := this.labelvar
                this.log.push("`r`n== " this.labelvar " ==`r`n")
            }
            this.log.push("Test Number: " this.testtotal "`r`n")
            this.log.push("Input1: " para_1 "`r`n")
            this.log.push("Input2: " para_2 "`r`n")
            this.log.push("They were Expected to be DIFFERENT")
            this.log.push("`r`n")
            return false
        }
	}

    label(para_label) {
        if ( A_IsCompiled ) {
            return 0
        }

        this.labelvar :=  para_label
        return
    }

    buildReport() {
        if ( A_IsCompiled ) {
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
        if ( A_IsCompiled ) {
            return 0
        }

        msgbox, % this.buildreport()
        return true
    }


    fullReport() {
        if ( A_IsCompiled ) {
            return 0
        }

        msgreport := this.buildreport()
        if (this.failtotal > 0) {
            msgreport .= "`r`n=================================`r`n"
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
}
