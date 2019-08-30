class unittesting {
	
	__New() {
		this.testtotal := 0
		this.failtotal := 0
		this.successtotal := 0

		this.log := []
		this.Info_Array := []

		this.labelvar := ""
		this.lastlabelvar := ""
	}


	test(para_1, para_2) {
        global

        if ( A_IsCompiled ) {
            return 0
        }
	
        para_1 := JSON.stringify(para_1)
        para_2 := JSON.stringify(para_2)

        
        this.testtotal += 1
        if (para_1 = para_2) {
            this.successtotal++
            return true
        } else {
            this.failtotal++
            if (this.labelvar != this.lastlabelvar) {
                this.lastlabelvar := this.labelvar
                this.log.push("`r`n== " this.labelvar " ==`r`n")
            }
            this.log.push("Test Number: " this.testtotal "`r`n")
            this.log.push("Expected: " para_2 "`r`n")
            this.log.push("Actual: " para_1 "`r`n")
            this.log.push("`r`n")
            return false
        }
	}

    true(para_1) {
        if (para_1) {
            this.test("true","false")
        } else {
            this.test("true","true")
        }
    }

    false(para_1) {
        if (!para_1) {
            this.test("false","true")
        } else {
            this.test("false","false")
        }
    }

    label(para_label) {
        this.labelvar :=  para_label
        return
    }

    buildreport() {
        if ( A_IsCompiled ) {
            return 0
        }
        this.percentsuccess := Ceil( ( this.successtotal / this.testtotal ) * 100 )
        returntext := this.testtotal " tests completed with " this.percentsuccess "% success"
        if (this.failtotal = 1) {
            returntext .= " (" this.failtotal " failure)"
        }
        if (this.failtotal > 1) {
            returntext .= " (" this.failtotal " failures)"
        }
        return returntext
    }


    report() {
        msgbox, % this.buildreport()
    }


    fullreport() {
        if ( A_IsCompiled ) {
            return 0
        }

        logresult_dir := A_ScriptDir "\testresults.log"
        FileDelete, % logresult_dir
        msgreport := this.buildreport()
        if (this.failtotal > 0) {
            msgreport .= "`r`n=================================`r`n"
        }
        
        loop % this.log.MaxIndex()
        {
            line := this.log[A_Index]
            FileAppend, %line%, %logresult_dir%
            msgreport .= this.log[A_Index]
        }
        msgbox % msgreport
        return msgreport
    }
}
