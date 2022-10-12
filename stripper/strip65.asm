;
;
; Stripper 
; djm, 25/03/08
;
; Dumps chiller temp probe from original .DTA to .CSV files.
; 1. read up until '#Endcom' <CR>
; 2. read in temp value, write out temp value
;
;-----------------------------------------------
;#DL SOFTWARE#
;E7824_26
;min
;5
;1418
;2008
;3
;20
;15
;5
;33
;933
;
;
;
;
;#Endcom
;1 -273.00
;2 31.29
;3 22.51
;4 22.33
;5 22.16
;6 21.89
;7 21.72
;8 21.37
;9 21.10
;10 20.84
;11 20.49
;12 20.19
;13 19.88
;14 19.67
;15 19.36
;16 19.10
;17 18.80
;18 18.45
;19 18.15
;20 17.84
;21 17.49
;22 17.19
;23 16.89
;24 16.63
;25 16.32
;-----------------------------------------------

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

notes   	DB      cr,lf,'Stripper'
        	DB      cr,lf,''
        	DB      cr,lf,'strip <input file> <output file>',cr,lf, 0
dot		db	'.',0
option1		db	0
http		db	'http://',0

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


@@50:	call	readbyte		;    #Endcom
	cmp	al, 'E'
	jne	@@50
	call	readbyte
	cmp	al, 'n'
        jne     @@50
	call	readbyte
	cmp	al, 'd'
        jne     @@50
	call	readbyte
        cmp     al, 'c'
        jne     @@50
	call	readbyte
        cmp     al, 'o'
        jne     @@50
	call	readbyte
        cmp     al, 'm'
        jne     @@50

	
@@51:	call	readbyte	; read in bytes until ' ' is found.
	cmp	al, ' '
	jne	@@51
				; next bytes are temp. Dump this.

@@52:	call	readbyte
	cmp	al, 0ah
	je	@@53
	call	writebyte
	jmp	@@52	
@@53:	call	writebyte
	jmp	@@51

	


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
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@80                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
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
