; NOW
;
; Now [echo text] <DATE>
;
;
code    SEGMENT PARA PUBLIC 'code'
        ASSUME  cs:code
	org     100h
	.386

start:  
	
	mov	cx, 60h
	mov	si, 80h
	mov	di, offset mess
	rep	movsb


	mov     ah, 2ah
        int     21h
        mov     al, dl
        xor     ah, ah
        mov     di, 080h
        push    di
        push    cx
        call    ascii
        mov     al, dh
        call    ascii
        pop     ax
        call    ascii

	mov	dx, offset mess
	mov	ah, 9
	int	21h

        pop     dx
        mov     ah, 9h
        int     21h

        ret

Ascii:  mov     cx, 2
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
	
@@6:    mov     byte ptr [di], 0
        pop     dx
        ret




mess1	db 	"                                                                "
mess3	db	"                                                                "
mess5	db	"                                                                "
mess6	db	"$"

   code    ENDS
END     start
