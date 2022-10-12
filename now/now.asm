; NOW. DJM, 18/July/2006.
;
; Useage:    Now [echo text] 
; Outputs:   <date> <time> [echo text]
;
; 419 bytes
; 159 bytes
; 130 bytes
;
code    SEGMENT PARA PUBLIC 'code'
        ASSUME  cs:code
	org     100h
	.386
start: 	mov     di, offset mess
        push    di
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
	mov	al, 9
	stosb

 	mov	si, 82h
@@_0:	lodsb
	cmp	al, 0dh
	stosb
	jne	@@_0
	dec	di
	mov	ax, 00a0dh
	stosw
	mov	al, '$'
	stosb

	pop	dx
        mov     ah, 9h
        int     21h

        ret


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

mess	db 40 dup (?)
   code    ENDS
END     start
