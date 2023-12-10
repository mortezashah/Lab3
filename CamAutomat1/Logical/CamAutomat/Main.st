//[*********************************************************************************
//* Primary Author:    	Morteza Shahmoradi
//* Created:   			Dec 4, 2023
//* Description: 		Machine  Control
//	*********************************************************************************]  
PROGRAM _INIT	

	(* Initialize MpAxisBasic_AxisMaster *)	
	MpAxisBasic_AxisMaster.Enable := TRUE;		
	AxisParameters_Master.Position := 0.0;	
	AxisParameters_Master.Velocity := 72.0;	
	AxisParameters_Master.Acceleration := 3600.0;	
	AxisParameters_Master.Deceleration := 3600.0;
	AxisParameters_Master.Jog.Deceleration := 3600;
	AxisParameters_Master.Stop.Deceleration := 3600.0;
	(* Initialize MpAxisBasic_AxisSlave *)	
	MpAxisBasic_AxisSlave.Enable := TRUE;		
	AxisParameters_Slave.Position := 0.0;	
	AxisParameters_Slave.Velocity := 72.0;	
	AxisParameters_Slave.Acceleration := 3600.0;	
	AxisParameters_Slave.Deceleration := 3600.0;	
	AxisParameters_Slave.Stop.Deceleration := 3600.0;
	AxisParameters_Slave.Jog.Deceleration := 3600;
	AxisParameters_Slave.Stop.Deceleration := 3600.0;
	
	AxisParameters_Master.AutoTune.Mode 				:= mcAXIS_TUNE_AUTOMATIC;
	AxisParameters_Master.AutoTune.MaxCurrentPercent 	:= 80.0;
	AxisParameters_Master.AutoTune.MaxDistance 			:= 10;
	AxisParameters_Master.AutoTune.MaxPositionError 	:= 30;

	AxisParameters_Slave.AutoTune.Mode 				:= mcAXIS_TUNE_AUTOMATIC;
	AxisParameters_Slave.AutoTune.MaxCurrentPercent 	:= 80.0;
	AxisParameters_Slave.AutoTune.MaxDistance 			:= 10;
	AxisParameters_Slave.AutoTune.MaxPositionError 	:= 30;
	

	
	MpAxisBasic_AxisMaster.MpLink := ADR(gConv_MpLink);	
	MpAxisBasic_AxisMaster.Parameters := ADR(AxisParameters_Master);		
	MpAxisBasic_AxisSlave.MpLink := ADR(gCutter_MpLink);	
	MpAxisBasic_AxisSlave.Parameters := ADR(AxisParameters_Slave);	
	MpAxisCamSequencer_0.MpLink := ADR(gCutter_MpLink);	

	MpAxisCamSequencer_0.MpLinkMaster := ADR(gConv_MpLink);	
	MpAxisCamSequencer_0.Parameters := ADR(CamSequencerParameters_0);	

END_PROGRAM

PROGRAM _CYCLIC	
				
	AxisParameters_Master.Velocity := gConvPrSpeed / 60  ;	// speed comes the part per minites divided by 60 s 
	AxisParameters_Slave.Jog.Velocity := gCutJogSpeed;	  // Jog speed comes from HMi manaul page
	AxisParameters_Master.Jog.Velocity := gConvJogSpeed; // belt jog peed  comes from HMi manaul page
	gConvPosition := MpAxisBasic_AxisMaster.Position;  // realtime belt position  to  HMi manaul page
	gCutPosition  := MpAxisBasic_AxisSlave.Position;  // real time saw position to hmi
	gManualActive :=  NOT MpAxisBasic_AxisMaster.MoveVelocity;
	IF  (MpAxisBasic_AxisSlave.Position < cutJogEnableFWL) THEN // if the saw is not in cut zone move is backward
		AxisParameters_Slave.Direction := mcDIR_NEGATIVE;
	ELSE 
		AxisParameters_Slave.Direction :=  mcDIR_POSITIVE;
		
	END_IF
		
	sawInCutPosition := NOT (MpAxisBasic_AxisSlave.Position > cutJogEnableBWL AND MpAxisBasic_AxisSlave.Position < cutJogEnableFWM) AND NOT MpAxisBasic_AxisMaster.MoveVelocity ;
	displayMessageAuto := NOT sawInCutPosition AND NOT MpAxisBasic_AxisMaster.MoveVelocity ; // dispay disable message so no possibe run
	
	(* Insert code here *)
	TON_DelayDo1.PT := DelayOpc;
	// Create Pulse Generator Start
	
	IF TON_DelayDo1.ET <> DelayOpc THEN
		TON_DelayDo1.IN := TRUE;
	END_IF
	
	TON_DelayDo1();
	gServoInitialized:= TON_DelayDo1.Q ;	
	gDispalyServoNotReady := NOT gServoInitialized;
	
	// Create Pulse Generator End

	
		CASE AxisStep OF
				
				STATE_WAIT :     //**************** 00000 ************************** STATE_WAIT ********************* 0000 ********************* STATE_WAIT
					MpAxisBasic_AxisMaster.Power		:= FALSE; // turn of drive
					MpAxisBasic_AxisSlave.Power			:= FALSE; // turn of drive Saw
					MpAxisCamSequencer_0.Enable			:= FALSE; // diale the cam sequencer
					gEnableTouchProbe := FALSE;		
					IF ( Axis1.Exists AND gServoInitialized) THEN
						MpAxisBasic_AxisMaster.Power	:= TRUE;
						MpAxisBasic_AxisSlave.Power		:= TRUE;
						AxisStep :=  STATE_POWER_ON;
					END_IF			
				STATE_POWER_ON : //************************ 1 ****************** STATE_POWER_ON ********************* 1 ********************* STATE_POWER_ON
					gEnableTouchProbe := FALSE;
					IF (MpAxisBasic_AxisMaster.PowerOn = TRUE AND MpAxisBasic_AxisMaster.PowerOn = TRUE ) THEN
						AxisStep := STATE_HOME;
					END_IF
					IF (MpAxisBasic_AxisMaster.Error OR MpAxisBasic_AxisSlave.Error) THEN
						Axis1_ErrorID := 1;
						AxisStep := STATE_ERROR;
					END_IF
					
				STATE_HOME :  //***************************** 2 ********************STATE_HOME************************* 2 *********************STATE_HOME
					Axis1.statusHomed 							:= FALSE;
					AxisParameters_Master.Homing.Mode 		:= mcHOMING_DIRECT;// set the home type for the master ax
					AxisParameters_Master.Homing.Position 	:= 0.0;
					AxisParameters_Slave.Homing.Mode 		:= mcHOMING_ABSOLUTE; // set the home type abs for the slave
					AxisParameters_Slave.Homing.Position 	:= -161.4;  // relative position
					IF (NOT MpAxisCamSequencer_0.CommandBusy AND NOT MpAxisCamSequencer_0.StartSequence)  THEN
						MpAxisBasic_AxisMaster.Home 			:= TRUE;
						MpAxisBasic_AxisSlave.Home 			:= TRUE;
					END_IF
					IF EDGEPOS(MpAxisBasic_AxisMaster.IsHomed) THEN
						Axis1Home		:= TRUE;
					END_IF
					
					IF EDGEPOS(MpAxisBasic_AxisSlave.IsHomed) THEN
						Axis2Home		:= TRUE;
					END_IF
					
					IF (Axis1Home AND Axis2Home) THEN  // if its home then go to ready state
						Axis1.statusHomed 			:= 1;
						MpAxisBasic_AxisMaster.Home 	:= FALSE;
						MpAxisBasic_AxisSlave.Home 	:= FALSE;
						Axis2Home := FALSE;
						Axis1Home := FALSE;
						MpAxisCamSequencer_0.Enable := TRUE;
						gEnableTouchProbe := TRUE;
						AxisStep := STATE_READY;
						
					END_IF			
					IF (MpAxisBasic_AxisMaster.Error OR MpAxisBasic_AxisSlave.Error) THEN  // if there is an erro o to error state
						Axis1_ErrorID := 2;
						AxisStep := STATE_ERROR;
					END_IF
					
				STATE_READY : //***************************** 10 ************************ STATE_READY ******************** 10 ************************** STATE_READY 
					Axis1.statusOff := 0;
					Axis1.statusStarting :=0;
					MpAxisCamSequencer_0.Enable := TRUE;
					gEnableTouchProbe := FALSE;
						CutStart := FALSE;
						
						// Home state if requested by HMI
					IF (Axis1.cmdHome = 1 AND NOT  MpAxisBasic_AxisMaster.CommandBusy  AND NOT  MpAxisBasic_AxisSlave.CommandBusy )THEN  // command home if 
						Axis1Home							:= FALSE;
						Axis2Home							:= FALSE;
						MpAxisCamSequencer_0.StartSequence 	:= FALSE;
						AxisStep 							:= STATE_HOME;
						Axis1.cmdHome		 				:= FALSE;
		
					ELSIF (Axis1.cmdStop = 1) THEN  // Stop command activate from HMI

						Axis1.cmdCamAutomat 					:=FALSE;
						Axis1.cmdStop 							:= FALSE;
						Axis1.cmdMoveVelocity 					:= FALSE;
						Axis1.cmdMoveAdditive 					:= FALSE;
						MpAxisBasic_AxisMaster.MoveAdditive 	:= FALSE;
						MpAxisBasic_AxisMaster.MoveVelocity 	:= FALSE;
						AxisStep 				:= STATE_STOP;
						
					ELSIF MpAxisBasic_AxisMaster.MoveVelocity AND Axis1.cmdStartAutomat   THEN  // demand for the Cut
						MpAxisCamSequencer_0.StartSequence := TRUE;
						MpAxisCamSequencer_0.Signal1		:= FALSE;
						AxisStep := STATE_MOVE_CAMAUTOMAT;	

			
					ELSIF NOT MpAxisBasic_AxisSlave.MoveAbsolute AND Axis1.cmdMoveVelocity AND NOT MpAxisBasic_AxisMaster.MoveVelocity AND  MpAxisBasic_AxisSlave.Position = 0.0  THEN
							AxisStep := STATE_MOVE_VELOCITY;
					ELSIF Axis1.cmdMoveVelocity  AND NOT (MpAxisBasic_AxisSlave.Position = 0.0  ) THEN
						MpAxisBasic_AxisSlave.MoveAbsolute := TRUE;
					ELSIF MpAxisBasic_AxisSlave.MoveAbsolute  AND  ( MpAxisBasic_AxisSlave.Position = 0.0 ) THEN
						MpAxisBasic_AxisSlave.MoveAbsolute := FALSE;
									
					ELSIF NOT MpAxisBasic_AxisMaster.MoveVelocity AND (Axis1.cmdManualForward OR Axis1.cmdManualReverse OR Axis2.cmdManualForward OR Axis2.cmdManualReverse ) THEN
						AxisStep := STATE_JOG;
						startPositionJog := MpAxisBasic_AxisMaster.Position ;
					ELSIF (Axis1.Exists = 0) THEN  // power of servos
						AxisStep := STATE_WAIT;
				
					END_IF
					
					IF MpAxisBasic_AxisMaster.Error OR MpAxisBasic_AxisSlave.Error THEN  // if there is an erro o to error state
						AxisStep := STATE_ERROR;
					END_IF
					
					
									
				STATE_STOP : //*********************** 20 ****************************** STATE_STOP ***************************** 20 ********************** STATE_STOP 
					Axis1.statusOff := 0;
					MpAxisBasic_AxisMaster.Stop := TRUE;
					MpAxisBasic_AxisSlave.Stop := TRUE;
					(* if axis is stopped go to state wait *)
					IF (MpAxisBasic_AxisMaster.Stopped = 1 AND MpAxisBasic_AxisSlave.Stopped = 1 ) THEN
					MpAxisBasic_AxisMaster.Stop := FALSE;
					MpAxisBasic_AxisSlave.Stop := FALSE;
						AxisStep := STATE_READY;
					END_IF
					(* check if error occured *)
					IF (MpAxisBasic_AxisMaster.Error OR MpAxisBasic_AxisSlave.Error) THEN
						Axis1_ErrorID := 3;
						AxisStep := STATE_ERROR;
					END_IF				
				STATE_MOVE_ABSOLUTE : //*************** 24 *************************** STATE_MOVE_ABSOLUTE *********************** 24 ******************* STATE_MOVE_ABSOLUTE 
		
					
				STATE_MOVE_ADDITIVE : //********************* 26 *********************** STATE_MOVE_POSITION *************************** 26 ****************************STATE_MOVE_POSITION	
					IF ( Axis1.cmdMoveAdditive  )	 THEN
						MpAxisBasic_AxisMaster.MoveAdditive := TRUE;
						Axis1.cmdMoveAdditive := FALSE;
						TON_StepDelay.IN			:= TRUE;	
						AxisStep := STATE_READY;
					END_IF
					
					IF MpAxisBasic_AxisMaster.Error THEN  // if there is an erro o to error state
						AxisStep := STATE_ERROR;
					END_IF
					
				STATE_MOVE_VELOCITY : //*************** 28 *************************** STATE_MOVE_VELOCITY *********************** 28 ******************* STATE_MOVE_VELOCITY 
					IF ( Axis1.cmdMoveVelocity  ) 	THEN
						MpAxisBasic_AxisMaster.MoveVelocity	:= TRUE;
						Axis1.cmdMoveVelocity := FALSE;
						AxisStep := STATE_READY;
					TON_StepDelay.IN			:= TRUE;
					Axis1.cmdStartAutomat 		:= TRUE;
					END_IF

					IF MpAxisBasic_AxisMaster.Error THEN
						AxisStep := STATE_ERROR;
					END_IF			
						
				STATE_MOVE_CAMAUTOMAT : //*************** 30 *************************** STATE_MOVE_VELOCITY *********************** 30 ******************* STATE_MOVE_CAMAUTOMAT 
			gEnableTouchProbe := TRUE;
						MpAxisBasic_AxisMaster.Update := gSaveParameter;
						MpAxisCamSequencer_0.Signal2 := Axis1.statusOff ;	
						CutStart := MpAxisCamSequencer_0.ActualStateIndex <> 0 AND enableCut;
						gEnableTouchProbe := CutStart;
					 IF NOT Axis1.cmdStartAutomat  THEN  // demand for cut activate from HMI
						Axis1.cmdCam 			:= FALSE;
						MpAxisCamSequencer_0.StartSequence 		:= FALSE;
						AxisStep := STATE_READY;
					ELSIF (Axis1.cmdStop = 1) THEN
						enableCut								:= FALSE; // Enable cut will be clear as stop cmamnd comes
						Axis1.cmdStartAutomat 					:= FALSE;
						Axis1.cmdCam 							:= FALSE;
						Axis1.cmdStop 							:= FALSE;
						Axis1.cmdMoveVelocity 					:= FALSE;
						Axis1.cmdMoveAdditive 					:= FALSE;
						MpAxisBasic_AxisMaster.MoveAdditive 	:= FALSE;
						MpAxisBasic_AxisMaster.MoveVelocity 	:= FALSE;
						MpAxisCamSequencer_0.StartSequence		:= FALSE;
						AxisStep := STATE_STOP;
					ELSIF (Axis1.statusOff = 1 AND MpAxisCamSequencer_0.ActualStateIndex = 1 ) THEN
						Axis1.cmdStartAutomat 					:= FALSE;  // production finish procedure
						Axis1.cmdCam 							:= FALSE;
						Axis1.statusOff							:= FALSE;
						Axis1.cmdMoveVelocity 					:= FALSE;
						Axis1.cmdMoveAdditive 					:= FALSE;
						MpAxisBasic_AxisMaster.MoveAdditive 	:= FALSE;
						MpAxisBasic_AxisMaster.MoveVelocity 	:= FALSE;
						MpAxisCamSequencer_0.StartSequence		:= FALSE;
						AxisStep := STATE_STOP;
						enableCut								:= FALSE;
					ELSIF MpAxisCamSequencer_0.ActualStateIndex >=1 THEN
						MpAxisCamSequencer_0.Signal1 := Axis1.cmdCam AND NOT Axis1.statusOff AND NOT twoCutEnable ;	
						MpAxisCamSequencer_0.Signal2 := Axis1.cmdCam AND NOT Axis1.statusOff AND  twoCutEnable ;
			
					END_IF							
				
						
						
						
				STATE_JOG ://************************* 40 **************************** STATE_JOG ********************************* 40 ********************* STATE_JOG 					
				
			
				IF NOT (Axis1.cmdManualForward OR Axis1.cmdManualReverse OR Axis2.cmdManualForward OR Axis2.cmdManualReverse ) AND  gRunPage THEN
					gRunPage := FALSE;	
					AxisStep := STATE_READY;
				END_IF
				
				MpAxisBasic_AxisMaster.JogPositive 	:= Axis1.cmdManualForward AND sawInCutPosition;
				MpAxisBasic_AxisMaster.JogNegative	:= Axis1.cmdManualReverse AND MpAxisBasic_AxisMaster.Position > (startPositionJog - 100.00) AND sawInCutPosition;
						
				MpAxisBasic_AxisSlave.JogPositive 	:= Axis2.cmdManualForward AND cutJogEnableFW   ;
				MpAxisBasic_AxisSlave.JogNegative 	:= Axis2.cmdManualReverse AND cutJogEnableBW ;


							


				
			
				STATE_ERROR : //********************** 101 ******************************* STATE_ERROR **************************** 101 ********************** STATE_ERROR 
					gErrorID := 3;	
					alarmActive := TRUE;
			
					enableCut := FALSE;
					Axis1.statusStarting :=0;
					Axis1.statusFaulted := TRUE;					
					MpAxisBasic_AxisMaster.Power := FALSE;
					MpAxisBasic_AxisMaster.Home := FALSE;
					MpAxisBasic_AxisMaster.Stop := FALSE;
					MpAxisBasic_AxisMaster.MoveAbsolute := FALSE;
					MpAxisBasic_AxisMaster.MoveVelocity := FALSE;
					MpAxisBasic_AxisMaster.ErrorReset := Axis1.cmdReset;
					MpAxisBasic_AxisSlave.Power := FALSE;
					MpAxisBasic_AxisSlave.Home := FALSE;
					MpAxisBasic_AxisSlave.Stop := FALSE;
					MpAxisBasic_AxisSlave.MoveAbsolute := FALSE;
					MpAxisBasic_AxisSlave.MoveVelocity := FALSE;
					MpAxisBasic_AxisSlave.ErrorReset := Axis1.cmdReset;
					MpAxisCamSequencer_0.ErrorReset := Axis1.cmdReset;
					IF (NOT(MpAxisBasic_AxisSlave.Error ) AND NOT(MpAxisBasic_AxisMaster.Error )) THEN
						Axis1.statusFaulted:=FALSE;
						Axis1.cmdReset := FALSE;
						AxisStep := STATE_WAIT;
						Axis1.statusErrorID := 0;
						MpAxisBasic_AxisMaster.ErrorReset := FALSE;
						MpAxisBasic_AxisSlave.ErrorReset  := FALSE;
					MpAxisCamSequencer_0.ErrorReset := FALSE;
					gErrorID := 0;
					alarmActive := FALSE;
		
					END_IF
					
	END_CASE
	Data[0] := MpAxisBasic_AxisMaster.Position;
	Data[1] := MpAxisBasic_AxisSlave.Position;
	Data[2] := BOOL_TO_REAL(Axis1.cmdCam) * 360.0;
	Data[3] := 0.0;
	Data[4] := 0.0;
	Data[5] := MpAxisCamSequencer_0.ActualStateIndex * 50.0;
		
	
	gErrorID;

	
	(* Call FBs *)	
	MpAxisBasic_AxisMaster();	
	MpAxisBasic_AxisSlave();	
	MpAxisCamSequencer_0();
	
	// Stop blade pass the cut zone
	cutJogEnableFW := (MpAxisBasic_AxisSlave.Position > -0.1  AND MpAxisBasic_AxisSlave.Position < cutJogEnableFWL ) OR // stop jog when the blade is off
	(MpAxisBasic_AxisSlave.Position > cutJogEnableFWM  AND MpAxisBasic_AxisSlave.Position < 359.9999) OR
	bypassProtection;
	cutJogEnableBW := (MpAxisBasic_AxisSlave.Position > -0.1  AND MpAxisBasic_AxisSlave.Position < cutJogEnableBWL ) OR // stop jog when the blade is off
	(MpAxisBasic_AxisSlave.Position > cutJogEnableBWM  AND MpAxisBasic_AxisSlave.Position < 359.9999) OR
	bypassProtection;

	
	
	
	IF gErrorID > 0 THEN  // MAchine status code
		gMachineStatus := 3; // Error
		displayStopImage := TRUE;
		displayRunImage := FALSE;
	ELSIF AxisStep = 0 AND gServoInitialized  THEN
		gMachineStatus := 6;
		displayStopImage := TRUE;
		displayRunImage := FALSE;
	ELSIF MpAxisBasic_AxisMaster.MoveVelocity AND gErrorID = 0 THEN // define the stop mode
		gMachineStatus := 1;
		displayStopImage := FALSE;
		displayRunImage := TRUE;
	ELSIF AxisStep = 40 THEN
		gMachineStatus := 2;
		displayStopImage := TRUE;
		displayRunImage := FALSE;
	ELSIF Axis1.statusOff = 1 THEN // define the stop mode finalize mpod
		gMachineStatus := 5;
		displayStopImage := TRUE;
		displayRunImage := FALSE;
	ELSIF NOT MpAxisBasic_AxisMaster.MoveVelocity AND AxisStep = 10   THEN // define the Jog mode
		gMachineStatus := 0;	
		displayStopImage := TRUE;
		displayRunImage := FALSE;
	ELSIF gServoInitialized = 0 THEN // servo are intialized
		gMachineStatus := 4;
		displayStopImage := TRUE;
		displayRunImage := FALSE;
		
		
	END_IF		
	gMachineStatusMessage := gMachineStatusArray[gMachineStatus];	 // HMI status

	
	cutEnd := (MpAxisBasic_AxisSlave.Position > cutStartDegree AND MpAxisBasic_AxisSlave.Position < cutEndDegree ) OR (MpAxisBasic_AxisSlave.Position > cutStartDegree + 180.0 AND MpAxisBasic_AxisSlave.Position < cutEndDegree +180 AND twoCutEnable );

	IF EDGEPOS(cutEnd) THEN  // if one cut done cut the signal plc
		Axis1.cmdCam := FALSE;
		cutCount := cutCount +1; // add one cut is done
		
	END_IF
	
	IF gResetCount THEN  // reset cut count 
		cutCount := 0;
	END_IF
	
	

	
	
	
END_PROGRAM

PROGRAM _EXIT
	
	MpAxisBasic_AxisMaster.Enable := FALSE;
	MpAxisBasic_AxisSlave.Enable := FALSE;
	MpAxisCamSequencer_0.Enable := FALSE;
	MpAxisBasic_AxisMaster();
	MpAxisBasic_AxisSlave();
	MpAxisCamSequencer_0();

END_PROGRAM
