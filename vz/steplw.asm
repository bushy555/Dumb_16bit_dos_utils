; STEPLW   -  256x192 version.    8 pixels per byte.
;
; Dump hex values.	/dave.
;
; Dumps to hex format:       
;
;  asm for C:   .byte $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
;  asm      :   defb  0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
;  c        :         0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA
;  standard :         0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA,
;  standard :         AA,AA,AA,AA,AA,AA,AA,AA,AA,AA,AA,AA,AA,AA,AA,AA,
;  bpoke    :   bpoke(i, 23);bpoke(i+1, 23) etc.
;  asm      :   defb  $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
;  asm      :   db    $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
;  PASSTHRU (file to DEFB)
;  PASSTHRU (file to DB)
;
; 08/10/2002
; 23/08/2013 - STEPKG. Added Asm version with "defb" for C #asm.
; 00/00/2017?- STEPI.
; 05/12/2019 - STEPJ. added Asm version with "defb" for z80 asm.
; 05/12/2019 - STEPJ. added Asm version with "db"   for z80 asm.
; 27/12/2019 - STEPK. added Asm 'PASSTHRU' : FILE2DB. 
; 27/12/2019 - STEPK. added Asm 'PASSTHRU' : FILE2DEFB.
; 21/12/2020 - STEPLW. Version for 256x192 screens.  8 pixels per byte.  1 pixel per bit.
;
;
;	Do initial writeout DB /DEFB
;   A:      DO HEX CONVERSION
; 	    DO WRITEOUT CHAR
; 	    DO WIDTH
; 	    DO NEXT LINE, DB/ DEFB
; 	    LOOP A:



        IDEAL
        MODEL   small
        STACK   256
cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed
ASCnull EQU     0               ; ASCII null character

        DATASEG
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
outb		db	0	
outputtype	db	0	
name1		db	'$0'		 	; $0
name2		db	02ch		 	; ,
name3		db	029h, 03bh		; );
name4		db	00dh, 00ah		; <cr>
name5		db	'0x'		 	; 0x
name6		db	'.byte '	 	; .byte
name7		db	'0'		 	; 0
name8		db	'defb '			; defb
name9		db	'bpoke(i+0x'		; bpoke(i+0x'
name0		db	'db '			; db
namea		db 	' ; ---------------------------------------------------------' ,0
AOAH		db	0ah
AODH		db 	0dh
counter		db 	0
counter2	db	0
counter3	db	0
counter5	db	0
counter4	db	0
fullbyte	db	0,0,0
prompt          DB      cr,lf,'This file already exists. Erase old file? (y/n)  n=quit.', 0
prompt2		db	cr,lf
		db	cr,lf
		db	cr,lf, '   *********************************************'
		db	cr,lf, '   *   STEP LW  ---  256x192 version           *'
		db	cr,lf, '   ************************************21/12/20*'
		db	cr,lf
		db	cr,lf, '             VZ Colour palette conversion thingy.'
		db	cr,lf,'Converts VZ colour raw image (Paintshop Pro .RAW) to Hex''d include file'
		db	cr,lf
	    	db	cr,lf,' 1) assembly include format:    .byte $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA'
		db	cr,lf,' 2) assembly include format:    defb  0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA'
		db	cr,lf,' 3) c include format:                 0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA'
		db	cr,lf,' 4) standard hex include format:      0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA'
		db	cr,lf,' 5) standard hex include format:      AA,AA,AA,AA,AA,AA,AA,AA'
		db	cr,lf,' 6) bpoke        include format:      bpoke(i, 23);bpoke(i+1,23);bpoke(i+2,23)'
	    	db	cr,lf,' 7) assembly include format:    defb  $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA'
	    	db	cr,lf,' 8) assembly include format:    db    $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA'
		db	cr,lf,' 9) PASSTHRU (file2DB)'
		db	cr,lf,' 0) PASSTHRU (file2DEFB)'
		db	cr,lf
		DB      cr,lf,'Hey dude! : Which format yo: (1),(2),(3),(4),(5),(6),(7),(8),(9) or (0) ? ',0
diskFull        DB      cr,lf,'**ERROR: Disk is full dude; fix it.', 0
notes   	db	cr,lf
		db	cr,lf
		db	cr,lf, ' *********************************    ****************************************'
		db	cr,lf, ' *   STEP LW -- 256x192          *    *  VZ Colour palette conversion thingy *'
		db	cr,lf, ' ************************21/12/20*    ****************************************'
		db	cr,lf
		db	cr,lf,'Converts VZ colour raw image (Paintshop Pro) .RAW to Hex''d include file'
		db	cr,lf,'Choose your output format : '
		db	cr,lf,' 1) assembly     format:  .byte $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA'
		db	cr,lf,' 2) assembly (C) format:  defb  0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA'
		db	cr,lf,' 3) c include    format:        0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA'
		db	cr,lf,' 4) standard hex format:        0AA,0AA,0AA,0AA,0AA,0AA,0AA,0AA'
		db	cr,lf,' 5) standard hex format:        AA,AA,AA,AA,AA,AA,AA,AA'
		db	cr,lf,' 6) bpoke        format:        bpoke(i, 23);bpoke(i+1,23);bpoke(i+2,23)'
	    	db	cr,lf,' 7) assembly     format:  defb  $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA'
	    	db	cr,lf,' 8) assembly     format:  db    $0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA'
		db	cr,lf,' 9) PASSTHRU     (file2DB)'
		db	cr,lf,' 0) PASSTHRU     (file2DEFB)'
        	DB      cr,lf
        	DB      cr,lf, 'Do these steps prior:'
        	DB      cr,lf, '1.Find and load in the correct VZ four-colour palette for Paint Shop Pro.'
        	DB      cr,lf, '2.Manipulate the graphic, resize etc, copy graphic and paste as a layer into'
        	DB      cr,lf, '  the VZ 4-colour template graphic. Should then end up with only 4 colours.'
        	DB      cr,lf, '3.THEN save new image as a Paint Shop Pro .RAW image.'
        	DB      cr,lf, '4.Then it is a one step conversion process, to dump out to a .INC file.' 
		DB 	cr,lf
		db	cr,lf, 'PRESS <ANY> key to contine.'
		db 	0
notes2   	DB      cr,lf, 'Effectively this program changes each four-pixel-colour-per-byte in a RAW file'
                DB	cr,lf, 'from / to the following :00=green to 00=green, 01=yellow to 85=yellow,'
		DB	cr,lf, ' 02=blue to 170=blue and 04=red to 255=red.'
		db	cr,lf, ' Remembering  in BINARY:  00=GREEN, 01=YELLOW, 10=BLUE, 11=RED.'
		db	cr,lf, ' 01101001 = (1 byte) is 4 pixels being : yellow,blue,blue,yellow.'
		db	cr,lf, ' So, a mode(1) grafic: 128 pixels wide = 256 nibbles wide = 32 bytes wide.'
		DB 	cr,lf, 'So a RAW file of :'
		DB 	cr,lf, 'EX1:RRRR = RAW-colour: 3333 = BINARY: 11 11 11 11 (1 byte) = HEX: $FF'
		DB 	cr,lf, 'EX2:GYBR = RAW-colour: 0123 = BINARY: 00 01 10 11 (1 byte) = HEX: $1B'
		DB 	cr,lf, 'EX3:GYBRGYBRGYBRYYYY=00011011 00011011 00011011 00011011=$1B $1B $1B $55'
		DB 	cr,lf, '    GGGGYYYYBBBBRRRRGGYYRRBB           (24x pixels wide)'
		db	cr,lf, '    000011112222333300113322           (24x RAW colours)'
		db	cr,lf, '    00000000 01010101 10101010 11111111 00000101 11111010  (BIN)'
		DB 	cr,lf, '    $00 $55 $AA $FF $05 $FA            (HEX: 24 pixels = 6 bytes)'
		db	cr,lf
		db	cr,lf, ' RRRRRRRR       '
		db	cr,lf, ' RRGGRGGR     	'
		db	cr,lf, ' RRGGRGGR	'
		db	cr,lf, ' RRRRRRRR     -->    DEFB  $FF,$FF,$F0,$C3,$F0,$C3,$FF,$FF'
		DB 	cr,lf
		
        	DB      cr,lf,'STEPK <input-file> <output-file>'
        	DB      cr,lf,'   EG: STEPK fred.RAW fred.INC           (Menu selection will then appear)'
		db	cr,lf, 0

        CODESEG
        EXTRN StrWrite:Proc, NewLine:Proc
        EXTRN DiskErr:Proc
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc
Start:  mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 2                   ; Does count = 2?
        je      @@_05                    ; Continue if param count = 2
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
	xor	ah, ah
	mov	ax, ax			; press any key to continue.
	int	16h	
        mov     di, offset notes2       ; Address text with di
        call    StrWrite                ; Display notes

        jmp     Exit                    ; Exit program


								;----------- Get user input for which format of output
@@_05:  mov     di, offset Prompt2      ; Address prompt string
        call    StrWrite                ; Display message
        mov     ah, 1
        int     21h
        cmp     al, '1'
        jne     @@_050
	mov 	[outputtype], 1
	jmp	@@_10
@@_050: cmp     al, '2'
        jne     @@_052 
	mov 	[outputtype], 2
	jmp	@@_10
@@_051: cmp     al, '3'
        jne     @@_052 
	mov 	[outputtype], 3
	jmp	@@_10
@@_052: cmp     al, '4'
        jne     @@_053
	mov 	[outputtype], 4
	jmp	@@_10
@@_053:	cmp     al, '5'
        jne     @@_054
	mov 	[outputtype], 5
	jmp	@@_10
@@_054:	cmp     al, '6'
        jne     @@_055
	mov 	[outputtype], 6
	jmp	@@_10
@@_055:	cmp     al, '7'
        jne     @@_056
	mov 	[outputtype], 7
	jmp	@@_10
@@_056:	cmp     al, '8'
        jne     @@_057
	mov 	[outputtype], 8
	jmp	@@_10
@@_057:	cmp     al, '9'
        jne     @@_058
	mov 	[outputtype], 9
	jmp	@@_10
@@_058:	cmp     al, '0'
        jne     @@_059
	mov 	[outputtype], 0
	jmp	@@_10
@@_059:	jmp	@@_05



@@_10:
	mov	dx, offset name4	; Display <cr>
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 2
	int	21h
	mov	dx, offset name4	; Display <cr>
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 2
	int	21h
								;-----  Attempt to open the input file
        xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler


@@20:								;-----  Check whether the output file already exists
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


@@30:								;-----  Attempt to create the output file
	mov	dx, offset name4	; Display <cr>
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 2
	int	21h

        mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:
	mov	[fullbyte], 0
        mov     [outFile],  ax           
	mov	[counter],  0
	mov	[counter2], 0
	mov	[counter3], 0
	mov	[counter4], 0
	mov	[counter5], 0


	cmp	[outputtype], 1		; asm include file format				; ####################################
	jne	@@_402										; #####################################
@@_401:	mov	dx, offset name6	; Display '.byte '					; 
	mov	ah, 40h										; DO INITIAL "DEFB" or "DB" LINE
	mov	bx, [outfile]
	mov	cx, 6
	int	21h

@@_402:	cmp	[outputtype], 2		; asm include file format
	jne	@@_403
@@_402a:mov	dx, offset name8	; Display 'defb '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 5
	int	21h

@@_403: cmp	[outputtype], 7		; asm include file format
	jne	@@_404
@@_403a:mov	dx, offset name8	; Display 'defb '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 5
	int	21h

@@_404: cmp	[outputtype], 8		; asm include file format
	jne	@@_405
@@_404a:mov	dx, offset name0	; Display 'db '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 3
	int	21h


@@_405: cmp	[outputtype], 9		; asm include file format
	jne	@@_406
	mov	dx, offset name0	; Display 'db '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 3
	int	21h

@@_406: cmp	[outputtype], 0		; asm include file format
	jne	@@_407
	mov	dx, offset name8	; Display 'defb '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 5
	int	21h

@@_407:



loopdeloop:
@@50:								; start of loop de loop


@@_52:	inc	[counter]
	mov	dl, [oneByte]
	mov	[outb], 00000000b
;---------------------------------------------------------------- read dx. dl = bit 1
@@_bit1:mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
        jnc     @@60                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@60:   or      ax, ax                  ; Check for end of input file
	jnz	@@61
        jmp     ending1	;@@80                    ; ax=0=end of file; jump
;	jmp	@@80                    ; ax=0=end of file; jump
@@61:	

	cmp	[outputtype], 9		; asm include file format
	je	pass_1
	cmp	[outputtype], 0		; asm include file format
	jne	here3;@@_61a
	
pass_1:	mov	al, [onebyte]		; PASSTHRU STUFF for 9 and 0. JMP OVER THE BELOW HEX conversion stuff.
	mov	[outb], al
;	jmp	@@_a00
	jmp	writeoutroutine


here3:	mov	dl, [oneByte]								; #################################
;@@_61a:	mov	dl, [oneByte]							; #################################
	cmp 	dl, 1									; #################################
	jne	@@_b1									; 
	or	[outb], 10000000b							; DO HEX CONVERSION ROUTINE.  BEGIN  LOOP.

@@_b1:	mov     ah, 3Fh                	; Second 
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@62a                    
        jmp     Errors                  
@@62a:  or      ax, ax                  
	jnz	@@63a
	jmp	ending1
@@63a:	mov	dl, [oneByte]
	cmp 	dl, 1
	jne	@@_b3					
	or	[outb], 01000000b			

@@_b3:	mov     ah, 3Fh                 ; THIRD
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@62b
        jmp     Errors                  
@@62b:  or      ax, ax                  
	jnz	@@63b
	jmp	ending1
@@63b:	mov	dl, [oneByte]
	cmp 	dl, 1
	jne	@@_b4
	or	[outb], 00100000b			

@@_b4:	mov     ah, 3Fh                 ; FOURTH
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@62c
        jmp     Errors                  
@@62c:  or      ax, ax                  
	jnz	@@63c
	jmp	ending1
@@63c:	mov	dl, [oneByte]
	cmp 	dl, 1
	jne	@@_b5
	or	[outb], 00010000b			

@@_b5:	mov     ah, 3Fh                 ; FIFTH
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@62d
        jmp     Errors                  
@@62d:  or      ax, ax                  
	jnz	@@63d
	jmp	ending1
@@63d:	mov	dl, [oneByte]
	cmp 	dl, 1
	jne	@@_b6
	or	[outb], 00001000b			

@@_b6:	mov     ah, 3Fh                 ; SIXTH
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@62e
        jmp     Errors                  
@@62e:  or      ax, ax                  
	jnz	@@63e
	jmp	ending1
@@63e:	mov	dl, [oneByte]
	cmp 	dl, 1
	jne	@@_b7
	or	[outb], 00000100b			

@@_b7:	mov     ah, 3Fh                 ; SEVENTH
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@62f
        jmp     Errors                  
@@62f:  or      ax, ax                  
	jnz	@@63f
	jmp	ending1
@@63f:	mov	dl, [oneByte]
	cmp 	dl, 1
	jne	@@_b8
	or	[outb], 00000010b			

@@_b8:	mov     ah, 3Fh                 ; EIGHTH
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@62g
        jmp     Errors                  
@@62g:  or      ax, ax                  
	jnz	@@63g
	jmp	ending1
@@63g:	mov	dl, [oneByte]
	cmp 	dl, 1
	jne	@@_b9
	or	[outb], 00000001b			
@@_b9:	





@@_bit5:		;-------------------------------------------------------------


;	cmp	[outb], 0
;	jne	@@bit51
;	dec	[counter]
;	jmp	@@_70


@@bit51:

writeoutroutine:	
@@_a00:	mov	ah, 0									; #####################################
	mov	al, [outb]								; #####################################
	mov	bx, 16									; 
	mov	cx, 2									; WRITE OUT char ROUTINE.   (LOOP)
	mov	di, offset fullbyte
	
	call 	NumToASCII              ; Convert number to hex

	cmp	[outputtype], 1		; asm include file format
	je	@@_a1
	cmp	[outputtype], 2		; asm v2 include file format
	je	@@_a2
	cmp	[outputtype], 3		; c include file format
	je	@@_a3	
	cmp	[outputtype], 4		; standard file format
	je	@@_a4	
	cmp	[outputtype], 5		; standard file format
	je	@@_a5	
	cmp	[outputtype], 6
	je	@@_a6
	cmp	[outputtype], 7
	je	@@_a7
	cmp	[outputtype], 8
	je	@@_a8
	cmp	[outputtype], 9		; PASSTHRU FILE2DB
	je	@@_a9
	cmp	[outputtype], 0		; PASSTHRU FILE2DEFB
	je	@@_a0


@@_a1:	mov	dx, offset name1	; asm include file format. ; Display '$0'
	call	write_this
	jmp	@@_70


@@_a2:	mov	dx, offset name5	; asm include file format. ; Display '0x'
	call	write_this
	jmp	@@_70


@@_a3:	mov	dx, offset name5	; C include file format. ; Display '0x'
	call	write_this
	jmp	@@_70


@@_a4:	mov	dx, offset name7	; Standard output include file format   0AA,0AA,0AA,0AA. ; Display '0'
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 1
	int	21h
	call	this2
	jmp	@@_70


@@_a5:	call	this2			; Standard output include file format	AA,AA,AA,AA
	jmp	@@_70


@@_a6:	jmp	@@_bpoke		; jump to big bpoke routine


@@_a7: 	mov	dx, offset name1	; asm include file format. ; Display '$0'
	call	write_this
	jmp	@@_70


@@_a8:	mov	dx, offset name1	; asm include file format. ; Display '$0'
	call	write_this
	jmp	@@_70


@@_a9:	mov	dx, offset name1	; asm include file format. ; Display '$0'
	call	write_this
	jmp	@@_70


@@_a0:	mov	dx, offset name1	; asm include file format. ; Display '$0'
	call	write_this
	jmp	@@_70





@@_70:											; ################################
@@_5011:										; ################################3
	cmp	[counter], 16		; width is 16, then do a <CR>			; 
	je	@@_71									;  DO WIDTH.
	mov	dx, offset name2	; Display   ,					;  DO NEXT LINE "DEFB" / "DB"  ROUTINE
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 1
        int     21h                     
	jmp	@@_72	
@@_71:	mov	[counter], 0
	mov	dx, offset name4	; Display   <CR>
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 2                   
        int     21h                     

	cmp	[outputtype], 1		; asm include file format
	je	@@_710
	jmp	@@_719
@@_710:	mov	dx, offset name6	; Display '.byte '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 6
	int	21h

@@_719:	cmp	[outputtype], 2		; asm include file format
	je	@@_720
	jmp	@@_721
@@_720:	mov	dx, offset name8	; Display 'defb '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 5
	int	21h

@@_721:	cmp	[outputtype], 7		; asm include file format
	je	@@_722
	cmp	[outputtype], 0		; asm PASSTHRU    FILE2DEFB
	jne	@@_723
@@_722:	mov	dx, offset name8	; Display 'defb '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 5
	int	21h

@@_723:	cmp	[outputtype], 8		; asm include file format
	je	@@_724
	cmp	[outputtype], 9		; asm PASSTHRU    FILE2DB
	jne	@@_725
@@_724:	mov	dx, offset name0	; Display 'db '
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 3
	int	21h

@@_725:



@@_72:	jmp	loopdeloop





@@_bpoke:
	mov	[fullbyte], 0
	mov	[fullbyte +1],0
	mov	[fullbyte +2],0
	mov	ah, 0
	mov	al, [outb]
	mov	cx, 3
	mov	di, offset fullbyte
	call	BinToAscDec

	mov	dx, offset name9	; Display   a[
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 10
        int     21h                     
			
	mov	dl, [counter4] 		; Display 1st digit in hex offset
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@_5083           ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        jmp	@@_5084           ; Return to caller@@10:
@@_5083:or      dl, '0'         ; Convert digits 0 to 9
@@_5084:mov	[oneByte], dl
	mov	dx, offset oneByte
	mov     ah, 40h      
        mov     bx, [outFile]
        mov     cx, 1                 
        int     21h                   

	mov	dl, [counter3] 		; Display 2nd digit in hex offset
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@_5085           ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        jmp	@@_5086           ; Return to caller@@10:
@@_5085:or      dl, '0'         ; Convert digits 0 to 9
@@_5086:mov 	[onebyte], dl
	mov	dx, offset oneByte
	mov     ah, 40h      
        mov     bx, [outFile]
        mov     cx, 1        
        int     21h          

	mov	dl, [counter2] 		; Display 3rd digit in hex offset
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@_5087           ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        jmp	@@_5088           ; Return to caller@@10:
@@_5087:or      dl, '0'         ; Convert digits 0 to 9
@@_5088:mov 	[onebyte], dl
	mov	dx, offset oneByte
	mov     ah, 40h      
        mov     bx, [outFile]
        mov     cx, 1        
        int     21h          

	mov	dx, offset name2	; Display   ]='
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 1                   
        int     21h                     

	cmp	[fullbyte],'0'		;   x23   work out if number looks like  Octal or not.
	jne	@@_bpa3
	cmp	[fullbyte+1],'0'	
	jne	@@_bpa2

	mov	dx, offset fullbyte+2	;   --3
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 1
	int	21h
	jmp	@@_bpa4

@@_bpa2:mov	dx, offset fullbyte+1	;   -23
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 2
	int	21h
	jmp	@@_bpa4

@@_bpa3:mov	dx, offset fullbyte	;  123  Display three byte decimal figure.
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 3
	int	21h

@@_bpa4:mov	dx, offset name3	; Display   ';
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 2                   
        int     21h                    

@@_bp70:inc	[counter2]		; do three hex digit counter
	cmp	[counter2], 16
	jne	@@_bp5011
	mov	[counter2], 0
	inc	[counter3]
	cmp	[counter3], 16
	jne	@@_bp5011
	mov	[counter3], 0
	inc	[counter4]
	cmp	[counter4], 16
	jne	@@_bp5011
	mov	[counter4], 0
	inc	[counter5]
@@_bp5011:cmp	[counter], 6		; width is 6, then do a <CR>
	je	@@_bp71
	jmp	@@_bp72	
@@_bp71:mov	[counter], 0
	mov	dx, offset name4	; Display   <CR>
	mov     ah, 40h                 
        mov     bx, [outFile]           
        mov     cx, 2                   
        int     21h                     

@@_bp72:jmp	loopdeloop




ending1:
@@80:   			; mostly everything will be always a defb, or .byte or db
				; and will have a last defb or .byte  or db at the end.	
				; therefore, may as well write a single 0 right at the end as the last char.

	mov	dx, offset name1	; asm include file format. ; Display '$0'
	call	write_this

	mov	dx, offset name4	; asm include file format. ; Display <CR>
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 2
	int	21h

	mov	dx, offset namea	; display 60x -------------------------------------------- at bottom.
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 60
	int	21h


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




write_this:
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 2
	int	21h
this2:	mov	dx, offset fullbyte	; Dump hex to file
	mov	ah, 40h
	mov	bx, [outfile]
	mov	cx, 2
	int	21h
	ret



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



PROC    HexDigit
        cmp     dl, 10          ; Is dl < 10 (i.e. hex 'A')?
        jb      @@10            ; If yes, jump
        add     dl, 'A'-10      ; Else convert to A, B, C, D, E, or F
        ret                     ; Return to caller
@@10:
        or      dl, '0'         ; Convert digits 0 to 9
        ret                     ; Return to caller
ENDP    HexDigit
%NEWPAGE
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
%NEWPAGE
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


;---------------------------------------------------------------
; BinToAscDec   Convert binary values to ASCII decimal strings
;---------------------------------------------------------------
; Input:
;       ax = 16-bit value to convert
;       cx = minimum number of digits to output
;       di = address of string to hold result
;       Note: assumes string is large enough to hold result
;       Note: outputs full result if cx is less than the number
;             of digits required to specify the result
;
; Output:
;       none
; Registers:
;       ax, cx (indirectly)
;---------------------------------------------------------------
PROC    BinToAscDec
        push    bx              ; Save bx on stack
        mov     bx, 10          ; Set base = 10 (decimal)
        call    NumToAscii      ; Convert ax to ASCII
        pop     bx              ; Restore bx
        ret                     ; Return to caller
ENDP    BinToAscDec



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
%NEWPAGE
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


        END     Start        ; End of program / entry point
