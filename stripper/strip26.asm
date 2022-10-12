;
;
; Stripper22 --- Xray barcode Stripper
; djm, 8/8/6
; Extracts product and carton number from barcode
; Frominput file of raw barcodes, ie:
;0199327574010032130608033102001800210014
;0199327574010032130608033102001800210014
;0199327574010032130608033102001800210014
;
;will output:
; product , Carton Number , Prod date , Full barcode , 0dh,0ah,0
;01005,0001,150806,019932757401005613060815310200158021000
;01005,0002,150806,019932757401005613060815310200162021000
;01005,0003,150806,019932757401005613060815310200159021000
;01005,0004,150806,019932757401005613060815310200158021000
;01005,0005,150806,019932757401005613060815310200161021000
;01005,0006,150806,019932757401005613060815310200188021000
;01005,0007,150806,019932757401005613060815310200166021000
;01005,0008,150806,019932757401005613060815310200193021000
;01005,0009,150806,019932757401005613060815310200157021000
;01005,0010,150806,019932757401005613060815310200148021001
;01005,0011,150806,019932757401005613060815310200176021001
;01005,0012,150806,019932757401005613060815310200157021001
;01005,0013,150806,019932757401005613060815310200174021001

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

notes   	DB      cr,lf,'Stripper 22 v2. djm, 16/8/6.'
	        DB      cr,lf,'.'
	        DB      cr,lf,'strip22 <input file> <output file>',cr,lf, 0
barcode		db	'0199327574010032130608033102001800210014'
label1		db	'Product,Carton Number,Prod date,Full barcode',0dh,0ah,0

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
;	mov	di, offset label1
;	mov	cx, 46
;@@41:	mov	al, [di]
;	call	writebyte
;	inc	di
;	loop	@@41
;	mov	al, 0dh



@@50:   call	readbyte
	cmp	al, '0'			; (number 0)
	je	@@62

@@61:	call	readbyte		
	cmp	al, 0ah
	jne	@@61
	jmp	@@50

;O0199327574010032130608033102001800210014
;0199327574010032130608033102001800210014
;O0199327574015129130608033102001700210001
;060803_0638
;O0199327574011534130608033102002000210019
;160803_0638
;


@@62:	call	readbyte
	cmp	al, '1'			; (number 0)
	je	@@63

@@621:	call	readbyte		
	cmp	al, 0ah
	jne	@@621
	jmp	@@50


@@63:	call	readbyte
	cmp	al, '9'			; (number 0)
	je	@@65

;019327574010032130608033102001800210014

@@631:	call	readbyte		
	cmp	al, 0ah
	jne	@@631
	jmp	@@50


@@65:	
	mov	di, offset barcode
	mov	al, '0'
	mov	[di], al
	inc	di
	mov	al, '1'
	mov	[di], al
	inc	di
	mov	al, '9'
	mov	[di], al
	inc	di

@@66:	push	di			; Store barcode at buffer barcode
	call	readbyte
	cmp	al, 0ah
	je	@@67
	pop	di
	mov	[di], al
	inc	di
	jmp	@@66

@@67:	pop	di

	mov	di, offset barcode + 10		; write five bytes of product
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte

	mov	al, ','
	call	writebyte

	mov	di, offset barcode + 36		; write four bytes of carton number
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte

	mov	al, ','
	call	writebyte

	mov	di, offset barcode + 22	; write six bytes of date
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte

	mov	di, offset barcode + 20	; write six bytes of date
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte

	mov	di, offset barcode + 18	; write six bytes of date
	mov	al, [di]
	call	writebyte
	inc	di
	mov	al, [di]
	call	writebyte


	mov	al, ','
	call	writebyte

	mov	di, offset barcode  	; write entire barcode
	mov	cx, 40
@@68:	mov	al, [di]
	call	writebyte
	inc	di
	loop	@@68

;01234567890123456789012345678901234567890
;0199327574010032130608033102001800210014

;0123456789 01234 567 890123 456789012345 6789
;0199327574 01003 213 060803 310200180021 0014
	
;Product  Carton Number , Prod date, Full barcode
;01005   0001
;01005   0002
;01005   0003
;01005   0004
;01005   0005

	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte
	

	jmp	@@50





;---------------------------------------------------------------------------
Writebyte:
	push	cx
	push	di
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
        jz      @@81                    ; ax=0=end of file; jump
	pop	di
	pop	cx
        ret
@@81: jmp	a80	


        mov     di, offset diskFull     ; Address disk-full message
        call    StrWrite                ; Display message
									;-----  Close the input and output files, which is not strictly
									;       required as ending the program via function 04Ch also closes
									;       all open files.  Note: errors are handled only when closing
									;       the output file because no changes are made to the input.
a80:   mov     bx, [inFile]            ; Get input file handle
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
