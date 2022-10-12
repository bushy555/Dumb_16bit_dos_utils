;|      + Strip14.asm    --- comparison of two lines in in-line, writes one out. See text in asm file.
;|      + Strip19.asm 	--- [XRAY] list of same products, outputs single product and the number of them.



; Stripper343  /djm,  
; 5/10/6
; bug fix. djm, 20/6/7.
;
;
;got a list of sorted barcodes in this format.
;47040,2077,031006,0199327574470409130610033102002720212077
;47040,2077,031006,0199327574470409130610033102002720212077
;47040,2077,031006,0199327574470409130610033102002720212077
;47040,2077,031006,0199327574470409130610033102002720212077
;47040,2078,031006,0199327574470409130610033102002720212078
;47040,2079,031006,0199327574470409130610033102002720212079
;47040,2080,031006,0199327574470409130610033102002720212080
;47040,2081,031006,0199327574470409130610033102002720212081
;47040,2082,031006,0199327574470409130610033102002720212082
;47040,2083,031006,0199327574470409130610033102002720212083
;
;searches thru each product and creates/dumps a toal count of all duplicates for each serial number
;eg, if 47040 with serial 2077 goes around xray 5 times    !AND!
;    if 47040 with serial 2078 goes around xray 8 times
;                            this should output a total of : Prodcode: 47040    Duplicate: 12
;
;As above, 47040 is listed 10 times. Serial 2077 is listed 4 times. Output should be:
;47040   003




        IDEAL
        MODEL   small
        STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
;_double_comma	EQU	16		; gives single end comma
_double_comma	EQU	17		; gives double end comma. DIRTY HACK!
ASCnull         EQU     0               ; ASCII null character




        DATASEG
space		db	'   ',0
space2		db	'<-->',0
header		db	'product duplicates',0dh,0ah,0
count0		db	0
count1		db	0
count2		db	0
exCode          DB      0
counter		dw	0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Stripper34  /djm,  5/10/6', cr,lf
        	DB      cr,lf,'Xray product counter doovey.'
        	DB      cr,lf,'Stripper34  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0

;           000500,31,02792,
;
;                  0000000000000000000000000000000000000000
;47040,2077,031006,0199327574470409130610033102002720212077
;47040,2077,031006,0199327574470409130610033102002720212077
output	db '    ',0
buffer0 db '     ',0
buffer1	db '0000000000000000000000000000000000000000',0,0,0
buffer2	db '0000000000000000000000000000000000000000',0,0,0
buffer3 db '     ',0
read1	db 'X$'
read2	db 'O$'
read3	db '#$'
read4	db 'I$'


        CODESEG
        EXTRN StrLength:proc, StrUpper:proc
        EXTRN StrWrite:Proc, NewLine:Proc				;-----  From STRIO.OBJ
        EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ

        PUBLIC  HexDigit, ValCh, NumToAscii
        PUBLIC  BinToAscHex, SBinToAscDec, BinToAscDec, BinToAscBin
        PUBLIC  AscToBin



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

;47040,2077,031006,0199327574470409130610033102002720212077


        mov     ah, 40h                 	; write out header
        mov     bx, [outFile]           	
        mov     cx, 20		      		
        mov     dx, offset header		
        int     21h				

@@_401:	xor	bp, bp						; setup counter

				
	call	readbyte				; read in product code
	mov	di, offset buffer0
	mov	[di], al
	call	readbyte
	mov	di, offset buffer0 + 1
	mov	[di], al
	call	readbyte
	mov	di, offset buffer0 + 2
	mov	[di], al
	call	readbyte
	mov	di, offset buffer0 + 3
	mov	[di], al
	call	readbyte
	mov	di, offset buffer0 + 4
	mov	[di], al

	call	readbyte				; skip the next umpteen characters.
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte


	call	readbyte			; read in barcode in to buffer 1
	mov	di, offset buffer1
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+1
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+2
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+3
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+4
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+5
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+6
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+7
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+8
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+9
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+10
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+11
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+12
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+13
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+14
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+15
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+16
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+17
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+18
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+19
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+20
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+21
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+22
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+23
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+24
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+25
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+26
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+27
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+28
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+29
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+30
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+31
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+32
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+33
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+34
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+35
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+36
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+37
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+38
	mov	[di], al
	call	readbyte
	mov	di, offset buffer1+39
	mov	[di], al

	call	readbyte			; read in <CR>
	call	readbyte

@@_43:	

	call	readbyte				; read in product code
	mov	di, offset buffer3
	mov	[di], al
	call	readbyte
	mov	di, offset buffer3 + 1
	mov	[di], al
	call	readbyte
	mov	di, offset buffer3 + 2
	mov	[di], al
	call	readbyte
	mov	di, offset buffer3 + 3
	mov	[di], al
	call	readbyte
	mov	di, offset buffer3 + 4
	mov	[di], al

	call	readbyte				; skip the next umpteen characters.
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte
	call	readbyte


	call	readbyte			; read in next line (line 2) into buffer 2
	mov	di, offset buffer2
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+1
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+2
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+3
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+4
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+5
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+6
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+7
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+8
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+9
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+10
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+11
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+12
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+13
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+14
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+15
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+16
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+17
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+18
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+19
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+20
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+21
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+22
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+23
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+24
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+25
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+26
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+27
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+28
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+29
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+30
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+31
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+32
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+33
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+34
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+35
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+36
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+37
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+38
	mov	[di], al
	call	readbyte
	mov	di, offset buffer2+39
	mov	[di], al


	call	readbyte			; read in <CR>
	call	readbyte

	nop
	nop
	nop
	nop

	mov	cx, 40
	mov	si, offset buffer1
	mov	di, offset buffer2
	rep	cmpsb
	jnz	@@_403				; Barcode Difference found. Display total.
	inc	bp				; same, add 1 to counter
	jmp	@@_43

@@_403:	
	mov	di, offset counter
	mov	ax, [di]
	add	ax, bp
	mov	[di], ax
	mov	bp, 0

	mov	cx, 5
	mov	si, offset buffer3
	mov	di, offset buffer0
	rep	cmpsb
	jnz	@@_41				; PRODCODE Differnce found. Display total.
						; PRODCODE same. Start again.
	mov	di, offset buffer1
	mov	si, offset buffer2
	mov	cl, 40
	rep	movsb
;
;	mov	di, offset buffer0
;	mov	si, offset buffer3
;	mov	cl, 5
;	rep	movsb
	jmp	@@_43



@@_41:
	mov	di, offset counter
	mov	ax, [di]
	cmp	ax, 0
	je	@@_4040



;	cmp	bp, 0
;	je	@@_4040

@@_4033:

	mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 4		      		; Specify one byte to write
        mov     dx, offset buffer0		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 3		      		; Specify one byte to write
        mov     dx, offset space		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


	mov	di, offset counter		; calculate counter
	mov	ax, [di]
	mov	cx, 4
	mov	di, offset output
	call	BinToAscDec

        mov     ah, 40h                 	; Write counter
        mov     bx, [outFile]           	
        mov     cx, 4               		
        mov     dx, offset output		
        int     21h				


        mov     ah, 40h                 	; Write <CR>
        mov     bx, [outFile]           
        mov     cl, 2            	
        mov     dx, offset crlf			
        int     21h				

@@_4040:mov	bp, 0
	mov	di, offset counter
	mov	ax, 0
	mov	[di], ax

	jmp	@@_401




;-----------------------------------
; WRITE THE SUCKER oUT
;------------------------------------

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 5               	; Specify one byte to write
        mov     dx, offset buffer0	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

	mov	ax, bp				; display bp	
	mov	cx, 4
	mov	di, offset output
	call	BinToAscDec

        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	
        mov     cx, 4               		
        mov     dx, offset output		
        int     21h				



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
        je     	@read2                   ; ax=0=end of file; jump
	mov     di, offset oneByte
	mov	al, [di]
	ret
@read2: mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     @Exit3                    ; Exit if no errors detected
        jmp     Errors3                  ; Else jump to error handler
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
