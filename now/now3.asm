; NOW2.
; Attempt at making from .COM to .EXE file, for use with 64bit windows.
; DJM. 4/Oct/2018
; Has about a 60 character parameter limit.
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
oneByte         Db      0       ; Byte I/O variable

mess		db 	"                                                                                         ", 0
mess2		db 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

notes   DB      cr,lf,'NOW2. djm, 4/10/18.'
        DB      cr,lf,'Outputs current Date and <param> for the likes of logging files.... '
        DB      cr,lf,'NOW2 Hello there',cr,lf
	DB	cr,lf,'04/10/2018 9:00am Hello There',cr,lf, '---------------------------',0,0

        CODESEG
        EXTRN StrWrite:Proc, NewLine:Proc
        EXTRN DiskErr:Proc
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc
Start: 

	mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment

	mov	si, 082h
	mov	di, offset mess2
@@1:	lodsb
	cmp	al, 0dh
	stosb
	jne	@@1
	mov	al, 0ah
	stosb


	mov     ax, @data               ; Set ax to data segment
        mov     ds, ax                  ; Set es to data segment
        mov     es, ax                  ; Set es to data segment
	jmp	@@10
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 1                   ; Does count = 1?
        je      @@10                    ; Continue if param count = 1
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
        jmp     Exit                    ; Exit program
@@10:

 	mov     di, offset mess
        
	mov     ah, 2ah			; Get Date.
        int     21h
	push	cx
        mov     al, dl
        xor     ah, ah
        call    ascii			; day
	mov	al, '/'
	stosb
        mov     al, dh
        call    ascii			; month
	mov	al, '/'
	stosb
	pop	ax
        call    ascii			; year
	mov	al, ' '
	stosb

	mov 	ah, 2ch			; Get Time.    ch=hour, cl=minute.
	int	21h
	push	cx
	mov	al, ch
	xor	ah, ah
	call	ascii			; hour
	mov	al, ':'
	stosb
	pop	ax
	xor	ah, ah
	call	ascii			; Minute
	mov	al, 32
	stosb
	mov	al, 32
	stosb
	mov	al, 32
	stosb
	mov	al, 32
	stosb
	mov	al, 32
	stosb
	mov	al, 32
	stosb
	mov	al, 32
	stosb


 	mov	si, offset mess2
@@_0:	lodsb
	cmp	al, 0h
	stosb
	jne	@@_0
	dec	di
;	mov	ax, 00a0dh
;	stosw
	mov	al, '$'
	stosb

	mov     dx, offset mess
        mov     ah, 9h
        int     21h




Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program


Ascii:	mov     cx, 2
        mov     bl, 10
        push    dx
        xor     si, si
        jcxz    @@4
@@1:    xor     dx, dx
        div     bx
        cmp     dl, 10
        jb      @@2
        add     dl, 'A'-10
        jmp     @@3
@@2:    or      dl, '0'
@@3:    push    dx
        inc     si
        loop    @@1
@@4:    inc     cx
        or      ax, ax
        jnz     @@1
        mov     cx, si
        jcxz    @@6
@@5:    pop     ax
        stosb
        loop    @@5
@@6:    pop     dx
        ret






        END     Start        ; End of program / entry point






