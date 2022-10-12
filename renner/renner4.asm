; RENNER4.COM
;
; Grabs todays date. 
; Today is: 22-09-2004.   Ie:  DDMMYYYY
; Formats to:  042209a.DM2
;
; Renames  'DATA.DM2' to '042209a.DM2'            
;
;v4  - 115 bytes.
;
code    SEGMENT PARA PUBLIC 'code'
        ASSUME  cs:code
	org     100h
start:  mov     ah, 2ah
        int     21h
        mov     al, dl
        xor     ah, ah
        mov     di, offset new
        push    di
        push    cx
        call    ascii
        mov     al, dh
        call    ascii
        pop     ax
        call    ascii
	mov	di, offset rar
	mov	byte ptr [di], '.'
        pop     di			; di = offset 'new'
	mov	dx, offset old
        mov     ah, 56h			; rename
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


old	db 'DATA.DM2',0
new	db '00000000'
rar	db '.DM2',0

   code    ENDS
END     start

