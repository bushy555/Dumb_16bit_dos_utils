;
; vz dumper. djm. v3. 3/mar/2k9.
; dumps vz .DSK to an output text file. 
; Quick and dirty!
;
; VZDSKDUMP <in.dsk> <out.txt>
; VZDSKDUMP GAMES.DSK GAMES_DISK3.TXT
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; INFO:
; VZ directory occupies Track 0, Sector 0 through to the end of sector 14.
; Sector 0, Track 15 contains pointers to something. forget.
; ....meaning that the directory size is 1920 bytes, and can contain a maximum of 112 filenames per side of a disk.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  File type 1 byte
;  Delimitor (3AH) 1 byte
;  File name 8 byte
;  Start address 2 byte
;  End address 2 byte
;  Start track 1 byte
;  Start sector 1 byte
;

        IDEAL
        MODEL   small
        STACK   256
cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed
        DATASEG
_crlf		db	13,10,0
_del2		db	'?',0
_spaces		db	'    ',0
_spaces2	db	' ',0
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         Db      0,0,0,0,0,0,0,0       ; Byte I/O variable
s_address	db	0,0
e_address	db	0
s_track		db	0
e_track		db	0,0

tempbyte	db	0,0
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
notes   	DB      cr,lf,'VZ disk dumper. v3.0. By dave. Junkware. 3/mar/9.'
      	  	DB      cr,lf,'Dumps the directory of a VZ .DSK file to a text file.'
      	  	DB      cr,lf,'Is !rough! with very little error checking',cr,lf
        	DB      cr,lf,'VZDSKDUMP <in.dsk> <out.txt>',cr,lf
	        DB      cr,lf,'ie:  VZDSKDUMP GAMES.DSK GAMES.TXT',cr,lf,0


        CODESEG
        EXTRN StrWrite:Proc, NewLine:Proc			; external libraries.
        EXTRN DiskErr:Proc					; find 'TOM SWAM' asm libraries...
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc
Start:  mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 2                   ; Does count = 2?
        je      @@10                    ; Continue if param count = 2
        mov     di, offset notes        ; Address text with di
        call    StrWrite                ; Display notes
        jmp     Exit                    ; Exit program

@@10:   xor     cx, cx                  ; Specify parameter number 0
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     al, al                  ; Specify read-only access
        mov     ah, 3Dh                 ; DOS Open-file function
        int     21h                     ; Open the input file
        jnc     @@20                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler

@@20:   mov     [inFile], ax            ; Save input file handle
        mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        call    FileExists              ; Does output file exist?
        jc      @@30                    ; Jump if file does not exist
        call    StrWrite                ; Display file name
        call    Confirm                 ; Else confirm file removal
        je      @@30                    ; Continue if permission given
        jmp     Exit                    ; Else exit program

@@30:   mov     cx, 1                   
        call    GetOneParam             
        mov     dx, di                  
        xor     cx, cx                  
        mov     ah, 3Ch                 
        int     21h                     
        jnc     @@40                    
        jmp     Errors                  
@@40:   mov     [outFile], ax           
	xor	bp, bp

nop
nop
nop
nop
nop
nop


@@50:   inc	bp
	cmp	bp, 1920		; done reading first 1920 bytes (size of directory of VZ disk)
	jl	@@51
	jmp	@@80			; so now go bye bye and exit.			
@@51:	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            
        mov     cx, 1                   
        mov     dx, offset oneByte      
        int     21h                    
        jnc     @@60                   
        jmp     Errors                 

;--------------------------------------------------------------------------
@@60:   

	inc	bp
	cmp	bp, 1920		; done reading first 1920 bytes (size of directory of VZ disk)
	jl	@@601
	jmp	@@80			; so now go bye bye and exit.			

@@601:	mov     di, offset oneByte	; READ char. 
	mov	al, [di]
	mov	di, offset tempbyte
	mov	[di], al

@@71:  	mov     ah, 3Fh                 ; READ char. 
        mov     bx, [inFile]             
        mov     cx, 1                    
        mov     dx, offset oneByte       
        int     21h                      
        jnc     @@72                     
        jmp     Errors                   

@@72:	mov     di, offset oneByte	; Is it ':'?
	mov	al, [di]
	cmp	al, 03ah
	je	@@73
	jmp	@@60

@@73:	mov	di, offset tempbyte
	mov	al, [di]
	cmp	al, 01h			; Is filetype a deleted entry 0x01h?
	jne	@@730
	
	mov     ah, 40h                 ; THEN write filetype of new deleted filetype, '?'
        mov     bx, [outFile]            
        mov     cx, 1                   
        mov     dx, offset _del2
        int     21h                    
        jnc     @@731                  
        jmp     Errors                 

@@730:	mov     ah, 40h                 ; ELSE write filetype
        mov     bx, [outFile]            
        mov     cx, 1                   
        mov     dx, offset tempbyte    
        int     21h                    
        jnc     @@731                  
        jmp     Errors                 

	
@@731:	mov     ah, 40h                 ; write ':'
        mov     bx, [outFile]           
        mov     cx, 1  
        mov     dx, offset onebyte      
        int     21h                     
        jnc     @@74                    
        jmp     Errors                  

@@74:   add	bp, 13
	mov     ah, 3Fh                 ; read 8 char filename, 2x S-add, 1x E-add, 1x S-track, 1x S-sector.
        mov     bx, [inFile]            
        mov     cx, 13	;8     
        mov     dx, offset oneByte      
        int     21h                     
        jnc     @@75                    
        jmp     Errors                  
@@75:   mov     ah, 40h                 ; write 8 char filename
        mov     bx, [outFile]           
        mov     cx, 8                   
        mov     dx, offset onebyte      
        int     21h                     
        jnc     @@76                    
        jmp     Errors                  
@@76:	mov     ah, 40h                 ; write 4 spaces
        mov     bx, [outFile]           
        mov     cx, 4
        mov     dx, offset _spaces
        int     21h                     
        jnc     @@77                    
        jmp     Errors                  

@@77:	mov	di, offset s_address
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset s_address + 1
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset e_address
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset s_track
	mov	al, [di]
	or	al, 30h
	mov	[di], al
	mov	di, offset e_track
	mov	al, [di]
	or	al, 30h
	mov	[di], al


	mov     ah, 40h                 ; write 2 char Start Address
        mov     bx, [outFile]           
        mov     cx, 2
        mov     dx, offset s_address
        int     21h                     
        jnc     @@771    
        jmp     Errors                  


@@771:	

	mov     ah, 40h                 ; write 1 spaces
        mov     bx, [outFile]           
        mov     cx, 1
        mov     dx, offset _spaces2
        int     21h                     
        jnc     @@7710
        jmp     Errors                  

@@7710:	mov     ah, 40h                 ; write 1 char end Address
        mov     bx, [outFile]           
        mov     cx, 1
        mov     dx, offset e_address
        int     21h                     
        jnc     @@7720
        jmp     Errors                  

@@7720:	mov     ah, 40h                 ; write 1 spaces
        mov     bx, [outFile]           
        mov     cx, 1
        mov     dx, offset _spaces2
        int     21h                     
        jnc     @@772
        jmp     Errors                  


@@772:	mov     ah, 40h                 ; write 1 char Start track
        mov     bx, [outFile]           
        mov     cx, 1
        mov     dx, offset s_track
        int     21h                     
        jnc     @@7730
        jmp     Errors                  

@@7730:	mov     ah, 40h                 ; write 1 spaces
        mov     bx, [outFile]           
        mov     cx, 1
        mov     dx, offset _spaces2
        int     21h                     
        jnc     @@773
        jmp     Errors                  

@@773:	mov     ah, 40h                 ; write 1 char end track
        mov     bx, [outFile]           
        mov     cx, 1
        mov     dx, offset e_track
        int     21h                     
        jnc     @@78 
        jmp     Errors                  


@@78:  	mov     ah, 40h                 ; Write <CR><LF>
        mov     bx, [outFile]            
        mov     cx, 2          
        mov     dx, offset _crlf 
        int     21h                     
        jnc     @@79
        jmp     Errors                  
@@79:	jmp	@@50


@@80:   mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        mov     bx, [outFile]           ; Get output file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close output file
        jnc     Exit                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit:   mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program
Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

; Input:
;       ds:dx = address of ASCIIZ file name
; Output:
;       cf = 0 (jnc) = File of this name exists
;       cf = 1 (jc)  = File of this name does not exist
; Registers: ax, bx
;---------------------------------------------------------------
PROC    FileExists
        xor     al, al          ; Specify read-only access
        mov     ah, 3Dh         ; DOS Open-file function
        int     21h             ; Call DOS to open the file
        jc      @@99            ; Exit--file doesn't exist
        mov     bx, ax          ; Copy handle to bx
        mov     ah, 3Eh         ; DOS Close-file function
        int     21h             ; Close the file
        clc                     ; Clear carry flag (file exists)
@@99:
        ret                             ; Return to caller
ENDP    FileExists
%NEWPAGE
;---------------------------------------------------------------
; Confirm               Get Yes/No confirmation from user
;---------------------------------------------------------------
; Input:
;       none
; Output:
;       zf = 0 (jnz) = user typed N or n
;       zf = 1 (jz)  = user typed Y or y
; Registers: ax, cx, di
;---------------------------------------------------------------
PROC    Confirm
        mov     di, offset Prompt       ; Address prompt string
        call    StrWrite                ; Display message
        mov     ah, 1                   ; DOS GetChar function
        int     21h                     ; Get user response
        cmp     al, 'Y'                 ; Compare with Y
        je      @@99                    ; Exit if char = Y
        cmp     al, 'y'                 ; Compare with y
        je      @@99                    ; Exit if char = y
        cmp     al, 'N'                 ; Compare with N
        je      @@20                    ; Handle No response
        cmp     al, 'n'                 ; Compare with n
        jne     Confirm                 ; Repeat if not Y, y, N, n
@@20:
        cmp     al, '@'                 ; Reset zero flag (zf=0)
@@99:   
        ret                             ; Return to caller
ENDP    Confirm

        END     Start        ; End of program / entry point
