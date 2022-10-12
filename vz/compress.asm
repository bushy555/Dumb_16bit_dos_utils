; DM. 15/Apr/2021.
; FOR VZ : Compression from raw image to asm include file.
;
; COMPRESS <RAW MODE(1) IMAGE> <OUT.INC>
;
; FOR asm include file to use for VZ RLE Compression program.
; Take the output of this, and include it into VZ's RLE decompression program.
;
;
;
; PSP --> RAW.
; RAW --> STEPJ --> INC file as text. AA, AA, AA, AA, AA.
; TO DO: STEPJ --> dumps this as option as binary. 
;
; This COMPRESS util needs binary form, IN: AA, AA, AA to output RLE.
; (Will not and does not read in ASCII TEXT).
;
; TO DO: incorporate RLE COMPRESS into STEPJ, prior to writing to ASCII INC.
;    or: option for RLE, to 1) write out as binary to temp file.
;                           2) read back in binary file and RLE, out ascii.
;


        IDEAL
        MODEL   small
        STACK   256
cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed
ASCnull EQU     0               ; ASCII null character
        DATASEG
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         Db      0       ; Byte I/O variable
fullbyte	db	0,0,0
counter		db 	0
name1		db	'$',0		 	; $0
name2		db	',',0		 	; ,  <COMMA><SPACE>
name3		db	029h, 03bh		; );
name4		db	00dh, 00ah		; <cr>
name5		db	'0x'		 	; 0x
name6		db	'.byte '	 	; .byte
name7		db	'0'		 	; 0
name8		db	'defb '			; defb
name9		db	'bpoke(i+0x'		; bpoke(i+0x'
name0		db	'db '			; db
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   DB      cr,lf,'!VZ! RLE COMPRESS. v3. DJM, 15/4/21.'
	DB	cr,lf
	DB	cr,lf,'Pre-requisites:'
	DB	cr,lf,'1) Paint Shop Pro graphic to be exported as .RAW file format.'
	DB	cr,lf,'        This typically saves as a binary file with each pixel being' 
	DB	cr,lf,'        colour 1 to 4.'
	DB	cr,lf
	DB	cr,lf,'2) STEPL to process .RAW to a .BINary output.'
	DB	cr,lf,'        This converts all pixel colours 1-4 to full 255-byte values.'
	DB	cr,lf,'        ie:    STEPL <psp-file.RAW> <out.BIN>    --- Use option (A).'
	DB	cr,lf
        DB      cr,lf,'COMPRESS <in-file.BIN> <out-file.INC>'
	DB	cr,lf,'        RLE Compression is applied. '
        DB	cr,lf,'        Output <out.INC> file is ascii compressed to be used in '
	DB	cr,lf,'        a decompress program.'
	DB	cr,lf,'INPUT  : mode(1) RAW BINARY converted file, after STEPL conversion'
	DB	cr,lf,'        from Paint Shop Pro export.'
	DB	cr,lf,'OUTPUT : mode(1) RLE Compressed ascii .INC file.'
        DB      cr,lf,cr,lf,0

        CODESEG
        EXTRN StrLength:proc, StrUpper:proc
        EXTRN StrWrite:Proc, NewLine:Proc				;-----  From STRIO.OBJ
        EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ
Start:  				
        mov     ax, @data               
        mov     es, ax                  
        call    GetParams               
        call    ParamCount              
        cmp     dx, 2                   
        je      @@10                    
        mov     di, offset notes        
        call    StrWrite                
        jmp     Exit                    
@@10:   xor     cx, cx                  
        call    GetOneParam             
        mov     dx, di                  
        xor     al, al                  
        mov     ah, 3Dh                 
        int     21h                      
        jnc     @@20                    
        jmp     Errors                  
@@20:   mov     [inFile], ax            
@@30:   mov     cx, 1                   
        call    GetOneParam             
        mov     dx, di                  
        xor     cx, cx                  
        mov     ah, 3Ch                 
        int     21h                     
        jnc     @@40                    
        jmp     Errors                  
@@40:   mov     [outFile], ax           
;-----------------------------------------------------------------------------------------------------------------
	NOP
	NOP
	NOP

 
	call	write_db
	call	write_0



@@_41:	mov	cx, 0
@@_42:	mov	dx, 0
	call	readbyte		; read first char in.		

	call 	NumToASCII      	; Convert number to hex
	call	writebyte2		; write first char out.

@@_43:
@@_44:	inc	cx			; already read ONE
	
	mov	dl, al			; save first char
	call	readbyte		; read next char
	cmp	dl, al
	je	@@_44			; if same, then go back for another read.
	mov	dl, al
	mov	al, cl

	call	write_comma
	call	write_0
	call 	NumToASCII              ; Convert number to hex
	call	writebyte2		; write out QNTY

	mov	cx, 0			; QNTY counter = 0
	mov	al, dl


;===================================================
;   DO COUNTER <--> WIDTH CALCULATION CHECK
;===================================================

@@_70:	inc	[counter]
	cmp	[counter], 8		; width is 16, then do a <CR>			; 
	je	@@_71									;  DO WIDTH.

	call	write_comma
	call	write_0
	call 	NumToASCII              ; Convert number to hex
	call	writebyte2		; write out QNTY
	jmp	@@_43

@@_71:	mov	[counter], 0
	call	write_cr
	call	write_db
	call	write_0
	call 	NumToASCII              ; Convert number to hex
	call	writebyte2		; write out QNTY


@@_72:	jmp	@@_43





; ================================
; Z80 compression implementation
; ================================
;	ld	a, (hl)
;l0:	ld	ix, 0		; local char counter
;	ld	c, 0
;l1:	ld	a, (hl)
;	ld	c, a		; C := original.
;l2:	inc	hl		; inc HL pointer.
;	inc	ix		; local counter.
;	inc	iy		; global counter
;	ld	a, (hl)
;	cp	c		; c=current. a=prior
;	jr	nz, write	; is not equal, so jump to write
;	jr	l2		; is equal.
;write:	ld	a, c		; write out CHAR
;	ld	(de), a
;	inc	de
;	ld	a, ixl		; write out QNTY
;	ld	(de), a
;	inc	de
;	push	hl
;	push	de
;	push	iy
;	push	ix
;	push	bc
;	push	af
;
;	push	iy		; IY=global counter = DE
;	pop	de
;	ld	hl, 2048	; CP HL with DE
;	rst	$18		; RST $18 = "CMP HL, DE"
;	jr	c, quit		; C = "HL > DE, so jump"
;	
;	pop	af
;	pop	bc
;	pop	ix
;	pop	iy
;	pop	de
;	pop	hl
;	jp	l0
;
;
;quit: 	pop	af
;	pop	bc
;	pop	ix
;	pop	iy
;	pop	de
;	pop	hl
;	ei




write_comma:
	push	ax
	push	bx
	push	cx
	push	dx
	mov	dx, offset name2	; write <COMMA>
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 1
        int     21h                     
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

write_cr:
	push	ax
	push	bx
	push	cx
	push	dx
	mov	dx, offset name4	; write   <CR>
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 2                   
        int     21h                     
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

write_db:
	push	ax
	push	bx
	push	cx
	push	dx
	mov	dx, offset name0	; write 'db '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 3
	int	21h
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

write_0:
	push	ax
	push	bx
	push	cx
	push	dx
	mov	dx, offset name1	; write   '$'    write   0$
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 1
        int     21h                     
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

	
;-----------------------------------------------------------------------------------------------------------------

PROC 	readbyte
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                    ; ax=0=end of file; jump
	mov	di, offset onebyte
	mov	al, [di]
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	ret
@@802:  pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx


	call	write_comma
	call	write_0
	mov	al, 1
	call 	NumToASCII              ; Convert number to hex
	call	writebyte2		; write out QNTY
	call	write_cr



	mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit2                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit2:  mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program
ENDP	readbyte


PROC	writebyte
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	mov	di, offset oneByte
	mov	[di], al
	push	ax
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 2                   ; Specify one byte to write
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h			; Call DOS to write to file
	pop	ax
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	ret
ENDP	writebyte


PROC	writebyte2
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	push	ax
	mov	dx, offset fullbyte
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 2                   ; Specify one byte to write
        int     21h			; Call DOS to write to file
	pop	ax
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	ret
ENDP	writebyte2






Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

;------------------------------------------------------------------------------------------
; 
;   Instructions jump to here to handle any I/O errors, which
;   cause the program to end after displaying a message.
;
;------------------------------------------------------------------------------------------

Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program




%NEWPAGE
;---------------------------------------------------------------
; FileExists            Test whether a file already exists
;---------------------------------------------------------------
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
@@20:   cmp     al, '@'                 ; Reset zero flag (zf=0)
@@99:   ret                             ; Return to caller
ENDP    Confirm



PROC    HexDigit
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@10            ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        ret                     ; Return to caller
@@10:   or      dl, '0'         ; Convert digits 0 to 9
        ret                     ; Return to caller
ENDP    HexDigit
%NEWPAGE
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
@@10:   sub     dl, '0'         ; Convert ASCII to decimal
        test    dl, 0f0h        ; Check 4 msbs (sets cf=0)
        jnz     @@99            ; Jump  if error (not digit or A-F)
        xor     dh, dh          ; Convert byte in dl to word in dx
        cmp     dx, bx          ; Compare to number base (cf=1 if ok)
@@99:   cmc                     ; Complement cf to set/reset err flag
        ret                     ; Return to caller
ENDP    ValCh
%NEWPAGE
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

;--------------------------------------------------------------
; Assumes AL = incoming byte to be written out in ASCII form.
;--------------------------------------------------------------
;       ax = 16-bit value to convert
;       bx = base for result (2=binary;10=decimal;16=hex)
;       cx = minimum number of digits to output
;       di = address of string to hold result
NumToASCII:
 
	push	ax
	push	bx
	push	cx
        push    dx              ; Save some modified registers
        push    di
        push    si

	mov	cx, 2						; 2 char outputWRITE OUT char ROUTINE.   (LOOP
	mov	ah, 0									; #####################################
;	mov	al, [outb]								; #####################################
	mov	bx, 16									; 
	mov	di, offset fullbyte

; si = count of digits on stack

        xor     si, si          ; Set digit-count to zero
        jcxz    @@20            ; If cx=0, jump to set cx=1
@@10:   xor     dx, dx          ; Extend ax to 32-bit dxax
        div     bx              ; ax<-axdx div bx; dx<-remainder
        call    HexDigit        ; Convert dl to ASCII digit
        push    dx              ; Save digit on stack
        inc     si              ; Count digits on stack
        loop    @@10            ; Loop on minimum digit count
@@20:   inc     cx              ; Set cx = 1 in case not done
        or      ax, ax          ; Is ax = 0? (all digits done)
        jnz     @@10            ; If ax <> 0, continue conversion
        mov     cx, si          ; Set cx to stack char count
        jcxz    @@40            ; Skip next loop if cx=0000
        cld                     ; Auto-increment di for stosb
@@30:   pop     ax              ; Pop next digit into al
        stosb                   ; Store digit in string; advance di
        loop    @@30            ; Loop for cx digits
@@40:   mov     [byte di], ASCnull      ; Store null at end of string
        pop     si              ; Restore saved registers
        pop     di
        pop     dx
	pop	cx
	pop	bx
	pop	ax
        ret                     ; Return to caller



;---------------------------------------------------------------
; BinToAscDec   Convert binary values to ASCII decimal strings
;---------------------------------------------------------------
; Input:
;       ax = 16-bit value to convert
;       cx = minimum number of digits to output
;       di = address of string to hold result
;       Note: assumes string is large enough to hold result
;       Note: outputs full result if cx is less than the number
;             of digits required to specify the result
;
; Output:
;       none
; Registers:
;       ax, cx (indirectly)
;---------------------------------------------------------------
BinToAscDec:
        push    bx              ; Save bx on stack
        mov     bx, 10          ; Set base = 10 (decimal)
        call    NumToAscii      ; Convert ax to ASCII
        pop     bx              ; Restore bx
        ret                     ; Return to caller



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
@@10:   dec     si              ; Adjust si to last probable digit
@@20:   ret                     ; Return to caller
ENDP    ChToBase
%NEWPAGE
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
@@10:   cmp     si, di          ; At front of string?
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
@@99:   ret                     ; Return to caller
ENDP    AscToNum

        END     Start        ; End of program / entry point
