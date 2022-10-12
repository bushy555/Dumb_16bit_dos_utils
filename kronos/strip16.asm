;
;
; Stripper 15
; djm, 02/07/04
;
; Upon finding 'sat','sun','mon','tue','wed',thu','fri',' Totals' it writes 'that articular line. All other lines are killed.
;

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

notes   	DB      cr,lf,'Kronos listing Stripper. djm, 25/7/6.'
        	DB      cr,lf,'kills all lines bar those with mon/tue/wed/thu/fri/sat/sun/total'
        	DB      cr,lf,'strip15 <input file> <output file>',cr,lf, 0
dot		db	'.',0
option1		db	0
buffer		db	'   ',0

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




@@50:	call	readbyte
	mov	di, offset buffer
	mov	[di], al
	CMP	AL, 'S'
	jne	@@51
	call	readbyte
	mov	di, offset buffer+1
	mov	[di], al
	cmp	al, 'a'
	je	@@write
	cmp	al, 'u'
	je	@@write
	jmp	@@56
	
@@51:	cmp	al, 'M'
	jne	@@52
	call	readbyte
	mov	di, offset buffer+1
	mov	[di], al
	cmp	al, 'o'
	je	@@write
	jmp	@@56


@@52:	cmp	al, 'T'
	jne	@@53
	call	readbyte
	mov	di, offset buffer+1
	mov	[di], al
	cmp	al, 'u'
	je	@@write
	cmp	al, 'h'
	je	@@write
	jmp	@@56


@@53:	cmp	al, 'W'
	jne	@@54
	call	readbyte
	mov	di, offset buffer+1
	mov	[di], al
	cmp	al, 'e'
	je	@@write
	jmp	@@56


@@54:	cmp	al, 'F'
	jne	@@55			
	call	readbyte
	mov	di, offset buffer+1
	mov	[di], al
	cmp	al, 'r'
	je	@@write
	jmp	@@56

@@55:	cmp	al, ' '
	jne	@@56			; nothing found. Do not write this line.
	call	readbyte
	mov	di, offset buffer+1
	mov	[di], al
	cmp	al, 'T'
	je	@@write
	jmp	@@56



@@56:	call	readbyte
	cmp	al, 0ah
	jne	@@56			; loops until end of line is found
	jmp	@@50


@@write:mov	di, offset buffer
	mov	al, [di]
	call	writebyte
	mov	di, offset buffer + 1
	mov	al, [di]
	call	writebyte
@@w1:	call	readbyte
	cmp	al, 0ah
	je	@@w2
	call	writebyte
	jmp	@@w1
@@w2:	mov	al, 0ah
	call	writebyte

	jmp	@@50





PROC 	writebyte

	mov     di, offset oneByte
	mov	[di], al
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
	ret
ENDP	writebyte


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
