; Reads in Feedlot weather station data and strips out everything but:
; actual data.
; useage:
;           WSD5 <in-file> <out-file>
;
; DJM - 6/5/5
;
;
;
;
;  Converts Feedlot weather data into the same format as that as the old weather property weather station, so that
;  it can be directly imported straight in to Citect without any mods to Citect.
;
;  Other option, of course, is to modify Citect for importing of new feedlot weather station data format.
;   ...but sounds too hard. Buggerising around with assembly is more funner!
;
;
; FROM:
;  date  ,   time  , Temp 1, Temp 2, Rainfall, Solar Radiation, Humidity, Air Speed, Wind direction, Wind direction,
;dd/mm/yy, hh:mm:ss, 1 °C    , 3 °C    , 4 mm    , 5 W/m²  , 8 %     , B km/h  , C °     , D °S.Dev,
;
;
; TO:
;date time ,      wind speed,  rel hum, air 1, air 2, air 3, wind run, wind dir, magnitude, rainfall, solar, max wind gust
;
;
;
; WSD5, includes the headers for citect importation.



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
notes   	DB      cr,lf,'WSD4  /Bushy,  6/5/5.', cr,lf
        	DB      cr,lf,'Converts Feedlot weather station data files from old'
        	DB      cr,lf,'Property weather station, for importing into Citect.'
        	DB      cr,lf
        	DB      cr,lf,'WSD5  <in-file>  <out-file>'
        	DB      cr,lf,cr,lf,0
buffer		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
text1		db	'#06 AVERAGE WSPD Kph ', cr, lf
text2		db	'#06 AVERAGE R.H. %   ', cr, lf
text3		db	'#06 AVERAGE Ta1  DegC', cr, lf
text4		db	'#06 AVERAGE Ta2  DegC', cr, lf
text5		db	'#06 AVERAGE Ta3  DegC', cr, lf
text6		db	'#06 AVERAGE E/-W Kph ', cr, lf
text7		db	'#06 AVERAGE N/-S Kph ', cr, lf
text8		db	'#07 TOTAL RAIN mm  ', cr, lf
text9		db	'#07 TOTAL SOLR MJ/m', cr, lf
text10		db	'#08 MAXIMUM GUST Kph ', cr, lf, 0
text11		db	'\END OF DATA ', cr, lf
text12		db	'>', cr, lf,0





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


        mov     ah, 40h                 ; DOS Write- TEXT FILE HEADERS
        mov     bx, [outFile]           
        mov     cx, 226
        mov     dx, offset text1        
        int     21h			



	


@@_44: 	mov	di, offset buffer	; Read line into buffer memory
@@_45:	call	readbyte
	cmp	al, 0dh
	je	@@_46
	stosb
	jmp	@@_45


@@_46:	

	mov	si, offset buffer
        add     si, 14
@@_47:  lodsb
        cmp     al, '0'     ; nothing that we want.
	je	@@_48
	call	readbyte		; read 0ah, and start over again for next line.
	jmp	@@_44
@@_48:	

@@_49:					; do date and time
	mov	al, '2'
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	si, offset buffer
	add	si, 6
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, '/'
	call	writebyte
	mov	si, offset buffer
	add	si, 3
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, '/'
	call	writebyte
	mov	si, offset buffer
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ' '
	call	writebyte
	mov	si, offset buffer
	add	si, 10
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ' '
	call	writebyte
	
	
					; do Wind speed
	mov	si, offset buffer
	add	si, 73
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ' '
	call	writebyte

	

					; do rel humidity
	mov	si, offset buffer
        add     si,62
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ' '
	call	writebyte

					; do Air Temp 1
	mov	si, offset buffer
        add     si,22
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ' '
	call	writebyte
	

					; do Air Temp 2
	mov	si, offset buffer
        add     si,32
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ','
	call	writebyte
	


	mov	al, ' '		; do Air Temp 3
	call	writebyte
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, '.'
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, ','
	call	writebyte


					; do vector 1
	mov	al, ' '		
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, '.'
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, ' '
	call	writebyte
	mov	al, ','
	call	writebyte


					; do vector 2
	mov	al, ' '		
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, '.'
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, ' '
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ' '
	call	writebyte


					; do Wind Dir
	mov	si, offset buffer
        add     si,82
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ','
	call	writebyte


					; do magnitude (same as wind speed)

	mov	si, offset buffer
	add	si, 73
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, '0'
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ' '
	call	writebyte




					; do rainfall
;		     wind rel   air   air    air   vect  vect wind   air  rain  solar   max   
;                    speed hum   temp1  temp2 temp3   1    2    dir  mag   fall   rad   gust
;2005/05/26 04:00:00, 10.8,  15., 28.6, 36.1, 35.2,-6.09, 6.83, 318., 9.15,  0.0,0.000,  27.
;2005/05/25 14:30:00, 33.1,   0., 14.8, 16.2,12345,12345,12345, 211.,     ,     ,407.2,     
;2005/05/25 14:40:00, 25.0,   0., 15.0, 16.2,  0.0, 0.0 , 0.0 , 211.,     ,     ,383.5,     

;2005/05/25 15:10:00, 34.6,   0., 15.1, 16.4,  0.0, 0.0 , 0.0 , 214., 0.0 ,     ,308.5,     
;2005/05/26 04:00:00, 10.8,  15., 28.6, 36.1, 35.2,-6.09, 6.83, 318., 9.15,  0.0,0.000,  27.

	mov	si, offset buffer
        add     si,44
	lodsb
	cmp	al, ' '
	jne	@@_50
	mov	al, '0'	
@@_50:	call	writebyte
	lodsb
	cmp	al, ' '
	jne	@@_51
	mov	al, '0'	
@@_51:	call	writebyte
	lodsb
	cmp	al, ' '
	jne	@@_52
	mov	al, '.'
@@_52:	call	writebyte
	lodsb
	cmp	al, ' '
	jne	@@_53
	mov	al, '0'
@@_53:	call	writebyte
	
					; do solar
	mov	al, ','
	call	writebyte
	mov	si, offset buffer
        add     si,53
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	lodsb
	call	writebyte
	mov	al, ','
	call	writebyte
	mov	al, ' '
	call	writebyte


					; do max gust
	mov	al, ' '		
	call	writebyte
	mov	al, ' '		
	call	writebyte
	mov	al, '0'		
	call	writebyte
	mov	al, '.'		
	call	writebyte
	mov	al, 0dh
	call	writebyte
	mov	al, 0ah
	call	writebyte


	call 	readbyte		; get rid of 0ah
	jmp	@@_44






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
	push	di
	push	si
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@802                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	ret

@@802:

        mov     ah, 40h                 ; DOS Write- TEXT FILE HEADERS
        mov     bx, [outFile]           
        mov     cx, 18
        mov     dx, offset text11       
        int     21h			



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
END     start
