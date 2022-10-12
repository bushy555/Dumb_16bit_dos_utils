;
; vz dumper. djm. v3. 3/mar/2k9.
; dumps vz .DSK to an output text file. 
; Quick and dirty!
;
; VZDSKDUMP <in.dsk> <out.txt>
; VZDSKDUMP GAMES.DSK GAMES_DISK3.TXT
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INFO:
; VZ directory occupies Track 0, Sector 0 through to the end of sector 14.
; Sector 0, Track 15 contains pointers to something. forget.
; ....meaning that the directory size is 1920 bytes, and can contain a maximum of 112 filenames per side of a disk.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  File type 1 byte
;  Delimitor (3AH) 1 byte
;  File name 8 byte
;  Start address 2 byte
;  End address 2 byte
;  Start track 1 byte
;  Start sector 1 byte
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 3376, 3200, 3072
;

        	IDEAL
        	MODEL   small
        	STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
ASCnull         EQU     0               ; ASCII null character

        DATASEG
_crlf		db	13,10,0
_del2		db	'?',0
_spaces		db	'    ',0
_spaces2	db	' ',0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         Db      0,0,0,0,0,0,0,0       ; Byte I/O variable
s_track		db	0
e_track		db	0
s_address	db	0,0
e_address	db	0,0

s_track2	db	0,0,0,0
e_track2	db	0,0,0,0
s_address2	db	0,0,0,0
e_address2	db	0,0,0,0

tempbyte	db	0,0
exCode          DB      0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
notes   	DB      cr,lf,'VZ disk dumper. v3.0. By dave. Junkware. 3/mar/9.'
      	  	DB      cr,lf,'Dumps the directory of a VZ .DSK file to a text file.'
      	  	DB      cr,lf,'Is !rough! with very little error checking',cr,lf
        	DB      cr,lf,'VZDSKDUMP <in.dsk> <out.txt>',cr,lf
	        DB      cr,lf,'ie:  VZDSKDUMP GAMES.DSK GAMES.TXT',cr,lf,0



        CODESEG
        EXTRN StrLength:proc, StrUpper:proc
        EXTRN StrWrite:Proc, NewLine:Proc				;-----  From STRIO.OBJ
        EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ

        PUBLIC  HexDigit, ValCh, NumToAscii
        PUBLIC  BinToAscHex, SBinToAscDec, BinToAscDec, BinToAscBin
        PUBLIC  AscToBin


Start:  mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 2                   ; Does count = 2?
        je      @@10                    ; Continue if param count = 2
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
        jmp     Exit                    ; Exit program

@@10:   xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler

@@20:   mov     [inFile], ax            ; Save input file handle
        mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        call    FileExists              ; Does output file exist?
        jc      @@30                    ; Jump if file does not exist
        call    StrWrite                ; Display file name
        call    Confirm                 ; Else confirm file removal
        je      @@30                    ; Continue if permission given
        jmp     Exit                    ; Else exit program

@@30:   mov     cx, 1                   
        call    GetOneParam             
        mov     dx, di                  
        xor     cx, cx                  
        mov     ah, 3Ch                 
        int     21h                     
        jnc     @@40                    
        jmp     Errors                  
@@40:   mov     [outFile], ax           
	xor	bp, bp

nop
nop
nop
nop
nop
nop


@@50:   inc	bp
	cmp	bp, 1920		; done reading first 1920 bytes (size of directory of VZ disk)
	jl	@@51
	jmp	@@80			; so now go bye bye and exit.			
@@51:	mov	cx, 1

	call	readbyte

;--------------------------------------------------------------------------
@@60:   

	inc	bp
	cmp	bp, 1920		; done reading first 1920 bytes (size of directory of VZ disk)
	jl	@@601
	jmp	@@80			; so now go bye bye and exit.			

@@601:	mov     di, offset oneByte	; READ char. 
	mov	al, [di]
	mov	di, offset tempbyte
	mov	[di], al

@@71:  	mov	cx, 1
	call	readbyte


@@72:		; Is it ':'?
	
	cmp	al, 03ah
	je	@@73
	jmp	@@60

@@73:	mov	di, offset tempbyte
	mov	al, [di]
	cmp	al, 01h			; Is filetype a deleted entry 0x01h?
	jne	@@730
	
	mov	cx, 1			; THEN write filetype of new deleted filetype, '?'
	mov	dx, offset _del2
	call	writebuffer
	jmp	@@731


@@730:	mov     cx, 1                   ; ELSE write filetype 
        mov     dx, offset tempbyte    
	call	writebuffer

	
@@731:	mov     cx, 1  			; Write out ':'
        mov     dx, offset onebyte      
	call	writebuffer


@@74:   add	bp, 13
	mov	cx, 14			; read 8 char filename, 1x S-track, 1x E-Track, 2x S-add, 2x E-add.
	call	readbyte


@@75:   
        mov     cx, 8                    ; write 8 char filename
        mov     dx, offset onebyte      
	call	writebuffer

@@76:	mov     cx, 4			; write 4 spaces
        mov     dx, offset _spaces
	call	writebuffer

	
@@77:	

;	-CHIP 8-	01 00 7AE9 7AEB
;	--------	01 01 7AE9 7AEB
;       c8ED LDR	01 02 7AE9 8ADF


;       ax = 16-bit value to convert
;       bx = base for result (2=binary;10=decimal;16=hex)
;       cx = minimum number of digits to output
;       di = address of string to hold result
;	call	numtoascii


;       ax = 16-bit value to convert
;       cx = minimum number of digits to output
;       di = address of string to hold result
	call	BinToAscHex

	mov	di, offset s_track
	mov	al, [di]
	mov	ah, 0
	mov	cx, 2
	mov	di, offset s_track2
	call	BinToAscHex

	mov	di, offset e_track
	mov	al, [di]
	mov	ah, 0
	mov	cx, 2
	mov	di, offset e_track2
	call	BinToAscHex

	mov	di, offset s_address+1
	mov	al, [di]
	mov	ah, 0
	mov	cx, 2
	mov	di, offset S_address2
	call	BinToAscHex

	mov	di, offset s_address
	mov	al, [di]
	mov	ah, 0
	mov	cx, 2
	mov	di, offset S_address2+2
	call	BinToAscHex

	mov	di, offset e_address+1
	mov	al, [di]
	mov	ah, 0
	mov	cx, 2
	mov	di, offset e_address2
	call	BinToAscHex

	mov	di, offset e_address
	mov	al, [di]
	mov	ah, 0
	mov	cx, 2
	mov	di, offset e_address2+2
	call	BinToAscHex


	jmp	@@_here
	mov	di, offset s_track
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset e_track
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset s_address
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset s_address + 1
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset e_address
	mov	al, [di]
	or	al, 30h
	mov	[di], al
@@_here:


	                 ; write 2 char Start Address
                   
        mov     cx, 2
        mov     dx, offset s_track2
        call	writebuffer
               


@@771:	                 ; write 1 spaces
                   
        mov     cx, 1
        mov     dx, offset _spaces2
        call	writebuffer
                  

@@7710:	mov	cx, 2                 ; write 2 char end Address
        mov     dx, offset e_track2
	call	writebuffer
                  

@@7720:	                 ; write 1 spaces
        mov     cx, 1
        mov     dx, offset _spaces2
	call	writebuffer
                  


@@772:	                 ; write 2 char Start track
        mov     cx, 4
        mov     dx, offset s_address2
	call	writebuffer

@@7730:	                 ; write 1 spaces
        mov     cx, 1
        mov     dx, offset _spaces2
	call	writebuffer

@@773:	                 ; write 1 char end track
        mov     cx, 4
        mov     dx, offset e_address2
  	call	writebuffer


@@78:  	                 ; Write <CR><LF>
        mov     cx, 2          
        mov     dx, offset _crlf 
	call	writebuffer
@@79:	jmp	@@50


@@80:   mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program
Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

; Input:
;       ds:dx = address of ASCIIZ file name
; Output:
;       cf = 0 (jnc) = File of this name exists
;       cf = 1 (jc)  = File of this name does not exist
; Registers: ax, bx
;---------------------------------------------------------------
PROC    FileExists
        xor     al, al          ; Specify read-only access
        mov     ah, 3Dh         ; DOS Open-file function
        int     21h             ; Call DOS to open the file
        jc      @@99            ; Exit--file doesn't exist
        mov     bx, ax          ; Copy handle to bx
        mov     ah, 3Eh         ; DOS Close-file function
        int     21h             ; Close the file
        clc                     ; Clear carry flag (file exists)
@@99:
        ret                             ; Return to caller
ENDP    FileExists
%NEWPAGE
;---------------------------------------------------------------
; Confirm               Get Yes/No confirmation from user
;---------------------------------------------------------------
; Input:
;       none
; Output:
;       zf = 0 (jnz) = user typed N or n
;       zf = 1 (jz)  = user typed Y or y
; Registers: ax, cx, di
;---------------------------------------------------------------
PROC    Confirm
        mov     di, offset Prompt       ; Address prompt string
        call    StrWrite                ; Display message
        mov     ah, 1                   ; DOS GetChar function
        int     21h                     ; Get user response
        cmp     al, 'Y'                 ; Compare with Y
        je      @@99                    ; Exit if char = Y
        cmp     al, 'y'                 ; Compare with y
        je      @@99                    ; Exit if char = y
        cmp     al, 'N'                 ; Compare with N
        je      @@20                    ; Handle No response
        cmp     al, 'n'                 ; Compare with n
        jne     Confirm                 ; Repeat if not Y, y, N, n
@@20:
        cmp     al, '@'                 ; Reset zero flag (zf=0)
@@99:   
        ret                             ; Return to caller
ENDP    Confirm



PROC 	readbyte
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            
        mov     dx, offset oneByte      
        int     21h                    
        jnc     @@rb2
        jmp     Errors                 
@@rb2:	mov     di, offset oneByte
	mov	al, [di]
	ret
ENDP	readbyte





PROC	writebuffer
	; cx count chars
	; dx offset
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        int     21h			; Call DOS to write to file
        jnc     @@wb2
        jmp     Errors                 
@@wb2:	ret
ENDP	writebuffer







;---------------------------------------------------------------
; HexDigit      Convert 4-bit value to ASCII digit
;---------------------------------------------------------------
; Input:
;       dl = value limited to range 0..15
; Output:
;       dl = ASCII hex digit equivalent
; Registers:
;       dl
;---------------------------------------------------------------
PROC    HexDigit
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@10            ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        ret                     ; Return to caller
@@10:
        or      dl, '0'         ; Convert digits 0 to 9
        ret                     ; Return to caller
ENDP    HexDigit

;---------------------------------------------------------------
; ValCh         Convert ASCII digit char to binary value
;---------------------------------------------------------------
; Input:
;       dl = ASCII digit '0'..'9'; 'A'..'F'
;       bx = base (2=binary, 10=decimal, 16=hexadecimal)
; Output:
;       cf = 0: dx = equivalent binary value
;       cf = 1: bad char for this number base (dx is meaningless)
; Registers:
;       dx
;---------------------------------------------------------------
PROC    ValCh
        cmp     dl, '9'         ; Check for possible hex digit
        jbe     @@10            ; Probably '0'..'9', jump
        sub     dl, 7           ; Adjust hex digit to 3A..3F range
@@10:
        sub     dl, '0'         ; Convert ASCII to decimal
        test    dl, 0f0h        ; Check 4 msbs (sets cf=0)
        jnz     @@99            ; Jump  if error (not digit or A-F)

        xor     dh, dh          ; Convert byte in dl to word in dx
        cmp     dx, bx          ; Compare to number base (cf=1 if ok)
@@99:
        cmc                     ; Complement cf to set/reset err flag
        ret                     ; Return to caller
ENDP    ValCh

;---------------------------------------------------------------
; NumToASCII    Convert unsigned binary value to ASCII
;---------------------------------------------------------------
; Input:
;       ax = 16-bit value to convert
;       bx = base for result (2=binary;10=decimal;16=hex)
;       cx = minimum number of digits to output
;       di = address of string to hold result
;       Note: assumes string is large enough to hold result
;       Note: creates full result if cx is less than the number
;             of digits required to specify the result or cx = 0
;       Note: if cx=0 and ax=0 then length of string will be 0
;             set cx=1 if you want string to = '0' if ax=0
;       Note: assumes (2<=bx<=16)
; Output:
;       none
; Registers:
;       ax, cx
;---------------------------------------------------------------
PROC    NumToASCII              ; Normal entry point
        push    dx              ; Save some modified registers
        push    di
        push    si

; si = count of digits on stack

        xor     si, si          ; Set digit-count to zero
        jcxz    @@20            ; If cx=0, jump to set cx=1
@@10:
        xor     dx, dx          ; Extend ax to 32-bit dxax
        div     bx              ; ax<-axdx div bx; dx<-remainder
        call    HexDigit        ; Convert dl to ASCII digit
        push    dx              ; Save digit on stack
        inc     si              ; Count digits on stack
        loop    @@10            ; Loop on minimum digit count
@@20:
        inc     cx              ; Set cx = 1 in case not done
        or      ax, ax          ; Is ax = 0? (all digits done)
        jnz     @@10            ; If ax <> 0, continue conversion
        mov     cx, si          ; Set cx to stack char count
        jcxz    @@40            ; Skip next loop if cx=0000
        cld                     ; Auto-increment di for stosb
@@30:
        pop     ax              ; Pop next digit into al
        stosb                   ; Store digit in string; advance di
        loop    @@30            ; Loop for cx digits
@@40:
        mov     [byte di], ASCnull      ; Store null at end of string
        pop     si              ; Restore saved registers
        pop     di
        pop     dx

        ret                     ; Return to caller
ENDP    NumToASCII

;---------------------------------------------------------------
; BinToAscHex   Convert binary values to ASCII hex strings
;---------------------------------------------------------------
; Input:
;       ax = 16-bit value to convert
;       cx = minimum number of digits to output
;       di = address of string to hold result
;       Note: assumes string is large enough to hold result
;       Note: outputs full result if cx is less than the number
;             of digits required to specify the result
; Output:
;       none
; Registers:
;       ax, cx
;---------------------------------------------------------------
PROC    BinToAscHex
        push    bx              ; Save bx on stack
        mov     bx, 16          ; Set base = 16 (hex)
        call    NumToAscii      ; Convert ax to ASCII
        pop     bx              ; Restore bx
        ret                     ; Return to caller
ENDP    BinToAscHex

;---------------------------------------------------------------
; BinToAscDec   Convert binary values to ASCII decimal strings
;---------------------------------------------------------------
; Input:
;       Same as BinToAscHex
; Output:
;       none
; Registers:
;       ax, cx (indirectly)
;---------------------------------------------------------------
PROC    BinToAscDec
        push    bx              ; Save bx on stack
        mov     bx, 10          ; Set base = 10 (decimal)
        call    NumToAscii      ; Convert ax to ASCII
        pop     bx              ; Restore bx
        ret                     ; Return to caller
ENDP    BinToAscDec

;---------------------------------------------------------------
; SBinToAscDec  Convert signed binary to ASCII decimal strings
;---------------------------------------------------------------
; Input:
;       Same as BinToAscHex (ax = signed 16-bit value)
; Output:
;       none
; Registers:
;       ax, cx
;---------------------------------------------------------------
PROC    SBinToAscDec
        push    bx                      ; Save bx and di
        push    di
        cmp     ax, 0                   ; Is signed ax < 0?
        jge     @@10                    ; Jump if ax >= 0
        neg     ax                      ; Form twos complement of ax
        mov     [byte di], '-'          ; Insert '-' in string
        inc     di                      ; Advance string pointer
@@10:
        mov     bx, 10                  ; Set base = 10 (decimal)
        call    NumToAscii              ; Convert ax to ASCII
        pop     di                      ; Restore bx and di
        pop     bx
        ret                             ; Return to caller
ENDP    SBinToAscDec

;---------------------------------------------------------------
; BinToAscBin   Convert binary values to ASCII binary strings
;---------------------------------------------------------------
; Input:
;       Same as BinToAscHex
; Output:
;       none
; Registers:
;       ax, cx (indirectly)
;---------------------------------------------------------------
PROC    BinToAscBin
        push    bx              ; Save bx on stack
        mov     bx, 2           ; Set base = 2 (binary)
        call    NumToAscii      ; Convert ax to ASCII
        pop     bx              ; Restore bx
        ret                     ; Return to caller
ENDP    BinToAscBin

;---------------------------------------------------------------
; ChToBase      Return number base for string
;---------------------------------------------------------------
; Note:
;       Private subroutine for AscToBin. Don't call directly.
; Input:
;       si = pointer to null terminator at end of string
;       Note: assumes length of string >= 1
; Output:
;       bx = 2(binary), 10(decimal/default), 16(hexadecimal)
;       si = address of last probable digit character in string
; Registers:
;       bx, dl, si      
;---------------------------------------------------------------
PROC    ChToBase
        mov     dl, [byte si-1]   ; Get last char of string
        mov     bx, 16          ; Preset base to 16 (hexadecimal)
        cmp     dl, 'H'         ; Is it a hex string?
        je      @@10            ; Jump if hex
        mov     bx, 2           ; Preset base to 2 (binary)
        cmp     dl, 'B'         ; Is it a binary string?
        je      @@10            ; Jump if binary
        mov     bx, 10          ; Preset base to 10 (decimal)
        cmp     dl, 'D'         ; Is it a decimal string?
        jne     @@20            ; Jump if NOT decimal
@@10:
        dec     si              ; Adjust si to last probable digit
@@20:
        ret                     ; Return to caller
ENDP    ChToBase

;---------------------------------------------------------------
; AscToNum      Convert ASCII characters to binary
;---------------------------------------------------------------
; Note:
;       Private subroutine for AscToBin. Don't call directly.
; Input:
;       ax = initial value (0)
;       bx = number base (2=binary, 10=decimal, 16=hexadecimal)
;       di = address of unsigned string (any format)
;       si = address of last probable digit char in string
; Output:
;       cf = 0 : ax = unsigned value
;       cf = 1 : bad character in string (ax is meaningless)
; Registers:
;       ax, cx, dx, si
;---------------------------------------------------------------
PROC    AscToNum
        mov     cx, 1           ; Initialize multiplier
@@10:
        cmp     si, di          ; At front of string?
        je      @@99            ; Exit if at front (cf=0)
        dec     si              ; Do next char to left
        mov     dl, [byte si]   ; Load char into dl
        call    ValCh           ; Convert dl to value in dx
        jc      @@99            ; Exit if error (bad char)
        push    cx              ; Save cx on stack
        xchg    ax, cx          ; ax=multiplier; cx=partial value
        mul     dx              ; dxax <- digit value * multiplier
        add     cx, ax          ; cx <- cx + ax (new partial value)
        pop     ax              ; Restore multiplier to ax
        mul     bx              ; dxax <- multiplier * base
        xchg    ax, cx          ; ax=partial value; cx=new multiplier
        jmp     @@10            ; do next digit
@@99:
        ret                     ; Return to caller
ENDP    AscToNum

;---------------------------------------------------------------
; AscToBin      Convert ASCII strings to binary values
;---------------------------------------------------------------
; Input:
;       di = ASCIIZ string to convert to binary
;            'H' at end of string = hexadecimal
;            'B' at end of string = binary
;            'D' or digit at end of string = decimal
;            '-' at s[0] indicates negative number
;       Note: no blanks allowed in string
; Output:
;       cf = 1 : bad character in string (ax undefined)
;       cf = 0 : ax = value of string
;       Note: chars in string converted to uppercase
;       Note: null strings set ax to zero
; Registers:
;       ax
;---------------------------------------------------------------
PROC    AscToBin
        push    bx              ; Save modified registers
        push    cx              ; (some of these are changed
        push    dx              ;  in subroutines called by
        push    si              ;  this procedure)

        call    StrUpper        ; Convert string to uppercase
        call    StrLength       ; Set cx to Length of string at di
        xor     ax, ax          ; Initialize result to zero (cf=0)
        jcxz    @@99            ; Exit if length = 0.  ax=0, cf=0
        mov     si, di          ; Address string at di with si
        add     si, cx          ; Advance si to null at end of string
        cmp     [byte di], '-'  ; Check for minus sign
        pushf                   ; Save result of compare
        jne     @@10            ; Jump if minus sign not found
        inc     di              ; Advance di past minus sign
@@10:
        call    ChToBase        ; Set bx=number base; si to last digit
        call    AscToNum        ; Convert ASCII (base bx) to number
        rcl     bx, 1           ; Preserve cf by shifting into bx
        popf                    ; Restore flags from minus-sign check
        jne     @@20            ; Jump if minus sign was not found
        neg     ax              ;  else form twos complement of ax
        dec     di              ;  and restore di to head of string
@@20:
        rcr     bx, 1           ; Restore cf result from AscToNum
@@99:
        pop     si              ; Restore registers
        pop     dx
        pop     cx
        pop     bx
        ret                     ; Return to caller
ENDP    AscToBin

        END     Start        ; End of program / entry point
