           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT

	   ORG 400H

START	   INC AL
	   OUT 0,AL
	   JMP START

	   END
