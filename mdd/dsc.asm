;######################################################################################
; dsc.COM	c Drive.
;######################################################################################
;
; Disk Space checker. - C drive.
; finds free space on drive. 
; if drive is invalid, returns errorlevel 9.
;
;
;

code    SEGMENT PARA PUBLIC 'code'
        ASSUME  cs:code
	org     100h
	.386
start:  
	mov	ah, 36h
	mov	dl, 03h
	int	21h
	
	mov	sectors,  ax
	mov	clusters, bx
	mov	sectors,  cx
	

	
INT 21 - DOS 2+ - GET FREE DISK SPACE
	AH = 36h
	DL = drive number (00h = default, 01h = A:, etc)
Return: AX = FFFFh if invalid drive
	else
	    AX = sectors per cluster
	    BX = number of free clusters
	    CX = bytes per sector
	    DX = total clusters on drive
Notes:	free space on drive in bytes is AX * BX * CX





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

old	db 'logfiles.zip',0
new	db '00000000'
zip	db '.zip',0

   code    ENDS
END     start






--------D-214D-------------------------------
INT 21 - DOS 2+ - GET RETURN CODE (ERRORLEVEL)
	AH = 4Dh
Return: AH = termination type
	    00h normal (INT 20,INT 21/AH=00h, or INT 21/AH=4Ch)
	    01h control-C abort
	    02h critical error abort
	    03h terminate and stay resident (INT 21/AH=31h or INT 27)
	AL = return code
	CF clear
Notes:	the word in which DOS stores the return code is cleared after being
	  read by this function, so the return code can only be retrieved once
	COMMAND.COM stores the return code of the last external command it
	  executed as ERRORLEVEL
	this call should not be used if the child was started with AX=4B04h;
	  use AH=8Ah instead
	the following sequence will close a Virtual DOS Machine under OS/2 2.0
	  through OS/2 Merlin (but may change in the future):
	    MOV	AH,4Dh
	    INT	21h
	    HLT
	    DB	02h,0FDh
	  This sequence is the only way to close a specific VDM which was
	  booted from floppy or a disk image.
SeeAlso: AH=4Bh,AH=4Ch,AH=8Ah




INT 21 - DOS 2+ - GET FREE DISK SPACE
	AH = 36h
	DL = drive number (00h = default, 01h = A:, etc)
Return: AX = FFFFh if invalid drive
	else
	    AX = sectors per cluster
	    BX = number of free clusters
	    CX = bytes per sector
	    DX = total clusters on drive
Notes:	free space on drive in bytes is AX * BX * CX
	total space on drive in bytes is AX * CX * DX
	"lost clusters" are considered to be in use
	according to Dave Williams' MS-DOS reference, the value in DX is
	  incorrect for non-default drives after ASSIGN is run
	this function does not return proper results on CD-ROMs;
	  use AX=4402h"CD-ROM" instead
	(FAT32 drive) the reported total and free space are limited to 2G-32K
	  should they exceed that value
SeeAlso: AH=1Bh,AH=1Ch,AX=4402h"CD-ROM",AX=7303h
