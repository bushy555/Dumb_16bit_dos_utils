	.486
cseg	segment dword public use16 'code'
	assume	cs:cseg, ds:cseg, es:cseg, ss:cseg

	org	100h
start:	mov ah,2
    	int 1ah      ; time in BCD , dl=0
    	push cx
    	push dx
    	pop eax
m1:     mov al,163
    	sub dl,160   ; gives c,c,nc,c,c,nc,c,nc+z
    	ja $+3       ;       h h :  m m  : s s
    	rol eax,4
    	int 29h
    	jne m1
    	ret
cseg	ends
	end	start

