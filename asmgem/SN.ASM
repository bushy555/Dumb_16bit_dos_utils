0AF0:0100 B013          MOV	AL,13                              
0AF0:0102 CD10          INT	10                                 
0AF0:0104 88CA          MOV	DL,CL                              
0AF0:0106 20DA          AND	DL,BL                              
0AF0:0108 B40C          MOV	AH,0C                              
0AF0:010A CD10          INT	10                                 
0AF0:010C FEC9          DEC	CL                                 
0AF0:010E 75F4          JNZ	0104                               
0AF0:0110 FEC3          INC	BL                                 
0AF0:0112 75F8          JNZ	010C                               
0AF0:0114 C3            RET	                                   
