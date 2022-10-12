;deletes everything from <chr> to <chr>
;v3 - current version of del1.exe
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
fromChr		db	0
toChr		db	0
count		db	0
crtn		db	cr, lf, 0
prompt1		db	0
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   	DB      cr,lf,'Del1. v3.  /Bushy, 5-Aug-2k3.', cr,lf
        	DB      cr,lf,'Deletes everything (and including) from <start-chr> to <end-chr>'
        	DB      cr,lf,'del1 <in-file> <out-file> <start-chr> <end-chr> <[0|1]>'
	        DB      cr,lf,'<[0|1]> is:  0 = ignore Carrage returns'
	        DB      cr,lf,'<[0|1]> is:  1 = include Carrage returns'
        	DB      cr,lf,cr,lf
fred		db	cr,lf,cr,lf,0

        CODESEG

        EXTRN StrWrite:Proc, NewLine:Proc				;-----  From STRIO.OBJ
        EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ
Start:  					;-----  Initialize and display notes if no parameters entered
        mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 5                   ; Does count = 4?
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
        mov     cx, 2                   ; Get start Chr  (From chr)
        call    GetOneParam             
        mov     dx, [di]
	mov	di, offset FromChr
	mov	[di], dx
        mov     cx, 3                   ; Get End Chr  (From chr)
        call    GetOneParam             
        mov     dx, [di]
	mov	di, offset ToChr
	mov	[di], dx


@@41:   mov     cx, 4                   ; Specify parameter number 4
        call    GetOneParam             ; PROMPT1
        mov     dx, [di]                ;    0=no CR. 
	mov	di, offset Prompt1	;    1=CR
	mov	[di], dx


;-----  At this point, the input and output files are open and
;       their handles are stored at inFile and outFile.  The next 
;       step is to read from the input file and write each byte
;       to the output.

@@50:   mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
        jnc     @@60                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler

@@60:   or      ax, ax                  ; Check for end of input file
        jnz     @@_61
	jmp	@@80                    ; ax=0=end of file; jump

@@_61:	mov	di, offset Prompt1	; 0 = ignore  <CR>
        mov     al, [di]                ; 1 = include <CR>
	cmp	al, 31h
	je	@@_011

	mov	di, offset OneByte	; <CR>?
	mov	al, [di]
	cmp	al, 0dh
	jne	@@_011			
	mov     ah, 40h                	
        mov     bx, [outFile]           
        mov     cx, 2                   
        mov     dx, offset crtn
        int     21h                     

@@_011: 

	mov	di, offset OneByte
	mov	al, [di]
	mov	di, offset FromChr
	cmp	al, [di]   		;FromChr   ;22h	; offset oneByte	; is in range? (start if chr?)
	jne	@@_continue

@@_01:  mov     ah, 3Fh                 ;read next char.
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        or      ax, ax                  ; Check for end of input file
        jz      @@80                    ; ax=0=end of file; jump

	mov	di, offset OneByte
	mov	al, [di]
	mov	di, offset ToChr	
	cmp	al, [di]
	jne	@@_01			; if not, jump to @@_01, keep reading next char until EOC.
					
@@_02:  mov     ah, 3Fh                 ; if is end of chr, then read next char, and continue writing.
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        or      ax, ax                  ; Check for end of input file
        jz      @@80                    ; ax=0=end of file; jump

	mov     ah, 40h                	; Write char.
        mov     bx, [outFile]           
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     

	jmp	@@50


;---------------------------------------------------------------------------
@@_Continue:
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
        jnc     @@70                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@70:
        or      ax, ax                  ; Check for disk-full condition
        jz      @@_DF
	jmp	@@50                    ; Repeat for next byte

@@_DF:  mov     di, offset diskFull     ; Address disk-full message
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
PROC FileExists
        xor     al, al          ; Specify read-only access
        mov     ah, 3Dh         ; DOS Open-file function
        int     21h             ; Call DOS to open the file
        jc      @@90            ; Exit--file doesn't exist
        mov     bx, ax          ; Copy handle to bx
        mov     ah, 3Eh         ; DOS Close-file function
        int     21h             ; Close the file
        clc                     ; Clear carry flag (file exists)
@@90:   ret                             ; Return to caller
ENDP    FileExists



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
PROC Confirm
	mov     di, offset Prompt       ; Address prompt string
        call    StrWrite                ; Display message
        mov     ah, 1                   ; DOS GetChar function
        int     21h                     ; Get user response
        cmp     al, 'Y'                 ; Compare with Y
        je      @@101                    ; Exit if char = Y
        cmp     al, 'y'                 ; Compare with y
        je      @@101                   ; Exit if char = y
        cmp     al, 'N'                 ; Compare with N
        je      @@100                    ; Handle No response
        cmp     al, 'n'                 ; Compare with n
        jne     Confirm                 ; Repeat if not Y, y, N, n
@@100:   cmp     al, '@'                 ; Reset zero flag (zf=0)
@@101:   ret                             ; Return to caller
endP confirm
END     start