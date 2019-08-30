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
	
        para_1 := JSON.stringify(para_1)
        para_2 := JSON.stringify(para_2)

        
        this.testtotal += 1
        if (para_1 = para_2) {
            this.successtotal++
            return 1
        } else {
            this.failtotal++
            if (this.label != this.lastlabel) {
                this.lastlabel := this.label
                this.log.push("`r`n== " this.label " ==`r`n")
            }
            this.log.push("Test Number: " this.testtotal "`r`n")
            this.log.push("Expected: " JSON.stringify(para_2) "`r`n")
            this.log.push("Actual: " JSON.stringify(para_1) "`r`n")
            this.log.push("`r`n")
            return 0
        }
	}

    label(para_label) {
        this.label := para_label
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
