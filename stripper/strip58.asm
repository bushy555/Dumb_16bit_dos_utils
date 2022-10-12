;
;
; Stripper 41
; djm, 29/3/7
;
; Upon finding <cr> will replace it with "<BR>" with <cr>
; Rest of text that is outside of this is skipped.
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
ccr		db	'<BR>',cr,lf,0

notes   	DB      cr,lf,'0ah Stripper 58. djm, 27/9/7. v3'
        	DB      cr,lf,' '
        	DB      cr,lf,'strip58 <input file> <output file>',cr,lf, 0
dot		db	'.',0
option1		db	0
_out	db	32h,0,38h,0,31h,0,1dh,0,35h,0,1dh,0,33h,0,30h,0,1dh,0,46,0,31h,0,20h,0,4ch,0,2dh,0,52h,0,4fh,0,59h,0,31h,0,4ch,0,20h,0,52h,0,4dh,0,34h,0,36h,0,0dh,0,0ah,0,0
_hello	db	'fred______',0
_buffer	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
line	db	'1',0,'3',0,'000281',0,'5',0,'30',0,'F1 L-ROYAL RM46',0dh,0ah,0
_buffer2 db 	'F1 L-ROYAL RM46',0dh,0ah,0
_buffer3 db 	'F2 ROCKDALE RM46',0dh,0ah,0
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
@@30:   mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:   mov     [outFile], ax           ; Save output file handle


@@50:	xor	bp, bp
	mov	di, offset _buffer
@@51:	call	readbyte
	inc	bp
	cmp	al, 0ah
	je	@@52
	stosb
	jmp	@@51
@@52:	stosb	


	mov	si, offset _buffer
@@53:	lodsb
	cmp	al, 0ah
	je	@@writeout
	cmp	al, '4'
	je	@@531
	cmp	al, '2'
	jne	@@53
	lodsb
	cmp	al, '8'
	jne	@@53
	lodsb
	cmp	al, '1'
	je	@@54
	cmp	al, '0'
	je	@@54
	jmp	@@53
@@531:	lodsb
	cmp	al, '9'
	je	@@532
	cmp	al, '8'
	jne	@@53
	lodsb
	cmp	al, '9'
	je	@@56
@@532:	lodsb
	cmp	al, '0'
	je	@@57
	jmp	@@53




@@writeout:
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, bp                 ; Specify one byte to write
        mov     dx, offset _buffer
        int     21h                     ; Call DOS to write to file
	jmp	@@50




@@54:					; 281 F1 L-ROYAL RM46   <and>    280 F1 L-ROYAL RM46
	call	@@writebit
        mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 17                  
        mov     dx, offset _buffer2
        int     21h                
	jmp	@@50



@@56:					; 489 F2 ROCKDALE RM46
	call	@@Writebit
        mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 18                  
        mov     dx, offset _buffer3
        int     21h                
	jmp	@@50



@@57:					; 490 F2 ROCKDALE RM46
	call	@@Writebit
        mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 18                  
        mov     dx, offset _buffer3
        int     21h                
	jmp	@@50


@@Writebit:
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 10                 
        mov     dx, offset _buffer
        int     21h               
	mov	al, 1dh
	call	writebyte
	mov	al, '4'
	call	writebyte
	mov	al, 1dh
	call	writebyte
	mov	al, '3'
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, 1dh
	call	writebyte
	ret
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

PROC 	readbyte
	push	bx
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
	pop	bx
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

END     Start        ; End of program / entry point
