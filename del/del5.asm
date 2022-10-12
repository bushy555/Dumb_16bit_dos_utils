; Directory Deleter. DEL5.com
; started: 12/07/2k4.
; finished:14/07/2k4.
;
; Searches for all directories over < 15 > days.
; 	Then deletes all files, and removes sub directory name.
;	Will search for all directories > 15 days, remove contents, and remove directory.
;
; 	No output, no messages, no anything. Is quiet in here.
;	_TODAY contains 'date' that is today() minus number of days, ie date of 15 days ago.


code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
	.386
start:	


	mov     dx, offset DTA
       	mov     ah, 1ah
       	int     21h

	mov     ah, 2ah				; Get todays date.
        int     21h
	dec	dl				; dl= yesterday, dh=month, cx=year

	push	dx
	mov	dl, dh
	xor	dh, dh
	and	dl, 01111b
	shl	dx, 5
	mov	ax, dx
	pop	dx
	xor	dh, dh
	and	dl, 011111b
	or	dx, ax
	sub	cx, 1980
	shl	cx, 9
	or	dx, cx
						;**************************************************************
	sub	dx, 10				;*****   DAYS before today() to delete from. CHANGE THIS. *****
						;**************************************************************
	mov	word ptr _today, dx


        mov     dx, offset file_argument 	;load search mask,  *.*,  for any files
        mov     ah, 4Eh            	     	;find first host file,  any file
@refind:mov	cx, 16				; we want directory's. 16 = directory.
	int     21h                 	    	;keep cycling through directory
        jb      @exit               	    	;no more files,  exit

	mov	cx, 30				; copy filename to buffer.
	mov	si, offset filename
	mov	di, offset filename3
	rep	movsb

        mov     ah, 2Fh             	    	;get DTA
	int     21h                     

        lea     bp, [bx+24]			; 25 = date,  01Eh/30d = filename
	mov	dx, [bp]
	mov	bx, word ptr _today		; Is folder 10 days old?
	sub	bx, dx
	cmp	bx, 10				; is this days as well?
	jg	@do_it
	mov	ah, 4fh
	jmp	@refind	

@do_it:	mov	di, offset filename3		; check if '.' or '..' dir. If is, then skip.
	cmp	byte ptr [di], 02Eh
	je	@next

        mov     dx, offset filename3		;change to sub directory
     	mov     ah, 3Bh
        int     21h

        mov     dx, offset file_argument	;load search mask,  *.*,  for any files
        mov     ah, 4Eh                 	;find first host file,  any file
@re_do:	mov	cx, 15		
	int     21h     	                ;keep cycling through directory
        jb      @exit2 	                 	;no more files,  exit

        mov     ah, 2Fh  	               	;get DTA
	int     21h                     
	mov	bp, bx

        lea     dx, [bp+01Eh]			; 25 = date,  01Eh/30d = filename
	mov	ah, 41h				; delete file.
	int	21h

        mov     ah, 4Fh				; find next file
	jmp	@Re_do

@exit2: mov     dx, offset dirname2		;change to parent directory
     	mov     ah, 3bh
        int     21h

        mov     dx, offset filename3		; remove subdirectory
     	mov     ah, 3Ah
        int     21h

@next:	mov     dx, offset file_argument 	;load search mask,  *.*,  for any files
        mov     ah, 4Eh            	     	;find first host file,  any file
	mov	cx, 16				; we want directory's. 16 = directory.
	int     21h                 	    	;keep cycling through directory
        jb      @exit               	    	;no more files,  exit

	mov     ah, 4Fh				; find next file
	jmp	@Refind
   

@exit:  
@Quit:  mov     AX, 004ch               ;Outta here.
        int     21h


					
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Data

File_argument   db      "*.*", 0
dirname2 	db      '..',0
_today  	dw	0
dta     label byte
filename equ $ + 30
filename3 equ $ + 60


   code    ENDS
END     start

