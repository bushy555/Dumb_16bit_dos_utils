; Stripper30  /djm,  28/8/6
;
;made for xray
; Need to be fixed: Total for the day.
;
;
;got a list of product codes. 
; Product, Carton Number, Prod Date, Barcode 
; 09999,4002,220806,0199327574099990130608223102000680214002
; 09999,4001,220806,0199327574099990130608223102000680214001
; 09999,4002,220806,0199327574099990130608223102000680214002
; 09999,4002,220806,0199327574099990130608223102000680214002
; 09999,4001,220806,0199327574099990130608223102000680214001
; 00253,4001,260806,0199327574002532130608263102001980214001
; 00253,4002,260806,0199327574002532130608263102001730214002
; 00253,4003,260806,0199327574002532130608263102001710214003
; 00680,8009,260806,0199327574006806130608263102001440218009
; 00680,8009,260806,0199327574006806130608263102001440218009
; 00680,8008,260806,0199327574006806130608263102001540218008
; 00680,8008,260806,0199327574006806130608263102001540218008
; 00680,8008,260806,0199327574006806130608263102001540218008

;turns it into this:15/08/06
;Product  Totals
;54030   001
;
;
;16/08/06
;Product  Totals
;47020   005
;
;
;17/08/06
;Product  Totals
;47020    016
;
;
;18/08/06
;Product  Totals
;47020   004
;
;
;22/08/06
;Product  Totals
;00253   001
;04749   001
;
;
;23/08/06
;Product  Totals
;00020   005
;00154   009
;00253   004
;00256   009
;00680   009
;00681   015
;
;
;
;    read buf1
; 1: read buf2
;    dump date1
;   dump prod1
;   if date1=date2 & prod1=prod2
;      count1++
;   if date1=date2 & prod1<>prod2
;      dump count1
;      count1=1
;      move buf2 to buf1  
;      goto 1
;
;   if date1<>date2
;      dump count1
;      dump count2 ??
;      count1=1
;      count2=1
;      move buf2 to buf1  
;      goto 1
;
;
        IDEAL
        MODEL   small
        STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
ASCnull		equ	0
;_double_comma	EQU	16		; gives single end comma
_double_comma	EQU	17		; gives double end comma. DIRTY HACK!

        DATASEG
space		db	'    ',0
count0		db	0
count1		db	0
count2		db	0
count3		db	0
count4		db	0
count5		db	0
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Stripper19  /djm,  7/8/6', cr,lf
        	DB      cr,lf,'Xray product counter doovey.'
        	DB      cr,lf,'Stripper19  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0

	;           000500,31,02792,
	;  '09999,4002,220806,0199327574099990130608223102000680214002
buf1	equ $
prod1	db '00000'
	db ',0000,'
date1	db '000000'
	db ',0000000000000000000000000000000000000000',0,0,0

buf2	equ $
prod2	db '00000'
	db ',0000,'
date2   db '000000'
  	db ',0000000000000000000000000000000000000000',0,0,0

buffer1	db '00000',0,0,0
buffer2	db '00000',0,0,0
read1	db 'X$'
read2	db 'O$'
read3	db '#$'
read4	db 'I$'
slash	db '/',0
slashdash db '-',0
total	db 'Total : ',0
prod0	db 'Product  Totals',0
buffer3	db '0000',0,0

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
        cmp     dx, 2                   ; Does count = 4?
        je      @@10                    ; Continue if param count = 4
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
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
@@30:   mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:   mov     [outFile], ax           ; Save output file handle



nop
nop
nop
nop
	xor	bp,bp
	mov	di, offset count0		; Set Counter 1
	mov	ax, 1
	mov	[di], al
	mov	di, offset count1
	mov	ax, 0
	mov	[di], al
	mov	di, offset count2
	mov	ax, 0
	mov	[di], al
	mov	di, offset count3		; Set Counter 2
	mov	ax, 1
	mov	[di], al
	mov	di, offset count4
	mov	ax, 0
	mov	[di], al
	mov	di, offset count5
	mov	ax, 0
	mov	[di], al

	mov	si, offset prod1;buf1			; read in buffer/line 1
@@_41:	call	readbyte
	mov	di, si
	mov	[di], al
	inc	si
	cmp	al, 00ah
	jne	@@_41
	


	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 2
        mov     dx, offset date1		
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 1
        mov     dx, offset slash
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 2
        mov     dx, offset date1+2
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 1
        mov     dx, offset slash
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 2
        mov     dx, offset date1+4
        int     21h				
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h				


	mov     ah, 40h                 	; Write Prod 1.
        mov     bx, [outFile]           	
        mov     cx, 15
        mov     dx, offset prod0
        int     21h				
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h				



	mov     ah, 40h                 	; Write Prod 1.
        mov     bx, [outFile]           	
        mov     cx, 5
        mov     dx, offset prod1		
        int     21h				
;	mov     ah, 40h                 	; Write Prod 1.
;        mov     bx, [outFile]           	
;        mov     cx, 4
;        mov     dx, offset space		
;        int     21h				
	mov     ah, 40h                 	; Write Space
        mov     bx, [outFile]           	
        mov     cx, 4
        mov     dx, offset space		
        int     21h				
@@_420:	mov	si, offset prod2; buf2
@@_42:	call	readbyte			; read in buffer/line 2 
	mov	di, si
	mov	[di], al
	inc	si
	cmp	al, 00ah
	jne	@@_42
	mov	cx, 6
	mov	si, offset date1
	mov	di, offset date2
	rep	cmpsb
	jz	@@_43				; jump: DATES are same.
	jmp	@@_50				; jump: DATES are different.
@@_43:	mov	cx, 5
	mov	si, offset prod1
	mov	di, offset prod2
	rep	cmpsb
	jnz	@@_44				; jump: PROD are different. Dump counter.
	jmp	@@_46				; jump: PROD are same. Increase counter.


@@_44:	mov	di, offset count0		; ----------------------------: Here if DATE1=DATE2 and PROD1 <> PROD2 
	mov	al, [di]
	mov	di, offset count3
	mov	[di], al
	mov	di, offset count1
	mov	al, [di]
	mov	di, offset count4
	mov	[di], al
	mov	di, offset count2
	mov	al, [di]
	mov	di, offset count5
	mov	[di], al
	mov	di, offset count0
	call	or30
	mov	di, offset count1
	call	or30
	mov	di, offset count2
	call	or30
        mov     dx, offset count2	
	call	writebyte2
        mov     dx, offset count1	
	call	writebyte2
        mov     dx, offset count0	
	call	writebyte2
	mov     ah, 40h                 	
        mov     bx, [outFile]           	
        mov     cx, 2
	mov	dx, offset crlf
        int     21h				
;--------
	mov	di, offset count0
	mov	al, 1
	mov	[di], al
	mov	di, offset count1
	xor	ax, ax
	mov	[di], al
	mov	di, offset count2
	xor	ax, ax
	mov	[di], al
	mov	di, offset prod1
	mov	si, offset prod2
	mov	cl, 60
	rep	movsb
	mov     ah, 40h                 	; Write Prod 1.
        mov     bx, [outFile]           	
        mov     cx, 5
        mov     dx, offset prod1		
        int     21h				
	mov     ah, 40h                 	; Write Prod 1.
        mov     bx, [outFile]           	
        mov     cx, 4
        mov     dx, offset space		
        int     21h				
	jmp	@@_47



@@_50:	mov	di, offset count0				; ----------------------------: Here if Date1 <> Date2
	call	or30
	mov	di, offset count1
	call	or30
	mov	di, offset count2
	call	or30
	mov	di, offset count3
	call	or30
	mov	di, offset count4
	call	or30
	mov	di, offset count5
	call	or30
        mov     dx, offset count2	
	call	writebyte2
        mov     dx, offset count1
	call	writebyte2
        mov     dx, offset count0
	call	writebyte2
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h			
;        mov     ah, 40h                 	; Write C/R
;        mov     bx, [outFile]           	
;        mov     cx, 8
;        mov     dx, offset total
;        int     21h			
;        mov     dx, offset count5
;	call	writebyte2
;        mov     dx, offset count4
;	call	writebyte2
;        mov     dx, offset count3
;	call	writebyte2
;        mov     ah, 40h                 	; Write C/R
;        mov     bx, [outFile]           	
;        mov     cx, 4		      		
;        mov     dx, offset space
;        int     21h				


;       ax = 16-bit value to convert
;       bx = base for result (2=binary;10=decimal;16=hex)
;       cx = minimum number of digits to output
;       di = address of string to hold result
;
;	mov	ax, bp
;	mov	bx, 10
;	mov	cx, 3
;	mov	di, offset buffer3
;	call    NumToASCII              


;        mov     ah, 40h                 	; Write C/R
;        mov     bx, [outFile]           	
;        mov     cx, 3		      		
;        mov     dx, offset buffer3
;        int     21h				
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h				
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h				
	mov	di, offset count0
	mov	al, 1
	mov	[di], al
	mov	di, offset count1
	xor	ax, ax
	mov	[di], al
	mov	di, offset count2
	xor	ax, ax
	mov	[di], al
	mov	di, offset prod1
	mov	si, offset prod2
	mov	cl, 60
	rep	movsb
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 2
        mov     dx, offset date1		
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 1
        mov     dx, offset slash
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 2
        mov     dx, offset date1+2
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 1
        mov     dx, offset slash
        int     21h				
	mov     ah, 40h                 	; Write Date.
        mov     bx, [outFile]           	
        mov     cx, 2
        mov     dx, offset date1+4
        int     21h				
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h				


	mov     ah, 40h                 	; Write Prod 1.
        mov     bx, [outFile]           	
        mov     cx, 15
        mov     dx, offset prod0
        int     21h				
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h				


	mov     ah, 40h                 	; Write Prod 1.
        mov     bx, [outFile]           	
        mov     cx, 5
        mov     dx, offset prod1		
        int     21h
	mov     ah, 40h                 	; Write Prod 1.
        mov     bx, [outFile]           	
        mov     cx, 4
        mov     dx, offset space		
        int     21h
	jmp	@@_47



@@_46:	mov	di, offset count0		;Here if DATE1 = DATE2 and PROD1 = PROD2    ---   "counter 1"
	mov	al, [di]
	inc	ax
	cmp	al, 9
	jle	@@461
 	mov	al, 0
	mov	[di], al
	mov	di, offset count1
	mov	al, [di]
	inc	ax
	cmp	al, 9
	jle	@@462
	mov	al, 0
	mov	[di], al
	mov	di, offset count2
	mov	al, [di]
	inc	al
	cmp	al, 9
	jle	@@463
	mov	al, 0
	mov	[di], al
	jmp	@@_420
@@461:	mov	[di], al
	jmp	@@_420
@@462:	mov	[di], al
	jmp	@@_420
@@463:	mov	[di], al
	
;	jmp	@@_420


@@_47:	mov	di, offset count3		; Here if DATE1 <> DATE2    ---   "counter 2"
	mov	al, [di]
	inc	ax
	cmp	al, 9
	jle	@@471
 	mov	al, 0
	mov	[di], al
	mov	di, offset count4
	mov	al, [di]
	inc	ax
	cmp	al, 9
	jle	@@472
	mov	al, 0
	mov	[di], al
	mov	di, offset count5
	mov	al, [di]
	inc	al
	cmp	al, 9
	jle	@@473
	mov	al, 0
	mov	[di], al
	jmp	@@_420
@@471:	mov	[di], al
	jmp	@@_420
@@472:	mov	[di], al
	jmp	@@_420
@@473:	mov	[di], al
	inc	bp
	jmp	@@_420




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





Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program



Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

PROC 	readbyte
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
	mov	di, offset count0				; ----------------------------: Here if Date1 <> Date2
	call	or30
	mov	di, offset count1
	call	or30
	mov	di, offset count2
	call	or30
	mov	di, offset count3
	call	or30
	mov	di, offset count4
	call	or30
	mov	di, offset count5
	call	or30
        mov     dx, offset count2	
	call	writebyte2
        mov     dx, offset count1
	call	writebyte2
        mov     dx, offset count0
	call	writebyte2
        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h			
;        mov     ah, 40h                 	; Write C/R
;        mov     bx, [outFile]           	
;        mov     cx, 8
;        mov     dx, offset total
;        int     21h			
;        mov     dx, offset count5
;	call	writebyte2
;        mov     dx, offset count4
;	call	writebyte2
;        mov     dx, offset count3
;	call	writebyte2


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

PROC	writebyte2
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	push	ax
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
;        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h			; Call DOS to write to file
	pop	ax
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	ret
ENDP	writebyte2

PROC	writebuffer
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 16               ; Specify one byte to write
        mov     dx, offset buffer1	      		; Address variable with ds:dx
        int     21h			; Call DOS to write to file
	ret
ENDP	writebuffer

PROC	or30
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	ret
ENDP	or30


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

PROC    HexDigit
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@10            ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        ret                     ; Return to caller
@@10:
        or      dl, '0'         ; Convert digits 0 to 9
        ret                     ; Return to caller
ENDP    HexDigit

END     start
