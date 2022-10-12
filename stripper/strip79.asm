; LPSC. Payroll filter program. For use with NAB.ABA as the <in-file>.
; Creates a .CSV <out-file> for excel usage.
;
;djm. 1/06/11
;
; Needs final grand total fixing.
;
;
    	  IDEAL
    	  MODEL   small
      	  STACK   256
P386
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
ASCnull		equ	0
        DATASEG
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Strip79 ', cr,lf
        	DB      cr,lf,'Fixes pays - automated. Reads in NAB.ABA file and outputs .CSV file for auditing purposes.'
        	DB      cr,lf,'Strip79 <in> <out>'
        	DB      cr,lf,cr,lf,0
sum2		db	0,0,0
sum3		db	0,0,0
sum4		db	0,0,0,0,0
sum5		dd	0,0,0,0,0,0,0
dollars		dw	0,0,0
cents		dw	0,0,0
total		dd	0,0,0
total2		dw	0,0,0,0,0,0,0,0,0
counter1	db	0,0
counter2	db	0,0,0,0,0
buffer1	db '                                                                                                                               ',0,0,0
buffer2 db 'NAR               ,Name                            ,BSB      ,Account  , Amount , Total',0dh,0ah,0,0,0,0,0,0,0,0
buffer3 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
buffer5 db '                  ,                                ,         ,         ,        ,$',0
footer1	db ',Number of line entries reported:,  '
footer2	db ',Number of line entries counted :,  '

        CODESEG
        EXTRN StrLength:proc, StrUpper:proc
        EXTRN StrWrite:Proc, NewLine:Proc
        EXTRN DiskErr:Proc, GetParams:Proc
        EXTRN  ParamCount:Proc, GetOneParam:Proc
Start:  mov     ax, @data               
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
@@_45:	mov	cx, 122
@@_452:	push	cx
	call 	readbyte
	pop	cx
	loop	@@_452
	mov	di, offset buffer2
	mov	cx, 92
@@_451:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_451

	call	writecrlf2

@@_46:	mov	di, offset buffer1
@@_41:	call	readbyte
	cmp	al, 0dh
	je	@@_410
	mov	[di], al
	inc	di
	jmp	@@_41
@@_410:	call	readbyte
@@_4600:mov	cx, 95
@@_4601:mov	di, offset buffer1		;fix tabs
@@_4602:mov	al, [di]
	cmp	al, 9
	je	@@_4603
@@_4604:inc	di
	loop	@@_4602
	jmp	@@_4605
@@_4603:mov	al, 32
	mov	[di], al
	jmp	@@_4604
@@_4605:mov	di, offset counter1
	mov	al, [di]
	inc	ax
	mov	[di], al

	mov	si, offset buffer3
	mov	di, offset buffer1 + 62
	mov	cx, 18
	rep 	cmpsb
	je	@@_4606				; jump if same line. Do not write out total
						; DIFFERENT LINE / NAR.

	mov	di, offset sum3			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov	ax, [di]			; put into text format to auto work out carry over digit
	mov	cx, 3
	mov	bx, 10
	mov	di, offset cents
	call	numtoascii
	mov	di, offset cents		; pick up the hundredth (first) digit.
	mov	al, [di]
	mov	dl, al
	mov	bx, 10
	call	valch				; out: dl = binary value of carry over.
	mov	dh, 0				; if carry over was 1xx, 2xx, 3xx, 4xx, should add 1, 2, 3, 4etc
	mov	di, offset sum2			;    to sum2
	mov	ax, [di]
	add	ax, dx
	mov	[di], ax
	cmp	ax, 0				; if total is zero, then skip printing it.
	je	@@5
@@49:	mov	di, offset sum2
	mov	ax, [di]
	mov	cx, 5
	mov	bx, 10
	mov	di, offset dollars
	call	numtoascii
	mov	di, offset sum3
	mov	ax, [di]
	mov	cx, 3
	mov	bx, 10
	mov	di, offset cents
	call	numtoascii
	mov	di , offset buffer5	   
	mov	cx, 82
@@4:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@4
	mov	di, offset dollars
	mov	cx, 5
@@2:	mov	al, [di]
	call 	writebyte
	inc	di
	loop	@@2
	mov	al, '.'
	call 	writebyte
	mov	di, offset cents + 1
	mov	cx, 2
@@3:	mov	al, [di]
	call 	writebyte
	inc	di
	loop	@@3

	xor	edx, edx
	xor	eax, eax
	mov	di, offset sum2
	mov	eax, [di]
	mov	edx, eax
	mov	di, offset sum4
	mov	eax, [di]
	add	eax, edx
	mov	[di], eax

@@5:	call	writecrlf
	
	xor	ax, ax						; ZERO counters
	mov	di, offset sum2
	mov	[di], ax
	mov	di, offset sum3
	mov	[di], ax

@@_4606:

	mov	di, offset buffer1 + 62				; Check fr 2ns last line 'PAYROLL'. If true, writeout 2 CRLF
	mov	al, [di]
	cmp	al, 'P'
	jne	@@_4110
	inc	di
	mov	al, [di]
	cmp	al, 'A'
	jne	@@_4110
	inc	di
	mov	al, [di]
	cmp	al, 'Y'
	jne	@@_4110
	inc	di
	mov	al, [di]
	cmp	al, 'R'
	jne	@@_4110

	call	writecrlf


@@_4110:
	mov	di, offset buffer1 + 62		;nar
	mov	cx, 18
@@_411:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_411
	mov	al, ','
	call	writebyte
	mov	di, offset buffer1 + 30		;name
	mov	cx, 32
@@_412:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_412
	mov	al, ','
	call	writebyte
	mov	di, offset buffer1 		;BSB
	mov	cx, 9
@@_413:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_413
	mov	al, ','
	call	writebyte
	mov	di, offset buffer1+9 		;Account
	mov	cx, 9
@@_414:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_414
	mov	al, ','
	call	writebyte
	mov	al, '$'
	call	writebyte	

	mov	di, offset buffer1 + 62				; Check for 2nd last line 'PAYROLL'
	mov	al, [di]
	cmp	al, 'P'
	jne	@@_4149
	inc	di
	mov	al, [di]
	cmp	al, 'A'
	jne	@@_4149
	inc	di
	mov	al, [di]
	cmp	al, 'Y'
	jne	@@_4149
	inc	di
	mov	al, [di]
	cmp	al, 'R'
	jne	@@_4149

	mov	di, offset buffer1+20 		;Grand total Amount. Writes out a grand total amount when 2nd last line has been detected.
	mov	cx, 8
@@_4140:mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_4140
	mov	al, '.'
	call	writebyte	
	mov	di, offset buffer1+28 		;Amount
	mov	cx, 2
@@_4141:mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_4141
	mov	al, ','

	call	writebyte
	mov	al, '$'
	call	writebyte
	mov	di, offset buffer1+20 		;Grand total Amount
	mov	cx, 8
@@_4142:mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_4142
	mov	al, '.'
	call	writebyte	
	mov	di, offset buffer1+28 		;Amount
	mov	cx, 2
@@_4143:mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_4143


	call	writecrlf

	mov	di, offset footer1		; 	write text : Number of line entries,
	mov	cx, 34
@@_4144:mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_4144
	mov	di, offset buffer1		; read in 2nd last line.
@@_4145:call	readbyte	
	mov	[di], al
	inc	di
	cmp	al, 0dh
	jne	@@_4145


	mov	di, offset buffer1 + 74
	mov	cx, 6
@@_4146:mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_4146

	call	writecrlf2
	mov	di, offset footer2		; 	write text : Number of line entries,
	mov	cx, 34
@@_4147:mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_4147


	mov	di, offset counter1
	mov	ax, [di]
	mov	cx, 3
	mov	bx, 10
	mov	di, offset counter2
	call	numtoascii
	mov	di, offset counter2
	mov	cx, 3
@@41471:mov	al, [di]
	call 	writebyte
	inc	di
	loop	@@41471


	call	writecrlf
@@_4148:call	readbyte			; readout the rest of the in-file, finish and exit.
	jmp	@@_4148

	









@@_4149:mov	di, offset buffer1+24 		;Amount
	mov	cx, 4
@@_415:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_415
	mov	al, '.'
	call	writebyte	
	mov	di, offset buffer1+28 		;Amount
	mov	cx, 2
@@_416:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_416
@@_47:	mov	si, offset buffer1 + 62		;nar	SETUP NAR BUFFER FOR COMPARISON.
	mov	di, offset buffer3
	mov	cx, 18
	rep	movsb
	xor	ax, ax
	mov 	di, offset buffer1+24		; calc thousands
	mov	al, [di]
	sub	ax, 30h
	mov	dx, 1000
	mul	dx
	mov	bp, ax
	xor	ax, ax
	mov 	di, offset buffer1+25		; calc hundreds
	mov	al, [di]
	sub	ax, 30h
	mov	dx, 100
	mul	dx
	add	bp, ax
	xor	ax, ax
	mov 	di, offset buffer1+26		; calc tens
	mov	al, [di]
	sub	ax, 30h
	mov	dx, 10
	mul	dx
	add	bp, ax
	xor	ax, ax
	mov 	di, offset buffer1+27		; calc digits
	mov	al, [di]
	sub	ax, 30h
	add	bp, ax
	mov	di, offset sum2			; put dollars into buffer
	mov	ax, [di]
	add	ax, bp
	mov	[di], ax
	xor	ax, ax				; calculate cents
	xor	bp, bp
	mov 	di, offset buffer1+28		
	mov	al, [di]
	sub	ax, 30h
	mov	dx, 10
	mul	dx
	mov	bp, ax
	xor	ax, ax
	mov 	di, offset buffer1+29	
	mov	al, [di]
	sub	ax, 30h
	add	bp, ax

	mov	di, offset sum3			; put cents into buffer
	mov	ax, [di]
	add	ax, bp
	mov	[di], ax

@@_48:	call	writecrlf2

	jmp	@@_46



writecrlf:
	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte
writecrlf2:
	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte
	ret



PROC 	endtotal
	call	writecrlf2

	mov	al, ','
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, '$'
	call	writebyte

	mov	di, offset sum4
	mov	ax, [di]
	mov	cx, 8
	mov	bx, 10
	mov	di, offset total
	call	numtoascii
	mov	di, offset total
	mov	cx, 8
@@6:	mov	al, [di]
	call 	writebyte
	inc	di
	loop	@@6

	ret
ENDP	endtotal






Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program





PROC 	readbyte
	push	cx
	push	di
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                    ; ax=0=end of file; jump
	mov	di, offset onebyte
	mov	al, [di]
	pop	di
	pop	cx
	ret
@@802:  pop	cx
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


END     start
