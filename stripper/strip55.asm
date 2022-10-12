; Strip55.asm    -  /djm,  5/8/7
; Moves <param #3> chars from offset <param #1> to offset <param #2>. strip55 <in> <out> <par 1> <par 2> <par 3>.
; strip55 <in> <out> <param 1> <param 2> <param 3>           (1 to 99) (1 to 99) (1 to 99). 
;
; strip55 in.txt out.txt 10 15 4 - moves 4 characters from offset 10 to 15.
; strip55 in.txt out.txt 12 21 8 - moves 8 characters from offset 12 to 21.
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
notes   	DB      cr,lf,'Stripp55  /djm,  8/8/7', cr,lf
        	DB      cr,lf,'Moves <param #3> chars from offset <param #1> to offset <param #2>.'
		db	cr,lf,'strip55 <in> <out> <par 1> <par 2> <par 3>   (1 to 99) (1 to 99) (1 to 99).'
		db	cr,lf
        	DB      cr,lf,'strip55 in.txt out.txt 10 15 4 - moves 4 characters from offset 10 to 15.'
		db	cr,lf,'max of <99>, otherwise will crash.' 
	       	DB      cr,lf,cr,lf,0
_buffer		db	'                                                                                                                   '
		db	'                                                                                                                   '
		db	'                                                                                                                   '

_source			db	0
_destination		db	0
_buffer_source		db	0
_buffer_destination	db	0
_numberofchars		db	0


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
	je	@@_411
	cmp	bl, 20
	je	@@_411
	mov	cl, bh
	xor	cl, 30h
	mov	al, 10
	mul	cx
	xor	cx, cx
	mov	cl, al
	xor	bl, 30h
	add	cl, bl
	jmp	@@_412
@@_411:	xor	bh, 30h
	mov	cl, bh
@@_412:	mov	ch, 0
	mov	di, offset _source	; source = source offset of move
	mov	[di], cl
	mov	di, offset _buffer
	add	di, cx
	mov	dx, di
;	mov	offset _buffer_source, di

push	dx

@@_42:   mov	cx, 3                   ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string. Address filename  DS:DX
	xor	ax, ax
	xor	bx, bx
	xor	cx, cx
	xor	dx, dx
	mov	bh, [di]
	inc	di
	mov	bl, [di]
	cmp	bl, 0
	je	@@_421
	cmp	bl, 20
	je	@@_421
	mov	cl, bh
	xor	cl, 30h
	mov	al, 10
	mul	cx
	xor	cx, cx
	mov	cl, al
	xor	bl, 30h
	add	cl, bl
	jmp	@@_422
@@_421:	xor	bh, 30h
	mov	cl, bh
@@_422:	mov	ch, 0
	mov	di, offset _destination		; destination = destination offset of move
	mov	[di], cl
	mov	di, offset _buffer
	add	di, cx
	mov	bp, di
;	mov	offset _buffer_destination, di
	


@@_43:  mov	cx, 4                   ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string. Address filename  DS:DX
	xor	ax, ax
	xor	bx, bx
	xor	cx, cx
	xor	dx, dx
	mov	bh, [di]
	inc	di
	mov	bl, [di]
	cmp	bl, 0
	je	@@_431
	cmp	bl, 20
	je	@@_431
	mov	cl, bh
	xor	cl, 30h
	mov	al, 10
	mul	cx
	xor	cx, cx
	mov	cl, al
	xor	bl, 30h
	add	cl, bl
	jmp	@@_432
@@_431:	xor	bh, 30h
	mov	cl, bh
@@_432:	mov	ch, 0
	mov	di, offset _numberofchars 	; _numberofchar  = number of characters to move from source to destination.
	mov	[di], cl

pop	dx



@@_45:	mov	di, offset _buffer
@@_451:	call	readbyte
	cmp	al, 0ah
	je	@@_452
	mov	[di], al
	inc	di
	jmp	@@_451
@@_452:	mov	[di], al


	mov	di, offset _source
	mov	cl, [di]
	mov	di, offset _destination
	mov	bl, [di]
	cmp	cl, bl
	jg	@@_do2				; do1 = source < destination.   do2 = source > destination.

; ----------------------------------------------------------------------------------------
; If destination is after source 
;
;	bp = offset _buffer_destination
;	dx = offset _buffer_source
; ----------------------------------------------------------------------------------------

@@_do1: mov	di, offset _buffer
@@_461:	cmp	di, dx
	jge	@@_462
	mov	al, [di]
	call	writebyte
	inc	di
	jmp	@@_461	
@@_462:	mov	bx, offset _numberofchars		; skip over source + number of chars
	mov	ch, 0
	mov	cl, [bx]
	add	di, cx
@@_463:	cmp	di, bp					;write out gap between 'source + number of chars' to destination. Part 2.
	jge	@@_464
	mov	al, [di]
	call	writebyte	
	inc	di
	jmp	@@_463
@@_464:	mov	di, offset _numberofchars		; write out 'source+numberofchars' in destination spot. Part 3.
	mov	ch, 0
	mov	cl, [di]
	mov	di, dx
@@_465:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_465
@@_466:	mov	di, bp;offset _buffer_destination	;write out destination to EOL. part 4.
@@_467:	mov	al, [di]
	cmp	al, 0ah
	je	@@_468
	call	writebyte
	inc	di
	jmp	@@_467
@@_468:	call	writebyte
	jmp	@@_45

; ----------------------------------------------------------------------------------------
; If destination is before source 
;
;	bp = offset _buffer_destination
;	dx = offset _buffer_source
; ----------------------------------------------------------------------------------------
@@_do2:	mov	di, offset _buffer				; written out up to destination.    	- Write out Part 1.
@@_471:	cmp	di, bp
	jge	@@_472
	mov	al, [di]
	call	writebyte
	inc	di
	jmp	@@_471	
@@_472:	mov	di, offset _numberofchars	; write out 'source+numberofchars' in destination spot. Part 2.
	mov	ch, 0
	mov	cl, [di]
	mov	di, dx
@@_473:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@_473
	mov	di, bp				; write out gap in between destination and source. part 3
@@_474:	cmp	di, dx
	jge	@@_475
	mov	al, [di]
	call	writebyte
	inc	di
	jmp	@@_474
@@_475:	mov	bx, offset _numberofchars	; skip over source + number of chars
	mov	ch, 0
	mov	cl, [bx]
	add	di, cx
@@_476:	mov	al, [di]			;write out destination to EOL. part 4.
	cmp	al, 0ah
	je	@@_478
	call	writebyte
	inc	di
	jmp	@@_476
@@_478:	call	writebyte
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
	push	di
	push	bp
	push	dx
	push	bx
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
	pop	bx
	pop	dx
	pop	bp
	pop	di
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
	push	bp
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
	pop	bp
	pop	bx
	ret
ENDP	writebyte

END     start
