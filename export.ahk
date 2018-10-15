Class unittest_class {
	
	__New() {
        this.testtotal := 0
        this.failtotal := 0
        this.successtotal := 0

		this.log := log
		this.Info_Array := []
	}


	test(para_1, para_2) {
        if ( A_IsCompiled ) {
            return 0
        }

        this.testtotal += 1
        if (para_1 = para_2) {
            this.successtotal++
            return 1
        } else {
            this.failtotal++
            return 0
        }
	}


    report() {
        if ( A_IsCompiled ) {
            return 0
        }

        this.percentsuccess := Ceil( ( this.testtotal / this.successtotal ) * 100 )
        msgbox, % this.testtotal " asserts completed with " this.percentsuccess "% success"
    }


    fullreport() {
        if ( A_IsCompiled ) {
            return 0
        }
    }
}
