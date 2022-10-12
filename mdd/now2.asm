; MDD.COM
 ;
 ; Grabs todays date. Creates directory with the name  YYYY
 ; eg: This year is 2003, then directory "2003" will be created.
 ;     This year is 2004, then directory "2004" will be created.
 ;     This year is 2005, then directory "2005" will be created.
 ; Then changes into that directory:   "cd 2003"
 ;
 ;v1 - 84 bytes.
 ;v4 - 69 bytes.
 ;v5 - 40 bytes (ralf).
 ;v6 - 36 bytes (djm)
 code    SEGMENT PARA PUBLIC 'code'
         ASSUME  cs:code
         org     100h
.486
 start:
	mov	di, 80h
	mov	cx, 60h
	mov	al, 0
	rep 	stosb
	mov	al, '$'
	stosb
 	mov	di, 0FEh	; point at end of commandline buffer
 	std			; string functions go in reverse direction
	mov	al, '$'
	stosb
	mov	ah, 2ah
        int     21h		; returns year in CX
        mov     bl, 10		; use base 10
@@1:    cwd

        xchg    ax, cx		; put year/quotient into AX
        div     bx	
 	xchg	ax, cx		; put quotient back into CX
 	mov	al, '0'
 	or      al, dl		; convert remainder to ASCII digit
 	stosb			; add to end of string
	mov	al, ':'
 	test    cx, cx		; more digits to be generated?
        jnz     @@1		; if yes, continue loop
 	xchg	dx, di		; DX=pointer to start of string for DOS funcs


 	inc	dx		; (DI pointing one byte too low)
	push	dx

	mov	dx, 80h		;display the ECHO - command line parameter bit.
	mov	ah, 9h
	int	21h

	pop	dx		; display the time.
	mov     ah, 9h		
        int     21h
        ret			; terminate program
     code    ENDS
 END     start

