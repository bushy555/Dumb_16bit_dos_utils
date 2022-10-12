; Reads in Feedlot weather station data and strips out everything but:
; Minimum, maximum, average and 24 hour rain, and dumps it to <out-file>
; useage:
;           WSD <in-file> <out-file>
;
; DJM - 26/03/04 to 28/03/04.
;
;
; Searches for offset 12 'h' = hour, 'v' = average, 'i' = minimum, 'a' = maximum.
; Everything else is stripped and not written to out-file.
; So for a given <in-file>, such as 'DATA.TXT':
;
;  date  ,   time  , TA100079, TA100479, TA100422, RG200133, SR200026, AN2A0214, WD300033, WD300033, HU100183,
;dd/mm/yy, hh:mm:ss, 1 °C    , 2 °C    , 3 °C    , 4 mm    , 5 W/m²  , 6 km/h  , 7   sine, 8 cosine, 9 %     ,
;09/03/04, 24h Rain,         ,         ,         ,      0.0,
;16/03/04, 23:30:00,   15.058,   21.178,   23.022,         ,    288.7,     6.63,         ,         ,    71.53,
;16/03/04, 23:40:00,   15.564,   23.010,   22.964,         ,    345.1,     6.47,         ,         ,    70.54,
;16/03/04, 23:50:00,   16.072,   24.118,   22.912,         ,    312.7,     6.70,         ,         ,    69.29,
;17/03/04,  maximum,   32.150,   42.464,   30.628,         ,    963.0,    39.29,   0.9986,   0.9995,    67.84,
;17/03/04,  minimum,   17.188,   16.050,   24.786,         ,      0.1,     0.00, - 0.9996, - 0.9995,    34.34,
;17/03/04,  average,   24.928,   27.604,   27.460,         ,    298.0,    13.15,   0.2262,   0.6291,    47.28,
;17/03/04, 24h Rain,         ,         ,         ,      0.0,
;17/03/04, 09:00:00,   15.058,   21.178,   23.022,         ,    288.7,     6.63,         ,         ,    71.53,
;17/03/04, 09:10:00,   15.564,   23.010,   22.964,         ,    345.1,     6.47,         ,         ,    70.54,
;17/03/04, 09:20:00,   16.072,   24.118,   22.912,         ,    312.7,     6.70,         ,         ,    69.29,
;
;
; <Out-file> will be the following:
;
;09/03/04, 24h Rain,         ,         ,         ,      0.0,
;17/03/04,  maximum,   32.150,   42.464,   30.628,         ,    963.0,    39.29,   0.9986,   0.9995,    67.84,
;17/03/04,  minimum,   17.188,   16.050,   24.786,         ,      0.1,     0.00, - 0.9996, - 0.9995,    34.34,
;17/03/04,  average,   24.928,   27.604,   27.460,         ,    298.0,    13.15,   0.2262,   0.6291,    47.28,
;17/03/04, 24h Rain,         ,         ,         ,      0.0,
;
;
;
;
; Writing out buffer needs to be changed from 109 to single byte, then check single byte if <0Ah>.
;
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
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   	DB      cr,lf,'wsd.  /Bushy,  26-Mar-2k4.', cr,lf
        	DB      cr,lf,'Filters Feedlot weather-station data files'
        	DB      cr,lf,'WSD1  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0
buffer		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
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



	
					; Read from file into 'buffer' until <CR> or offset #61 is found.
					; If #61, then continue on. If <0Ah> then forget it altogether & start next line.
@@50:   xor	bp, bp
	mov	dx, offset buffer
@@_501:	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                  ; Specify one byte to read
        int     21h                     ; Call DOS to read from file
        jnc     @@_502                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@_502: or      ax, ax                  ; Check for end of input file
        jnz     @@_503
	jmp	@@80                    ; ax=0=end of file; jump
@@_503:	inc	bp
	inc	dx
	cmp	bp, 61
	je	@@60
	mov	di, dx
	dec	di
	mov	al, [di]
	cmp	al, 0ah
	je	@@50
	jmp	@@_501

@@60:
@@601:	
	mov	di, offset buffer
	add	di, 12
	mov	al, [di]
	cmp	al, 'a'
	je	@@70
	cmp	al, 'i'
	je	@@70
	cmp	al, 'v'
	je	@@70
	cmp	al, 'h'
	je	@@_001

					; Line is not to be written. Read next chars, dont write, and start again.
		; ********######   FIX to read until 0Ah

	
	mov	dx, offset buffer
	add 	dx, 59
@@_0010:mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        int     21h                     ; Call DOS to read from file
        jnc     @@_0011                 ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@_0011:or      ax, ax                  ; Check for end of input file
        jnz     @@_0012
	jmp	@@80                    ; ax=0=end of file; jump
@@_0012:mov	di, dx
	inc	dx
	mov	al, [di]
	cmp	al, 0ah
	jne	@@_0010
	jmp	@@50




@@_001:						; Valid 24 hour rain line.
	mov	di, offset buffer		;fill rest of buffer with ' ' when 24 hour rain.
	add 	di, 59				; and continue then to write it out.
	mov	cx, 48
@@_002:	mov	al, ' '
	mov	[di], al
	inc	di
	loop	@@_002
	mov	al, 0dh
	mov	[di], al
	inc	di
	mov	al, 0ah
	mov	[di], al
	jmp	@@75

					
@@70:					; Valid weather line. Read rest of buffer, continue to write it out.	
	mov	dx, offset buffer
	add	dx, 59
@@_701: mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        int     21h                     ; Call DOS to read from file
        jnc     @@_702                  ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@_702:	or      ax, ax                  ; Check for end of input file
        jnz     @@_703
	jmp	@@80                    ; ax=0=end of file; jump
@@_703:	mov	di, dx
	inc	dx
	mov	al, [di]
	cmp	al, 0ah
	jne	@@_701



	
@@75:	mov     ah, 40h                	; Write buffer to disk.
        mov     bx, [outFile]           
        mov     cx, 109
        mov     dx, offset buffer
        int     21h                     
	or      ax, ax                  ; Check for disk-full condition
        jz      @@_751
	jmp	@@50                    ; Repeat for next byte
@@_751: mov     di, offset diskFull     ; Address disk-full message
        call    StrWrite                ; Display message


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



END     start