code    segment public
        assume  cs:code
        org     100h
.386
start:
@0100:  MOV     AL,13h
@0102:  INT     10h
@0104:  MOV     BL,03
@0106:  MOV     SI,0A0A0h
@0109:  MOV     DS,SI
@010c equ $ + 1
@010B:  MOV     CX,0C8Bh

@010E:  XOR     CH,[BX+SI]
@0110:  MOV     [SI+0FEC2h],CH
@0114:  DEC     SI
@0115:  JNZ     @010C
@0117:  INT     16h
@0119:  XCHG    AX,BX
@011B:  INT     10h
@011D:  RET
   code   ends
end       start
                                        
