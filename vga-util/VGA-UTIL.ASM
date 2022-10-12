; VGA read file util.
; Util to read in raw binary files and display as VGA 320x200 screen.
; When screen is loaded (64k), hit any key to go on to next screen.
; started: 17/09/03. DJM.
; finished: 18/09/03.   2186 bytes.

        .386
        IDEAL
        MODEL   small
        STACK   256
cr      EQU     13              ; ASCII carriage return
lf      EQU     10              ; ASCII line feed
        DATASEG
exCode          DB      0
x               dw      0
y               dw      0
inFile          DW      0       ; Input file handle
outFile         DW      0       ; Output file handle
oneByte         Dw      0       ; Byte I/O variable
prompt          DB      cr,lf,'Erase this file? (y/n) ', 0
diskFull        DB      cr,lf,'**ERROR: Disk is full', 0
notes   DB      cr,lf,'VGA-Util.',cr,lf
        DB      cr,lf,'Displays file as a VGA screen.'
        DB      cr,lf,'When screen is full, hit any key to show next screen.'
        DB      cr,lf,'VGA-UTIL <input file>',cr,lf, 0

        CODESEG
        EXTRN StrWrite:Proc, NewLine:Proc
        EXTRN DiskErr:Proc
        EXTRN GetParams:Proc, ParamCount:Proc, GetOneParam:Proc
Start:  mov     ax, @data               ; Set ax to data segment
        mov     es, ax                  ; Set es to data segment
        call    GetParams               ; Get parameters with ds = PSP
        call    ParamCount              ; Get number of parameters (dx)
        cmp     dx, 1                   ; Does count = 1?
        je      @@10                    ; Continue if param count = 1
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
@@vga:  mov     dx, 0a000h
        mov     es, dx
@@vga2: xor     di, di
        mov     ax, 13h
        int     10h
        
@@50:   mov     ah, 3Fh                 ; DOS Read-file function
        mov     bx, [inFile]            ; Set bx to input file handle
        mov     cx, 2                   ; Specify one byte to read
        mov     dx, offset oneByte      ; Address variable with ds:dx
        int     21h                     ; Call DOS to read from file
        jnc     @@60                    ; Jump if no error detected
        jmp     Errors                  ; Else jump to error handler
@@60:   or      ax, ax                  ; Check for end of input file
        jz      @@80                    ; ax=0=end of file; jump

@@61:   mov     si, offset oneByte
        mov     ax, [si]

        stosw
        cmp     di, 0fffeh
        jne     @@50
        xor     ax, ax
        int     16h
        jmp     @@vga2
;---------------------------------------------------------------------------
@@Continue:
@@80:
        xor     ax, ax          ;complete screen filled. [PAUSE]
        int     16h
        mov     ax, 3
        int     10h

        mov     bx, [inFile]            ; Get input file handle
        mov     ah, 3Eh                 ; DOS Close-file function
        int     21h                     ; Close input file
        jnc     Exit                    ; Exit if no errors detected
        jmp     Errors                  ; Else jump to error handler
Exit:
        mov     ah, 04Ch                ; DOS function: Exit program
        mov     al, [exCode]            ; Return exit code value
        int     21h                     ; Call DOS. Terminate program

Errors:
        mov     [exCode], al            ; Save error code
        call    DiskErr                 ; Display error message
        jmp     Exit                    ; Exit program

        END     Start        ; End of program / entry point
