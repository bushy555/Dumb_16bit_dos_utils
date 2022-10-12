; Strip54.asm    -  /djm,  29/7/7
; Inserts number <param 3> of chars <param 4> at offset <param 5>. 
; <in> <out> (1 to 99) & (1 to 99). 
;
;     strip54 <in> <out> 3 # 15
;
;
; STRIP54 in.txt out.txt 5 J 9    Inserts 5 'J' characters at offset 9.  
; STRIP54 in.txt out.txt 9 # 17   Inserts 9 '#' characters at offset 17.
;
;
; Use ALT-255 for space
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
notes   	DB      cr,lf,'Stripp54  /djm,  29/7/7', cr,lf
        	DB      cr,lf,'Inserts <param1> of <param2> chars at offset <param3>. (1 to 99).'
        	DB      cr,lf,'Stripp54  <in-file>  <out-file> <99> <char> <99>',cr,lf,cr,lf
		db	'ie, Stripp54 in.txt out.txt 5 # 8',cr,lf,'    Stripp51 in.txt out.txt 34 @ 5',cr,lf
		db	'(Go easy but. Isn''t fully tested yet... and might have a few probs', cr,lf
		db	'if <99> is more than the in.txt line length.)' 
		db	cr,'Use <ALT-255> character for a space. (Char #32)'
	       	DB      cr,lf,cr,lf,0
_kill		db	0
_offset		db	0

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
        cmp     dx, 5                   ; Does count = 4?
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
	mov	di, offset _kill	; kill = number of params.
	mov	[di], cl


@@_44:   mov	cx, 4                   ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string. Address filename  DS:DX
	xor	ax, ax
	xor	bx, bx
	xor	cx, cx
	xor	dx, dx
	mov	bh, [di]
	inc	di
	mov	bl, [di]
	cmp	bl, 0
	je	@@45
	cmp	bl, 20
	je	@@45
	mov	cl, bh
	xor	cl, 30h
	mov	al, 10
	mul	cx
	xor	cx, cx
	mov	cl, al
	xor	bl, 30h
	add	cl, bl
	jmp	@@46
@@45:	xor	bh, 30h
	mov	cl, bh
@@46:	mov	ch, 0
	mov	di, offset _offset	; offset = offset position
	mov	[di], cl

	

@@_go:  mov	di, offset _offset	; get offset position
	mov	ch, 0
	mov	cl, [di]
@@47:	call	readbyte
	call	writebyte
	loop	@@47
@@_462: mov	cx, 3                   ; Get character to write out
        call    GetOneParam             
        mov     dx, di                  
	mov	al, [di]
	cmp	al, 255
	jne	@@_463
	mov	al, 32

@@_463:	mov	di, offset _kill	; get number of chars to write.
	mov	cl, [di]
	mov	ch, 0
@@_48:	call	writebyte
	loop	@@_48
@@_49:	call	readbyte		; read and write until end of line.
	call	writebyte
	cmp	al, 0ah
	jne	@@_49		
	jmp	@@_go



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
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                    ; ax=0=end of file; jump
	mov	di, offset onebyte
	mov	al, [di]
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
