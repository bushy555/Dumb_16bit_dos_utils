; Stripper14  /djm,  14/6/6
;
; This reads in 1st line. Then reads in 2nd line. Compares the two lines.
; If they are different, writes 1st line to out-file. If line 1 and line 2 are same ignores both.
; program reads line 3. Compares line 2 to line 3. If same then ignores, if different then writes line 2.
; Program reads line 4. Compares line 3 to line 4. If same then ignores, if different then writes line 3.
;
;
; Compares 1st and 2nd line in in-file.
; If 1st and 2nd is different, writes out 1st line.
; If 1st and 2nd is same, ignores both.
; line 2 goes into buffer 1, buffer 2 then reads in line 3. Compares line 2 and 3.
; if different, writes out line 2, if same, ignores both. Reads line 4, compares lines 3 to 4. ETC
;
; Stripper14  <in-file>  <out-file>
;
; Currently reads in line up to 00Dh. Bit of a hack with <cr><lf> and the ending ',' (comma).
; Works ok for large in-file.    1.4meg is around a second or two.
;
;
;
;  000500,31,02792,
;  000500,31,02792,
;  000500,31,02792,
;  000501,01,02793,
;  000501,01,02793,
;  000502,02,02794,
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
notes   	DB      cr,lf,'Stripper14  /djm,  14/6/6', cr,lf
        	DB      cr,lf,'Compares 1st and 2nd line in in-file.'
        	DB      cr,lf,'If 1st and 2nd is different, writes out 1st line.'
        	DB      cr,lf,'If 1st and 2nd is same, ignores both.'
        	DB      cr,lf,'Stripper14  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0

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

	mov	di, offset buffer1
@@_41:	mov     ah, 3Fh                 ; DOS Read-file function47W Y [Q497U
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
        jnc     @@_411                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@_411: or      ax, ax                  ; Check for end of input file
        jnz     @@_412
	jmp	@@80                   ; ax=0=end of file; jump
@@_412:	

	push	di
        mov     di, offset oneByte
	mov	al, [di]
	pop	di

	cmp	al, 0dh
	je	@@_43
	stosb
	jmp	@@_41
	

@@_43:	
	mov	al, ','
	stosb
;	mov	al, 10
;	stosb
;	mov	al, 13
;	stosb
;	call	readbyte		; get rid of <CR>
;	call	readbyte		; get rid of <LF>
	mov	di, offset buffer2
@@_44:	mov     ah, 3Fh                 ; DOS Read-file function47W Y [Q497U
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
        jnc     @@_441                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@_441: or      ax, ax                  ; Check for end of input file
        jnz     @@_442
	jmp	@@80                   ; ax=0=end of file; jump
@@_442:	

	push	di
        mov     di, offset oneByte
	mov	al, [di]
	pop	di

	cmp	al, 0dh
	je	@@_45
	stosb
	jmp	@@_44
@@_45:	
	mov	al, ','
	stosb
;	mov	al, 10
;	stosb
;	mov	al, 13
;	stosb
;	call	readbyte		; get rid of <CR>
;	call	readbyte		; get rid of <LF>




	mov	cx, 16
	mov	si, offset buffer1
	mov	di, offset buffer2
	rep	cmpsb
	jz	@@_46				;jump coz no difference found.
			
        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, _double_comma      		; Specify one byte to write
        mov     dx, offset buffer1		; Address variable with ds:dx
        int     21h				; Call DOS to write to file

        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 1            		; Specify one byte to write
        mov     dx, offset crlf			; Address variable with ds:dx
        int     21h				; Call DOS to write to file

	mov	di, offset buffer1
	mov	si, offset buffer2
	mov	cx, 16
	rep	movsb

@@_46:	jmp	@@_43
	



;-----------------------------------
; WRITE THE SUCKER oUT
;------------------------------------

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 16               ; Specify one byte to write
        mov     dx, offset buffer1	      		; Address variable with ds:dx
        int     21h			; Call DOS to write to file


@@80:
        mov     bx, [inFile]            ; Get input file handle
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
