; Reads in Feedlot weather station data (can contain utter crap, headings and rubbish) and strips out everything but:
; actual data. Strips extra spaces and the last 01ah as well. 
; useage:
;           WSD6 <in-file> <out-file>
;
; DJM - 4/2/5
; djm   25/5/5

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
notes   	DB      cr,lf,'wsd2  /Bushy,  4/2/5.', cr,lf
        	DB      cr,lf,'Filters Feedlot weather-station data files, and removes menu text and other text rubbish.'
        	DB      cr,lf,'WSD2  <in-file>  <out-file>'
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
        jmp     Exit                    ; Exit program
					;-----  Attempt to open the input fil
@@10:   xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
					;-----  Check whether the output file already exist
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



@@50:	call 	readbyte
	cmp	al, ' '
	je	@@60
	cmp	al, 'd'
	je	@@60
	cmp	al, 0dh
	je	@@60
	cmp	al, 01ah
	je	@@52	

@@51:	call	writebyte		; read in good data line and write it out
@@52:	call	readbyte
	cmp	al, 0ah
	jne	@@51
	call	writebyte
	jmp	@@50

@@60:	call	readbyte		; read in entire useless line until 0ah is found.
	cmp	al, 0ah
	jne	@@60
	jmp	@@50



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
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@802                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
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
	mov	di, offset oneByte
	mov	[di], al


        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
	pop	dx
	pop	cx
	pop	bx
	ret


ENDP	writebyte
END     start