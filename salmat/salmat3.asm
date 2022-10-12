


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
display_char	db	0,'$'
_title		db	"Start - press any key$",0
pagenum		dw	0
charcount	dw	0


line1	db	'Ass # : $',0
line2	db 	'Date  : $',0
line3	db 	'Name  : $',0
line4	db 	'        $',0
line5	db 	'Add 1 : $',0
line6	db 	'Add 2 : $',0
line7	db 	'        $',0
line8	db 	'Add   : $',0
line9	db 	'TAG   : $',0
line10	db 	'line10: $',0
line11	db 	'line11: $',0
line12	db 	'METER : $',0
line13	db 	'        $',0
line14	db 	'        $',0
;line13	db 	'        $',0
;line13	db 	'line13: $',0
;line13	db 	'line13: $',0
;line14	db 	'line14: $',0
line15	db 	'        $',0
line16	db 	'        $',0
;line15	db 	'line15: $',0
;line16	db 	'line16: $',0
line17	db 	'line17: $',0
line18	db 	'line18: $',0
line19	db 	'        $',0
;line19	db 	'line19: $',0
line20	db 	'line20: $',0
line21	db 	'        $',0
line22	db 	'        $',0
;line21	db 	'line21: $',0
;line22	db 	'line22: $',0
line23	db 	'Amount: $',0
line24	db 	'Amount: $',0



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
        ;call    FileExists              ; Does output file exist?
        ;jc      @@30                    ; Jump if file does not exist
        ;call    StrWrite                ; Display file name
        ;call    Confirm                 ; Else confirm file removal
        ;je      @@30                    ; Continue if permission given
        ;jmp     Exit                    ; Else exit program
@@30:   mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:   mov     [outFile], ax           ; Save output file handle


	mov 	ax, 03
	int	10h
@@50:	
nop
nop
	mov	di, offset charcount
	mov	ax, 0
	mov	[di], ax

	mov	dx, offset line1
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line2
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line3
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line4
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line5
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line6
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line7
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line8
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line9
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line10
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line11
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line12
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line13
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line14
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line15
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line16
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line17
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line18
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line19
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line20
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line21
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line22
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line23
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	dx, offset line24
	mov	ah, 9
	int	21h
	call	readbyte2

	mov	di, offset pagenum		;	page = page + 1
	mov	al, [di]
	inc	ax
	mov	[di], al



	xor	ax, ax				;	PRESS A KEY
	int	16h



	cmp	ax, 011bh			; ESC
	je	@@QUIT2

	cmp	ax, 04B00h			; Left, Back 24 chr$13
	je	@@back

	cmp	ax, 04700h			; Home
	je	@@home

	cmp	ax, 5300h			; DEL
	je	@@DEL

	jmp	@@50


; -----------------------------------------------------------------  Delete line


@@DEL:
	jmp	@@50

; -----------------------------------------------------------------  Quit

@@QUIT2:mov     ah, 04Ch                
        mov     al, [exCode]            
        int     21h                     

; -----------------------------------------------------------------  Go back one page

@@home:
	mov	al, 0			; reset file pointer to offset 0
	mov	ah, 42h
	mov	bx, [inFile]
	mov	cx, 0
	mov	dx, 0
	int	21h
	jmp	@@50

@@back:					; Go back 24x 0x13
	mov	al, 1			; reset file pointer to offset 0
	mov	ah, 42h
	mov	bx, [inFile]
	mov	cx, 0
	mov	dx, 0
	int	21h


	mov	di, offset pagenum	; dec pagenum
	mov	al, [di]
	dec	ax
	dec	ax
	dec	ax
	mov	[di], al

;
;	jmp	@@50


	mov	dx, ax
	mov	ax, 24
	mul	dx

	mov	cx, ax

@@B3:	
@@B4:	push	cx
	call	readbyte
	pop	cx
	cmp	al, 0ah
	jne	@@B4
	call	readbyte
	loop	@@B3

	mov	dx, offset _title
	mov	ah, 9
	int	21h
		
	jmp	@@50



@@B0:
@@B1:	push	cx
	mov	cx, 24
@@B2:	call	readbyte
	cmp	al, 0ah
	jne	@@B2
	call	readbyte
	loop	@@B2
	pop	cx
	loop	@@B1

	mov	dx, offset _title
	mov	ah, 9
	int	21h
		
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
;	push	ax
;	push	bx
	push	cx
;	push	dx
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@80                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
;	pop	dx
	pop	cx
;	pop	bx
;	pop	ax
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



PROC	readbyte0			; readin entire line
@@_200:	call	readbyte
	cmp	al, 0ah
	jne	@@_200
	ret
ENDP	readbyte0



PROC	readbyte1			; readin 24 lines
	mov	cx, 24
@@_300:	call	readbyte0
	loop	@@_300
	ret
ENDP	readbyte1






PROC	readbyte00			; readin 24 lines
	mov	cx, 24

@@_301:	call	readbyte
	cmp	al, 0ah
	jne	@@_301
	loop	@@_301
	ret
ENDP	readbyte00




PROC	readbyte2			; readin and display entire line
@@_100:	
	mov	di, offset charcount
	mov	ax, [di]
	inc	ax
	mov	[di], ax

	call	readbyte

	cmp	al, 0ah
	je	@@_101
	mov	di, offset display_char
	mov	[di], al
	mov	dx, offset display_char
	mov	ah, 9
	int	21h
	jmp	@@_100
@@_101:	mov	di, offset display_char
	mov	[di], al
	mov	dx, offset display_char
	mov	ah, 9
	int	21h
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
