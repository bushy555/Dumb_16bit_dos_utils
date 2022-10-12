


        IDEAL
        MODEL   small
        STACK   256

cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed

        DATASEG
hitenter	db	13,10,0
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         Db      0       ; Byte I/O variable
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0

notes   	DB      cr,lf,'Deadies Stripper. djm, 04/11/6.'
        	DB      cr,lf,''
        	DB      cr,lf,'strip number <input file> <output file>',cr,lf, 0
dot		db	'.',0


line1	db	'line01: $',0
line2	db 	'line02: $',0
line3	db 	'line03: $',0
line4	db 	'line04: $',0
line5	db 	'line05: $',0
line6	db 	'line06: $',0
line7	db 	'line07: $',0
line8	db 	'line08: $',0
line9	db 	'line09: ',0
line10	db 	'line10: ',0
line11	db 	'line11: ',0
line12	db 	'line12: ',0
line13	db 	'line13: ',0
line14	db 	'line14: ',0
line15	db 	'line15: ',0
line16	db 	'line16: ',0
line17	db 	'line17: ',0
line18	db 	'line18: ',0
line19	db 	'line19: ',0
line20	db 	'line20: ',0
line21	db 	'line21: ',0
line22	db 	'line22: ',0
line23	db 	'line23: ',0
line24	db 	'line24: ',0

liner1	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner2	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner3	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner4	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner5	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner6	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner7	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner8	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner9	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner10	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner11	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner12	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner13	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner14	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner15	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner16	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner17	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner18	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner19	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner20	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner21	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner22	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner23	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
liner24	db 0,0,0,0,0,0,0,0,0,0,0,0,0,00,0,0,0,0,0,0,0,00,00,0,0,0,0,0,00,0,0,0,0,0,0,00,0,0,0,0,0,0,0,0,0,0,0,0,0,0




	        CODESEG
	        EXTRN StrWrite:Proc, NewLine:Proc
	        EXTRN DiskErr:Proc
	        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc
Start:  mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 2                   ; Does count = 2?
        je      @@10                    ; Continue if param count = 2
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
        jmp     Exit                    ; Exit program
@@10:   xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@20:   mov     [inFile], ax            ; Save input file handle
        mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        call    FileExists              ; Does output file exist?
        jc      @@30                    ; Jump if file does not exist
        call    StrWrite                ; Display file name
        call    Confirm                 ; Else confirm file removal
        je      @@30                    ; Continue if permission given
        jmp     Exit                    ; Else exit program
@@30:   mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:   mov     [outFile], ax           ; Save output file handle




@@50:	; mov 	ax, 0
	; int	10h


	mov	di, offset liner1
	call	readbyte2
	mov	di, offset liner2
	call	readbyte2
	mov	di, offset liner3
	call	readbyte2
	mov	di, offset liner4
	call	readbyte2
	mov	di, offset liner5
	call	readbyte2
	mov	di, offset liner6
	call	readbyte2
	mov	di, offset liner7
	call	readbyte2
	mov	di, offset liner8
	call	readbyte2
	mov	di, offset liner9
	call	readbyte2
	mov	di, offset liner10
	call	readbyte2
	mov	di, offset liner11
	call	readbyte2
	mov	di, offset liner12
	call	readbyte2
	mov	di, offset liner13
	call	readbyte2
	mov	di, offset liner14
	call	readbyte2
	mov	di, offset liner15
	call	readbyte2
	mov	di, offset liner16
	call	readbyte2
	mov	di, offset liner17
	call	readbyte2
	mov	di, offset liner18
	call	readbyte2
	mov	di, offset liner19
	call	readbyte2
	mov	di, offset liner20
	call	readbyte2
	mov	di, offset liner21
	call	readbyte2
	mov	di, offset liner22
	call	readbyte2
	mov	di, offset liner23
	call	readbyte2
	mov	di, offset liner24
	call	readbyte2


;	mov	ax, 03			; CLS
;	int	10h



	mov	dx, offset line1
	mov	ax, 9
	int	21h

	mov	dx, offset liner1
	mov	ax, 9
	int	21h

	mov	dx, offset line2
	mov	ax, 9
	int	21h
	mov	dx, offset liner2
	mov	ax, 9
	int	21h

	mov	di, offset line3
	mov	ax, 9
	int	21h
	mov	di, offset liner3
	mov	ax, 9
	int	21h

	mov	di, offset line4
	mov	ax, 9
	int	21h
	mov	di, offset liner4
	mov	ax, 9
	int	21h

	mov	di, offset line5
	mov	ax, 9
	int	21h
	mov	di, offset liner5
	mov	ax, 9
	int	21h

	mov	di, offset line6
	mov	ax, 9
	int	21h
	mov	di, offset liner6
	mov	ax, 9
	int	21h

	mov	di, offset line7
	mov	ax, 9
	int	21h
	mov	di, offset liner7
	mov	ax, 9
	int	21h

	mov	di, offset line8
	mov	ax, 9
	int	21h
	mov	di, offset liner8
	mov	ax, 9
	int	21h

	mov	di, offset line9
	mov	ax, 9
	int	21h
	mov	di, offset liner9
	mov	ax, 9
	int	21h

	mov	di, offset line10
	mov	ax, 9
	int	21h
	mov	di, offset liner10
	mov	ax, 9
	int	21h

	mov	di, offset line11
	mov	ax, 9
	int	21h
	mov	di, offset liner11
	mov	ax, 9
	int	21h

	mov	di, offset line12
	mov	ax, 9
	int	21h
	mov	di, offset liner12
	mov	ax, 9
	int	21h

	mov	di, offset line13
	mov	ax, 9
	int	21h
	mov	di, offset liner13
	mov	ax, 9
	int	21h

	mov	di, offset line14
	mov	ax, 9
	int	21h
	mov	di, offset liner14
	mov	ax, 9
	int	21h

	mov	di, offset line15
	mov	ax, 9
	int	21h
	mov	di, offset liner15
	mov	ax, 9
	int	21h

	mov	di, offset line16
	mov	ax, 9
	int	21h
	mov	di, offset liner16
	mov	ax, 9
	int	21h

	mov	di, offset line17
	mov	ax, 9
	int	21h
	mov	di, offset liner17
	mov	ax, 9
	int	21h

	mov	di, offset line18
	mov	ax, 9
	int	21h
	mov	di, offset liner18
	mov	ax, 9
	int	21h

	mov	di, offset line19
	mov	ax, 9
	int	21h
	mov	di, offset liner19
	mov	ax, 9
	int	21h

	mov	di, offset line20
	mov	ax, 9
	int	21h
	mov	di, offset liner20
	mov	ax, 9
	int	21h

	mov	di, offset line21
	mov	ax, 9
	int	21h
	mov	di, offset liner21
	mov	ax, 9
	int	21h

	mov	di, offset line22
	mov	ax, 9
	int	21h
	mov	di, offset liner22
	mov	ax, 9
	int	21h

	mov	di, offset line23
	mov	ax, 9
	int	21h
	mov	di, offset liner23
	mov	ax, 9
	int	21h

	mov	di, offset line24
	mov	ax, 9
	int	21h
	mov	di, offset liner24
	mov	ax, 9
	int	21h

;	PRESS A KEY

;LEFT ARROW  :BACK 24x CHR$(13)
;rIGHT ARROW :fWD  24x CHR$(13)

	jmp	@@50





PROC 	writebyte
	mov     di, offset oneByte
	mov	[di], al
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
;        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
	ret
ENDP	writebyte


PROC 	writebyte2
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        int     21h                     ; Call DOS to write to file
	ret
ENDP	writebyte2



Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program
PROC    FileExists
        xor     al, al          ; Specify read-only access
        mov     ah, 3Dh         ; DOS Open-file function
        int     21h             ; Call DOS to open the file
        jc      @@99            ; Exit--file doesn't exist
        mov     bx, ax          ; Copy handle to bx
        mov     ah, 3Eh         ; DOS Close-file function
        int     21h             ; Close the file
        clc                     ; Clear carry flag (file exists)
@@99:   ret                             ; Return to caller
ENDP    FileExists

PROC 	readbyte
	push	di
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@80                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
	pop	di
	ret

@@80:   mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

ENDP	readbyte


PROC	readbyte2
	
@@_100:	call	readbyte
	cmp	al, 0ah
	je	@@_101
	mov	 [di], al
	inc	di
	
	jmp	@@_100
@@_101: mov	[di], al
	inc	di
	mov	al, '$'
	mov	[di], al
	inc	di
	ret

ENDP	readbyte2

PROC    Confirm
        mov     di, offset Prompt       ; Address prompt string
        call    StrWrite                ; Display message
        mov     ah, 1                   ; DOS GetChar function
        int     21h                     ; Get user response
        cmp     al, 'Y'                 ; Compare with Y
        je      @@99                    ; Exit if char = Y
        cmp     al, 'y'                 ; Compare with y
        je      @@99                    ; Exit if char = y
        cmp     al, 'N'                 ; Compare with N
        je      @@20                    ; Handle No response
        cmp     al, 'n'                 ; Compare with n
        jne     Confirm                 ; Repeat if not Y, y, N, n
@@20:   cmp     al, '@'                 ; Reset zero flag (zf=0)
@@99:   ret                             ; Return to caller
ENDP    Confirm
END     Start        ; End of program / entry point
