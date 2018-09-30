Class CPULoad
{
	__New() {
		this.PIT
		this.PKT
		this.PUT

        this.Get()
	}

	Get() {
		DllCall( "GetSystemTimes", "Int64P",this.PIT, "Int64P",this.PKT, "Int64P",this.PUT )

		DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
		, IdleTime := this.PIT - CIT,    KernelTime := this.PKT - CKT,    UserTime := this.PUT - CUT
		, SystemTime := KernelTime + UserTime 

        ReturnValue := ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    this.PIT := CIT,    this.PKT := CKT,    this.PUT := CUT
              
        if (ReturnValue >= 0 && ReturnValue < 100) {
            return ReturnValue
        } else {
            return 100 ;typically returned on 1st call
        }
	}
}
