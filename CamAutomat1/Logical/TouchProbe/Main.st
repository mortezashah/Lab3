//[*********************************************************************************
//* Primary Author:    	Morteza Shahmoradi
//* Created:   			Dec 7, 2023
//* Description: 		Touch Probe
//	*********************************************************************************]
PROGRAM _INIT
	(* Insert code here *)


	MC_BR_TouchProbe_1.Enable := TRUE;
	
END_PROGRAM

PROGRAM _CYCLIC
	// Code to write the par id 719 19, to bypass the encoder alarm, for cutter 
	MC_BR_ProcessParID_AcpAx_0(Axis := ADR(gCutter_MpLink), DataAddress := ADR(McAcpAxProcessParIDPar) , NumberOfParIDs :=1 , Mode := mcACPAX_PARID_SET);
	MC_BR_ProcessParID_AcpAx_0();
	MC_BR_ProcessParID_AcpAx_1(Axis := ADR(gConv_MpLink), DataAddress := ADR(McAcpAxProcessParIDPar) , NumberOfParIDs :=1 , Mode := mcACPAX_PARID_SET);
	MC_BR_ProcessParID_AcpAx_1();
	
	// touch probe setup, 
	MC_BR_TouchProbe_0.AdvancedParameters := McBrAdvancePar;
	MC_BR_TouchProbe_0.Axis := ADR(gConv_MpLink);
	MC_BR_TouchProbe_0.TriggerInput := McBrTrigger;
	MC_BR_TouchProbe_0(); 
	MC_BR_TouchProbe_0.Enable := gEnableTouchProbe;
	
	McBrAdvancePar.ReadTriggerWidth := TRUE; // Enable to read print lengh
	ValidTriggerCount := MC_BR_TouchProbe_0.ValidTriggerCount;// count of valid trigger
	MissedTriggerCount := MC_BR_TouchProbe_0.MissedTriggerCount; // count of missed trigger
	MC_BR_TouchProbe_0.TriggerInput.MaxWidth := MaxWidth; // MaxWidth to the touch probe
	MC_BR_TouchProbe_0.TriggerInput.MinWidth := MinWidth; // Min Width to the touch rpobe
	
	// second touch probe for training purpose
	MC_BR_TouchProbe_1.AdvancedParameters := McBrAdvancePar_1;
	MC_BR_TouchProbe_1.Axis := ADR(gConv_MpLink);
	MC_BR_TouchProbe_1.TriggerInput := McBrTrigger_1;
	MC_BR_TouchProbe_1(); 
	MC_BR_TouchProbe_1.Enable := NOT gResetCount;

	currentReadingDistance := MC_BR_TouchProbe_1.Period - MC_BR_TouchProbe_1.DeltaExpectedValue;
	
	// manaul paramter find
	
	newValue := MC_BR_TouchProbe_0.RecordedValue;	
	IF newValue > ( preValue + cutSize) THEN  // check if its a new print mark coms	
		difValue := newValue - preValue ;  // calculates
		IF difValue > gMinValue THEN   // validate correct distance
			newValueF := TRUE;
			preValue := newValue;
			partDetected := delatTimerProbe.Q ; // part is detected rise cut flag
			IF difValue < maxValueExpected THEN
				FOR i := 0 TO 6 BY 1 DO
					cutDistance[7-i] := cutDistance[6-i] ;
				END_FOR			
				cutDistance [0] := difValue;
				lastAndCurrentDif := difValue; // for Hmi display
				cutDistanceAve := 0;
				FOR i := 0 TO 7 BY 1 DO			// save old data
					cutDistanceAve := cutDistanceAve + cutDistance[i] ;
				END_FOR
				cutDistanceAveHmi := cutDistanceAve/ 8;
			END_IF
		END_IF
		
		IF difValue < gMinValue AND newValueF THEN   // count missed cuts
			missedCuts := missedCuts + 1;
			newValueF := FALSE;
		END_IF
		
	END_IF
	
	IF gResetCount THEN  // reset cut count 
		missedCuts := 0;
		gResetCount := FALSE;
	END_IF
	
	delatTimerProbe(IN := CutStart , PT := T#500ms);
	delatTimerProbe();	
	IF 	EDGEPOS(partDetected) AND delatTimerProbe.Q  THEN // activate the cut when the touch is 70mm after that
		Axis1.cmdCam := TRUE;
		partDetected := FALSE;
	END_IF
	
	IF EDGEPOS(Axis1.cmdStartAutomat) THEN // transfer the cut last and new position to the last position
		preValue := newValue;
	END_IF
	IF EDGEPOS(gEnableTouchProbe) THEN  // reset the partDetected bit to prevent stop in jog
		partDetected := FALSE;
	END_IF
	
	
	//  get paramter infor from cam automat

	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	MC_BR_TouchProbe_0.Enable := FALSE;
	MC_BR_TouchProbe_0();
	MC_BR_TouchProbe_1.Enable := FALSE;
	MC_BR_TouchProbe_1();
	 
	 
END_PROGRAM

