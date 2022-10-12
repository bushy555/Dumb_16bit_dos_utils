; MDT.COM
;
; Grabs todays date. Grabs today time.
; creates directory with date/time as the name.
; Ie:  19th March, 2003. At 3:19pm, will create:
;      19031519		(24 hour time)
; and then cd's into the directory.


code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h

start:  
	mov     ah, 2ah			; Get date. 	dl=day, dh=month.
        int     21h
			
        mov     di, 080h		; destination is command line.
        push    di
        mov     al, dl
	call	@123			; Day. Do hex to decimal text.
	mov	al, dh
	call	@123			; Month. Do hex to decimal text.

	mov 	ah, 2ch			; Get Time.    ch=hour, cl=minute.
	int	21h
	push	cx
	mov	al, ch
	call	@123			; Hour. Do hex to decimal text.
	pop	ax
	call	@123			; Minute. Do hex to decimal text.

	pop	dx
	mov	ah, 39h			; Create directory.
	int	21h
	mov	ah, 3bh			; CD into directory.
	int	21h
	ret
@123:	
	xor	ah, ah
	mov	cx, 2			; hex to decimal-text routine.
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

