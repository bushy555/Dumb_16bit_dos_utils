;deletes 1 character at offset <offset>
;v1 - current version of del3.exe
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
position	db	0
		db	0
param3		db	0
		db	0
		db	0
realposition	db	0
		db	0
delete		db	0
		db	0
crtn		db	cr, lf, 0
prompt1		db	0
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   	DB      cr,lf,'Del3. v3.  /Bushy, 5-Aug-2k3.', cr,lf
        	DB      cr,lf,'Deletes 1 character at offset <offset>'
        	DB      cr,lf,'del1 <in-file> <out-file> <offset> <number chars to del?>'
        	DB      cr,lf,cr,lf
fred		db	cr,lf,cr,lf,0

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
        cmp     dx, 3                   ; Does count = 4?
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
        mov     cx, 2                   ; Get offset position
        call    GetOneParam             
	mov	di, offset param3
	call	AscToBin
	mov	di, offset param3
	mov	[di], ax

;        mov     cx, 3                   ; Get number of characters to delete
;        call    GetOneParam             
;        mov     dx, [di]
;	mov	di, offset delete
;	mov	[di], dx






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

@@_61:	mov	di, offset OneByte	; <CR>?
	mov	al, [di]
	cmp	al, 0dh
	jne	@@_03
	mov	di, offset realposition
	xor	dx, dx
	mov	[di], dx
@@_01:
					;found a <CR>
					; Count offset.
	mov	di, offset realposition
	mov	al, [di]
	inc	al
	mov	di, offset realposition
	mov	[di], al

	mov	di, offset param3
	mov	bl, [di]
	cmp	al, bl
	je	@@_02			; jmp & delete character

        mov     ah, 3Fh                 ; Read in character
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@_011
        jmp     Errors                  
@@_011:	mov     ah, 40h                	; Write char.
        mov     bx, [outFile]           
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
	jmp	@@_01



@@_02:  mov     ah, 3Fh                 ; Read 1 char and not write it (delete character)
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@_021
        jmp     Errors                  
@@_021:	jmp	@@50




@@_03:	mov     ah, 40h                	; Write char.
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



Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program



PROC FileExists
        xor     al, al          	; Specify read-only access
        mov     ah, 3Dh         	; DOS Open-file function
        int     21h             	; Call DOS to open the file
        jc      @@90            	; Exit--file doesn't exist
        mov     bx, ax          	; Copy handle to bx
        mov     ah, 3Eh         	; DOS Close-file function
        int     21h             	; Close the file
        clc                     	; Clear carry flag (file exists)
@@90:   ret                             ; Return to caller
ENDP    FileExists



PROC Confirm
	mov     di, offset Prompt       ; Address prompt string
        call    StrWrite                ; Display message
        mov     ah, 1                   ; DOS GetChar function
        int     21h                     ; Get user response
        cmp     al, 'Y'                 ; Compare with Y
        je      @@101                   ; Exit if char = Y
        cmp     al, 'y'                 ; Compare with y
        je      @@101                   ; Exit if char = y
        cmp     al, 'N'                 ; Compare with N
        je      @@100                   ; Handle No response
        cmp     al, 'n'                 ; Compare with n
        jne     Confirm                 ; Repeat if not Y, y, N, n
@@100:  cmp     al, '@'                 ; Reset zero flag (zf=0)
@@101:	ret                             ; Return to caller








;---------------------------------------------------------------
; ChToBase      Return number base for string
;---------------------------------------------------------------
; Note:
;       Private subroutine for AscToBin. Don't call directly.
; Input:
;       si = pointer to null terminator at end of string
;       Note: assumes length of string >= 1
; Output:
;       bx = 2(binary), 10(decimal/default), 16(hexadecimal)
;       si = address of last probable digit character in string
; Registers:
;       bx, dl, si      
;---------------------------------------------------------------
PROC    ChToBase
        mov     dl, [byte si-1]   ; Get last char of string
        mov     bx, 16          ; Preset base to 16 (hexadecimal)
        cmp     dl, 'H'         ; Is it a hex string?
        je      @@10            ; Jump if hex
        mov     bx, 2           ; Preset base to 2 (binary)
        cmp     dl, 'B'         ; Is it a binary string?
        je      @@10            ; Jump if binary
        mov     bx, 10          ; Preset base to 10 (decimal)
        cmp     dl, 'D'         ; Is it a decimal string?
        jne     @@20            ; Jump if NOT decimal
@@10:
        dec     si              ; Adjust si to last probable digit
@@20:
        ret                     ; Return to caller
ENDP    ChToBase



;---------------------------------------------------------------
; ValCh         Convert ASCII digit char to binary value
;---------------------------------------------------------------
; Input:
;       dl = ASCII digit '0'..'9'; 'A'..'F'
;       bx = base (2=binary, 10=decimal, 16=hexadecimal)
; Output:
;       cf = 0: dx = equivalent binary value
;       cf = 1: bad char for this number base (dx is meaningless)
; Registers:
;       dx
;---------------------------------------------------------------
PROC    ValCh
        cmp     dl, '9'         ; Check for possible hex digit
        jbe     @@10            ; Probably '0'..'9', jump
        sub     dl, 7           ; Adjust hex digit to 3A..3F range
@@10:
        sub     dl, '0'         ; Convert ASCII to decimal
        test    dl, 0f0h        ; Check 4 msbs (sets cf=0)
        jnz     @@99            ; Jump  if error (not digit or A-F)

        xor     dh, dh          ; Convert byte in dl to word in dx
        cmp     dx, bx          ; Compare to number base (cf=1 if ok)
@@99:
        cmc                     ; Complement cf to set/reset err flag
        ret                     ; Return to caller
ENDP    ValCh


;---------------------------------------------------------------
; AscToNum      Convert ASCII characters to binary
;---------------------------------------------------------------
; Note:
;       Private subroutine for AscToBin. Don't call directly.
; Input:
;       ax = initial value (0)
;       bx = number base (2=binary, 10=decimal, 16=hexadecimal)
;       di = address of unsigned string (any format)
;       si = address of last probable digit char in string
; Output:
;       cf = 0 : ax = unsigned value
;       cf = 1 : bad character in string (ax is meaningless)
; Registers:
;       ax, cx, dx, si
;---------------------------------------------------------------
PROC    AscToNum
        mov     cx, 1           ; Initialize multiplier
@@10:
        cmp     si, di          ; At front of string?
        je      @@99            ; Exit if at front (cf=0)
        dec     si              ; Do next char to left
        mov     dl, [byte si]   ; Load char into dl
        call    ValCh           ; Convert dl to value in dx
        jc      @@99            ; Exit if error (bad char)
        push    cx              ; Save cx on stack
        xchg    ax, cx          ; ax=multiplier; cx=partial value
        mul     dx              ; dxax <- digit value * multiplier
        add     cx, ax          ; cx <- cx + ax (new partial value)
        pop     ax              ; Restore multiplier to ax
        mul     bx              ; dxax <- multiplier * base
        xchg    ax, cx          ; ax=partial value; cx=new multiplier
        jmp     @@10            ; do next digit
@@99:
        ret                     ; Return to caller
ENDP    AscToNum





;---------------------------------------------------------------
; AscToBin      Convert ASCII strings to binary values
;---------------------------------------------------------------
; Input:
;       di = ASCIIZ string to convert to binary
;            'H' at end of string = hexadecimal
;            'B' at end of string = binary
;            'D' or digit at end of string = decimal
;            '-' at s[0] indicates negative number
;       Note: no blanks allowed in string
; Output:
;       cf = 1 : bad character in string (ax undefined)
;       cf = 0 : ax = value of string
;       Note: chars in string converted to uppercase
;       Note: null strings set ax to zero
; Registers:
;       ax
;---------------------------------------------------------------
PROC    AscToBin
        push    bx              ; Save modified registers
        push    cx              ; (some of these are changed
        push    dx              ;  in subroutines called by
        push    si              ;  this procedure)

        call    StrUpper        ; Convert string to uppercase
        call    StrLength       ; Set cx to Length of string at di
        xor     ax, ax          ; Initialize result to zero (cf=0)
        jcxz    @@99            ; Exit if length = 0.  ax=0, cf=0
        mov     si, di          ; Address string at di with si
        add     si, cx          ; Advance si to null at end of string
        cmp     [byte di], '-'  ; Check for minus sign
        pushf                   ; Save result of compare
        jne     @@10            ; Jump if minus sign not found
        inc     di              ; Advance di past minus sign
@@10:
        call    ChToBase        ; Set bx=number base; si to last digit
        call    AscToNum        ; Convert ASCII (base bx) to number
        rcl     bx, 1           ; Preserve cf by shifting into bx
        popf                    ; Restore flags from minus-sign check
        jne     @@20            ; Jump if minus sign was not found
        neg     ax              ;  else form twos complement of ax
        dec     di              ;  and restore di to head of string
@@20:
        rcr     bx, 1           ; Restore cf result from AscToNum
@@99:
        pop     si              ; Restore registers
        pop     dx
        pop     cx
        pop     bx
        ret                     ; Return to caller
ENDP    AscToBin


endP confirm
END     start