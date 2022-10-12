; MDD3.COM
;
; Grabs todays date. Creates directory with the name  YYYY
; eg: This year is 2003, then directory "2003" will be created.
;     This year is 2004, then directory "2004" will be created.
;     This year is 2005, then directory "2005" will be created.
; Then changes into that directory:   "cd 2003"
;
; [Written for auto download of weather station.]
; Dave. 12/06/2k3.
;
;v1 - 84 bytes.
;v4 - 69 bytes.
;
code    SEGMENT PARA PUBLIC 'code'
        ASSUME  cs:code
	org     100h
start:  mov     ah, 2ah
        int     21h
        mov     al, dl
        xor     ah, ah
        mov     di, 080h
        push    di
	xchg	ax, cx

Ascii:  mov     cl, 2
        mov     bl, 10
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
        mov     ah, 39h
        int     21h
        mov     ah, 3bh
        int     21h
        ret

   code    ENDS
END     start
