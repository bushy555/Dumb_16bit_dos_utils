;
;PT6_ROCK1
;PT6_ROCK2
;PT6_ROCK3
;PT6_ROCK4
;PT6_ROCK5
;PT6_ROCK6
;PT6_ROCK7
;PT6_ROCK8
;PT6_ROCK9
;PT6_ROCK10
;PT6_ROCK11
;PT6_ROCK12
;PT6_ROCK13
;PT6_ROCK14
;PT6_ROCK15
;09:40:20.91 Comms timeout cannot switch to design 4
;09:40:20.92 Cannot switch to label - aborted print
;09:40:27.93 Printer is not Responding
;09:44:31.18 Session closing
;09:44:31.18 Session close: Clean up comms library
;09:44:31.30 Session close: shutdown OK
;09:44:31.29 Stopping winDYOL server
;09:44:31.30 Child pipe closed
;09:45:11.08 Output Activity to c:\DLCTMP\LABE1.Mon append
;09:45:11.30 Using sascom.dll version 4.2.0.5
;09:45:11.34 winDYOL server listening on port 1800
;09:45:11.52 Labeller software version is: 5.10 14Jul06
;09:45:11.55 Labeller UBI version is: UBI FingerPrint 8.70.1:PX4i-4.0
;09:45:11.79 Plugin: dv-dyol.p Version: 2.5
;                    Device: Dyol printer interface
;09:45:28.37 Printer is not Responding
;09:45:58.39 read-printer-response: NAK 00 Labeller has been powered off
;09:46:37.38 Line Initialized
;09:50:35.49 read-printer-response: NAK 00 Labeller has been powered off
;09:50:41.52 Sending Design 17 - Extend timeout by 2.6 sec(s)
;09:50:43.56 Switch to design 
;09:50:51.23 Auto download complete
;14:05:08.23 REJECT-TRANSACTION for TransID= 114844151,PPN= 40645,Date= 15/01/07,Serial= 3.
;
;
;
        IDEAL
        MODEL   small
        STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
ASCnull		equ	0

        DATASEG
space		db	'    ',0
count0		db	0
count1		db	0
count2		db	0
count3		db	0
count4		db	0
count5		db	0
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Stripper19  /djm,  7/8/6', cr,lf
        	DB      cr,lf,'Xray product counter doovey.'
        	DB      cr,lf,'Stripper19  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0

;	;           000500,31,02792,
;	;  '09999,4002,220806,0199327574099990130608223102000680214002
;prod1	db '00000'
;	db ',0000,'
;date1	db '000000'
;	db ',0000000000000000000000000000000000000000',0,0,0
;
;buf2	equ $
;prod2	db '00000'
;	db ',0000,'
;date2   db '000000'
;  	db ',0000000000000000000000000000000000000000',0,0,0
;
buffer1	db '00000',0,0,0
;buffer2	db '00000',0,0,0
;read1	db 'X$'
;read2	db 'O$'
;read3	db '#$'
;read4	db 'I$'
;slash	db '/',0
;slashdash db '-',0
total	db 'Total : ',0
;prod0	db 'Product  Totals',0
;buffer3	db '0000',0,0

buf0	db '                                                                                                                                                       ',0
buf1	db '                                                                                                                                                       ',0


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
        jmp     Exit                    ; Exit program  -  Attempt to open the input file
@@10:   xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler  -  Check whether the output file already exists
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



nop

nop
nop
nop
nop
nop
nop
nop
@@_41:
	mov	al, 32
	mov	di, offset buf1
	mov	cx, 140
	rep	stosb


	mov	di, offset buf1
	xor	si, si
@@_42:	call	readbyte
	mov	[di], al
	inc	di
	inc	si
	cmp	al, 0ah
	jne	@@_42
	mov	[di], al
	mov	al, 0
	inc	di
	mov	[di], al
						; di = buf1 end 	, si = length



;06:27:14.20 Pulse Trans 122313468 pin 2
;06:27:14.22 Prior to switch-Label for TransID= 122313468,PPN= 02714,Date= 15/01/07,Serial= 2006
;06:27:14.30 Print design '3' for TransID= 122313468,PPN= 02714,Date= 15/01/07,Serial= 2006 Copies 1 Field Len 124
;06:27:15.47 LABEL-PRINTED for TransID= 122313468,PPN= 02714,Date= 15/01/07,Serial= 2006.
;06:27:17.16 PRINT-REQUEST found in ControlState for PPN 01101 Serial 2008 TransID 122313469.


	mov	di, offset buf1 
	mov	al, [di]
	cmp	al, 'P'
	jne	@@_50
	mov	al, [di+1]
	cmp	al, 'T'
	jne	@@_50
	mov	al, [di+2]
	cmp	al, '6'
	jne	@@_50

	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte
	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte

	call	@@_Writeout2

@@_49:	jmp	@@_41




@@_50:	mov	di, offset buf1 +18		;09:40:15.88 Pulse Trans 114842706 pin 2
	mov	al, [di]			;11:57:57.04 Pulse Trans 122314356 pin 2
	cmp	al, 'T'
	jne	@@_51
	mov	al, [di+1]
	cmp	al, 'r'
	jne	@@_51
	mov	al, [di+2]
	cmp	al, 'a'
	jne	@@_51
	jmp	@@_41


@@_51:	mov	di, offset buf1 + 12		;09:40:15.90 Prior to switch-Label for TransID= 114842706,PPN= 01653,Date= 15/01/07,Serial= 55
	mov	al, [di]
	cmp	al, 'P'
	jne	@@_52
	mov	al, [di+1]
	cmp	al, 'r'
	jne	@@_52
	mov	al, [di+2]
	cmp	al, 'i'
	jne	@@_52
	mov	al, [di+3]
	cmp	al, 'o'
	jne	@@_52
	jmp	@@_41

@@_52:	mov	di, offset buf1 + 20		;                    Device: Dyol printer interface
	mov	al, [di]			
	cmp	al,  'D'
	jne	@@_53
	mov	al, [di+1]
	cmp	al,  'e'
	jne	@@_53
	mov	al, [di+2]
	cmp	al,  'v'
	jne	@@_53		; jmp	@@_41
	jmp	@@_41


@@_53:	mov	di, offset buf1 + 12		;19:59:04.56 Child pipe closed

	mov	al, [di]
	cmp	al, 'C'
	jne	@@_54
	mov	al, [di+1]
	cmp	al, 'h'
	jne	@@_54
	mov	al, [di+2]
	cmp	al, 'i'
	jne	@@_54
	mov	al, [di+3]
	cmp	al, 'l'
	jne	@@_54		; jmp	@@_41
	jmp	@@_41

@@_54:	mov	di, offset buf1 + 12		;14:55:26.37 Sending Design 17 - Extend timeout by 2.6 sec(s)
	mov	al, [di]			
	cmp	al,  'S'
	jne	@@_55
	mov	al, [di+1]
	cmp	al,  'e'
	jne	@@_55
	mov	al, [di+2]
	cmp	al,  'n'
	jne	@@_55		; jmp	@@_41
	jmp	@@_41



@@_55:	mov	di, offset buf1 + 12		;14:53:35.27 Session closing
	mov	al, [di]			;14:53:35.28 Session close: Clean up comms library
	cmp	al,  'S'
	jne	@@_56
	mov	al, [di+1]
	cmp	al,  'e'
	jne	@@_56
	mov	al, [di+2]
	cmp	al,  's'
	jne	@@_56		; jmp	@@_41
	jmp	@@_41


@@_56:	mov	di, offset buf1 + 12		;14:55:30.63 Auto download complete
	mov	al, [di]			
	cmp	al,  'A'
	jne	@@_57
	mov	al, [di+1]
	cmp	al,  'u'
	jne	@@_57
	mov	al, [di+2]
	cmp	al,  't'
	jne	@@_57		; jmp	@@_41
	jmp	@@_41




@@_57:	mov	di, offset buf1 + 12		;14:53:35.39 Stopping winDYOL server
	mov	al, [di]			
	cmp	al,  'S'
	jne	@@_58
	mov	al, [di+1]
	cmp	al,  't'
	jne	@@_58
	mov	al, [di+2]
	cmp	al,  'o'
	jne	@@_58		; jmp	@@_41
	jmp	@@_41



@@_58:	mov	di, offset buf1 + 12		;14:54:29.07 Output Activity to c:\DLCTMP\LABE1.Mon append
	mov	al, [di]			
	cmp	al,  'O'
	jne	@@_59
	mov	al, [di+1]
	cmp	al,  'u'
	jne	@@_59
	mov	al, [di+2]
	cmp	al,  't'
	jne	@@_59		; jmp	@@_41
	jmp	@@_41


@@_59:	mov	di, offset buf1 + 12		;14:54:29.28 Using sascom.dll version 4.2.0.5
	mov	al, [di]			
	cmp	al,  'U'
	jne	@@_60
	mov	al, [di+1]
	cmp	al,  's'
	jne	@@_60
	mov	al, [di+2]
	cmp	al,  'i'
	jne	@@_60		; jmp	@@_41
	jmp	@@_41



@@_60:	mov	di, offset buf1 + 18		;09:39:58.90 Print design '4' for TransID= 114842704,PPN= 01603,Date= 15/01/07,Serial= 54 Copies 1 Field Len 117
	mov	al, [di]
	cmp	al,  'd'
	jne	@@_61
	mov	al, [di+1]
	cmp	al,  'e'
	jne	@@_61
	mov	al, [di+2]
	cmp	al,  's'
	jne	@@_61		; jmp	@@_41
	jmp	@@_41

@@_61:	mov	di, offset buf1 + 12		;14:54:29.34 winDYOL server listening on port 1800
	mov	al, [di]
	cmp	al,  'w'
	jne	@@_62
	mov	al, [di+1]
	cmp	al,  'i'
	jne	@@_62
	mov	al, [di+2]
	cmp	al,  'n'
	jne	@@_62		; jmp	@@_41
	jmp	@@_41


@@_62:	mov	di, offset buf1 + 12		;14:54:29.52 Labeller software version is: 5.10 14Jul06
	mov	al, [di]			;14:54:29.56 Labeller UBI version is: UBI FingerPrint 8.70.1:PX4i-4.0
	cmp	al,  'L'
	jne	@@_63
	mov	al, [di+1]
	cmp	al,  'a'
	jne	@@_63
	mov	al, [di+2]
	cmp	al,  'b'
	jne	@@_63		; jmp	@@_41
	jmp	@@_41


@@_63:	mov	di, offset buf1 + 12		;14:54:29.78 Plugin: dv-dyol.p Version: 2.5
	mov	al, [di]			
	cmp	al,  'P'
	jne	@@_64
	mov	al, [di+1]
	cmp	al,  'l'
	jne	@@_64
	mov	al, [di+2]
	cmp	al,  'u'
	jne	@@_64		; jmp	@@_41
	jmp	@@_41



@@_64:	mov	di, offset buf1 + 12		;18:30:50.84 Timeout increased by 2 secs for TransID: 140295015
	mov	al, [di]			
	cmp	al,  'T'
	jne	@@_70
	mov	al, [di+1]
	cmp	al,  'i'
	jne	@@_70
	mov	al, [di+2]
	cmp	al,  'm'
	jne	@@_70		; jmp	@@_41
	jmp	@@_41





@@_70:	mov	di, offset buf1 + 12		;09:40:05.94 Label printing incomplete for TransID= 114842704,PPN= 01603,Date= 15/01/07,Serial= 54.
	mov	al, [di]
	cmp	al,    'L'
	jne	@@_80
	mov	al, [di+1]
	cmp	al,  'A'
	jne	@@_80
	mov	al, [di+2]
	cmp	al,  'B'
	jne	@@_80
	jmp	@@_41


@@_80:	mov	di, offset buf1 + 12		;09:40:15.81 PRINT-REQUEST found in ControlState for PPN 01653 Serial 55 TransID 114842706.
	mov	al, [di]
	cmp	al,    'P'
	jne	@@_90
	mov	al, [di+1]
	cmp	al,  'R'
	jne	@@_90
	mov	al, [di+2]
	cmp	al,  'I'
	jne	@@_90
	jmp	@@_41

@@_90:	mov	di, offset buf1 + 12		;09:31:02.68 Switch to design 45 for TransID= 170238264,PPN= 52402,Date= 13/01/07,Serial= 1001.
	mov	al, [di]
	cmp	al,  'S'
	jne	@@_95
	mov	al, [di+1]
	cmp	al,  'w'
	jne	@@_95
	mov	al, [di+2]
	cmp	al,  'i'
	jne	@@_95
	jmp	@@_41

@@_95:	mov	di, offset buf1 + 12		;12:27:25.64 Zero copies of label 1
	mov	al, [di]
	cmp	al,  'Z'
	jne	@@_96
	mov	al, [di+1]
	cmp	al,  'e'
	jne	@@_96
	mov	al, [di+2]
	cmp	al,  'r'
	jne	@@_96
	jmp	@@_41

@@_96:	mov	di, offset buf1 + 12		;12:30:33.67 purge 
	mov	al, [di]
	cmp	al,  'p'
	jne	@@_98
	mov	al, [di+1]
	cmp	al,  'u'
	jne	@@_98
	mov	al, [di+2]
	cmp	al,  'r'
	jne	@@_98
	jmp	@@_41


@@_98:
@@_Writeout2:
	mov 	di, offset buf1
@@_43:
@@_44:	mov	al, [di]
	call	writebyte
	inc	di	
	cmp	al, 0ah
	jne	@@_43


@@_150:	jmp	@@_41





Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program



Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

PROC 	readbyte
	push	di
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                   ; ax=0=end of file; jump
	mov     di, offset oneByte
	mov	al, [di]
	pop	di
	ret

@@802:

        mov     ah, 40h                 	; Write C/R
        mov     bx, [outFile]           	
        mov     cx, 2		      		
        mov     dx, offset crlf
        int     21h			
;        mov     ah, 40h                 	; Write C/R
;        mov     bx, [outFile]           	
;        mov     cx, 8
;        mov     dx, offset total
;        int     21h			
;        mov     dx, offset count5
;	call	writebyte2
;        mov     dx, offset count4
;	call	writebyte2
;        mov     dx, offset count3
;	call	writebyte2


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

PROC	writebyte2
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	push	ax
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
;        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h			; Call DOS to write to file
	pop	ax
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	ret
ENDP	writebyte2

PROC	writebuffer
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 16               ; Specify one byte to write
        mov     dx, offset buffer1	      		; Address variable with ds:dx
        int     21h			; Call DOS to write to file
	ret
ENDP	writebuffer

PROC	or30
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	ret
ENDP	or30


;---------------------------------------------------------------
; NumToASCII    Convert unsigned binary value to ASCII
;---------------------------------------------------------------
; Input:
;       ax = 16-bit value to convert
;       bx = base for result (2=binary;10=decimal;16=hex)
;       cx = minimum number of digits to output
;       di = address of string to hold result
;       Note: assumes string is large enough to hold result
;       Note: creates full result if cx is less than the number
;             of digits required to specify the result or cx = 0
;       Note: if cx=0 and ax=0 then length of string will be 0
;             set cx=1 if you want string to = '0' if ax=0
;       Note: assumes (2<=bx<=16)
; Output:
;       none
; Registers:
;       ax, cx
;---------------------------------------------------------------
PROC    NumToASCII              ; Normal entry point
        push    dx              ; Save some modified registers
        push    di
        push    si

; si = count of digits on stack

        xor     si, si          ; Set digit-count to zero
        jcxz    @@20            ; If cx=0, jump to set cx=1
@@10:
        xor     dx, dx          ; Extend ax to 32-bit dxax
        div     bx              ; ax<-axdx div bx; dx<-remainder
        call    HexDigit        ; Convert dl to ASCII digit
        push    dx              ; Save digit on stack
        inc     si              ; Count digits on stack
        loop    @@10            ; Loop on minimum digit count
@@20:
        inc     cx              ; Set cx = 1 in case not done
        or      ax, ax          ; Is ax = 0? (all digits done)
        jnz     @@10            ; If ax <> 0, continue conversion
        mov     cx, si          ; Set cx to stack char count
        jcxz    @@40            ; Skip next loop if cx=0000
        cld                     ; Auto-increment di for stosb
@@30:
        pop     ax              ; Pop next digit into al
        stosb                   ; Store digit in string; advance di
        loop    @@30            ; Loop for cx digits
@@40:
        mov     [byte di], ASCnull      ; Store null at end of string
        pop     si              ; Restore saved registers
        pop     di
        pop     dx

        ret                     ; Return to caller
ENDP    NumToASCII

PROC    HexDigit
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@10            ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        ret                     ; Return to caller
@@10:
        or      dl, '0'         ; Convert digits 0 to 9
        ret                     ; Return to caller
ENDP    HexDigit

END     start
