; Stripper 92
; Finds '" ' in <in-file> and replaces it with '"' in <out-file>
; 22/12/11
;
        IDEAL
        MODEL   small
        STACK   256
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed

        DATASEG
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Stripper88  /djm,  22/12/11', cr,lf
        	DB      cr,lf,'Stripper88  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0



        CODESEG
        EXTRN StrLength:proc, StrUpper:proc
        EXTRN StrWrite:Proc, NewLine:Proc				;-----  From STRIO.OBJ
        EXTRN DiskErr:Proc						;-----  From DISKERR.OBJ
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc		;-----  From PARAMS.OBJ
Start:  				
        mov     ax, @data               
        mov     es, ax                  
        call    GetParams               
        call    ParamCount              
        cmp     dx, 2                   
        je      @@10                    
        mov     di, offset notes        
        call    StrWrite                
        jmp     Exit                    
@@10:   xor     cx, cx                  
        call    GetOneParam             
        mov     dx, di                  
        xor     al, al                  
        mov     ah, 3Dh                 
        int     21h                      
        jnc     @@20                    
        jmp     Errors                  
@@20:   mov     [inFile], ax            
@@30:   mov     cx, 1                   
        call    GetOneParam             
        mov     dx, di                  
        xor     cx, cx                  
        mov     ah, 3Ch                 
        int     21h                     
        jnc     @@40                    
        jmp     Errors                  
@@40:   mov     [outFile], ax           
;-----------------------------------------------------------------------------------------------------------------
@@_41:	call	readbyte		
	cmp	al, '"'			; not a "; write it out
	jne	@@501				
	call	readbyte		; read 2nd char
	cmp	al, ' '
	je	@@_50			; space found, remove it.
	push	ax
	mov	al, '"'
	call	writebyte
	pop	ax
	call	writebyte
	jmp	@@_41


@@_50:	mov	al, '"'
@@501:	call	writebyte
	jmp	@@_41
	
;-----------------------------------------------------------------------------------------------------------------
@@80:   mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit3                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit3:  mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program
Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program
Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

PROC 	readbyte
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                    ; ax=0=end of file; jump
	mov	di, offset onebyte
	mov	al, [di]
	ret
@@802:  mov     bx, [inFile]            ; Get input file handle
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

END     start
