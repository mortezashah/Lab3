//[*********************************************************************************
//* Primary Author:    	Morteza Shahmoradi
//* Created:   			Dec 4, 2023
//* Description: 		Machine  Control
//	*********************************************************************************]  
PROGRAM _INIT
	(* Insert code here *)
	MpAlarmXCore_0(
				MpLink := ADR(MpLinkMachinegAlarmXCore), 
				Enable := TRUE, );
	//		ErrorReset := );
	MpAlarmXAcknowledgeAll_0(
	MpLink := ADR(MpLinkMachinegAlarmXCore), 
	Enable := TRUE, );
	//		ErrorReset := );
END_PROGRAM

PROGRAM _CYCLIC

	MpAlarmXCore_0();

	MpAlarmXAcknowledgeAll_0.Execute := ackAlarms;
	MpAlarmXAcknowledgeAll_0();
	ackAlarms := FALSE;

	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)

	MpAlarmXCore_0.Enable:= FALSE;
	MpAlarmXCore_0();
	MpAlarmXAcknowledgeAll_0.Enable:= FALSE;
	MpAlarmXAcknowledgeAll_0();
END_PROGRAM

