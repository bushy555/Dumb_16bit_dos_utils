; Stripper 37 - html addition for web site delivery.
; Reads CSV in and outputs HTML formatted
;
; djm, 02/07/04
; djm, 18/5/7.  Added 'Bodies'.
;
;
;
;Reads in CSV
;
;Fri 11/05/2007	,8533	,1196	,0	,207065  <BR>
;Sat 12/05/2007	,0	,1	,0	,0  <BR>
;Sun 13/05/2007	,0	,1 	,0	,0	<BR>
;Mon 14/05/2007	,8349	,1198	,0	,196043  <BR>
;Tue 15/05/2007	,9623	,1164	,0	,194790  <BR>
;Wed 16/05/2007	,8630	,1228	,0	,211374  <BR>
;Thu 17/05/2007	,8689	,1105	,0	,191631  <BR>
;
;
;
;
;Outputs HTML:
;
;<HTML>
;<HEAD>
;<TITLE>Current production</TITLE>
;<META name="description" content="">
;<META name="keywords" content="">
;</HEAD>
;<H3>
;<TABLE BORDER CELLSPACING=1 CELLPADDING=7 WIDTH=445>
; <TR>
;    <TD WIDTH="32%" VALIGN="TOP" HEIGHT=38>   <PRE>    Date         </PRE> </TD>
;    <TD WIDTH="19%" VALIGN="TOP" HEIGHT=38>   <PRE>    Cartons      </PRE> </TD>
;    <TD WIDTH="22%" VALIGN="TOP" HEIGHT=38>   <PRE>    Sides        </PRE> </TD>
;    <TD WIDTH="22%" VALIGN="TOP" HEIGHT=38>   <PRE>    Bodies       </PRE> </TD>
;    <TD WIDTH="27%" VALIGN="TOP" HEIGHT=38>   <PRE>    Kill weight  </PRE> </TD>
;  </TR>
;
;
;
        IDEAL
        MODEL   small
        STACK   256

cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed
;_double_comma	EQU	16		; gives single end comma
_double_comma	EQU	17		; gives double end comma. DIRTY HACK!
ASCnull         EQU     0               ; ASCII null character

        DATASEG
hitenter	db	13,10,0
exCode          DB      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         Db      0       ; Byte I/O variable
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   	DB      cr,lf,'STRIP 37 djm,  6/12/6.'
        	DB      cr,lf,'For HTML adding on to kill for web site delivery.'
        	DB      cr,lf,'strip37 <input file> <output file>',cr,lf, 0
crlf		db    	0dh,0ah,0
tab		db	09,0



;------------------------------------
m01		db '<HTML>',0dh,0ah
m02		db '<HEAD>',0dh,0ah
m03		db '<TITLE>Current production</TITLE>',0dh,0ah
m04		db '<META name="description" content="">',0dh,0ah
m05		db '<META name="keywords" content="">',0dh,0ah
m06		db '</HEAD>',0dh,0ah
m07		db '<H3>',0dh,0ah,0dh,0ah
m1		db '<TABLE BORDER CELLSPACING=1 CELLPADDING=7 WIDTH=445>',0dh,0ah
m2		db ' <TR>',0dh,0ah
m3		db '    <TD WIDTH="32%" VALIGN="TOP" HEIGHT=38>   <PRE>    Date         </PRE> </TD>',0dh,0ah
m4		db '    <TD WIDTH="19%" VALIGN="TOP" HEIGHT=38>   <PRE>    Cartons      </PRE> </TD>',0dh,0ah
m5		db '    <TD WIDTH="22%" VALIGN="TOP" HEIGHT=38>   <PRE>    Sides        </PRE> </TD>',0dh,0ah

m51		db '    <TD WIDTH="22%" VALIGN="TOP" HEIGHT=38>   <PRE>    Bodies        </PRE> </TD>',0dh,0ah

m6		db '    <TD WIDTH="27%" VALIGN="TOP" HEIGHT=38>   <PRE>    Kill weight  </PRE> </TD>',0dh,0ah
m7		db '  </TR>',0dh,0ah,0
;------------------------------------
m71		db ' <TR>',0dh,0ah,0								; 7
m8		db '   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=38> ',0dh,0ah,0			; 43
m9		db ' </TD>',0dh,0ah,0								; 6
m10		db '  </TR>',0dh,0ah,'</TABLE>',0dh,0ah,0					; 19
m11		db '  </TR>',0dh,0ah,'</TABLE>',0dh,0ah,'</BODY>',0dh,0ah,'</HTML>',0dh,0ah,0	; 37



	        CODESEG

        EXTRN StrLength:proc, StrUpper:proc
	        EXTRN StrWrite:Proc, NewLine:Proc
	        EXTRN DiskErr:Proc
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
@@30:   mov     cx, 1                   ; Specify parameter number 1
        call    GetOneParam             ; Get address of parameter string
        mov     dx, di                  ; Address file name with ds:dx
        xor     cx, cx                  ; Specify normal attributes
        mov     ah, 3Ch                 ; DOS Create-file function
        int     21h                     ; Create the output file
        jnc     @@40                    ; Continue if no error
        jmp     Errors                  ; Else jump to error handler
@@40:   mov     [outFile], ax           ; Save output file handle



;--------------------------------------------------
;HEADER
;--------------------------------------------------

;<TABLE BORDER CELLSPACING=1 CELLPADDING=7 WIDTH=445>
; <TR>
;    <TD WIDTH="32%" VALIGN="TOP" HEIGHT=38>   <PRE>    Date         </PRE> </TD>
;    <TD WIDTH="19%" VALIGN="TOP" HEIGHT=38>   <PRE>    Cartons      </PRE> </TD>
;    <TD WIDTH="22%" VALIGN="TOP" HEIGHT=38>   <PRE>    Sides        </PRE> </TD>
;    <TD WIDTH="22%" VALIGN="TOP" HEIGHT=38>   <PRE>    Bodies       </PRE> </TD>
;    <TD WIDTH="27%" VALIGN="TOP" HEIGHT=38>   <PRE>    Kill weight  </PRE> </TD>
;  </TR>

        mov     ah, 40h                
        mov     bx, [outFile]          
        mov     cx, 539+81 ;600 ;615                
        mov     dx, offset m01
        int     21h           
;--------------------------------------------------
;<TR>
;--------------------------------------------------
@@45:   mov     ah, 40h                	
        mov     bx, [outFile]      
        mov     cx, 7
        mov     dx, offset m71
        int     21h           
;--------------------------------------------------
;FIRST LINE
;--------------------------------------------------
        mov     ah, 40h                		;   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>    
        mov     bx, [outFile]          
        mov     cx, 43
        mov     dx, offset m8
        int     21h           
@@_50:	call	readbyte			; write out day and date.
	cmp	al, ','
	je	@@_51
	call	writebyte
	jmp	@@_50
@@_51:  mov     ah, 40h                		; write out </td>
        mov     bx, [outFile]          
        mov     cx, 8   
        mov     dx, offset m9
        int     21h           
;--------------------------------------------------
;SECOND LINE
;--------------------------------------------------
        mov     ah, 40h                		;   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>    
        mov     bx, [outFile]          
        mov     cx, 43
        mov     dx, offset m8
        int     21h           
@@_52:	call	readbyte			; write out day and date.
	cmp	al, ','
	je	@@_53
	call	writebyte
	jmp	@@_52
@@_53:  mov     ah, 40h                		; write out </td>
        mov     bx, [outFile]          
        mov     cx, 8   
        mov     dx, offset m9
        int     21h           

;--------------------------------------------------
;THIRD LINE
;--------------------------------------------------
        mov     ah, 40h                		;   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>    
        mov     bx, [outFile]          
        mov     cx, 43
        mov     dx, offset m8
        int     21h           
@@_54:	call	readbyte			; write out day and date.
	cmp	al, ','
	je	@@_55
	call	writebyte
	jmp	@@_54
@@_55:  mov     ah, 40h                		; write out </td>
        mov     bx, [outFile]          
        mov     cx, 8   
        mov     dx, offset m9
        int     21h           

;--------------------------------------------------
;Fourth LINE   						;Write out Bodies - added 18/5/7
;--------------------------------------------------
        mov     ah, 40h                		;   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>    
        mov     bx, [outFile]          
        mov     cx, 43
        mov     dx, offset m8
        int     21h           
@@_542:	call	readbyte			; write out day and date.
	cmp	al, ','
	je	@@_552
	call	writebyte
	jmp	@@_542
@@_552: mov     ah, 40h                		; write out </td>
        mov     bx, [outFile]          
        mov     cx, 8   
        mov     dx, offset m9
        int     21h           

;--------------------------------------------------
;FIFTH LINE
;--------------------------------------------------
        mov     ah, 40h                		;   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>    
        mov     bx, [outFile]          
        mov     cx, 43
        mov     dx, offset m8
        int     21h           

@@_56:	call	readbyte			; write out day and date.
	cmp	al, '<'
	je	@@_57
	call	writebyte
	jmp	@@_56
@@_57:  mov     ah, 40h                		; write out </td>
        mov     bx, [outFile]          
        mov     cx, 8   
        mov     dx, offset m9
        int     21h           

@@_58:	call	readbyte			; read in to get rid of <BR><cr><LF>
	cmp	al, 0ah
	jne	@@_58
        

;Mon 27/11/2006	,8365	,1211	999,	,212680  <BR>
;Tue 28/11/2006	,9246	,1192	999,	,189162  <BR>
;Wed 29/11/2006	,7608	,1203	999,	,208643  <BR>
;Thu 30/11/2006	,8316	,1214	999,	,218674  <BR>
;Fri 01/12/2006	,8860	,1252	999,	,217610  <BR>
;Sat 02/12/2006	,9301	,1252	999,	,142554  <BR>
;Sun 03/12/2006	,5422	,1130	999,	,215712  <BR>
;Mon 04/12/2006	,10326	,1232	999,	,208529  <BR>
;Tue 05/12/2006	,8459	,1216	999,	,210771  <BR>
;Wed 06/12/2006	,138	,40	999,	,8353  <BR>
;
;06/12/2006 08:25 . : Cartons: 1615 , Sides: 241 , Bodies: 999 , Weight: 49883
;
; <TR>
;   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>    Mon 27/11/2006 </TD>
;   <TD WIDTH="19%" VALIGN="TOP" HEIGHT=382>    8365 </TD>
;   <TD WIDTH="22%" VALIGN="TOP" HEIGHT=382>    1211 </TD>
;   <TD WIDTH="27%" VALIGN="TOP" HEIGHT=382>   212680  </TD> 
; </TR>
;</TABLE>
;

;m71		db ' <TR>',0dh,0ah,0								; 7
;m8		db ' <TR>',0dh,0ah,'   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>',0dh,0ah,0	;52
;m9		db ' </TD>',0dh,0ah,0								;6
;m10		db '   <TD WIDTH="19%" VALIGN="TOP" HEIGHT=382> ',0dh,0ah,0   			;52
;m11		db '  </TR>',0dh,0ah,'</TABLE>'0dh,0ah,0  					;21



	jmp	@@45


PROC 	writebyte

	mov     di, offset oneByte
	mov	[di], al
        mov     ah, 40h                 ; DOS Write-file function
        mov     bx, [outFile]           ; Set bx to output file handle
        mov     cx, 1                   ; Specify one byte to write
        mov     dx, offset onebyte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to write to file
	ret
ENDP	writebyte


Errors: mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program
PROC    FileExists
        xor     al, al          ; Specify read-only access
        mov     ah, 3Dh         ; DOS Open-file function
        int     21h             ; Call DOS to open the file
        jc      @@99            ; Exit--file doesn't exist
        mov     bx, ax          ; Copy handle to bx
        mov     ah, 3Eh         ; DOS Close-file function
        int     21h             ; Close the file
        clc                     ; Clear carry flag (file exists)
@@99:   ret                             ; Return to caller
ENDP    FileExists

PROC 	readbyte
	mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 1                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
  	or      ax, ax                  ; Check for end of input file
        je     @@80                    ; ax=0=end of file; jump

	mov     di, offset oneByte
	mov	al, [di]
	ret

@Close:
@@80: 

;--------------------------------------------------
;</TR></TABLE>;</BODY>,</HTML>
;--------------------------------------------------
        mov     ah, 40h                		;   <TD WIDTH="32%" VALIGN="TOP" HEIGHT=382>    
        mov     bx, [outFile]          
        mov     cx, 19
        mov     dx, offset m10
        int     21h   


	mov     bx, [inFile]            ; Get input file handle
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

ENDP	readbyte


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
@@20:   cmp     al, '@'                 ; Reset zero flag (zf=0)
@@99:   ret                             ; Return to caller
ENDP    Confirm

END     Start        ; End of program / entry point
