; MDD.COM
;
; Grabs todays date. Creates directory with the name  DDMMYYYY
; eg: 19th March, 2003:    19032003
; Then changes into that directory:   "cd 19032003"
;
;v1  - 416 bytes.
;v13 -  84 bytes.
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
        push    cx
        call    ascii
        mov     al, dh
        call    ascii
        pop     ax
        call    ascii
        pop     dx
        mov     ah, 39h
        int     21h
        mov     ah, 3bh
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

   code    ENDS
END     start
