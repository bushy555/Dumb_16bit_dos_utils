;
;
; Stripper69
; djm, 12/6/10
;
; Upon finding  ". . . . . . . . . . . " and removes it - for IPCONFIG'

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
oneByte         Db      0       ; Byte I/O variable

prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0

notes   DB      cr,lf,'01ah Strip69 +djm, 12/6/10'
        DB      cr,lf,'Finds ". . . . . . . . . . . " and removes it - for IPCONFIG'
        DB      cr,lf,'strip69 <input file> <output file>',cr,lf, 0


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

@@50:	call	readbyte	; .      ". . . . . . . . . . . "
	cmp	al, '.'
	jne	@@501
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '
	call	readbyte	;.
	call	readbyte	;' '

@@501:
@@Continue:
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
        jnc     @@70                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@70:
        or      ax, ax                  ; Check for end of input file
        jz      @@80                    ; ax=0=end of file; jump
        jmp     @@50

;-----  Handle special case of disk-full condition

        mov     di, offset diskFull     ; Address disk-full message
        call    StrWrite                ; Display message

;-----  Close the input and output files, which is not strictly
;       required as ending the program via function 04Ch also closes
;       all open files.  Note: errors are handled only when closing
;       the output file because no changes are made to the input.

@@80:
        mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit:
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

;-----  Instructions jump to here to handle any I/O errors, which
;       cause the program to end after displaying a message.

Errors:
        mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

%NEWPAGE
;---------------------------------------------------------------
; FileExists            Test whether a file already exists
;---------------------------------------------------------------
; Input:
;       ds:dx = address of ASCIIZ file name
; Output:
;       cf = 0 (jnc) = File of this name exists
;       cf = 1 (jc)  = File of this name does not exist
; Registers: ax, bx
;---------------------------------------------------------------
PROC    FileExists
        xor     al, al          ; Specify read-only access
        mov     ah, 3Dh         ; DOS Open-file function
        int     21h             ; Call DOS to open the file
        jc      @@99            ; Exit--file doesn't exist
        mov     bx, ax          ; Copy handle to bx
        mov     ah, 3Eh         ; DOS Close-file function
        int     21h             ; Close the file
        clc                     ; Clear carry flag (file exists)
@@99:
        ret                             ; Return to caller
ENDP    FileExists


PROC 	readbyte
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@802                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
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
        END     Start        ; End of program / entry point
