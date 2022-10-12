; Stripper105  /djm,  07/01/16
;
; reads and writes first 16 chars, kills 2 chars, read/writes rest
; for LPSC fuel dump when stuffed-up.
;
;
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
notes   	DB      cr,lf,'Strip105  /djm,  07/01/2016', cr,lf
        	DB      cr,lf,'For LPSC FUEL file issue. Fixes the offset'
        	DB      cr,lf,'FUEL.EXE  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf
        	DB      cr,lf,'Press any key to continue'
        	DB      cr,lf,cr,lf,0
message0	db	cr,lf,'LPSC Fuel fixeruperer. For those times when it is stuffed!',cr,lf,0
message1	db	cr,lf,'Yep, file is buggered: Fixing...',cr,lf,0
message2	db	cr,lf,'File is correct! Use this file to import.',cr,lf,0


	;           000500,31,02792,
db '>'
buffer1	db '000000,00,00000,',0,0,'<'
db '>'
buffer2	db '000000,00,00000,',0,0,'<',0,0,0


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
	xor	ax, ax
	int	16h
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

        mov     di, offset message0
        call    StrWrite           

nop
nop
nop
nop


@@_45:	call	readbyte	; do first line manually, and display if decimal point is in 
	call 	writebyte	; correct lcoation or not.
	call	readbyte
	call 	writebyte	; then after first line, continually loop in second part.
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte	; read and write 16 chars.

	call	readbyte	; ...then skip 1
	call	readbyte	;    	  skip 2
	call	readbyte	; continue reading and writing.
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	cmp	al, '.'
	jne	@@_mes2
        mov     di, offset message2
        call    StrWrite           
@@_mes2:call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte	
	cmp	al, '.'
	jne	@@_mes1
        mov     di, offset message1
        call    StrWrite                ; Display notes
@@_mes1:call 	writebyte	; write '.'
	call	readbyte
	call 	writebyte
@@_46:	call	readbyte	; do rest of file
	cmp	al, 0ah
	je	@@_47
	call	writebyte
	jmp	@@_46
@@_47:	call	writebyte



; 123456789012345678901234567890	
; 070420151002111      50.0DIE    40201    
; 210420151078131     120.0DIE    19750    
; 080420151079091     107.0DIE    37394    
;
; The period/full stop is at offset 24.  Two spaces need to be removed to bring the full stop back to offset 22
;
; 123456789012345678901234567890	
; 070420151002111    50.0DIE    40201    
; 210420151078131   120.0DIE    19750    

	
@@_48:	call	readbyte		; second part / second loop de loop for rest of file after 1st line done.
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte	; read and write 16 chars.
	call	readbyte	; ...then skip 1
	call	readbyte	;    	  skip 2
	call	readbyte	; continue reading and writing.
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte
	call 	writebyte
	call	readbyte	
	call 	writebyte
	call	readbyte
	call 	writebyte
@@_50:	call	readbyte
	cmp	al, 0ah
	je	@@_60
	call	writebyte
	jmp	@@_50
@@_60:	call	writebyte
	jmp	@@_48
	



@@80:   mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit3                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit3:
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
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                    ; ax=0=end of file; jump
	mov	di, offset onebyte
	mov	al, [di]
	ret

@@802:
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

PROC	writebuffer
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 16               ; Specify one byte to write
        mov     dx, offset buffer1	      		; Address variable with ds:dx
        int     21h			; Call DOS to write to file
	ret
ENDP	writebuffer

END     start
