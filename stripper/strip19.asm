; Stripper19  /djm,  
; 07/8/6, 
; 29/8/6, fixed bug
;
;
;made for xray
;
;got a list of product codes. 
;01001
;01002
;01002
;01002
;01003
;01003
;04123
;09999
;09999
;
;turns it into this:
;01001   001
;01002   003
;01003   002
;04123   001
;09999   002



        IDEAL
        MODEL   small
        STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
;_double_comma	EQU	16		; gives single end comma
_double_comma	EQU	17		; gives double end comma. DIRTY HACK!

        DATASEG
space		db	'   ',0
count0		db	0
count1		db	0
count2		db	0
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Stripper19  /djm,  7/8/6', cr,lf
        	DB      cr,lf,'Xray product counter doovey.'
        	DB      cr,lf,'Stripper19  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0

	;           000500,31,02792,
buffer1	db '00000',0,0,0
buffer2	db '00000',0,0,0
read1	db 'X$'
read2	db 'O$'
read3	db '#$'
read4	db 'I$'


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

	mov	di, offset count0
	mov	ax, 1
	mov	[di], al
	mov	di, offset count1
	mov	ax, 0
	mov	[di], al
	mov	di, offset count2
	mov	ax, 0
	mov	[di], al



	call	readbyte
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


@@_43:	

	call	readbyte
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


	mov	cx, 7
	mov	si, offset buffer1
	mov	di, offset buffer2
	rep	cmpsb
	jnz	@@_403				;jump coz no difference found. GOTO add 1 to counter.
	jmp	@@_46

@@_403:	mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 5		      		; Specify one byte to write
        mov     dx, offset buffer1		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 2		      		; Specify one byte to write
        mov     dx, offset space		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


	mov	di, offset count0
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset count1
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset count2
	mov	al, [di]
	or	al, 30h
	mov	[di], al

	
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1               	; Specify one byte to write
        mov     dx, offset count2	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1               	; Specify one byte to write
        mov     dx, offset count1	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1               	; Specify one byte to write
        mov     dx, offset count0	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cl, 2            		; Specify one byte to write
        mov     dx, offset crlf			; Address variable with ds:dx
        int     21h				; Call DOS to write to file

	mov	di, offset count0
	mov	al, 1
	mov	[di], al
	mov	di, offset count1
	xor	ax, ax
	mov	[di], al
	mov	di, offset count2
	xor	ax, ax
	mov	[di], al


	mov	di, offset buffer1
	mov	si, offset buffer2
	mov	cl, 7
	rep	movsb
	jmp	@@_43

@@_46:	


	mov	di, offset count0
	mov	al, [di]
	inc	ax
	cmp	al, 9
	jle	@@461
 	mov	al, 0
	mov	[di], al
	mov	di, offset count1
	mov	al, [di]
	inc	ax
	cmp	al, 9
	jle	@@462
	mov	al, 0
	mov	[di], al
	mov	di, offset count2
	mov	al, [di]
	inc	al
	cmp	al, 9
	jle	@@463
	mov	al, 0
	mov	[di], al
	jmp	@@_43

@@461:	mov	[di], al
	jmp	@@_43
	
@@462:	mov	[di], al
	jmp	@@_43

@@463:	mov	[di], al
	jmp	@@_43



;-----------------------------------
; WRITE THE SUCKER oUT
;------------------------------------

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 7               	; Specify one byte to write
        mov     dx, offset buffer1	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 3               	; Specify one byte to write
        mov     dx, offset count0	; Address variable with ds:dx
        int     21h			; Call DOS to write to file



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
        je     	@@802                   ; ax=0=end of file; jump
	mov     di, offset oneByte
	mov	al, [di]
	ret

@@802:

	mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 5		      		; Specify one byte to write
        mov     dx, offset buffer1		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


        mov     ah, 40h                 	; DOS Write-file function
        mov     bx, [outFile]           	; Set bx to output file handle
        mov     cx, 2		      		; Specify one byte to write
        mov     dx, offset space		; Address variable with ds:dx
        int     21h				; Call DOS to write to file


	mov	di, offset count0
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset count1
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset count2
	mov	al, [di]
	or	al, 30h
	mov	[di], al

	
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1               	; Specify one byte to write
        mov     dx, offset count2	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1               	; Specify one byte to write
        mov     dx, offset count1	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1               	; Specify one byte to write
        mov     dx, offset count0	; Address variable with ds:dx
        int     21h			; Call DOS to write to file

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
