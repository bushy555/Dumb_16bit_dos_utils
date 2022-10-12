;
;
; Stripper22 --- Xray barcode Stripper
; djm, 8/8/6
;?,00001,BLANK,,,181,,1,1,1,1,1,99,Y,N,C,99327574000019,N,,1,0,0,,,,,N,,0,TEST WEIGH LABEL,10-20-30 KG,NO TARE,,,0,1,2,,,,05115;1,,,,no,R
;?,00009,Neck Bones,,,97,,1,2,1,1,1,99,Y,N,P,99327574000095,N,,1,0,0,,,,,N,,0,*S*NECK BONES,(WITH MEAT),(HAM.6222) LP,,,0,2,2,,,,,,,,no,F
;?,00013,PEB DECKLE OFF,,,93,,1,1,1,1,1,99,Y,N,P,99327574000132,N,,1,0,0,,,,,N,,0,*S* PEB DECKLE OFF,(HAM.2350),IW,,,0,5,2,,,,,,,,no,F
;?,00019,PEB DECKLE OFF,,,93,,1,1,1,1,1,99,Y,N,P,99327574000194,N,,1,0,0,,,,,N,,0,*S* PEB DECKLE OFF,(HAM.2350),IW,,,0,2,2,,,,,,,,no,F
;?,00020,PEB DECKLE OFF,,,113,,1,1,1,1,1,99,Y,N,P,99327574000200,N,,1,6,0,,,,,N,,0,*S* PEB DECKLE OFF,(HAM.2350),IW/VAC,,,0,5,2,,,,,,,,no,F
;?,00021,BRISKET TRIMMINGS,,,29,,1,1,1,1,1,5,Y,N,P,99327574000217,N,,1,4,0,,,,,N,,0,*S* BRISKET TRIMMINGS,IW/VAC,,,,0,3,2,,,,,,,,no,F
;?,00023,BRISKET TRIMMINGS,,,49,,1,1,1,1,1,5,Y,N,P,99327574000231,N,,1,40,0,,,,,N,,0,*S* BRISKET TRIMMINGS,MW/VAC,,,,0,3,2,,,,,,,,no,F
;?,00024,PEB DECKLE OFF,,,93,,1,1,1,1,1,99,Y,N,P,99327574000248,N,,1,4,0,,,,,N,,0,*S* PEB DECKLE OFF,GRAIN FED,IW/VAC (HAM.2350),,,0,5,2,,,,,,,,no,F
;?,00025,Neck Bones,,,91,,1,2,1,1,1,99,Y,N,P,99327574000255,N,,1,0,0,,,,,N,,0,*PR* NECK BONE GF,(HAM.6222),LP,,,0,1,2,,,,,,,,no,F


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

notes   	DB      cr,lf,'01ah Stripper. djm, 11/5/4.'
	        DB      cr,lf,'Finds 01ah, and kills it.'
	        DB      cr,lf,'strip2 <input file> <output file>',cr,lf, 0

buf1		db 	0
buf2		db 	0
buf3		db 	0
buf4		db 	0

        CODESEG
        EXTRN StrWrite:Proc, NewLine:Proc				;-----  From STRIO.OBJ
        EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ

Start:  mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 2                   ; Does count = 2?
        je      @@10                    ; Continue if param count = 2
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
        mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        call    FileExists              ; Does output file exist?
        jc      @@30                    ; Jump if file does not exist
        call    StrWrite                ; Display file name
        call    Confirm                 ; Else confirm file removal
        je      @@30                    ; Continue if permission given
        jmp     Exit                    ; Else exit program
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
										;-----  At this point, the input and output files are open and
										;       their handles are stored at inFile and outFile.  The next 
										;       step is to read from the input file and write each byte
										;       to the output. 
;--------------------------------------------------------------------------


;?,00001,BLANK,,,181,,1,1,1,1,1,99,Y,N,C,99327574000019,N,,1,0,0,,,,,N,,0,TEST WEIGH LABEL,10-20-30 KG,NO TARE,,,0,1,2,,,,05115;1,,,,no,R
;?,00009,Neck Bones,,,97,,1,2,1,1,1,99,Y,N,P,99327574000095,N,,1,0,0,,,,,N,,0,*S*NECK BONES,(WITH MEAT),(HAM.6222) LP,,,0,2,2,,,,,,,,no,F
;?,00013,PEB DECKLE OFF,,,93,,1,1,1,1,1,99,Y,N,P,99327574000132,N,,1,0,0,,,,,N,,0,*S* PEB DECKLE OFF,(HAM.2350),IW,,,0,5,2,,,,,,,,no,F

@@50:   
	call	readbyte
	call	readbyte
	call	readbyte
	call	writebyte
	call	readbyte
	call	writebyte
	call	readbyte
	call	writebyte
	call	readbyte
	call	writebyte
	call	readbyte
	call	writebyte
	mov	al, 20h
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, '2'
	call	writebyte


@@61:	call	readbyte		
	cmp	al, 0ah
	jne	@@61

	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte

	jmp	@@50

	call	writebyte
	jmp	@@50





;---------------------------------------------------------------------------
Writebyte:
	mov     di, offset oneByte
	mov	[di], al
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
        jnc     @@70                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@70:   or      ax, ax                  ; Check for end of input file
        jz      @@80                    ; ax=0=end of file; jump
        ret
									;-----  Handle special case of disk-full condition
        mov     di, offset diskFull     ; Address disk-full message
        call    StrWrite                ; Display message
									;-----  Close the input and output files, which is not strictly
									;       required as ending the program via function 04Ch also closes
									;       all open files.  Note: errors are handled only when closing
									;       the output file because no changes are made to the input.
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
									;-----  Instructions jump to here to handle any I/O errors, which
									;       cause the program to end after displaying a message.
Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program



PROC    FileExists
        xor     al, al          	; Specify read-only access
        mov     ah, 3Dh         	; DOS Open-file function
        int     21h             	; Call DOS to open the file
        jc      @@99            	; Exit--file doesn't exist
        mov     bx, ax  	        ; Copy handle to bx
        mov     ah, 3Eh        		; DOS Close-file function
        int     21h     	        ; Close the file
        clc             	        ; Clear carry flag (file exists)
@@99:   ret                          	; Return to caller
ENDP    FileExists



PROC 	readbyte
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je      @@801                    ; ax=0=end of file; jump
	mov     di, offset oneByte
	mov	al, [di]
	ret
@@801:  mov     bx, [inFile]            ; Get input file handle
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
