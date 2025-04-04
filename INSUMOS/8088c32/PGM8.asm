           CPU     "8086.TBL"      ; CPU TABLE
           HOF     "INT8"         ; HEX OUTPUT FORMAT

SCAN_DISPLAY  EQU 0D000H
CS_SEGMENT    EQU 0F000H

	   ORG 400H

START	   MOV CX,100
	   
ON	   PUSH CX
           MOV SI,TEXT1
           CALL  FAR PTR SCAN_DISPLAY,CS_SEGMENT ; FD000H 
	   POP CX
	   LOOP ON

	   MOV CX,200

OFF	   PUSH CX
           MOV SI,TEXT2
           CALL  FAR PTR SCAN_DISPLAY,CS_SEGMENT ; FD000H 
	   POP CX
	   LOOP OFF

	   JMP START

	   

TEXT1      DFB 0
           DFB 0
	   DFB 0
	   DFB 3fh ; O
	   DFB 38h ; L
	   DFB 38h ; L
	   DFB 79h ; E 
	   DFB 76h ; H


TEXT2      DFB 0
           DFB 0
	   DFB 0
	   DFB 0
	   DFB 0
	   DFB 0
	   DFB 0 
	   DFB 0

	   END
