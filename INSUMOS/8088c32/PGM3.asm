           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT

	   ORG 400H

START	   MOV AL,1

LOOP	   OUT 0,AL
	   ROL  AL,1
	   JMP LOOP

	   END