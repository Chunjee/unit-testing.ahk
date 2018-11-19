class unittesting {
	
	__New() {
        this.testtotal := 0
        this.failtotal := 0
        this.successtotal := 0

		this.log := []
		this.Info_Array := []
	}


	test(para_1, para_2) {
        global

        if ( A_IsCompiled ) {
            return 0
        }

        this.testtotal += 1
        if (para_1 = para_2) {
            this.successtotal++
            return 1
        } else {
            this.failtotal++
            this.log.push("Test Number: " this.testtotal "`n`r")
            ; this.log.push("Function: " A_ThisFunc "`n`r")
            this.log.push("Expected: " JSON.stringify(para_2) "`n`r")
            this.log.push("Actual: " JSON.stringify(para_1) "`n`r")
            this.log.push("`n`r`n`r")
            return 0
        }
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
            msgreport .= "`n`r=================================`n`r"
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
