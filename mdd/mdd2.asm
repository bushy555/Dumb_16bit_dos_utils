; MDD.COM
;
; Grabs yesterday date (close enough),  Creates directory with the name  DDMMYYYY
; creates directory with yesterdays dates as the name.
; cd into the directory


code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h

start:  mov     ah, 2ah
        int     21h
	dec	dl		; dl=day, dh=month, cx=year
        mov     al, dl
	xor	ah, ah
        mov     di, 080h	;destination
        push    di
	push	cx
	call	@123
	mov	al, dh
	call	@123
	pop	ax
	call	@123
	pop	dx
	mov	ah, 39h
	int	21h
	mov	ah, 3bh
	int	21h
	ret
@123:	mov	cx, 2
	mov	bl, 0Ah
	push	dx
	xor	si, si
	jcxz	@142
@12d:	xor	dx, dx
	div	bx
	cmp	dl, 0Ah
	jb	@13b
	add	dl, 37h
	jmp	@13e
@13b:	or	dl, 30h
@13e:	push	dx
	inc	si
	loop	@12d
@142:	inc	cx
	or	ax, ax
	jne	@12d
	mov	cx, si
	jcxz	@14f
@14b:	pop	ax
	stosb
	loop	@14b
@14f:	mov	byte ptr [di], 0
	pop	dx
	ret

   code    ENDS
END     start
