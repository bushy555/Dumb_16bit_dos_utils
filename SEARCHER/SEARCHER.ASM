code segment para
Assume cs:code, ds:code, ss:nothing, es:nothing
start:	jmp	begin
;   0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
@1 db ' SEARCHER .=.use "-" and "+".  <ESC> quits.  Bushy 08-Mar-95.'

begin:	mov	ax, 0b800h
	mov	ds, ax
	mov	es, ax
	xor	si, si
	xor	di, di

	mov	cx, 07d0h
loop0:	lodsw
	cmp	al, 219
	je 	jmptmp
	cmp	al, 020h
	jne	jmp01
jmptmp:	mov	ax, 006dbh
	jmp	jmp0
jmp01:	mov	ah, 007
jmp0:	stosw
	loop	loop0

key:	xor	si, si
	xor	di, di
	xor	ax, ax
	int	16h
	cmp	al, 027
	je	quit
	cmp	al, 043
	je	increase
	cmp	al, 045
	je	decrease
	jmp	key
quit:
	mov	cx, 07d0h
loop00:	lodsw
	cmp	al, 0219
	jne	jmp00
	mov	ax, 00720h
jmp00:	stosw
	loop	loop00

	int	20h

increase:
	mov	cx, 07d0h
loop1:	lodsw
	cmp	al, 255
	jne	jmp10
	mov	al, 0
jmp10:	cmp	ah, 006
	je	jmp11
jmp1:	inc	ax
jmp11:	stosw
	loop	loop1
	jmp	key

decrease:
	mov	cx, 07d0h
loop2:	lodsw
	cmp	al, 000
	jne	jmp20
	mov	al, 255
jmp20:	cmp	ah, 006
	je	jmp21
jmp2:	dec	ax
jmp21:	stosw
	loop	loop2
	jmp	key

code ends
end start   