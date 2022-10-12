;	Password for batch file. Exits with errorlevel 0 or 1.
; 	djm, 6/6/5.
;

code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
.386
start:  mov     dx, offset disp1
	mov	ah, 9
	int	21h

	mov	ah, 7
	int	21h
	cmp	al, 't'
	jne	@@_1
	mov	ah, 7
	int	21h
	cmp	al, 'h'
	jne	@@_1
	mov	ah, 7
	int	21h
	cmp	al, 'o'
	jne	@@_1
	mov	ah, 7
	int	21h
	cmp	al, 'r'
	jne	@@_1
	mov	ah, 7
	int	21h
	cmp	al, 's'
	jne	@@_1
	mov	ah, 7
	int	21h
	cmp	al, 'y'
	jne	@@_1
	mov	ah, 7
	int	21h
	cmp	al, 's'
	jne	@@_1
	mov	ah, 7
	int	21h
	cmp	al, '1'
	jne	@@_1
	jmp	@@_ok

@@_1:	mov     dx, offset bad
	mov	ah, 9
	int	21h
        mov     dx, offset disp1
	mov	ah, 9
	int	21h
	mov	ah, 7
	int	21h
	cmp	al, 't'
	jne	@@_2
	mov	ah, 7
	int	21h
	cmp	al, 'h'
	jne	@@_2
	mov	ah, 7
	int	21h
	cmp	al, 'o'
	jne	@@_2
	mov	ah, 7
	int	21h
	cmp	al, 'r'
	jne	@@_2
	mov	ah, 7
	int	21h
	cmp	al, 's'
	jne	@@_2
	mov	ah, 7
	int	21h
	cmp	al, 'y'
	jne	@@_2
	mov	ah, 7
	int	21h
	cmp	al, 's'
	jne	@@_2
	mov	ah, 7
	int	21h
	cmp	al, '1'
	jne	@@_2
	jmp	@@_ok

@@_2:	mov     dx, offset bad
	mov	ah, 9
	int	21h
        mov     dx, offset disp1
	mov	ah, 9
	int	21h
	mov	ah, 7
	int	21h
	cmp	al, 't'
	jne	@@_3
	mov	ah, 7
	int	21h
	cmp	al, 'h'
	jne	@@_3
	mov	ah, 7
	int	21h
	cmp	al, 'o'
	jne	@@_3
	mov	ah, 7
	int	21h
	cmp	al, 'r'
	jne	@@_3
	mov	ah, 7
	int	21h
	cmp	al, 's'
	jne	@@_3
	mov	ah, 7
	int	21h
	cmp	al, 'y'
	jne	@@_3
	mov	ah, 7
	int	21h
	cmp	al, 's'
	jne	@@_3
	mov	ah, 7
	int	21h
	cmp	al, '1'
	je	@@_ok
@@_3:	jmp	@@_bad

@@_Ok:	mov	al, 0
        mov     ah, 04ch
        int     21h                     ; Call DOS. Terminate program

@@_bad: mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, 1
        int     21h                     ; Call DOS. Terminate program





cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed

exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         DB      0       ; Byte I/O variable
notes   	DB      cr,lf,'pass  /Bushy,  3/6/5.', cr,lf
        	DB      cr,lf,cr,lf,0

disp1		db	cr,lf,'Enter password: $',0
password1	db	'thorsys1$',0
buffer		db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
bad		db	'Incorrect Password - try again',cr,lf,'$',0
 
   code   ends


end       start
