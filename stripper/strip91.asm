;Strip91
; formatting of addresseses for importing into mapinfo
; 22/12/11
;
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
notes   	DB      cr,lf,'Strip91 ', cr,lf
        	DB      cr,lf,'Strip91 <in> <out>'
        	DB      cr,lf,cr,lf,0
buffer1	db '                                                                                                                                                          ',0,0,0


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
@@42:	call	readbyte
	cmp	al, 0ah
	je	@@43
	mov	[di], al
	inc	di	
	jmp	@@42
@@43:	mov	al, 0ah			;force write 0ah in <CR>
	mov	[di], al
					; BUFFER1 now good to go.




;  parcel_num, ass_num, fmt_nm1, fmt_nm2, fmt_ad1, fmt_ad2, fmt_ad3, house_num, street_name, street_type, suburb_name, state_name, post_code, property_area, area_ind
;
;  Name             :   fmt_nm1 + fmt_nm2                 											::   3 + 4
;  Property Address :   house_num + " " + street_name + " " + street_type + " " + suburb_name + " " + state_name + " " + post_code      	::   8 + 9 + 10 + 11 + 12 + 13
;  Postal Address   :   fmt_ad1 + " " + fmt_ad2 + " " + fmt_ad3											::   5 + 6 + 7
;  valuation        :   															::   14

; 40,69342,,Mrs P Murray,Lot 35,13 Ellerslie Street,PREMER NSW 2381,35,Ellerslie,Street,PREMER,NSW,2381,1877331 
; 41,71950,,Land and Property Management Authority,PO Box 535,TAMWORTH NSW 2340,,15,Ellerslie,Street,PREMER,NSW,2381,3228696 
; 43,71669,,Betoota Holdings Pty Limited,C/- HR & RE Rankin,Betoota,PREMER NSW 2381,8642,Bundella,Road,PREMER,NSW,2381,3234941 
; 44,69582,,Betoota Holdings Pty Limited,C/- HR & RE Rankin,Betoota,PREMER NSW 2381,8642,Bundella,Road,PREMER,NSW,2381,2979106 
; 45,15,,Mr E Fornazaric & Miss O Slacek,8799 Bundella Road,PREMER NSW 2381,,8799,Bundella,Road,PREMER,NSW,2381,1877315 
; 46,71669,,Betoota Holdings Pty Limited,C/- HR & RE Rankin,Betoota,PREMER NSW 2381,8642,Bundella,Road,PREMER,NSW,2381,3234941 
; 63,18,,AMPS Agribusiness Pty Limited,Att: Nigel Herring,PO Box 3493,TAMWORTH NSW 2340,13,Tambar,Street,PREMER,NSW,2381,1877317 
; 64,18,,AMPS Agribusiness Pty Limited,Att: Nigel Herring,PO Box 3493,TAMWORTH NSW 2340,14,Premer,Street,PREMER,NSW,2381,1877317 
;                                                                      .....................^

@@401:	mov	di, offset buffer1	; write out parcel_num
@@410:	mov	al, [di]
	cmp	al, ','
	je	@@411
	call 	writebyte
	inc	di	
	jmp	@@410
@@411:	call	writebyte
;------------------------------------------------------------------------------------	
@@412:	inc	di			; write out ass_num
	mov	al, [di]
	cmp	al, ','
	je	@@413
	call 	writebyte
	jmp	@@412
@@413:	call	writebyte
;------------------------------------------------------------------------------------
@@414:	inc	di			; write out name 1 + name 2 
	mov	al, [di]
	cmp	al, ','
	je	@@415
	call 	writebyte
	jmp	@@414
@@415:	
@@416:	inc	di
	mov	al, [di]
	cmp	al, ','
	je	@@417
	call 	writebyte
	jmp	@@416
@@417:	call	writebyte		; write out last comma after name2.
;------------------------------------------------------------------------------------
@@418:	inc	di			; write out property address
	mov	al, [di]		; add1 , pos 5
	cmp	al, ','
	je	@@419
	call 	writebyte
	jmp	@@418
@@419:	
	mov	al, ' '
	call	writebyte
@@420:	inc	di			; add2 , pos 6
	mov	al, [di]
	cmp	al, ','
	je	@@421
	call 	writebyte
	jmp	@@420
@@421:	mov	al, ' '
	call	writebyte
@@422:	inc	di			; add 3 , pos 7
	mov	al, [di]
	cmp	al, ','
	je	@@423
	call 	writebyte
	jmp	@@422
@@423:	call	writebyte
;---------------------------------------------------------------------------
@@424:	inc	di			; write out postal address
	mov	al, [di]		; write out housenumber
	cmp	al, ','
	je	@@425
	call 	writebyte
	jmp	@@424
@@425: 	mov	al, ' '
	call	writebyte
@@426:	inc	di			;
	mov	al, [di]		; add1 , pos 8
	cmp	al, ','
	je	@@427
	call 	writebyte
	jmp	@@426
@@427: 	;mov	al, ' '
	;call	writebyte
@@428:	inc	di
	mov	al, [di]		; add2 , pos 9
	cmp	al, ','
	je	@@429
	call 	writebyte
	jmp	@@428
@@429:	;mov	al, ' '			
	;call	writebyte
@@430:	inc	di
	mov	al, [di]		; add3 , pos 10
	cmp	al, ','
	je	@@431
	call 	writebyte
	jmp	@@430
@@431: 	;mov	al, ' '
	;call	writebyte
@@432:	inc	di
	mov	al, [di]		; add4 , pos 11
	cmp	al, ','
	je	@@433
	call 	writebyte
	jmp	@@432
@@433: 	mov	al, ' '
	call	writebyte
@@434:	inc	di
	mov	al, [di]		; add5 , pos 12
	cmp	al, ','
	je	@@435
	call 	writebyte
	jmp	@@434
@@435: 	call	writebyte
;-------------------------------------------------------------------------------------
@@436:	inc	di
	mov	al, [di]		; add6 , pos 13
	cmp	al, 0ah 
	je	@@437
	call 	writebyte
	jmp	@@436
@@437:  call	writebyte
	

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
