; STRIP64.EXE  /djm,  25/2/2k8 to ...
;
; Utility to strip all lines of an exacting matched phrase.
; STRIP64 <in-file> <out-file> <text>
;
; ie:
;       > fred was here
;       > Was fred here
;       > Yes fred was here
;       > Or was fred here
;
; "STRIP64 in-txt out-txt Yes"  will strip the third line and output:
;
;       > fred was here
;       > Was fred here
;       > Or was fred here
;
;
;
        IDEAL
        MODEL   small
        STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed

        DATASEG
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'STRIP64  /djm,  26/2/2k8', cr,lf
        	DB      cr,lf,'Kills line if <param 1> was found within the line.'
        	DB      cr,lf,'STRIP64  <in-file>  <out-file> <text>',cr,lf,cr,lf
		db	'ie, STRIP64 in.txt out.txt fred',cr,lf,'Removes each line with any reference of "fred".',cr,lf
		db	cr,lf
		db	'** Use chr$(254) for space - to be done.' 
	       	DB      cr,lf,cr,lf,0
_buffer		db	'                                                                                                                                      '
		db	'                                                                                                                                      '
                db	0
_kill		db	0
_offset		db	0
_char		db	0
_char2		db	0
_temp		db 	0
_count		db 	0
_count2		db 	0
_end_of_buffer	db	0

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
        cmp     dx, 3                   ; Does count = 4?
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
@@_44:  mov	cx, 2                   ; Specify parameter number 3
        call    GetOneParam             ; Get address of parameter string. Address filename  DS:DX
	mov	al, [di]
	mov	si, di
	
	mov	di, offset _char
;	mov	[di], si
	xor	cx, cx
@@_440:	lodsb
	cmp	al, 0h
	je	@@_441
	stosb
	inc	cx
	jmp	@@_440

@@_441: stosb				
	inc	cx
	mov	al, cl			;get length of string-to-find
	mov	di, offset _COUNT
	mov	[di], al
	mov	si, offset _char

@@_47:	mov	cx, 0			; load in first line and get length of line

	mov	si, offset _char

@@_45:	mov	di, offset _buffer
@@_451: call	readbyte
	mov	[di], al
	inc	cx
	inc	di
	cmp	al, 0ah
	jne	@@_451
	mov	[di], al
	inc	cx
	mov	bp, offset _count2	; count2 = length of buffer.
	mov	ax, cx
	mov	[bp], al
	mov	bp, offset _end_of_buffer
	mov	[bp], di

	mov	di, offset _buffer
	mov	bp, offset _count2
	mov	ah, 0
	mov	al, [bp]
	mov	cx, ax			; cx = length of buffer (count2)
	lodsb				; get first or next char of string-to-find

@@_44a: 
;	DI = buffer
; 	AL = first char of string-to-find	
; 	cx = length of buffer
	mov	bp, offset _char2
	mov	[bp], al
	repne	scasb
	jcxz	@@_60			; jmp if no char was found. write out buffer line and go get next line.

					; at this point, DI -> the second char of string-to-be-found within buffer
					; store it for later re-start if this is not the correct first char.
	mov	bp, offset _temp
	mov	[bp], di

	mov	bp, offset _count	; get string-to-be-found char length, setting up for REP CMP
	mov	ch, 0
	mov	cl, [bp]
	dec	cx
					; SI --> first char of string-to-be-found
					; DI --> next char after finding first char of string-to-be-found in buffer.
					; CX =   length of string-to-be-found.

	rep	cmpsb
	jnz	@@_50			; difference has been found. continue rest of buffer until end of buffer
	jz	@@_47			; exact match. Need to skip writing of line and grab next line.



@@_50:	mov	bp, offset _temp	; difference found, so set up to go back to last char and redo scasb
	mov	di, bp
	mov	di, offset _count2
	mov	cx, [di]
	push	si
	mov	si, offset _end_of_buffer
	mov	bp, [si]
	pop	si
	cmp	di, bp
	je	@@_60			; over done the buffer, not exist, lets leave and write out buffer
					; otherwise not yet at end of buffer, go for another scasb.
	mov	ax, di			;get difference left and put into CX for SCASB
	sub	bp, ax			; I think bp minus ax --> bp
	mov	cx, bp
	mov	bp, offset _char2
	mov	al, [bp]
	jmp	@@_44a


@@_60:	mov	di, offset _buffer	; Nothing was found; write out buffer line to text.
@@_61:	mov	al, [di]
	call 	writebyte
	inc	di
	cmp	al, 0ah
	jne	@@_61
;	call	writebyte
	jmp	@@_47



	


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
