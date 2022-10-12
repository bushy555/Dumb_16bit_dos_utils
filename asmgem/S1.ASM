code    segment public
        assume  cs:code
        org     100h
.386
start:

@0100:  MOV     AL,13h
@0102:  INT     10h
@0104:  MOV     DL,CL
@0106:  AND     DL,BL
@0108:  MOV     AH,0Ch
@010A:  INT     10h
@010C:  DEC     CL
@010E:  JNZ     @0104
@0110:  INC     BL
@0112:  JNZ     @010C
xor ax, ax
int 16h
@0114:  RET

   code   ends
end       start

                              
