//[*********************************************************************************
//* Primary Author:    	Morteza Shahmoradi
//* Created:   			Dec 7, 2023
//* Description: 		recpie management
//	*********************************************************************************]  
ACTION RecipeStateMachine: 	

	McAcpAxCamAutDefinetyp.DataAddress := ADR(McAcpAxCamAutPartyp);
	MC_BR_CamAutomatGetPar_AcpAx_0(Slave := ADR(gCutter_MpLink) , CamAutomat := McAcpAxCamAutDefinetyp);
	 
	MC_BR_CamAutomatSetPar_AcpAx_0(Slave := ADR(gCutter_MpLink) , CamAutomat := McAcpAxCamAutDefinetyp , AdvancedParameters := McAcpAxAdvCamAutSetPar);
	
	IF  gReceiptChanged THEN // Recepit Change paramter command comes from HMI
		
		RecipeCurrent := gCutPar[gRecepitRefHmi].RecipeName;
		CutType	:= gCutPar[gRecepitRefHmi].selCutType;
		gMinValue := gCutPar[gRecepitRefHmi].minimumCutSpped;
		gConvPrSpeed := gCutPar[gRecepitRefHmi].productionSpeed;
		upperPosition :=  gCutPar[gRecepitRefHmi].upperPosition;
		lowerPosition := gCutPar[gRecepitRefHmi].lowerPosition;
		FOR i := 0 TO 2 BY 1 DO
			RecipeList[i] := gCutPar[i].RecipeName;
		END_FOR;
		pasteSelection := TRUE;  // Ececute of cam automat save
		
		gReceiptChanged := FALSE;
	END_IF	
	

		
	IF gSaveParameter THEN  // save paramter command comes from HMI
		gCutPar[gRecepitRefHmi].RecipeName := RecipeCurrent;
		RecipeList [gRecepitRefHmi] := RecipeCurrent; 
		gCutPar[gRecepitRefHmi].selCutType := CutType;
		gCutPar[gRecepitRefHmi].upperPosition := upperPosition;
		gCutPar[gRecepitRefHmi].lowerPosition := lowerPosition;
		gCutPar[gRecepitRefHmi].minimumCutSpped := gMinValue;
		gCutPar[gRecepitRefHmi].productionSpeed := gConvPrSpeed;

		gSaveParameter := FALSE; // Ececute of cam automat save
		copySelctionValid := TRUE;
		
	END_IF
	IF 	EDGEPOS( MC_BR_CamAutomatSetPar_AcpAx_0.Done) THEN // remove the excute command after save
		MC_BR_CamAutomatSetPar_AcpAx_0.Execute := 0;
	END_IF
	
	
		FOR i := 0 TO 2 BY 1 DO  // create data provider for recepir selection
		DataProviderMid[i] := CONCAT(DataProviderTail[i],RecipeList[i]);
		DataProvider[i] := CONCAT(DataProviderMid[i],DataProviderHead[i]); 
	END_FOR;
	
	IF copyAll THEN
		gCutPar[1] := gCutPar[0] ;
		gCutPar[2] := gCutPar[0] ;

	END_IF
	
	
		MC_BR_CamAutomatGetPar_AcpAx_0.Execute := copySelction AND gManualActive AND NOT gSaveParameter  AND NOT gReceiptChanged AND gServoInitialized AND NOT validDateCamExist ;
	IF MC_BR_CamAutomatGetPar_AcpAx_0.Done THEN  // copy paramters to the data 
		copySelction := FALSE;
		MC_BR_CamAutomatGetPar_AcpAx_0.Execute := FALSE; // get the right paramter at the start up
		McAcpAxCamAutPartypDef[0]:= McAcpAxCamAutPartyp;
		McAcpAxCamAutPartypDef[1]:= McAcpAxCamAutPartyp;
		McAcpAxCamAutPartypDef[2]:= McAcpAxCamAutPartyp; // save the parater to the diffrent set up
		McAcpAxCamAutPartypDef[1].State[2].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[2].CompensationParameters.SlaveCompDistance - upperPosition;
		McAcpAxCamAutPartypDef[1].State[4].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[4].CompensationParameters.SlaveCompDistance + upperPosition;
		McAcpAxCamAutPartypDef[1].State[5].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[5].CompensationParameters.SlaveCompDistance - upperPosition;
		McAcpAxCamAutPartypDef[1].State[7].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[7].CompensationParameters.SlaveCompDistance + upperPosition;

		McAcpAxCamAutPartypDef[2].State[2].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[2].CompensationParameters.SlaveCompDistance + lowerPosition;
		McAcpAxCamAutPartypDef[2].State[4].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[4].CompensationParameters.SlaveCompDistance - lowerPosition;
		McAcpAxCamAutPartypDef[2].State[5].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[5].CompensationParameters.SlaveCompDistance + lowerPosition;
		McAcpAxCamAutPartypDef[2].State[7].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[7].CompensationParameters.SlaveCompDistance - lowerPosition;
		pasteSelection := TRUE;
		validDateCamExist := TRUE;
	END_IF

	IF copySelctionValid AND validDateCamExist THEN // if the valid datat esit then adjust the state of the machine
		McAcpAxCamAutPartypDef[1].State[2].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[2].CompensationParameters.SlaveCompDistance - upperPosition;
		McAcpAxCamAutPartypDef[1].State[4].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[4].CompensationParameters.SlaveCompDistance + upperPosition;
		McAcpAxCamAutPartypDef[1].State[5].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[5].CompensationParameters.SlaveCompDistance - upperPosition;
		McAcpAxCamAutPartypDef[1].State[7].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[7].CompensationParameters.SlaveCompDistance + upperPosition;

		McAcpAxCamAutPartypDef[2].State[2].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[2].CompensationParameters.SlaveCompDistance + lowerPosition;
		McAcpAxCamAutPartypDef[2].State[4].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[4].CompensationParameters.SlaveCompDistance - lowerPosition;
		McAcpAxCamAutPartypDef[2].State[5].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[5].CompensationParameters.SlaveCompDistance + lowerPosition;
		McAcpAxCamAutPartypDef[2].State[7].CompensationParameters.SlaveCompDistance := McAcpAxCamAutPartypDef[0].State[7].CompensationParameters.SlaveCompDistance - lowerPosition;
		pasteSelection := TRUE; // set the parameter to the servos
	END_IF
	
		
	IF pasteSelection AND NOT gSaveParameter  AND NOT gReceiptChanged AND validDateCamExist THEN // only save the new cam dat if its valid
		
		McAcpAxCamAutPartyp :=  McAcpAxCamAutPartypDef[CutType-1]; // cam data is valid copy
		MC_BR_CamAutomatSetPar_AcpAx_0.Execute := pasteSelection AND gManualActive ;
		pasteSelection := FALSE;
	END_IF	
	
END_ACTION
