
PROGRAM _INIT
	(* Insert code here *)



	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	MC_BR_TouchProbe_0.AdvancedParameters := McBrAdvancePar;
	MC_BR_TouchProbe_0.Axis := ADR(gConv_MpLink);
	MC_BR_TouchProbe_0.TriggerInput := McBrTrigger;
	MC_BR_TouchProbe_0(); 
	MC_BR_TouchProbe_0.Enable := gEnableTouchProbe;
	
	newValue := MC_BR_TouchProbe_0.RecordedPeriodicValue;
	
	IF newValue > ( preValue + 15.0) THEN
		difValue := newValue - preValue ;

		IF difValue > minValue THEN
		preValue := newValue;
		partDetected := TON_0.Q ;
		END_IF
		
		
	END_IF
	
	TON_0(IN := CutStart , PT := T#500ms);
	TON_0();	
	IF 	EDGEPOS(partDetected) AND TON_0.Q THEN
		Axis1.cmdCam := TRUE;
		partDetected := FALSE;
	END_IF
	
	TON_1.IN := Axis1.cmdCam;
	TON_1();
	IF EDGEPOS(TON_1.Q) THEN
		Axis1.cmdCam := FALSE;
	END_IF
	
	IF EDGEPOS(Axis1.cmdStartAutomat) THEN
		preValue := newValue;
	END_IF
		
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	MC_BR_TouchProbe_0.Enable := FALSE;
	MC_BR_TouchProbe_0();
	 
END_PROGRAM

