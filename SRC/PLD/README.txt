O projeto github.com/ppsilv/galasm.git compila o mesmo fonte que o galette e gera os arquivos .chp, .fus e .pin.

A sintaxe dos dois são iguais galasm e galette horrivel sem parenteses, abaixo um exemplo que usei no projeto
MY_PCXT

;  1       2       3    4      5         6       7        8        9    10 
BUFA16 BUFA17 BUFA18  BUFA19  MRD      MWR      NC       NC       NC   GND

; 11      12      13      14      15      16      17      18      19    20       
  NC    ROMCE  RAM896K RAM768K RAM640K RAM512K RAM384K RAM256K RAM128K VCC


A sintaxe boa seria:
           (/BUFA19 * /BUFA18 * /BUFA17 * /BUFA16) * (/MRD + /MWR)
         + (/BUFA19 * /BUFA18 * /BUFA17 * /BUFA16) * (/MRD + /MWR)
Mas como não posso usar parenteses fiz o seguinte:
           /BUFA19 * /BUFA18 * /BUFA17 * /BUFA16 * /MRD + /MWR
         + /BUFA19 * /BUFA18 * /BUFA17 * /BUFA16 * /MRD + /MWR
Mas isso não funciona como esperador e a solução foi esta abaixo:
;/* Ram chips de 64Kbytes */
/RAM128K = /BUFA19 * /BUFA18 * /BUFA17 * /BUFA16 * /MRD 
         + /BUFA19 * /BUFA18 * /BUFA17 * /BUFA16 * /MWR 
         + /BUFA19 * /BUFA18 * /BUFA17 *  BUFA16 * /MRD 
         + /BUFA19 * /BUFA18 * /BUFA17 *  BUFA16 * /MWR

/RAM256K = /BUFA19 * /BUFA18 *  BUFA17 * /BUFA16 * /MRD 
         + /BUFA19 * /BUFA18 *  BUFA17 * /BUFA16 * /MWR 
         + /BUFA19 * /BUFA18 *  BUFA17 *  BUFA16 * /MRD
         + /BUFA19 * /BUFA18 *  BUFA17 *  BUFA16 * /MWR 