	.model	tiny
	.code
	.286
	org	100h
start:	mov	di,si		; 8b fe	;	?s	format: ss:mm:hh lf cr. ie: 95:95:32
	mov	si,10ah		; be 0a 01;   s:m
	mov	cl,0ah		; b1 0a	;       m:
@printbyte:
	mov	ax,bx			;					    hh
	cmp	bh,[di]		; 3a 3d
	inc	di
	out	070h,al
	in	al,071h
	db	0d4h, 010h	; aam 16
	stosw
	inc	bx
	inc	bx
	jnp	@printbyte
	std	
@printloop:
	lodsb
	xor	al,30h
	xchg	ax,dx
	lahf				; flags turned out to be 2 or 6 for all cases..
	int 	21h
	loop 	@printloop
	ret	

	end	start
