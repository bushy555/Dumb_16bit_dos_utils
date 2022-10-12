;	Will search current directory for TAGGED and then do a CD TAGGED.
;
;
code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h

start:
        mov     dx, offset DTA
        mov     ah, 1ah
        int     21h

        mov     cx, 10h
        mov     dx, offset dirname
        mov     ah, 4eh
        int     21h

        mov     dx, offset filename
     	mov     ah, 3bh
        int     21h
   
        ret

dirname db      'TAGGED',0
dta     label byte
filename equ $ + 30

   code    ENDS
END     start

