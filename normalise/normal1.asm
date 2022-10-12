; 22/8/9
;
;Dopey value program for 'normalising' to find min and max value within <in-file>
; written for VZ sound stuff.
;
;
; ie, file called 'a.in', which consists of:    1,2,4,3,7,1,0,5,2,9,8,0,0
;          program will read and display min: 1,  max: 9, zero's: 3
; program ignores zero's as being the minimum.


; nv = 255 * (n - min) / (max - min)
; nv = 15 * (n - min) / (max - min)


;
        IDEAL
        MODEL   small
        STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
;_double_comma	EQU	16		; gives single end comma
_double_comma	EQU	17		; gives double end comma. DIRTY HACK!
        DATASEG
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'normaliser means program  /djm,  22/8/9', cr,lf
        	DB      cr,lf,'normal1  <in-file>'
        	DB      cr,lf,'See asm file for readme'
		db	cr,lf
        	DB      cr,lf,cr,lf,0
space		db	'   ',0
output		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
buffer0		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ascnull		db	0,0
a		db	cr,lf,'DB ',0
b		db 	0,0,0,0,0,0,0
flag		db 	0,0
reg		db 	0,0
reg_hi		db 	0,0
reg_lo		db	0,0
		db	0,0
notes2		db	cr,lf,'Normaliser MEANS program - to find the MIN + MAX values within a file.'
		db	cr,lf
		db	cr,lf,'Can then apply a normalisation formula, such as:'
		db	cr,lf,' nv = 255 * (n - min) / (max - min)'
		db	cr,lf,' nv = 15 * (n - min) / (max - min)'
		db	cr,lf
		db	cr,lf,0
menu		db	cr,lf,'       Hex Dec Offset',0
mess1		db	cr,lf,'Min  :                  ',0,0,0,0,0,0,0,0,0
mess2		db	cr,lf,'Max  :                  ',0,0,0,0,0,0,0,0,0
zeros		db	cr,lf,'Zeros: ',0,0,0,0,0,0,0,0,0
zero		db 	0
hi_offset	db	0,0,0
lo_offset	db	0,0,0

        CODESEG
        EXTRN StrLength:proc, StrUpper:proc
        EXTRN StrWrite:Proc, NewLine:Proc				;-----  From STRIO.OBJ
        EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ
Start:  				;-----  Initialize and display notes if no parameters entered
        mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment




        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 1                   ; Does count = 4?
        je      @@10                    ; Continue if param count = 4
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
	mov	di, offset notes2
	call	StrWrite
        jmp     Exit                    ; Exit program  -  Attempt to open the input file
@@10:   xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler  -  Check whether the output file already exists
@@20:   mov     [inFile], ax            ; Save input file handle  -  Attempt to create the output file


	mov	di, offset zero
	mov	al, 0
	mov	[di], al

	mov	bx, 1
	mov	cx, 0
	mov	bp, 0	
@@_40a:	call	readbyte
	inc	bx
	cmp	al, 0
	je	@@_40a

	mov	ch, al
	mov	cl, al

@@_41:	
				; nv = 255 * (n - min) / (max - min)
				; 0 80 80 0 80 79 72 0 80 80 82 0 0 0

	call	readbyte
	inc	bx
	cmp	al, 0
	jne	@@_41a
	inc	bp		; inc zero counter
	jmp	@@_41

@@_41a: cmp	al,ch
	jb	@@_42
	mov	ch, al
	mov	si, offset hi_offset
	mov	[si], bl
	inc	si
	mov	[si], bh

@@_42:	cmp	al,cl
	ja	@@_43
	mov	cl, al
	mov	si, offset lo_offset
	mov	[si], bl
	inc	si
	mov	[si], bh
@@_43:	
	jmp	@@_41
	
		



	

@@80:   mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit3                   ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit3:  mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program




Exit4: 

; NumToASCII    Convert unsigned binary value to ASCII
;       ax = 16-bit value to convert
;       bx = base for result (2=binary;10=decimal;16=hex)
;       cx = minimum number of digits to output
;       di = address of string to hold result
	mov	di, offset notes2
	call	strwrite
	mov	di, offset menu
	call	strwrite

	mov	di, offset reg_lo
	mov	al, [di]
	mov	ah, 0
	mov	bx, 16
	mov	cx, 3
	mov	di, offset mess1+9
	call	numtoascii	
	mov	si, offset reg_lo
	mov	al, [si]
	mov	ah, 0
	mov	bx, 10
	mov	cx, 3
	add	di, 4
	call	numtoascii	
	mov	si, offset lo_offset
	mov	al, [si]
	inc	si
	mov	ah, [si]
	mov	bx, 16
	mov	cx, 4
	add	di, 4
	call	numtoascii	
	mov	di, offset mess1
	call	StrWrite


	mov	di, offset reg_hi
	mov	al, [di]
	mov	ah, 0
	mov	bx, 16
	mov	cx, 3
	mov	di, offset mess2+9
	call	numtoascii	
	mov	si, offset reg_hi
	mov	al, [si]
	mov	ah, 0
	mov	bx, 10
	mov	cx, 3
	add	di, 4
	call	numtoascii	
	mov	si, offset hi_offset
	mov	al, [si]
	inc	si
	mov	ah, [si]
	mov	bx, 16
	mov	cx, 4
	add	di, 4
	call	numtoascii	
	mov	di, offset mess2
	call	StrWrite
	
	mov	di, offset zeros
	call	strwrite
	mov	di, offset zero
	mov	ax, bp
	mov	bx, 10
	mov	cx, 3
	mov	di, offset b
	call	numtoascii
	mov	di, offset b + 4
	mov	al, 0
	stosb	
	mov	di, offset b
	call	StrWrite



	mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program









Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program



Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program


PROC 	readbyte
	mov	di, offset reg_lo
	mov	al, cl
	mov	[di], al
	mov	di, offset reg_hi
	mov	al, ch
	mov	[di], al

	push	bx
	push	cx

	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@read2                   ; ax=0=end of file; jump
	mov     di, offset oneByte
	mov	al, [di]
	pop	cx
	pop	bx
	ret
@read2: pop	cx
	pop	bx
	mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
;        jc     Errors3                  ; Else jump to error handler
        jmp     Exit4                    ; Exit if no errors detected
@Exit3: mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program
Errors3:mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program
ENDP	readbyte


PROC 	readbyte2
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                   ; ax=0=end of file; jump
	mov     di, offset oneByte
	mov	al, [di]
	ret



@@802:

	mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 5		      		; Specify one byte to write
        mov     dx, offset buffer0		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 2		      		; Specify one byte to write
        mov     dx, offset space		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


	mov	ax, bp				; display bp	
	mov	cx, 4
	mov	di, offset output
	call	BinToAscDec

        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	
        mov     cx, 4               		
        mov     dx, offset output		
        int     21h				

        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cl, 2            		; Specify one byte to write
        mov     dx, offset crlf			; Address variable with ds:dx
        int     21h				; Call DOS to write to file


        mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit2                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit2:
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

ENDP	readbyte2



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
        mov     cx, 1                   ; Specify one byte to write
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

PROC	writebuffer
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 16               ; Specify one byte to write
        mov     dx, offset buffer0	      		; Address variable with ds:dx
        int     21h			; Call DOS to write to file
	ret
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
	push	bp
	push	bx
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
;        mov	al, 0
;	mov     [di], al
;[djm]
;	mov	[byte es:di], ASCnull      ; Store null at end of string
	pop	bx
	pop	bp
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


END     start
