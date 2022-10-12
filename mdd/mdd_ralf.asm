; MDD.COM
> ;
> ; Grabs todays date. Creates directory with the name  YYYY
> ; eg: This year is 2003, then directory "2003" will be created.
> ;     This year is 2004, then directory "2004" will be created.
> ;     This year is 2005, then directory "2005" will be created.
> ; Then changes into that directory:   "cd 2003"
> ;
> ;v1 - 84 bytes.
> ;v4 - 69 bytes.
> ;v5 - 40 bytes (ralf).
> ;
> code    SEGMENT PARA PUBLIC 'code'
>         ASSUME  cs:code
>         org     100h
> start:
> 	mov	di, 0FFh	; point at end of commandline buffer
> 	std			; string functions go in reverse direction
> 	mov     ax, 2a00h       ; AH=Get system date, AL=terminating NUL char
> 	stosb
>         int     21h		; returns year in CX
>         mov     bx, 10		; use base 10
> @@1:    xor     dx, dx
>         xchg    ax, cx		; put year/quotient into AX
>         div     bx	
> 	xchg	ax,cx		; put quotient back into CX
> 	mov	al, '0'
> 	or      al, dl		; convert remainder to ASCII digit
> 	stosb			; add to end of string
> 	test    cx, cx		; more digits to be generated?
>         jnz     @@1		; if yes, continue loop
> 
> 	mov	dx, di		; DX=pointer to start of string for DOS funcs
> 	inc	dx		; (DI pointing one byte too low)
>         mov     ah, 39h		; create directory
>         int     21h
>         mov     ah, 3bh		; change to newly-created directory
>         int     21h
>         ret			; terminate program
>     code    ENDS
> END     start

