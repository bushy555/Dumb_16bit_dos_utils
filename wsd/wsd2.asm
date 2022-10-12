; Reads in Feedlot weather station data and strips out everything but:
; actual data.
; useage:
;           WSD2 <in-file> <out-file>
;
; DJM - 4/2/5
;
;
; Searches for offset 3 'd' = 1st line (date), '/' 2nd line and actual data.
; Everything else is stripped and not written to out-file.
;
;------------------------------------------------------------------------------------------------
; So for a given <in-file>, such as 'DATA.TXT':
;------------------------------------------------------------------------------------------------
;        Press 7 for one touch download 
;       Press 8 to repeat the last one touch download 
;       Press 9 to exit ;;
;  date  ,   time  , TA10079, TA100422, SR200026, HU100183, AN2A0328, WD400200, WD400200,
;dd/mm/yy, hh:mm:ss, 1 °C   , 3 °C    , 5 W/m²  , 8 %     , B km/h  , C °     , D °S.Dev,
;03/02/05, 15:00:00,   11.490,   19.494,    350.6,    87.87,    35.51,   309.07,     5.23,
;
;    03/02/2005 15:03 
;
;
;
;
;    04/02/2005 10:47 
;
;
;        Press 1 to see a list of sensors connected 
;        Press 2 to read the current values of the sensors 
;        Press 3 to download the stored data 
;        Press 4 to change the logger settings 
;        Press 5 to see the current page and each new entry 
;        Press 6 to see any page in memory 
;        Press 7 for one touch download 
;        Press 8 to repeat the last one touch download 
;        Press 9 to exit 
;
;
;
;
;
;  date  ,   time  , TA100079, TA100422, RG200133, SR200026, HU100183, AN2A0328, WD400200, WD400200,
;dd/mm/yy, hh:mm:ss, 1 °C    , 3 °C    , 4 mm    , 5 W/m²  , 8 %     , B km/h  , C °     , D °S.Dev,
;03/02/05, 15:30:00,         ,         ,         ,         ,         ,    33.54,   314.61,     4.93,
;03/02/05, 15:40:00,         ,         ,         ,         ,         ,    28.98,   312.24,     5.80,
;03/02/05, 15:50:00,         ,         ,         ,         ,         ,    43.72,   293.64,    15.26,
;03/02/05, 16:00:00,   10.252,   19.566,         ,     40.3,    90.98,    31.70,   279.14,     6.11,
;
;
;
;
;------------------------------------------------------------------------------------------------
; <Out-file> will be the following:
;------------------------------------------------------------------------------------------------
;
;  date  ,   time  , TA10079, TA100422, SR200026, HU100183, AN2A0328, WD400200, WD400200,
;dd/mm/yy, hh:mm:ss, 1 °C   , 3 °C    , 5 W/m²  , 8 %     , B km/h  , C °     , D °S.Dev,
;03/02/05, 15:00:00,   11.490,   19.494,    350.6,    87.87,    35.51,   309.07,     5.23,
;  date  ,   time  , TA100079, TA100422, RG200133, SR200026, HU100183, AN2A0328, WD400200, WD400200,
;dd/mm/yy, hh:mm:ss, 1 °C    , 3 °C    , 4 mm    , 5 W/m²  , 8 %     , B km/h  , C °     , D °S.Dev,
;03/02/05, 15:30:00,         ,         ,         ,         ,         ,    33.54,   314.61,     4.93,
;03/02/05, 15:40:00,         ,         ,         ,         ,         ,    28.98,   312.24,     5.80,
;03/02/05, 15:50:00,         ,         ,         ,         ,         ,    43.72,   293.64,    15.26,
;03/02/05, 16:00:00,   10.252,   19.566,         ,     40.3,    90.98,    31.70,   279.14,     6.11,



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
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   	DB      cr,lf,'wsd2  /Bushy,  4/2/5.', cr,lf
        	DB      cr,lf,'Filters Feedlot weather-station data files, and removes menu text and other text rubbish.'
        	DB      cr,lf,'WSD2  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0
buffer		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



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



	

@@50:	call 	readbyte
	mov	bl, al
	call	readbyte
	cmp	al, 0ah
	je	@@50
	mov	bh, al
	call	readbyte
	cmp	al, '/'		
	je	@@_51		; Line is correct
	cmp	al, 'd'
	je	@@_51		; Line is correct
	jmp	@@_60

@@_51:	mov	si, ax		; data line is correct. write line out until 0ah is found.
	mov	al, bl
	call	writebyte
	mov	al, bh
	call	writebyte
	mov	ax, si
	call	writebyte

@@_501:	call	readbyte	; write out rest of line util 0ah is found.
	cmp	al, 0ah
	je	@@_502
	call	writebyte
	jmp	@@_501
@@_502:	call	writebyte	; write out one 0ah to finish line.

	jmp	@@50		; go back for next line.

@@_60:	call	readbyte	; not a correct line - read until 0ah is found.
	cmp 	al, 0ah
	jne	@@_60
;	mov	al, 0dh
;	call	writebyte
;	mov	al, 0ah
;	call	writebyte

	jmp	@@50




	
	

;
;@@75:	mov     ah, 40h                	; Write buffer to disk.
;        mov     bx, [outFile]           
;        mov     cx, 109
;        mov     dx, offset buffer
;        int     21h                     
;	or      ax, ax                  ; Check for disk-full condition
;        jz      @@_751
;	jmp	@@50                    ; Repeat for next byte
;@@_751: mov     di, offset diskFull     ; Address disk-full message
;        call    StrWrite                ; Display message
;
;
;@@80:   mov     bx, [inFile]            ; Get input file handle
;        mov     ah, 3Eh                 ; DOS Close-file function
;        int     21h                     ; Close input file
;        mov     bx, [outFile]           ; Get output file handle
;        mov     ah, 3Eh                 ; DOS Close-file function
;        int     21h                     ; Close output file
;        jnc     Exit                    ; Exit if no errors detected
;        jmp     Errors                  ; Else jump to error handler
Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program



Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

PROC 	readbyte
	push	bx
	push	cx
	push	dx
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@802                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
	pop	dx
	pop	cx
	pop	bx
	ret

@@802:
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
	mov	di, offset oneByte
	mov	[di], al


        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
	pop	dx
	pop	cx
	pop	bx
	ret


ENDP	writebyte
END     start