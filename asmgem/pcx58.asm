; 58 byte 320x200x256 .PCX file viewer.
; 58PCX.COM < FILE.PCX

code    segment public
        assume  cs:code
        org     100h
        .386
start:  mov     al, 13h
        int     10h
        mov     ax, 0a000h
        mov     es, ax
        mov     dx, 03c8h
        out     dx, al
        mov     ah, 3fh
        mov     ch, 0fah
        int     21h
        mov     si, 0448h
        stosw
@0117:  lodsb
        cmp     al, 0c0h
        jbe     @0122
        and     ax, 003fh
        xchg    cx, ax
        lodsb
        repz
@0122:  stosb
        cmp     di, 0fa00h
        jbe     @0117
        mov     ch, 03
        inc     dx
@012c:  shr     byte ptr [si], 2
        outsb
        loop    @012c
        int     16h
        mov     ax, 0003h
        int     10h
        ret
        code    ends
end       start

