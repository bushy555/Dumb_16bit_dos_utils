; Zero Byte File Checker.   ZBFC
; djm, 8/6/5


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
notes   	DB      cr,lf,'zbfc  - zero byte file checker  /Bushy,  8/6/5.', cr,lf
        	DB      cr,lf,'Checks if certain file is 0 byte in size.'
		db	cr,lf,' If yes, exits with errorlevel code 1. If not, then exits with 0.'
        	DB      cr,lf,'zbfc  <file>'
        	DB      cr,lf,cr,lf,0
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
        cmp     dx, 1                   ; Does count = 4?
        je      @@10                    ; Continue if param count = 4
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
        jmp     @@_Exit                 ; Exit program

					;-----  Attempt to open the input file
@@10:   mov	ah, 1ah
	int	21h

	xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        mov	cx, 0
        mov     ah, 4eh                 ; DOS Open-file function
	int	21h



	mov	ah, 2fh
	int	21h

	mov	si, 1bh
	mov	al, offset es:[si]

	cmp	al, 0
	je	@@_yes
	cmp	al, 80
	je	@@_yes



@@_exit:
@@_Ok:	mov	al, 0
        mov     ah, 04ch
        int     21h                     ; Call DOS. Terminate program

@@_yes: mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, 1
        int     21h                     ; Call DOS. Terminate program

END     start