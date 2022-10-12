; Directory Deleter v1.0
; DJM, 22/Feb/2k4.
;
; Deletes all files in current directory that are older than two (2) days ago.
;   Reads in todays date, then for every file in current directory, it will compare the creation date
;   with yesterdays date, and will delete those files that are older.
;
; Format:	deller <filename> | {switch}
;  filename:	Any 8.3 filename in current directory. If a filename is give, this program will only 
;               concentrate on this file. It will read the creation date of the file, and if before
;               yesterday, will delete it. Otherwise it will leave it alone.
;
;  switch:   a  Program will do entire directory.
;
; >deller a		(will work on complete directory)
; >deller fred.com	(only for file fred.com)
;
; No output, no messages, no anything. Is quiet in here.



code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
	
start:	
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

	mov	word ptr _today, dx

        mov     si, 080h                ;point to command tail in PSP
        mov     cl, [si]                ;get number of characters in tail
        xor     ch, ch                  ;make it a word
        inc     si                      ;point to first character
        push    si
        add     si, cx                  ;point to last character
        mov     byte ptr [si], 0        ;make it an ASCIIZ string (clear the CR)
        mov     Name_end, si            ;save pointer to last character
        pop     si                      ;get back pointer to filename

        jcxz    @@_00
	jmp	@@_01
@@_00:	jmp	@no_filename
@@_01:  cld
@Del_spaces:
        lodsb                           ;get character into AL
        cmp     al, " "                 ;is it a space?
        jne     @Found_letter
        loop    @Del_spaces
@Found_letter:
        dec     si                      ;backup pointer to first letter

        cmp     byte ptr [si], 'a'
        je      @Tis_a
        cmp     byte ptr [si], 'A'
        jne     @Not_A
@Tis_a:
        mov     flag, 1
        mov     dx, offset file_argument ;load search mask,  *.*,  for any files
        mov     ah, 4Eh                 ;find first host file,  any file

@refind:int     21h                     ;keep cycling through directory
        jb      @exit                   ;no more files,  exit
        mov     ah, 2Fh                 ;set DTA
	int     21h                     
        mov     si, bx
        mov     ax, 04301h              ;clear file attributes so this can
        xor     cx, cx                  ;roll over read-only & system files.
        lea     dx, [si+01Eh]
	int     21h                     
        jmp     short @open
@Not_A: mov     Name_pointer, si        ;save pointer to filename

@Attrib_error:
        mov     dx, si
@open:  mov     ax, 03D02h              ;setup to open file
        int     21h                     ;DOS call
                                        ;Opened file handle is in AX
        mov    bx,  ax
        Jc      @No_file

@File_opened:
nop
nop
nop
nop

        mov     ax,  05700h		;read
        int     21h
	push	dx
        mov     AH, 3Eh                 ;close the opened file
        int     21h
	pop	dx

	cmp	dx, word ptr _today	; compare to File read date to that of _Today.
	jge	@@_no_del
	
        lea     dx, [si + 01eh]
	mov 	ah, 41h
	int	21h

@@_no_del:	
@Close_err_exit:

        cmp     flag, 1
	jne	@exit

        mov     ah, 4Fh                 ;find next file in directory
        jmp     Short @refind           ;cycle to "refind"

@exit:  
@no_file:
@no_filename:
@print:
@Quit:  mov     AX, 004ch               ;Outta here.
        int     21h


					
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Data

Flag            db      0
Exit1           db      "TS <filename> [a]", 0ah, 0dh, 0ah, 0dh
                db      "option: a  -will kill date/time stamp for all files "
		db	"in the current directory.", 0ah, 0dh, "$"
Exit2           db      "Invalid filename.", 0ah, 0dh, 0ah, 0dh, "$"
Opening         db      0ah,  0dh, "TIME STAMP KILLER by Bushy", 0ah, 0dh, "$"
Mess1           db      "Killing date\time", 0ah, 0dh, 0ah, 0dh, "$"
Closing         db      "Done!", 0ah, 0dh, "$"
File_argument   db      "*.*", 0
delmess		db	"Delete!",0ah,0dh,"$"

Even                                    ;"word align" (for 16-bit bus accesses)
Name_pointer    dw      081h             ;offset of command tail in PSP
Name_end        dw      081h             ;end of tail

fred0   db 	'-------------'
_day1	dw	0
fred1	db	'X'
_month1	dw	0
fred2	db 	'X'
_today  dw	0
fred3   db 	'-------'
_day2	db	0
fred4	db	'X'
_month2	db	0
fred5	db	'X'
_date	dw	0
fred6   db 	'------------------------------'



   code    ENDS
END     start

