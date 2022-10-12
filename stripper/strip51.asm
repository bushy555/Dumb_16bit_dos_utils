; Stripp51  /djm,  20/7/7
;
; Kills first <param 3> characters at offset <param 4>
;
; STRIP51 in.txt out.txt 5 9          Kills first 5 characters at offset 9.   dumps the rest.
; STRIP51 in.txt out.txt 34 17        Kills first 34 characters at offset 17. dumps the rest.
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
notes   	DB      cr,lf,'Stripp51  /djm,  20/7/7', cr,lf
        	DB      cr,lf,'Kills first <99> characters at offset <99> per line. (1 to 99).'
        	DB      cr,lf,'Stripp51  <in-file>  <out-file> <99> <99>',cr,lf,cr,lf
		db	'ie, Stripp51 in.txt out.txt 5 8',cr,lf,'    Stripp51 in.txt out.txt 34 5',cr,lf
		db	'(Go easy but. Isn''t fully tested yet... and might have a few probs', cr,lf
		db	'if <99> is more than the in.txt line length.)' 
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
	mov	di, offset _kill
	mov	[di], cl


@@_44:   mov	cx, 3                   ; Specify parameter number 0
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
;	mov	di, offset _offset
;	mov	[di], cl
	
	cmp	cl, 0			; Is offset = 0?, then jump.
	je	@@_48			
@@47:	call	readbyte		; read and write out <99> bytes until offset reached if offset = 1 or greater.
	call	writebyte
	loop	@@47	
	
	mov	di, offset _kill
	mov	cl, [di]

@@_48:	call	readbyte		; loop until all characters-to-be-killed are read
	loop	@@_48
@@_50:	call	readbyte		; continue reading and writing.
	cmp	al, 0ah
	je	@@_60
	call	writebyte
	jmp	@@_50
@@_60:	call	writebyte
	jmp	@@_41
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
