; Reads in SLBODY.CSV, strips out crap, writes out SLKILL.CSV
; for sastek <--> thorsys stuff.
;
;           MAKE_SLKILL <in-file> <out-file>
;
; v1 DJM - 09/05/05
; v2 DJM - 16/05/05
; v3 DJM - 20/05/05
;
;
;example
;
;v3:
;2,20/05/05, 1,1,,"F1         ", 1,,1,,,,,,,,,, 1,,,,,,,,,,,,,,,,,,,,,18001,,,,EK
;2,20/05/05, 2,1,,"F1         ", 2,,1,,,,,,,,,, 1,,,,,,,,,,,,,,,,,,,,,18001,,,,EK
;2,20/05/05, 3,1,,"F1         ", 3,,1,,,,,,,,,, 1,,,,,,,,,,,,,,,,,,,,,18001,,,,EK
;2,20/05/05, 4,1,,"F2         ", 4,,1,,,,,,,,,, 2,,,,,,,,,,,,,,,,,,,,,18002,,,,EK
;2,20/05/05, 5,1,,"F2         ", 5,,1,,,,,,,,,, 2,,,,,,,,,,,,,,,,,,,,,18002,,,,EK
;2,20/05/05, 6,1,,"F2         ", 6,,1,,,,,,,,,, 2,,,,,,,,,,,,,,,,,,,,,18002,,,,EK
;2,20/05/05, 7,1,,"F3         ", 7,,1,,,,,,,,,, 3,,,,,,,,,,,,,,,,,,,,,18003,,,,EK
;2,20/05/05, 8,1,,"F4         ", 8,,1,,,,,,,,,, 4,,,,,,,,,,,,,,,,,,,,,18004,,,,EK
;2,20/05/05, 9,1,,"F5         ", 9,,1,,,,,,,,,, 5,,,,,,,,,,,,,,,,,,,,,18005,,,,EK
;2,20/05/05,10,1,,"Y6         ",10,,1,,,,,,,,,, 6,,,,,,,,,,,,,,,,,,,,,18006,,,,EK
;2,20/05/05,11,1,,"Y7         ",11,,1,,,,,,,,,, 7,,,,,,,,,,,,,,,,,,,,,18007,,,,EK
;2,20/05/05,12,1,,"Y8         ",12,,1,,,,,,,,,, 8,,,,,,,,,,,,,,,,,,,,,18008,,,,EK
;2,20/05/05,13,1,,"Y9         ",13,,1,,,,,,,,,, 9,,,,,,,,,,,,,,,,,,,,,18009,,,,EK
;2,20/05/05,14,1,,"KOG        ",14,,1,,,,,,,,,,10,,,,,,,,,,,,,,,,,,,,,18010,,,,EK
;2,20/05/05,15,1,,"R1         ",15,,1,,,,,,,,,,11,,,,,,,,,,,,,,,,,,,,,18011,,,,EK
;2,20/05/05,16,1,,"R2         ",16,,1,,,,,,,,,,12,,,,,,,,,,,,,,,,,,,,,18012,,,,EK
;2,20/05/05,17,1,,"LOG        ",17,,1,,,,,,,,,,13,,,,,,,,,,,,,,,,,,,,,18013,,,,EK
;2,20/05/05,18,1,,"KOA        ",18,,1,,,,,,,,,,14,,,,,,,,,,,,,,,,,,,,,18014,,,,EK
;2,20/05/05,19,1,,"KOA        ",19,,1,,,,,,,,,,14,,,,,,,,,,,,,,,,,,,,,18014,,,,EK
;2,20/05/05,20,1,,"KOA        ",20,,1,,,,,,,,,,14,,,,,,,,,,,,,,,,,,,,,18014,,,,EK
;
;
;
        IDEAL
        MODEL   small
        STACK   256


cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed

        DATASEG

exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   	DB      cr,lf,'MAKE_SLKILL  /djm,  9/5/5.', cr,lf
        	DB      cr,lf,'Converts SLBODY.CSV to SLKILL.CSV'
        	DB      cr,lf,''
        	DB      cr,lf
        	DB      cr,lf,'MAKE_SLKILL  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0

buffer		db '2,20/05/05,10,1,,"F1         ", 1,,1,,,,,,,,,, 1,,,,,,,,,,,,,,,,,,,,,18001,,,,EK',0dh,0ah
		db '2,20/05/05,20,1,,"F1         ", 2,,1,,,,,,,,,, 1,,,,,,,,,,,,,,,,,,,,,18001,,,,EK',0dh,0ah
		db '2,20/05/05,30,1,,"F1         ", 3,,1,,,,,,,,,, 1,,,,,,,,,,,,,,,,,,,,,18001,,,,EK',0dh,0ah
		db '2,20/05/05,40,1,,"F2         ", 4,,1,,,,,,,,,, 2,,,,,,,,,,,,,,,,,,,,,18002,,,,EK',0dh,0ah
		db '2,20/05/05,50,1,,"F2         ", 5,,1,,,,,,,,,, 2,,,,,,,,,,,,,,,,,,,,,18002,,,,EK',0dh,0ah
		db '2,20/05/05,60,1,,"F2         ", 6,,1,,,,,,,,,, 2,,,,,,,,,,,,,,,,,,,,,18002,,,,EK',0dh,0ah
		db '2,20/05/05,70,1,,"F3         ", 7,,1,,,,,,,,,, 3,,,,,,,,,,,,,,,,,,,,,18003,,,,EK',0dh,0ah
		db '2,20/05/05,80,1,,"F4         ", 8,,1,,,,,,,,,, 4,,,,,,,,,,,,,,,,,,,,,18004,,,,EK',0dh,0ah
		db '2,20/05/05,90,1,,"F5         ", 9,,1,,,,,,,,,, 5,,,,,,,,,,,,,,,,,,,,,18005,,,,EK',0dh,0ah
		db '2,20/05/05,100,1,,"Y6        ",10,,1,,,,,,,,,, 6,,,,,,,,,,,,,,,,,,,,,18006,,,,EK',0dh,0ah
		db '2,20/05/05,110,1,,"Y7        ",11,,1,,,,,,,,,, 7,,,,,,,,,,,,,,,,,,,,,18007,,,,EK',0dh,0ah
		db '2,20/05/05,120,1,,"Y8        ",12,,1,,,,,,,,,, 8,,,,,,,,,,,,,,,,,,,,,18008,,,,EK',0dh,0ah
		db '2,20/05/05,130,1,,"Y9        ",13,,1,,,,,,,,,, 9,,,,,,,,,,,,,,,,,,,,,18009,,,,EK',0dh,0ah
		db '2,20/05/05,140,1,,"KOG       ",14,,1,,,,,,,,,,10,,,,,,,,,,,,,,,,,,,,,18010,,,,EK',0dh,0ah
		db '2,20/05/05,150,1,,"R1        ",15,,1,,,,,,,,,,11,,,,,,,,,,,,,,,,,,,,,18011,,,,EK',0dh,0ah
		db '2,20/05/05,160,1,,"R2        ",16,,1,,,,,,,,,,12,,,,,,,,,,,,,,,,,,,,,18012,,,,EK',0dh,0ah
		db '2,20/05/05,170,1,,"LOG       ",17,,1,,,,,,,,,,13,,,,,,,,,,,,,,,,,,,,,18013,,,,EK',0dh,0ah
		db '2,20/05/05,180,1,,"KOA       ",18,,1,,,,,,,,,,14,,,,,,,,,,,,,,,,,,,,,18014,,,,EK',0dh,0ah
		db '2,20/05/05,190,1,,"KOA       ",19,,1,,,,,,,,,,14,,,,,,,,,,,,,,,,,,,,,18014,,,,EK',0dh,0ah
		db '2,20/05/05,200,1,,"KOA       ",20,,1,,,,,,,,,,14,,,,,,,,,,,,,,,,,,,,,18014,,,,EK',0dh,0ah,0


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
        jmp     Exit                    ; Exit program

					;-----  Attempt to open the input file
@@10:   xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler


					;-----  Check whether the output file already exists
@@20:   mov     [inFile], ax            ; Save input file handle
					;-----  Attempt to create the output file
@@30:   mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:   mov     [outFile], ax           ; Save output file handle




	mov	di, offset buffer
@@_44:	add	di, 2
@@_45:	
@@_46:	call	readbyte	; read:		get rid of first ,
	cmp	al, ','
	jne	@@_46
@@_47:	call	readbyte	; read:		get rid of second ,
	cmp	al, ','
	jne	@@_47
	call	readbyte	
	stosb			; write:	d 
	call	readbyte
	stosb			; write:	d
	call	readbyte
	stosb			; write:	/
	call	readbyte
	stosb			; write:	m
	call	readbyte	
	stosb			; write:	m
	call	readbyte
	stosb			; write:	/
	call	readbyte
	stosb			; write:	y
	call	readbyte
	stosb			; write:	y




						; second line
	mov	si, offset buffer + 2
	mov	di, offset buffer + 84
	mov	cx, 8
	push	si
	rep 	movsb
						; third line
	pop	si
	push	si
	mov	di, offset buffer + 83 + 83 
	mov	cx, 8
	rep 	movsb
						; fourth line
	pop	si
	push	si
	mov	di, offset buffer + 83 + 83 + 82
	mov	cx, 8
	rep 	movsb
						; fifth line
	pop	si
	push	si
	mov	di, offset buffer + 83 + 83 + 82 + 82
	mov	cx, 8
	rep 	movsb
						; sixth line
	pop	si
	push	si
	mov	di, offset buffer + 82 + 82 + 82 + 82 + 82 + 2
	mov	cx, 8
	rep 	movsb
						; seventh line
	pop	si
	push	si
	mov	di, offset buffer + 82 + 82 + 82 + 82 + 82 + 82 + 2
	mov	cx, 8
	rep 	movsb
						; eighth line
	pop	si
	push	si
	mov	di, offset buffer + 82 + 82 + 82 + 82 + 82 + 82 + 82 + 2
	mov	cx, 8
	rep 	movsb
						; ninth line
	pop	si
	push	si
	mov	di, offset buffer + 82 + 82 + 82 + 82 + 82 + 82 + 82 + 82 + 2
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82+82+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82+82+82+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82+82+82+82+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	push	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82+82+82+82+82+82+82
	mov	cx, 8
	rep 	movsb

	pop	si
	mov	di, offset buffer+82+82+82+82+82+82+82+82+2+82+82+82+82+82+82+82+82+82+82
	mov	cx, 8
	rep 	movsb


;-----------------------------------
; WRITE THE SUCKER oUT
;------------------------------------

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 82*20               ; Specify one byte to write
        mov     dx, offset buffer	      		; Address variable with ds:dx
        int     21h			; Call DOS to write to file


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
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                    ; ax=0=end of file; jump

	cmp	al, 0dh
	je	@@802

	mov     di, offset oneByte
	mov	al, [di]
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
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
END     start
