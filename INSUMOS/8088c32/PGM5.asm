           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT

	   ORG 400H

START	   MOV BX,0
	   MOV AL,[BX]
	   OUT 0,AL
	   INT 3

	   END