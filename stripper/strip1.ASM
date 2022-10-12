;
;
; 0dh,0dh Stripper
; djm, 23/04/04
;
; Upon finding 0dh 0dh within the input file, will replace it with single 0dh.
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

notes   DB      cr,lf,'0dh Stripper. djm, 23/4/4.'
        DB      cr,lf,'Replaces 0dh 0dh within input file with single 0dh'
        DB      cr,lf,'strip1 <input file> <output file>',cr,lf, 0


        CODESEG

;-----  From STRIO.OBJ
        EXTRN StrWrite:Proc, NewLine:Proc

;-----  From DISKERR.OBJ
        EXTRN DiskErr:Proc

;-----  From PARAMS.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc

Start:  

;-----  Initialize and display notes if no parameters entered

        mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 2                   ; Does count = 2?
        je      @@10                    ; Continue if param count = 2
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
        jmp     Exit                    ; Exit program

;-----  Attempt to open the input file

@@10:
        xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler

;-----  Check whether the output file already exists

@@20:
        mov     [inFile], ax            ; Save input file handle
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

@@30:
        mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:
        mov     [outFile], ax           ; Save output file handle

;-----  At this point, the input and output files are open and
;       their handles are stored at inFile and outFile.  The next 
;       step is to read from the input file and write each byte
;       to the output. 

@@50:
        mov     ah, 3Fh                 ; DOS Read-file function47W Y [Q497U
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
        jnc     @@60                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@60:
        or      ax, ax                  ; Check for end of input file
        jz      @@80                    ; ax=0=end of file; jump
;--------------------------------------------------------------------------


        mov     di, offset oneByte
	mov	al, [di]

	cmp	al, 0dh
	jne	@@continue

        mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
        jnc     @@61                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@61:
        or      ax, ax                  ; Check for end of input file
        jz      @@80                    ; ax=0=end of file; jump





;---------------------------------------------------------------------------
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
%NEWPAGE
;---------------------------------------------------------------
; Confirm               Get Yes/No confirmation from user
;---------------------------------------------------------------
; Input:
;       none
; Output:
;       zf = 0 (jnz) = user typed N or n
;       zf = 1 (jz)  = user typed Y or y
; Registers: ax, cx, di
;---------------------------------------------------------------
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
@@20:
        cmp     al, '@'                 ; Reset zero flag (zf=0)
@@99:   
        ret                             ; Return to caller
ENDP    Confirm

        END     Start        ; End of program / entry point
