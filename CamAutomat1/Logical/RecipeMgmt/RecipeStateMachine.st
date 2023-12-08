ACTION RecipeStateMachine: 	

	
	IF  gReceiptChanged THEN
		gReceiptChanged := FALSE;
		RecipeCurrent := gCutPar[gRecepitRefHmi].RecipeName;
		
		gMinValue := gCutPar[gRecepitRefHmi].minimumCutSpped;
		gConvPrSpeed := gCutPar[gRecepitRefHmi].productionSpeed;

		FOR i := 0 TO 9 BY 1 DO
			RecipeList[i] := gCutPar[i].RecipeName;
		END_FOR;
		
	END_IF	
	

		
	IF gSaveParameter THEN
		gCutPar[gRecepitRefHmi].RecipeName := RecipeCurrent;

		gSaveParameter := FALSE;
		gCutPar[gRecepitRefHmi].minimumCutSpped := gMinValue;
		gCutPar[gRecepitRefHmi].productionSpeed := gConvPrSpeed;
		
	END_IF

	FOR i := 0 TO 9 BY 1 DO
		DataProviderMid[i] := CONCAT(DataProviderTail[i],RecipeList[i]);
		DataProvider[i] := CONCAT(DataProviderMid[i],DataProviderHead[i]); 
	END_FOR;
	
END_ACTION
