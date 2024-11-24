           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT

	   ORG 400H

START	   MOV BX,400H
	   MOV AX,1000H
	   MOV DS,AX
           		
	   MOV AL,[BX] ; DS:BX
	   OUT 0,AL

	   MOV AX,0
	   MOV DS,AX

	   INT 3

	   END
