;#####################################################################################################
; RENNER3.COM
;#####################################################################################################
;
; Renames a specified (hard-coded) file name in current directory to a date/time formatted file name.
; Searches for 'LOGFILES.ZIP' in current directory.
; ie:  'LOGFILES.ZIP' to 'DDMMhhmm.ZIP' 
; being: DDMMhhmm  is  Date Date Month Month hour hour minute minute
; ie: now is 24th June, 11:05am
; ie:  'LOGFILES.ZIP' to '24061105.ZIP'            
;
;v1 	117 bytes.
;

code    SEGMENT PARA PUBLIC 'code'
        ASSUME  cs:code
	org     100h
	.386
start:  
	mov     ah, 2ah
        int     21h
        mov     di, offset new
	push	di

        mov     al, dl			; day. do hex to dec text.
        call    ascii
        mov     al, dh			; month. do hex to dec text.
        call    ascii

	mov 	ah, 2ch			; Get Time.    ch=hour, cl=minute.
	int	21h

	push	cx
	mov	al, ch
	call	ascii			; Hour. Do hex to decimal text.
	pop	cx
	mov	al, cl
	call	ascii			; Minute. Do hex to decimal text.

	pop	di			; di = offset new
	mov	dx, offset old
        mov     ah, 56h			; rename
        int     21h
        ret


Ascii:  mov     cx, 2
	xor	ah, ah
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

old	db 'arj.arj',0
new	db '00000000'
zip	db '.arj',0

   code    ENDS
END     start

