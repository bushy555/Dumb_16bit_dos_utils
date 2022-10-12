;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; vz dumper. djm. v3. 3/mar/2k9.
; dumps vz .DSK to an output text file. 
; Quick and dirty!
;
; VZDSKDUMP <in.dsk> <out.txt>
; VZDSKDUMP GAMES.DSK GAMES_DISK3.TXT
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INFO:
; VZ directory occupies Track 0, Sector 0 through to the end of sector 14.
; Sector 0, Track 15 contains pointers to something. forget.
; ....meaning that the directory size is 1920 bytes, and can contain a 
; maximum of 112 filenames per side of a disk.
;
;
;  File type 1 byte
;  Delimitor (3AH) 1 byte
;  File name 8 byte
;  Start track 1 byte
;  Start sector 1 byte
;  Start address 2 byte
;  End address 2 byte
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Platform :  80x86
; File size:  2630 bytes.
; Compile  :  (Use Borland Turbo Assembler v4 or v5. "TASM4" or "TASM5"
; Libraries:  Tom Swan Assembler libraries.
;
;	TASM VZDSKDUMP
;	LINK VZDSKDUMP,,,_MTA
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Don't bother reading the below source code. It has been size optimised, 
; slabs of code are missing and sections just wont make any sense.
;
; Esentially every byte within the first 0 to 14 tracks are read from sector 0,
; and the file index line that contains a colon is written into a buffer.
; track, sector, begin and end memory addresses are also written to the buffer.
; The entire buffer is then written to the output file.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        	IDEAL
        	MODEL   small
        	STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
ASCnull         EQU     0               ; ASCII null character

        DATASEG
_crlf		db	13,10
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         Db      0,0,0,0,0,0,0,0       ; Byte I/O variable
s_track		db	0
e_track		db	0
s_address	db	0,0
e_address	db	0,0

buffer		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
tempbyte	db	0
exCode          DB      0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
notes   	DB      cr,lf,'VZ disk dumper. v3.0. By dave. Junkware. 4/mar/9.'
      	  	DB      cr,lf,'Dumps the directory of a VZ .DSK file to a text file.'
        	DB      cr,lf,'VZDSKDUMP <in.dsk> <out.txt>',cr,lf
	        DB      cr,lf,'ie:  VZDSKDUMP GAMES.DSK GAMES.TXT',cr,lf,0



        CODESEG
	        EXTRN StrWrite:Proc						;-----  From STRIO.OBJ
        	EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
	        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ
	        PUBLIC  BinToAscHex


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
        xor     al, al          ; Specify read-only access
        mov     ah, 3Dh         ; DOS Open-file function
        int     21h             ; Call DOS to open the file
        jc      @@21            ; Exit--file doesn't exist
        mov     bx, ax          ; Copy handle to bx
        mov     ah, 3Eh         ; DOS Close-file function
        int     21h             ; Close the file
        clc                     ; Clear carry flag (file exists)
@@21:   jc      @@30                    ; Jump if file does not exist
@@22:   call    StrWrite                ; Display file name
        mov     di, offset Prompt       ; Address prompt string
        call    StrWrite                ; Display message
        mov     ah, 1                   ; DOS GetChar function
        int     21h                     ; Get user response
        cmp     al, 'Y'                 ; Compare with Y
        je      @@29                    ; Exit if char = Y
        cmp     al, 'y'                 ; Compare with y
        je      @@29                    ; Exit if char = y
        cmp     al, 'N'                 ; Compare with N
        je      @@28                    ; Handle No response
        cmp     al, 'n'                 ; Compare with n
        jne     @@22                 ; Repeat if not Y, y, N, n
@@28:   cmp     al, '@'                 ; Reset zero flag (zf=0)
@@29:   je      @@30                    ; Continue if permission given
        jmp     Exit                    ; Else exit program
@@30:   mov     cx, 1                   
        call    GetOneParam             
        mov     dx, di                  
        xor     cx, cx                  
        mov     ah, 3Ch                 
        int     21h                     
        jnc     @@40                    
        jmp     Errors                  
@@40:   mov     [outFile], ax           
	xor	bp, bp
;-------------------------------------
@@50:   inc	bp
	cmp	bp, 1920		; done reading first 1920 bytes (size of directory of VZ disk)
	jl	@@51
	jmp	@@80			; so now go bye bye and exit.			
@@51:	mov	cx, 1
	call	readbyte
@@60:   inc	bp
	cmp	bp, 1920		; done reading first 1920 bytes (size of directory of VZ disk)
	jl	@@601
	jmp	@@80			; so now go bye bye and exit.			
@@601:	mov     di, offset oneByte	; READ char. 
	mov	al, [di]
	mov	di, offset tempbyte
	mov	[di], al
@@71:  	call	readbyte
@@72:	cmp	al, 03ah		; Is it ':'?
	je	@@73
	jmp	@@60
@@73:	mov	di, offset tempbyte
	mov	al, [di]
	cmp	al, 01h			; Is filetype a deleted entry 0x01h?
	jne	@@730
	mov	al, '?'			; THEN write filetype of new deleted filetype, '?'
	mov	di, offset buffer
	stosb
	jmp	@@731
@@730:	mov     si, offset tempbyte    ; ELSE write filetype char
        mov     di, offset buffer
	rep	movsb 			
@@731:	mov     cl, 1  			; Write out ':'
	mov	si, offset onebyte
	rep	movsb
@@74:   add	bp, 13
	mov	cl, 14			; read 8 char filename, 1x S-track, 1x E-Track, 2x S-add, 2x E-add.
	call	readbyte
@@75:   mov     cl, 8                   ; write 8 char filename
	mov	si, offset onebyte      
	mov	di, offset buffer +2
	rep	movsb
@@76:	mov     cl, 4			; write 4 spaces
	mov	al, 020h			; di = buffer + 10
	rep	stosb
@@77:	mov	al, [si]			; si = s_track
	mov	cl, 2				; di = buffer + 14
	call	BinToAscHex
	mov	al, 020h
	inc	di
	inc	di				; di = buffer + 16
	stosb
	mov	si, offset e_track		; di = buffer + 17
	mov	al, [si]
	mov	cl, 2
	call	BinToAscHex
	mov	al, 020h		; write 1 space
	inc	di		
	inc	di				; di = buffer + 19
	stosb
	mov	si, offset s_address+1
	call	@@_1
	mov	al, 020h	    		; write a spaces
	inc	di
	inc	di				; di = buffer + 24
	stosb
	mov	si, offset e_address+1
	call	@@_1
	mov	si, offset _crlf
	inc	di
	inc	di				; di = buffer + 29
	mov	cl, 2
	rep	movsb
        mov     cl, 31			; DOS write out buffer to disk
        mov     dx, offset buffer
        mov     ah, 40h          
        mov     bx, [outFile]    
        int     21h		
        jnc     @@79
        jmp     Errors                 
@@79:	jmp	@@50



@@_1:	mov	al, [si]
	mov	cl, 2				; di = buffer+20
	call	BinToAscHex
	dec	si
	mov	al, [si]
	mov	cl, 2
	inc	di
	inc	di				; di = buffer +22
	call	BinToAscHex
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
Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program



PROC 	readbyte
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            
        mov     dx, offset oneByte      
        int     21h                    
        jnc     @@rb2
        jmp     Errors                 
@@rb2:	mov     di, offset oneByte
	mov	al, [di]
	ret
ENDP	readbyte



PROC    BinToAscHex
        push    bx              ; Save bx on stack
        mov     bx, 16          ; Set base = 16 (hex)
        push    dx              ; Save some modified registers
        push    di
        push    si
        xor     si, si          ; Set digit-count to zero
        jcxz    @@20            ; If cx=0, jump to set cx=1
@@10:   xor     dx, dx          ; Extend ax to 32-bit dxax
        div     bx              ; ax<-axdx div bx; dx<-remainder
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@15            ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
	jmp	@@17
@@15:   or      dl, '0'         ; Convert digits 0 to 9
@@17:   push    dx              ; Save digit on stack
        inc     si              ; Count digits on stack
        loop    @@10            ; Loop on minimum digit count
@@20:   inc     cx              ; Set cx = 1 in case not done
        or      ax, ax          ; Is ax = 0? (all digits done)
        jnz     @@10            ; If ax <> 0, continue conversion
        mov     cx, si          ; Set cx to stack char count
        jcxz    @@40            ; Skip next loop if cx=0000
        cld                     ; Auto-increment di for stosb
@@30:   pop     ax              ; Pop next digit into al
        stosb                   ; Store digit in string; advance di
        loop    @@30            ; Loop for cx digits
@@40:   mov     [byte di], ASCnull      ; Store null at end of string
        pop     si              ; Restore saved registers
        pop     di
        pop     dx
        pop     bx              ; Restore bx
        ret                     ; Return to caller
ENDP    BinToAscHex

        END     Start        ; End of program / entry point
