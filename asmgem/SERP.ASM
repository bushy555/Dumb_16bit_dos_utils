0AF0:0100 B013          MOV	AL,13                              
0AF0:0102 CD10          INT	10                                 
0AF0:0104 B303          MOV	BL,03                              
0AF0:0106 BEA0A0        MOV	SI,A0A0                            
0AF0:0109 8EDE          MOV	DS,SI                              
0AF0:010B B98B0C        MOV	CX,0C8B                            
0AF0:010E 3228          XOR	CH,[BX+SI]                         
0AF0:0110 88ACC2FE      MOV	[SI+FEC2],CH                       
0AF0:0114 4E            DEC	SI                                 
0AF0:0115 75F5          JNZ	010C                               
0AF0:0117 CD16          INT	16                                 
0AF0:0119 87C3          XCHG	AX,BX                              
0AF0:011B CD10          INT	10                                 
0AF0:011D C3            RET	                                   
