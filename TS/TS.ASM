;Time Stamp killer. version 0.0000000001 Alpha Alpha Gamma Delta version.

; From:
;	TS       ASM      3756 05-15-96  11:08p
;	TS       COM       358 05-15-96  11:08p
;	TS       TXT      4618 05-15-96  11:08p
; To:
;	TS       ASM      3756
;	TS       COM       358
;	TS       TXT      4618
        
;   or can change date/time to whatever by the equalities and re-compiling this.
;	ts a     - will obliviate the whole directory. Coolish. 
;		 - Can also create dates such as 16/14/00 or time as 12:63p

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
_date	equ	0;10240
_time	equ	0;26623

;12:63p		26623
;00-00-00	10240
;Total wipeout	0 & 0
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�



code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
	
start:	mov	dx, offset opening	;display stuff
	mov	ah, 9
	int	21h

        mov     si, 080h                ;point to command tail in PSP
        mov     cl, [si]                ;get number of characters in tail
        xor     ch, ch                  ;make it a word
        inc     si                      ;point to first character
        push    si
        add     si, cx                  ;point to last character
        mov     byte ptr [si], 0        ;make it an ASCIIZ string (clear the CR)
        mov     Name_end, si            ;save pointer to last character
        pop     si                      ;get back pointer to filename

        jcxz    @no_filename
        cld
@Del_spaces:
        lodsb                           ;get character into AL
        cmp     al, " "                 ;is it a space?
        jne     @Found_letter
        loop    @Del_spaces
@Found_letter:
        dec     si                      ;backup pointer to first letter

        mov     dx,  offset Mess1
        mov     ah,  9
        int     21h

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
        xchg    bx,  ax
        Jc      @No_file
@File_opened:
        mov     ax,  05701h
        mov     cx,  _time
        mov     dx,  _date
        int     21h

@Close_err_exit:
        mov     AH, 3Eh                 ;close the opened file
        int     21h

        cmp     flag, 1
	jne	@exit

        mov     ah, 4Fh                 ;find next file in directory
        jmp     Short @refind           ;cycle to "refind"

@exit:  mov     dx, offset closing
        mov     ah, 9
        int     21h
        jmp     short @Quit

@no_file:mov    dx, offset exit2
        jmp     short @print
@no_filename:
        mov     dx, offset exit1
@print: mov     ah, 9
        int     21h

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

Even                                    ;"word align" (for 16-bit bus accesses)
Name_pointer    dw      081h             ;offset of command tail in PSP
Name_end        dw      081h             ;end of tail


   code    ENDS
END     start

