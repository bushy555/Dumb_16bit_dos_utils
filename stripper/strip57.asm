; Stripp57  /djm,  13/8/7
;
; Strip57.asm    --- Dumps line of single char <param 2> at offset <param 1>. strip56 <in> <out> <par 1> <par 2>
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
notes   	DB      cr,lf,'Stripp57  /djm,  13/8/7', cr,lf
        	DB      cr,lf,'Dumps line with char <param 2> at position <param 1>.'
        	DB      cr,lf,'Strip57  <in-file>  <out-file> <0-99> <0-99>',cr,lf,cr,lf
		db	'ie, Strip57 in.txt out.txt 5 Z',cr,lf,'Dumps lines with a Z at offset 5.',cr,lf
		db	'(Go easy but. Isn''t fully tested yet... and might have a few probs', cr,lf
		db	'if <0> - <99> is more than the in.txt line length.)'
		db	'use chr$(254) for space.' 
	       	DB      cr,lf,cr,lf,0
_buffer		db	'                                                                                                                                      '
		db	'                                                                                                                                      '
                db	0
_kill		db	0
_offset		db	0
_char		db	0

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
        cmp     dx, 4                   ; Does count = 4?
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

@@_41:   mov	cx, 2                   ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string. Address filename  DS:DX
	xor	ax, ax
	xor	bx, bx
	xor	cx, cx
	xor	dx, dx
	mov	bh, [di]
	inc	di
	mov	bl, [di]
	cmp	bl, 0
	je	@@42
	cmp	bl, 20
	je	@@42
	mov	cl, bh
	xor	cl, 30h
	mov	al, 10
	mul	cx
	xor	cx, cx
	mov	cl, al
	xor	bl, 30h
	add	cl, bl
	jmp	@@43
@@42:	xor	bh, 30h
	mov	cl, bh
@@43:	mov	ch, 0
	mov	di, offset _offset
	mov	[di], cl


@@_44:   mov	cx, 3                   ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string. Address filename  DS:DX
	mov	al, [di]
	cmp	al, 254
	jne	@@_441
	mov	al, ' '
@@_441:	mov	di, offset _char
	mov	[di], al	
					;	mov 	offset _char, [di]

@@_45:	mov	di, offset _buffer
@@_451: call	readbyte
	mov	[di], al
	inc	di
	cmp	al, 0ah
	jne	@@_451

	mov	di, offset _offset
	mov	cx, [di]
	mov	ch, 0
	mov	di, offset _buffer
	add	di, cx
	mov	al, [di]
	mov	di, offset _char
	mov	bl, [di]

	cmp	al, bl
	jne	@@_45


	mov	di, offset _buffer
@@46:	mov	al, [di]
	call 	writebyte
	inc	di
	cmp	al, 0ah
	jne	@@46


	jmp	@@_45

@@80:   mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit3                    ; Exit if no errors detected
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
	pop	di
@@802:  pop	cx
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

END     start
