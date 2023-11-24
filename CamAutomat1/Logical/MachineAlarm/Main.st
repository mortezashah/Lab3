
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
	(* Insert code here *)
	
//	//ice cream temperature >= -4°C
//	IF gIceCreamTemperatures >= -4 THEN
//		MpAlarmXSet(MpLinkICEgAlarmXCore,'TemperatureHigh');
//	ELSE
//		MpAlarmXReset(MpLinkICEgAlarmXCore,'TemperatureHigh');
//	END_IF;
//	
//	//ice cream temperature <= -20°C
//	IF gIceCreamTemperatures <= -20.0 THEN
//		MpAlarmXSet(MpLinkICEgAlarmXCore,'TemperatureLow');
//	ELSE
//		MpAlarmXReset(MpLinkICEgAlarmXCore,'TemperatureLow');
//	END_IF;
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

