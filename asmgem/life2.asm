;**************************** LIFE.ASM -- Life simulation
; Suitable for MASM.  Use the command: ml /AT lifesmll.asm
;
; This is a tiny program to play John Conway's "LIFE" written by Tenie Remmel.
; Adapted for MASM by Paul Hsieh
;
.386

code segment USE16 'code'
            mov ax,13h              ;Set mode 13h
            int 10h

            push 0                  ;ES = 0
            pop es
            mov eax,[es:046Ch]      ;Seed RNG
            mov [RandNum],eax
                                    
            mov ax,cs               ;DS, ES = virtual video
            add ax,1000h
            mov ds,ax
            mov es,ax

            xor di,di               ;Zero DI
            mov cx,32768            ;32K dwords
            xor ax,ax               ;Clear memory
            rep stosw

            mov di,320              ;DI = 320
            mov cx,64000            ;64000 bytes

RandLoop:   call Rand               ;Get random number
            imul ax,0Fh             ;Scale it
            stosb                   ;Store byte
            loop RandLoop           ;Loop back

            push 0A000h             ;ES = video memory
            pop es

MainLoop:   mov si,320              ;Display this frame
            xor di,di
            mov cx,16000
            rep movsd

            mov di,321              ;Set up for LifeLoop
            mov cx,200              ;Make a border...

LifeOLoop:  mov dx,318
LifeLoop:   mov ax,-1               ;Get boundary count
            mov bl,[di-1]
            mov bh,[di+1]
            sub ax,bx
            mov bl,[di-319]
            mov bh,[di+321]
            sub ax,bx
            mov bx,[di-321]
            sub ax,bx
            mov bx,[di+319]
            sub ax,bx
            add al,ah
            and al,0Fh

            cmp al,1                ;2 = stay, 3 = birth
            jl LifeStay             ;any other = death
            jg LifeLB               ;actual value is 2 less

            or byte ptr [di],10h        ;Birth: add 10h
            jmp LifeLB

LifeStay:   mov al,[di]             ;Stay: add 10h if it's on
            add al,al
            or [di],al

LifeLB:     inc di                  ;Loop back -- pixel loop
            dec dx
            jnz LifeLoop
            inc di                  ;Loop back -- row loop
            inc di
            loop LifeOLoop

            mov di,320              ;Set up for CleanLoop
            mov cx,64000

CleanLoop:  mov al,[di]             ;Get pixel
            shr al,4                ;10h, 1Fh -> 0Fh
            jz $+4                  ;00h, 0Fh -> 00h
            mov al,0Fh
            mov [di],al             ;Set pixel

            inc di                  ;Loop back
            dec cx
            jnz CleanLoop

            mov ah,1                ;Check for key
            int 16h
            jz MainLoop             ;Loop if no key

            mov ax,3                ;Set text mode
            int 10h

            ret                     ;Return


;**************************** Rand -- Generate random number 0 or 1

Rand:

            imul eax,[cs:RandNum],015A4E35h
            inc eax
            mov [cs:RandNum],eax
            xchg dx,ax
            ror eax,16
            xor ax,dx
            ror ax,11
            and ax,1
            ret

RandNum     dd ?                   ;Random number

code ends

End
