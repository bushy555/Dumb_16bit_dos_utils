; Strip106
; Used for Exoprt dump stripper in LPSC levy export file
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
temp1		db 	0,0,0,0,0,0,0,0,0
temp2		db 	0
temp3		db 	0

exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Stripper106  /djm,  8/9/16', cr,lf
        	DB      cr,lf,'Stripper106  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0



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

@@_41:	
	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte


					; at the start of an ASS num
@@_412:	call	readbyte
	cmp	al, 0dh
	je	@@_413
	call	writebyte
	jmp	@@_412
@@_413:					; at the end of first line
					; dont write <CR>
	call	readbyte		; read 0ah - 2nd bit of <CR>
	

@@_4130:
	call	readbyte
	mov	di, offset temp1
	mov	[di], al
	call	readbyte
	mov	di, offset temp1+1
	mov	[di], al
	call	readbyte
	mov	di, offset temp1+2
	mov	[di], al
	call	readbyte
	mov	di, offset temp1+3
	mov	[di], al
	call	readbyte
	mov	di, offset temp1+4
	mov	[di], al
	call	readbyte
	mov	di, offset temp1+5
	mov	[di], al
	call	readbyte
	mov	di, offset temp1+6
	mov	[di], al

;	mov	di, offset temp1+7
;	call	readbyte
;	mov	[di], al

	cmp	al, 32
	jne	@@_416
	call	writebyte
						
@@_414:	call	readbyte
	cmp	al, 0dh
	je	@@_415
	call	writebyte
	jmp	@@_414
@@_415: call	readbyte	; read in 2nd part of CR
	jmp	@@_4130


@@_416:	

	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte


	mov	di, offset temp1
	mov	al, [di]	
	call	writebyte
	mov	di, offset temp1+1
	mov	al, [di]	
	call	writebyte
	mov	di, offset temp1+2
	mov	al, [di]	
	call	writebyte
	mov	di, offset temp1+3
	mov	al, [di]	
	call	writebyte
	mov	di, offset temp1+4
	mov	al, [di]	
	call	writebyte
	mov	di, offset temp1+5
	mov	al, [di]	
	call	writebyte
	mov	di, offset temp1+6
	mov	al, [di]	
	call	writebyte

	jmp	@@_412




	

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
@@802:  mov     bx, [inFile]            ; Get input file handle
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
END     start
