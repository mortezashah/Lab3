//[*********************************************************************************
//* Primary Author:    	Morteza Shahmoradi
//* Created:   			Dec 7, 2023
//* Description: 		Touch Probe
//	*********************************************************************************]
PROGRAM _INIT
	(* Insert code here *)



	
END_PROGRAM

PROGRAM _CYCLIC
	MC_BR_ProcessParID_AcpAx_0(Axis := ADR(gCutter_MpLink), DataAddress := ADR(McAcpAxProcessParIDPar) , NumberOfParIDs :=1 , Mode := mcACPAX_PARID_SET);
	MC_BR_ProcessParID_AcpAx_0();
	(* Insert code here *)
	MC_BR_TouchProbe_0.AdvancedParameters := McBrAdvancePar;
	MC_BR_TouchProbe_0.Axis := ADR(gConv_MpLink);
	MC_BR_TouchProbe_0.TriggerInput := McBrTrigger;
	MC_BR_TouchProbe_0(); 
	MC_BR_TouchProbe_0.Enable := gEnableTouchProbe;
	
	newValue := MC_BR_TouchProbe_0.RecordedPeriodicValue;
	
	IF newValue > ( preValue + 15.0) THEN
		difValue := newValue - preValue ;

		IF difValue > gMinValue THEN
		preValue := newValue;
		partDetected := delatTimerProbe.Q ;
		END_IF
		
		
	END_IF
	
	delatTimerProbe(IN := CutStart , PT := T#500ms);
	delatTimerProbe();	
	IF 	EDGEPOS(partDetected) AND delatTimerProbe.Q THEN
		Axis1.cmdCam := TRUE;
		partDetected := FALSE;
	END_IF
	
	delatTimerCut.IN := Axis1.cmdCam;
	delatTimerCut();
//	IF EDGEPOS(delatTimerCut.Q) THEN
//		Axis1.cmdCam := FALSE;
//	END_IF
	
	IF EDGEPOS(Axis1.cmdStartAutomat) THEN
		preValue := newValue;
	END_IF
		
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	MC_BR_TouchProbe_0.Enable := FALSE;
	MC_BR_TouchProbe_0();
	 
END_PROGRAM

