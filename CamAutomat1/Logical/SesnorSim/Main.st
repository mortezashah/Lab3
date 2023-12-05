//[*********************************************************************************
//* Primary Author:    	Morteza Shahmoradi
//* Created:   			Dec 4, 2023
//* Description: 		Machine  Control
//	*********************************************************************************]  
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)

	
		
	IF  0.0 < Data[0] AND Data[0] < 10.0 THEN	/// Simulation gSensorUpStream every 50degree one whole
		gSensorUpStream := TRUE;
	ELSE  
		gSensorUpStream := FALSE;
	END_IF	
	Data[3] := gSensorUpStream * 360.0;
	
	
	IF  145.0 < Data[0] AND Data[0] < 155.0 AND  Data[1] > 175.0 AND Data[1] < 185.0 THEN	 /// Simulation gSensorLowStream
		gSensorLowStream := TRUE;	
	ELSE  
		gSensorLowStream := FALSE;
	END_IF
	
	Data[4] := gSensorLowStream * 360.0;
		
//	IF 	EDGEPOS(gSensorUpStream) AND CutStart THEN
//		Axis1.cmdCam := TRUE;
//	END_IF
//	
		
		
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

