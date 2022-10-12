;Strip89
; removes first and second occurences of single inverted comma (") on each line.
; 22/12/11
;
;
    	  IDEAL
    	  MODEL   small
      	  STACK   256
P386
cr      	EQU     13              ; ASCII carriage return
lf      	EQU     10              ; ASCII line feed
ASCnull		equ	0
        DATASEG
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
crlf		db	cr,lf,0
notes   	DB      cr,lf,'Strip89 ', cr,lf
        	DB      cr,lf,'.'
        	DB      cr,lf,'Strip89 <in> <out>'
        	DB      cr,lf,cr,lf,0
sum2		db	0,0,0
sum3		db	0,0,0
sum4		db	0,0,0,0,0
sum5		dd	0,0,0,0,0,0,0
dollars		dw	0,0,0
cents		dw	0,0,0
total		dd	0,0,0
total2		dw	0,0,0,0,0,0,0,0,0
counter1	db	0,0
counter2	db	0,0,0,0,0
buffer1	db '                                                                                                                               ',0,0,0


        CODESEG
        EXTRN StrLength:proc, StrUpper:proc
        EXTRN StrWrite:Proc, NewLine:Proc
        EXTRN DiskErr:Proc, GetParams:Proc
        EXTRN  ParamCount:Proc, GetOneParam:Proc
Start:  mov     ax, @data               
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

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop




@@41:	mov	di, offset buffer1
@@410:	call	readbyte
	cmp	al, 0ah
	je	@@411
	mov	[di], al
	inc	di	
	jmp	@@410
@@411:	mov	al, 0ah			;force write 0ah in <CR>
	mov	[di], al
					; BUFFER1 now good to go.


	mov	di, offset buffer1	
@@412:	inc	di			;start of buffer1 will always be ", so skip it, saving one loop.
	mov	al, [di]
	cmp	al, '"'
	je	@@413
	call	writebyte
	jmp	@@412
@@413:	inc	di			; first time: ignore current (2nd) "
	mov	al, [di]		; and write out rest of buffer to disk
	cmp	al, 0ah
	je	@@414
	call	writebyte
	jmp	@@413
@@414:	mov	al, 0ah
	call	writebyte


	jmp	@@41






Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

PROC 	readbyte
	push	cx
	push	di
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     	@@802                    ; ax=0=end of file; jump
	mov	di, offset onebyte
	mov	al, [di]
	pop	di
	pop	cx
	ret
@@802:  pop	cx
	mov     bx, [inFile]            ; Get input file handle
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
