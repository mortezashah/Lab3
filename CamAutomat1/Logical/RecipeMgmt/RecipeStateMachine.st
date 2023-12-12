ACTION RecipeStateMachine: 	

	McAcpAxCamAutDefinetyp.DataAddress := ADR(McAcpAxCamAutPartyp);
	MC_BR_CamAutomatGetPar_AcpAx_0(Slave := ADR(gCutter_MpLink) , CamAutomat := McAcpAxCamAutDefinetyp);
	 
	MC_BR_CamAutomatSetPar_AcpAx_0(Slave := ADR(gCutter_MpLink) , CamAutomat := McAcpAxCamAutDefinetyp , AdvancedParameters := McAcpAxAdvCamAutSetPar);
	MC_BR_CamAutomatSetPar_AcpAx_0.Execute := gReceiptChanged OR gSaveParameter;
	IF  gReceiptChanged THEN // Recepit Change paramter command comes from HMI
		gReceiptChanged := FALSE;
		RecipeCurrent := gCutPar[gRecepitRefHmi].RecipeName;
		McAcpAxCamAutPartyp := gCutPar[gRecepitRefHmi].CutType[gCutPar[gRecepitRefHmi].selCutType - 1];
		CutType	:= gCutPar[gRecepitRefHmi].selCutType;
		gMinValue := gCutPar[gRecepitRefHmi].minimumCutSpped;
		gConvPrSpeed := gCutPar[gRecepitRefHmi].productionSpeed;

		FOR i := 0 TO 9 BY 1 DO
			RecipeList[i] := gCutPar[i].RecipeName;
		END_FOR;
		
	END_IF	
	

		
	IF gSaveParameter THEN  // save paramter command comes from HMI
		gCutPar[gRecepitRefHmi].RecipeName := RecipeCurrent;
		gCutPar[gRecepitRefHmi].selCutType := CutType;
		gCutPar[gRecepitRefHmi].CutType[CutType] := McAcpAxCamAutPartyp;
		gSaveParameter := FALSE;
		gCutPar[gRecepitRefHmi].minimumCutSpped := gMinValue;
		gCutPar[gRecepitRefHmi].productionSpeed := gConvPrSpeed;
		
	END_IF

	FOR i := 0 TO 9 BY 1 DO  // create data provider for recepir selection
		DataProviderMid[i] := CONCAT(DataProviderTail[i],RecipeList[i]);
		DataProvider[i] := CONCAT(DataProviderMid[i],DataProviderHead[i]); 
	END_FOR;
	
	IF copyAll THEN
		gCutPar[1] := gCutPar[0] ;
		gCutPar[2] := gCutPar[0] ;
		gCutPar[3] := gCutPar[0] ;
		gCutPar[4] := gCutPar[0] ;
		gCutPar[5] := gCutPar[0] ;
		gCutPar[6] := gCutPar[0] ;
		gCutPar[7] := gCutPar[0] ;
		gCutPar[8] := gCutPar[0] ;
		gCutPar[9] := gCutPar[0] ;
	END_IF
	
	IF copySelction THEN  // copy paramters to the data 
		
		gCutPar[0].CutType[selction]:= McAcpAxCamAutPartyp;
	END_IF
	
END_ACTION
