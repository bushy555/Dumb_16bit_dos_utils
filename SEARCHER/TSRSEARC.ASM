;************************
PAGE 55,132             ;Format .LST listing at 55 lines by 132 columns.
TITLE TSRBONES Version 0.1 Jan 20 91 Robert Curtis Davis
SUBTTL Introduction
;**************************************************************************
;
;       TSRBONES.ASM     Version 0.1     Jan 20 91
;       A part of the TBONES software package.
;
;       Copyright (C) 1990, 1991 by Robert Curtis Davis,
;	All Rights Reserved.
;
;	DESCRIPTION:
;	ASM Program template for Terminate-and-Stay-Resident (TSR) programs
;		that are activated by a specified HotKey WHEN DOS IS NOT
;               BUSY (the InDOS Flag AND the DOS Critical Error Flag are zero)
;               flag), OR WHEN DOS IS AT "BUSY IDLE" (when INT28h is called),
;               AND WHEN NO HARDWARE INTERRUPT IRQ0-IRQ7 IS BEING HANDLED.
;               This avoids problems of interfering with hardware interrupt
;               handling and with DOS non-reentrancy; and allows DOS function
;               calls above 0Ch to be used in the TSR routine. The TSR's code
;               prevents multiple installations. Also checks DOS version and
;               requires DOS Version 2 or later before installation is
;               permitted.
;
;	PURPOSE:
;	Provides a skeletal framework program as a starting point in the 
;       design of your own HotKey TSRs which use DOS function calls, and
;       for which a single installation is desired.
;
;                   E-mail address:
;			  Internet: sonny@trantor.harris-atd.com
;
;                  US Mail address:
;                                   430 Bahama Drive
;                                   Indialantic, FL 32903
;
;**************************************************************************
;
; Special thanks to Roy Silvernail, whose persistent hacking (in the best
; sense of that word) and E-mail exchanges over the holiday season in
; December 1990, rooted out TBONES incompatibilities with Borland's TASM v.1.0.
;
;**************************************************************************
;
; Special thanks to Anto Prijosoesilo and Richard Brittain for E-mail
; exchanges which helped solve detailed problems with the implementation of
; the "Pseudo-Environment" idea.
;
;**************************************************************************
;
; Special thanks to David Kirschbaum, whose Toad Hall Tweaks significantly
; improved an early version of the TBONES Assembly Language code:
;
;v0.01	Toad Hall Tweak, 25 Nov 90
;**************************************************************************
SUBTTL Code Segment
PAGE
;**************************************************************************
;
CodeSeg		segment
		assume cs:CodeSeg,ds:CodeSeg
BeginDump	EQU	$		;Roy Silvernail - Keep TASM 1.0 happy
					;when computing # resident paragraphs.
;
		org	2CH		;v0.01 ORG in PSP to pick up the
envseg		label	word		;v0.01 Environment Segment.
;
		org	100h		;ORG for all COM programs.
;
Entry		PROC	NEAR		;v0.01
		jmp	TSRinit		;Jump over resident portion and
					;initialize things and make code
					;between Entry: and TSRinit: resident.

;
; Old Interrupt Vectors are stored here during TSR initialization:
oldint09        dd      ?               ;Keyboard Hardware Interrupt.
oldint13        dd      ?               ;Disk BIOS Interrupt.
oldint16        dd      ?               ;Keyboard BIOS Interrupt.
oldint28        dd      ?               ;DOS Idle Interrupt.
;
; For this HotKey TSR Template, specify Keyboard Interrupt 09h as the Hook:
HOOK09		equ	09h			;Hooked Interrupt 09h.
; Int 13h is used to set a flag to prevent TSR trigger while disk active:
HOOK13          equ     13h                     ;Hooked Interrupt 13h.
; Int 16h is hooked solely to provide way to check for prior TSR installation.
HOOK16		equ	16h			;Hooked Interrupt 16h.
; We also have to hook Interrupt 28h to check for "DOS idle":
HOOK28		equ	28h			;Hooked Interrupt 28h.
;
bellgate	db	0	;Gate closed (=1) when in Bell routine.
				;Gate open (=0) when not in Bell routine.
; Below:
; EQUates related to the Intel 8259A Programmable Interrupt Controller (PIC)
;	chip. Hardware Interrupts IRQ0 through IRQ7 are controlled by the PIC.
;
;	To really understand the nitty-gritty details of this stuff, 
;	you have to study the Intel Specification data for the 8259A PIC chip.
;	These EQUates are used in this TSR to examine the PIC chip's In Service
;	Register (ISR) to be sure that the TSR is not interrupting one of
;	the hardware interrupt service routines. The reason for not wanting to 
;	interrupt these hardware interrupt service routines is that they are
;	often time-critical and can be compromised by intruding on them with
;	our TSR (for example, a hardware COM port interrupt-driven comm 
;	program might lose bytes on a modem transfer if we bull our way in and
;	steal the CPU away from the comm program's service routine):
PICPORT		EQU	20h		;I/O Port for the 8259A PIC chip.
ISRREQ		EQU	00001011B	;This is a byte defining the
					;Operation Control Word 3 (OCW3) to
					;output on port 20h to make the PIC
					;chip's In Service Register available 
					;for reading by the CPU on the
					;next IN 20h command.
;
; EQUs defining Key Flag weights in the Key Flag Byte:
RSHIFT		equ	00000001B		;Right Shift Key Flag weight.
LSHIFT		equ	00000010B		;Left Shift  Key Flag weight.
CTRL		equ	00000100B		;Ctrl        Key Flag weight.
ALT		equ	00001000B		;Alt         Key Flag weight.
;SCROLL          equ     00010000B               ;Scroll Lock Key Flag weight.
;NUM             equ     00100000B               ;Num Lock    Key Flag weight.
;CAPS            equ     01000000B               ;Caps Lock   Key Flag weight.
INSRT		equ	10000000B		;Ins         Key Flag weight.
;
LockKeyMask     equ     10001111B               ;For masking out Scroll, Caps,
                                                ;and Num Lock bits in KeyFlags.
;
; Pointer to "DOS busy" (InDOS) flag (loaded during TSR initialization):
indosptr	dd	?
;
; Pointer to "Critical Error" (CritErr) flag (loaded at TSR initialization):
criterrptr	dd	?
;
; Pointer to "Print Screen" busy (PrtScrn) flag
prtscrn         dd      00500000h
;
; hotkeyflag used to signal HotKey pressed to "DOS idle" Interrupt 28h:
hotkeyflag      db      0       ;hotkeyflag initially zero.
;
; diskflag used to prevent TSR trigger during time-critical Disk operations:
diskflag        db      0       ;diskflag initially zero.
;*************************************************************************
;	Your HotKey is specified here:
;       (This sample HotKey is set for Ctrl-Alt-B)
;
; Specify TSR's HotKey Shift Keys:
KEYFLAGBYTE     equ    CTRL+ ALT                ;HotKey Flags
;
; Specify TSR's HotKey Scan Code:
HOTKEY          equ     1fh                     ;'B' (for Bones) key

;
;*************************************************************************
; Specify TSR's signature words:
TSRsigA         equ     'SE'            ;'TSRBONES' Signature
TSRsigB         equ     'AR'
TSRsigC         equ     'CH'
TSRsigD         equ     'ER'
;*************************************************************************
Entry	ENDP		;v0.01
;
;*************************************************************************
SUBTTL User-supplied TSR Routine
PAGE
;*************************************************************************
ROUTINE         PROC    NEAR
;*************************************************************************
;	Code for your HotKey-triggered TSR routine  GOES HERE:
;	( Here, a dummy routine has been placed which simply rings the
;	  terminal Bell whenever the TSR is triggered. )
;
;	Announce this dummy TSR's trigger by a Bell signal:
;
Enter:
                mov     al,07h          ;al = ASCII Bell.
                mov     bh,0            ;Video page.
                mov     cx,1            ;No. of bytes to write.
                mov     ah,0Eh          ;BIOS Int10,OEh=TTY Screen.
                Int     10h             ;Write ASCII Bell to screen.


tsrbegin:	mov	ax, 0b800h
	mov	ds, ax
	mov	es, ax
	xor	si, si
	xor	di, di

	mov	cx, 07d0h
loop0:	lodsw
	cmp	al, 219
	je 	jmptmp
	cmp	al, 020h
	jne	jmp01
jmptmp:	mov	ax, 006dbh
	jmp	jmp0
jmp01:	mov	ah, 007
jmp0:	stosw
	loop	loop0

tsrkey:	xor	si, si
	xor	di, di
	xor	ax, ax
	int	16h
	cmp	al, 027
	je	tsrquit
	cmp	al, 043
	je	increase
	cmp	al, 045
	je	decrease
	jmp	tsrkey
tsrquit:
	mov	cx, 07d0h
loop00:	lodsw
	cmp	al, 0219
	jne	jmp00
	mov	ax, 00720h
jmp00:	stosw
	loop	loop00

	jmp	exit

increase:
	mov	cx, 07d0h
loop1:	lodsw
	cmp	al, 255
	jne	jmp10
	mov	al, 0
jmp10:	cmp	ah, 006
	je	jmp11
jmp1:	inc	ax
jmp11:	stosw
	loop	loop1
	jmp	tsrkey

decrease:
	mov	cx, 07d0h
loop2:	lodsw
	cmp	al, 000
	jne	jmp20
	mov	al, 255
jmp20:	cmp	ah, 006
	je	jmp21
jmp2:	dec	ax
jmp21:	stosw
	loop	loop2
	jmp	tsrkey

;
Exit:
                ret                     ;Return from TSR routine.
;
ROUTINE         endp
;
;	End of your HotKeyed TSR routine.
;***************************************************************************
SUBTTL Hooked Interrupts
PAGE
;***************************************************************************
;
NewInt09	PROC	FAR		;v0.01
;
; The following three instructions often are said to "simulate an interrupt"
; that calls the PRIOR interrupt handler routine and then the prior interrupt
; handler's IRET instruction pops the flags and returns here to the point
; after the following CALL instruction.
;    The reason for "simulating the interrupt" here is to give prior (and
; presumably more time-critical) handlers a shot at processing this interrupt
; before we process with this TSR's code.
;
		pushf			;Push flags as a true interrupt would.
                cli                     ;Be sure interrupts are disabled.
		call	CS:oldint09	;Call FAR PTR address of old interrupt
;					;     handler routine.
;
;
                push    ax      ;Prepare to check for Hotkey.
                push    bx      ;Save all registers (DS is already pushed).
                push    cx
                push    dx
                push    si
                push    di
                push    bp
                push    ds
                push    es
;
                push    CS              ;Set up data segment
                pop     DS              ;register to point to code segment.
;
                ASSUME  DS:CodeSeg      ;v0.01
;
;       Determine if the current Keyboard Interrupt (Int09h) occurred
;       because this TSR's HotKey was pressed:
                in      al,60h          ;Get current Key Scan Code.
                cmp     al,HOTKEY       ;Is it HotKey's Scan Code?
                jne     Exit09          ;Exit if not.
                mov     ah,02h          ;Int16h,Fcn02h:GetKEYFLAGBYTE.
                Int     16h             ;Return Key Flag Byte in al.
                and     al,LockKeyMask  ;Mask out Num, Caps, Scroll Lock bits.
                cmp     al,KEYFLAGBYTE  ;Are the HotKey Flags active ?
                jne     Exit09          ;Exit if not.
;
;       At this point, Hotkey is known to have been pressed. First, purge
;       the DOS Keyboard type-ahead buffer of the hot key(s) so they won't
;       be passed on to DOS:
;
ClrKbdBuf:      ;Clear Keyboard buffer:
                mov     ah,01h          ;Get Keyboard buffer status
                int     16h             ;via BIOS Interrupt 16h.
                jz      BufClr          ;Jump if buffer empty.
                mov     ah,00h          ;Get key from buffer (to purge it)
                int     16h             ;via BIOS Interrupt 16h.
                jmp     ClrKbdBuf       ;Loop back to purge another key.
BufClr:
;
; We shall allow other interrupts to occur during our TSR ROUTINE.
; If we didn't allow other interrupts (through the STI instruction),
; we could lock out time-critical interrupts from access to the CPU during
; our TSR routine. However, by allowing interrupts during our routine, we 
; have an increased responsibility to make sure critical portions of our
; own code is not re-entered. (The "bellgate" stuff below is an example
; of a measure necessary to keep us from re-entering our own TSR's code).
; What we really want to do by allowing interrupts is to make the CPU avail-
; able to OTHER critical interrupt service routines WITHOUT swarming all over 
; ourselves through multiple detections of our own HotKey.
;               This "gate" technique is a good one to keep in
;               mind whenever you have a code region in an interrupt handler
;               that needs to be protected from re-entry:
;
                cmp     bellgate,0      ;Is it clear to re-enter Hotkey code?
                jne     BusyExit09      ;Exit if not,
                mov     bellgate,1      ;Else, close gate and proceed.
;
                CLI                     ;DISABLE INTERRUPTS
;       Now we will check to be sure that no time-critical hardware interrupt
;       handling is underway. We do this by querying the Intel 8259A Program-
;       mable Interrupt Controller (PIC) chip's In Service Register (ISR) and
;	testing it to see that it is zero (i.e., nothing being serviced).
;
HotKeyPressed:
                mov     al,ISRREQ       ;al=PIC's OCW3 to ask for ISR Register.
		out	PICPORT,al	;Tell PIC to get ISR ready for reading.
		jmp	Dally		;Give PIC time to make ISR available.
Dally:		in	al,PICPORT	;Fetch the ISR Register from PIC.
                or      al,al           ;Activate processor flags.
                jnz     SetFlag         ;If al not zero, go set flag.
;
;       At this point, HotKey is known to be pressed AND NO hardware interrupt
;	is being serviced. BUT is InDOS flag zero, indicating that DOS is
;	not busy and therefore can safely be entered? This will now be
;	checked:
;
HotKeyNoHWI:
		les	bx,indosptr	;es:bx = pointer to InDOS flag
		mov	al,es:[bx]	;al = InDOS flag.
                or      al,al           ;Activate processor flags.
                jnz     SetFlag         ;Jump if InDOS not zero.
;
;       Include a check on Critical Error flag. Don't trigger the TSR if
;       DOS is in the middle of handling a Critical Error:
;
                les     bx,criterrptr   ;es:bx = pointer to CritErr flag.
                mov     al,es:[bx]      ;al = CritErr flag.
;
;       Also, don't trigger the TSR if time-critical Disk access is underway:
;               Normally, this Disk check would not be necessary since the
;               InDOS flag would not be clear during Disk accesses, BUT some
;               software will bypass DOS and go directly to the BIOS Int13
;               Interrupt for Disk access. Therefore, to be safe, we HAVE to
;               be sure Int13 has not been entered and is not in the process
;               of performing time-critical Disk stuff when we hit the TSR
;               HotKey. Many TSRs don't even check this. They just depend
;               upon users not to hit the HotKey during Disk access. That seems
;               terribly risky to me:
;
                or      al,diskflag     ;al = CritErr | diskflag
                                        ; (| => Logical OR).
                jnz     Exit09          ;If al not zero, try again later.
;
;       Also, don't trigger the TSR if a PrtScrn is in progress:
;       (Is this really necessary? I don't think TSR will trigger during PrtSc)
                les     bx,prtscrn      ;ES:bx = pointer to PrtScrn busy flag.
                cmp     BYTE PTR es:[bx],1      ;Is PrtScrn in progress?
                je      Exit09          ;If so, try again later.
;
                STI                     ;Allow other interrupts in our TSR.
;
                call    ROUTINE         ;All is clear!, so call routine.
                mov     hotkeyflag,0    ;Be sure HotKey flag is reset.
                jmp     SHORT Exit09    ;Exit after TSR routine.
;
SetFlag:
                mov     hotkeyflag,1    ;Set HotKey Flag for use by Int28h.
;
Exit09:
                mov     CS:bellgate,0   ;Open gate allowing new HotKey detect.
BusyExit09:
                pop     es              ;Restore all registers
                pop     ds
                ASSUME  DS:NOTHING      ;v0.01
                pop     bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
;
;
;	Return from this TSR's Keyboard Interrupt 09h handler routine:
		iret
;
NewInt09	ENDP			;v0.01
;
;*************************************************************************
PAGE
;*************************************************************************
NewInt13        PROC    FAR             ;We hook Int13h only for purpose
                                        ;of setting a flag to prevent our
                                        ;TSR from triggering during time-
                                        ;critical Disk accesses.
                mov     CS:diskflag,1   ;Set flag to show Disk access.
;
                pushf                   ;Invoke prior Int13 handler
                cli                     ;(be sure interrupts disabled)
                call    CS:oldint13     ;by simulating an interrupt.
;
                mov     CS:diskflag,0   ;Clear flag to show Disk finished.
;
; The following RET 2 bumps the SP register up by 2 bytes to effectively
;        take the flags off the stack (where they were put by the invoking
;        INT 13h) WITHOUT popping them off and ruining the meaningful flags
;        left in the Flags register by the original DOS INT13 handler (the
;        DOS INT13 handler also returns via a RET 2 to keep from ruining the
;        Flags that the handler has painstakingly prepared for communicating
;        back to the calling program). The effect on the stack pointer, SP, is
;        exactly the same as with the more usual IRET. It is just that the Flags
;        in the Flag register are preserved at the values the handler placed
;        and wanted there.
;
                RET     2               ;Return from interrupt while
                                        ;preserving flags.
;
NewInt13        ENDP
;*************************************************************************
PAGE
;*************************************************************************
NewInt16	PROC	FAR		;v0.01
;
                push    ds              ;Entry for New Int. Handler.
;                                       ;Save required registers.
;
                push    CS              ;Set data seg   v0.01
                pop     DS              ;to our CodeSeg v0.01
		ASSUME	DS:CodeSeg	;v0.01
;
; This next portion of code provides back to the non-resident
; TSR installation code a check on whether the TSR has already been installed.
; It does this through the following technique:
;        Check to see if the ax, bx, cx, dx registers are loaded with this
;	TSR's signature words. Since all TSR ax signature words are chosen 
;	so as NOT to match any allowed DOS Int16h Function in ah, ALL
;	standard DOS Int16h calls will exit from this sequence of compares
;	at the first JNE instruction below and will ultimately be processed
;	by the standard DOS Int16h handler.
;	 The ONLY place where all the registers are loaded with THIS TSR's
;	signature words and then Int16h called is IN THE INITIALIZATION CODE 
;	AT THE END OF THIS TSR. Given that all the signature words are matched
;	in the four comparisons below, we need to signal back to the
;	invoking TSR initialization code by setting the data registers to
;	values that NEVER would be returned by the standard DOS Int16h handler,
;	and that therefore could ONLY have come from this previously-installed
;	TSR's Int16h handler code. The TSR installation code will then take
;	the return of these unique register values as the indication that
;	this TSR has already been installed.
;
		cmp	ax,TSRsigA	;Is ax = TSR signature word A?
		jne	Exit16		;No, let regular Int16 handle this.
		cmp	bx,TSRsigB	;Is bx = TSR signature word B?
		jne	Exit16		;No, let regular Int16 handle this.
		cmp	cx,TSRsigC	;Is cx = TSR signature word C?
		jne	Exit16		;No, let regular Int16 handle this.
		cmp	dx,TSRsigD	;Is dx = TSR signature word D?
		jne	Exit16		;No, let regular Int16 handle this.
;
;       The ONLY way you ever get to here is by having called Int16h with the
;	ax, bx, cx, dx registers loaded with this TSR's signature words. This
;	only occurs in the TSR initialization routine. Therefore, set the
;       registers to return values that a DOS Int16h never would, and then
;       return from this interrupt back to the TSR initialization routine.
;
                xchg    bx,cx   ;Exchange regs. (DOS Int16h wouldn't do this)
		xchg	ax,dx	;   "         "        "
;
                pop     ds      ;Restore regs.
                iret            ;Return from Int to TSR Initialize routine.
;
Exit16:
                pop     ds                      ;Restore all registers
		ASSUME	DS:NOTHING	;v0.01
;
;       Chain to prior Interrupt 16h handler routine:
                jmp     CS:oldint16
;
NewInt16        ENDP            ;v0.01

;*************************************************************************
PAGE
;*************************************************************************
NewInt28	PROC	FAR		;v0.01
;
                pushf                   ;Call prior handler.
                cli
                call    CS:oldint28
;
;	Determine if this TSR's HotKey has been flagged as pressed:
                cmp     CS:hotkeyflag,1 ;Has HotKey been pressed?
                jne     QuickExit       ;Exit if not.
;
                cmp     CS:bellgate,1   ;Is gate closed?
                je      QuickExit       ;If so, exit.
                mov     CS:bellgate,1   ;Else close gate and proceed.
;
                CLI                     ;DISABLE INTERRUPTS
;       If you are here, then HotKey has been pressed.
                push    ax              ;Entry for New Int. Handler.
                push    bx              ;Save all registers.
                push    cx
                push    dx
                push    si
                push    di
                push    bp
                push    ds
                push    es
;
                push    CS
                pop     DS
                ASSUME  DS:CodeSeg      ;v0.01
;
;
;       Make sure InDOS flag is no greater than 1. The InDOS flag equals
;       the number of DOS calls currently active. If we want to be sure
;       that we do not disrupt DOS by reentry in our TSR user routine,
;       we have to be sure that the present Int28 has occurred while
;       only 1-deep into DOS calls (as it is when DOS is TRULY idling):
                les     bx,indosptr             ;ES:bx points to InDOS flag.
                cmp     BYTE PTR ES:[bx],1      ;Is InDOS flag above 1?
                ja      Exit28                  ;Exit if InDOS > 1.
;
;       DOS is known to be idling at this point.
;	At this point, HotKey is known to have been pressed. Now we will
;	check to be sure that no time-critical hardware interrupt handling
;	is underway. We do this by querying the Intel 8259A Programmable
;	Interrupt Controller (PIC) chip's In Service Register (ISR) and
;	testing it to see that it is zero (i.e., nothing being serviced
;	except Int09 (PIC's IRQ1) ):
HotKeyPressed2:
                mov     al,ISRREQ       ;al=PIC's OCW3 to ask for ISR Register.
		out	PICPORT,al	;Tell PIC to get ISR ready for reading.
		jmp	Dally2		;Give PIC time to make ISR available.
Dally2:		in	al,PICPORT	;Fetch the ISR Register from PIC.
;
;       Also, don't trigger the TSR if time-critical Disk access is underway:
                or      al,diskflag     ;al = ISR | diskflag. (| => Logical OR).
                jnz     Exit28          ;If al not zero, try again later.
;
;       Also, don't trigger the TSR if a PrtScrn is in progress:
;       (Is this really necessary? I don't think TSR will trigger during PrtSc)
                les     bx,prtscrn      ;ES:bx = pointer to PrtScrn busy flag.
                cmp     BYTE PTR es:[bx],1      ;Is PrtScrn in progress?
                je      Exit28                  ;If so, Exit w/o triggering TSR.
;
                STI                     ;ENABLE OTHER INTERRUPTS.
;
HotKeyFlagSet:
;	Here, HotKey is flagged as pressed and DOS is idling (since we are
;       servicing Int28h) and no hardware interrupts are being handled.
;       Also, no Print Screen or Disk access is underway.
;	DOS Int21h Functions above 0Ch can be accessed if required in your 
;	TSR routine:
;
                call    ROUTINE         ;Call TSR routine; DOSOK & No Hardware
					;interrupts being serviced.
                mov     CS:hotkeyflag,0    ;Clear HotKey Flag.
;
Exit28:
                pop     es                      ;Restore all registers
                pop     ds
                ASSUME  ds:NOTHING
                pop     bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
                mov     CS:bellgate,0
;
QuickExit:
;       Return from this Keyboard Interrupt 28h handler routine:
                iret
;
NewInt28        ENDP            ;v0.01
;*************************************************************************
;	-END OF TSR's RESIDENT CODE-
;	Only the code above will remain locked in memory
;		after the initialization performed below.
;*************************************************************************
SUBTTL TSR BOOSTER (Initialization)
PAGE
;*************************************************************************
;       BEGINNING OF TSR's INITIALIZATION CODE (THE "BOOSTER"):
;	The following code is protected in RAM *ONLY* during initialization
;               of the TSR that occurs when the TSR name is first invoked
;		at the DOS command level. All the following code is abandonned
;               unprotected in RAM after the Terminate-and-Stay-Resident (TSR)
;		call to Function 31h of DOS Interrupt 21h below. This
;		is allowed to happen because the code's work is complete at
;		that point. The code will be overwritten as the memory which
;		it temporarily occupied is needed by DOS for other purposes.
;
;               I have seen this following section of code colorfully called
;               the TSR "Booster". This is quite appropriate since the code
;               sits here, strapped to the very end of the TSR, and it is of
;               use only during the "blastoff" (initialization) of the TSR, when
;               it is used to put the TSR into "orbit" (residency), and after
;               which it is "jettisoned" (abandonned unprotected in memory) by
;               the DOS TSR call, Int 21h, Fcn 31h.
;
TSRinit		PROC	NEAR				;v0.01
EndDump		EQU	$	;Roy Silvernail - Keep TASM 1.0 happy
				;when computing # resident paragraphs.
;
;       Get DOS Version Number:
                mov     ah,30h                  ;Fcn 30h = Get DOS Version
                int     21h                     ;DOS Version = al.ah
;
;       If this is DOS v.1.x, this TSR cannot work, so go print message
;       and exit without installing:
                cmp     al,1         ;Is this DOS Version 1.x?
                ja      DOSverOK     ;If not, DOS version is OK.
                push    bx           ;A "push" for the "pop" at DOSver1 label.
                jmp     DOSver1      ;If so, TSR won't work so exit.
;
DOSverOK:
;       If here, DOS version is 2.0 or later. TSR can work, so proceed.
;
;       Check for prior installation of this TSR:
;
                mov     ax,TSRsigA              ;Prime registers for our
                mov     bx,TSRsigB              ;Int16h handler's check
                mov     cx,TSRsigC              ;for prior installation
                mov     dx,TSRsigD              ;thru TSR signature words.
;
                Int     16h                     ;Check prior installation.
;
                cmp     ax,TSRsigD              ;Was TSR signature detected?
                jne     Install                 ;If not, Install it.
                cmp     bx,TSRsigC
                jne     Install         
                cmp     cx,TSRsigB
                jne     Install         
                cmp     dx,TSRsigA
                jne     Install
;
; If you are here, all four TSR signature words were detected and signalled,
; so the TSR is already installed.
;       Announce the TSR's PRIOR Installation and exit:
                mov     dx,Offset PriorInstMsg  ;DX points to message.
                mov     ah,09h                  ;DOS Fcn. 09h=Display String.
                Int     21h                     ;Display String via DOS.
;
                mov     ax,4C00h                ;Fcn 4C = DOS Terminate call
                Int     21h                     ;Do it.
;
Install:
;       If you are here, then DOS version is 2.+ and the TSR has not
;       previously been installed.
;
;       To conserve RAM usage, release from memory the copy of the DOS 
;	Environment passed to this TSR (this assumes, of course, that
;	your Interrupt handler routine will not need to reference this
;	de-allocated Environment) So, if you are going to write your
;	TSR routine to reference the Environment, DON'T DEALLOCATE IT
;	HERE.
;
                ;Get segment of Environment
		;from 02Ch in the Program
		;Segment Prefix (PSP).
;
                mov     ES,envseg       ;ES=PSP's environ seg   v0.01
                mov     ah,49h          ;DOS Fcn 49h = Release Memory
                int     21h             ;Release it via DOS interrupt.
;
; In order to make the TSR's command name show under the "owner" column in 
;	the "MAPMEM" command of Kim Kokkonen's excellent TSR Mark/Release 
;       package, allocate a tiny 1-paragraph "Pseudo-Environment" here which
;       contains nothing but the TSR name.
;
; Allocate the memory needed by the tiny 'Pseudo-Environment":
                mov     bx,1            ;Allocate one parag. (16bytes)
                mov     ah,48h          ;and return allocation
                int     21h             ;segment in ax via DOS call.
;
                mov     ES,ax           ;Pseudo-Env. Segment to ES.
		mov	si,OFFSET PseudoEnv	;si=source string OFFSET.
                mov     di,0            ;di=destination string OFFSET.
                mov     cx,ENVLNGTH     ;cx=Bytes in Pseudo-Env.string.
                cld                     ;Forward string move direction.
		rep	movsb	;Move Pseudo-Env. string @ DS:si to ES:di
;
; Set PSP's Environment segment pointer to point to tiny Pseudo-Environment.
		mov	envseg,ES	
;
;*****************************************************************************
; NOW, capture all the required Interrupts:
;
;       **** INT 09 ****
;       Get Old Interrupt 09h Vector:
                mov     ax,3500H+HOOK09 ;Get old Int 9 vector   v0.01
                int     21h             ;Int.Vector in ES:BX via DOS.
;
;	Save Old Interrupt 09h Vector:
		mov	Word Ptr oldint09,bx	;Save Offset of Old Interrupt.
		mov	word ptr oldint09+2,ES	;save seg		v0.01
;
;	Install New Interrupt Vector to this TSR's "NewInt09:" Label:
                mov     ax,2500H+HOOK09         ;Set new Int 9 vector   v0.01
		mov	dx,Offset NewInt09	;dx=Offset of New Int Handler.
                int     21h                     ;Set New Int via DOS.
;
;       **** INT 13 ****
;       Get Old Interrupt 13h Vector:
                mov     ax,3500H+HOOK13         ;Get old Int 13 vector
                int     21h                     ;Int.Vector in ES:BX via DOS.
;
;       Save Old Interrupt 13h Vector:
                mov     Word Ptr oldint13,bx    ;Save Offset of Old Interrupt.
                mov     word ptr oldint13+2,ES  ;save Segment.
;
;       Install New Interrupt Vector to this TSR's "NewInt13:" Label:
                mov     ax,2500H+HOOK13         ;Set new Int 13 vector.
                mov     dx,Offset NewInt13      ;dx=Offset of New Int Handler.
                int     21h                     ;Set New Int via DOS.
;
;       **** INT 16 ****
;       Get Old Interrupt 16h Vector:
                mov     ax,3500H+HOOK16         ;get old Int 16H vector v0.01
                int     21h                     ;Int.Vector in ES:BX via DOS.
;
;	Save Old Interrupt 16h Vector:
                mov     Word Ptr oldint16,bx    ;Save Offset of Old Interrupt.
                mov     word ptr oldint16+2,ES  ;save segment           v0.01
;
;	Install New Interrupt Vector to this TSR's "NewInt16:" Label:
                mov     ax,2500H+HOOK16         ;set new Int 16H vector v0.01
                mov     dx,Offset NewInt16      ;dx=Offset of New Int Handler.
                int     21h                     ;Set New Int via DOS.
;
;       **** INT 28 ****
;	Get Old Interrupt 28h Vector:
                mov     ax,3500H+HOOK28         ;Get old Int 28H vector v0.01
                int     21h                     ;Int.Vector in ES:BX via DOS.
;
;	Save Old Interrupt 28h Vector:
                mov     Word Ptr oldint28,bx    ;Save Offset of Old Interrupt.
                mov     word ptr oldint28+2,ES  ;save segment           v0.01
;
;	Install New Interrupt Vector to this TSR's "NewInt28:" Label:
                mov     ax,2500H+HOOK28         ;set new Int 28H vector v0.01
                mov     dx,Offset NewInt28      ;dx=Offset of New Int Handler.
                int     21h                     ;Set New Int via DOS.
;
;*****************************************************************************
;       Get Pointer to InDOS flag ("DOS Busy" flag) and save it:
                mov     ah,34h                  ;DOS FCN=34h:Get InDOS Pointer.
                int     21h                     ;Pointer in ES:BX
                mov     Word Ptr indosptr,bx    ;Save Offset of InDOS flag.
                mov     Word Ptr indosptr+2,ES  ;Save Segment of InDOS flag.
;
                mov     Word Ptr criterrptr+2,ES ;Also, Seg of CritErr flag.
                push    bx      ;Save indosptr on stack for use below.
;
;       Get DOS Version Number:
                mov     ah,30h          ;Fcn 30h = Get DOS Version
                int     21h             ;DOS Version = al.ah
;
;       If DOS version is 2.x, then DOS Critical Error flag is @ indosptr + 1.
;       If DOS version is 3.x+, then DOS Critical Error flag is @ indosptr - 1.
;	Determine DOS Version:
                cmp     al,2            ;Is it DOS Version 2.x?
                je      DOSver2         ;If yes, jump;
                ja      DOSver3         ;or, if later version, jump;
                                        ;else, it's DOS Version 1.x:
;
DOSver1:        ;If here, DOS Version 1.x is being run:
                mov     dx,OFFSET BailOutMsg    ;TBONES needs DOS 2.x or later.
                mov     ah,09h                  ;Say we're sorry, but NO GO
                int     21h                     ;via DOS.
                pop     bx                      ;Clear stack.
                int     20h                     ;Terminate without installing
                                                ;in only way DOS 1.x knows.
;
DOSver2:        ;If here, DOS Version 2.x is being run:
                pop     bx                      ;Get indosptr from stack.
                inc     bx                      ;CritErr flag is @ indosptr+1.
                mov     Word Ptr criterrptr,bx  ;Save CritErr Pointer.
                jmp     Announce                ;Go announce TSR installed.
;
DOSver3:        ;If here, DOS Version 3.+ is being run:
                pop     bx                      ;Get indosptr from stack.
                dec     bx                      ;CritErr flag is @ indosptr-1.
                mov     Word Ptr criterrptr,bx  ;Save CritErr Pointer.
;
;	Announce the TSR's Installation:
Announce:
                mov     dx,Offset InstallMsg    ;DX points to message.
                mov     ah,09h                  ;DOS Fcn. 09h=Display String.
                int     21h                     ;Display String via DOS.
;
; Lock resident code in memory via Terminate-and-Stay-Resident (TSR) DOS call:
;
;v0.11	DX requires size of resident code (in 16-byte paragraphs)
;	This awkward construct is required to keep
;	DOS Function 31h happy.  Notice how we first compute
;	the length of the TSR code in bytes [i.e., end of
;	the TSR code (EndDump) minus start of the TSR code
;	(0, our BeginDump)], round it up to the next whole paragraph ( + 0Fh),
;	and then divide by 16 (SHR 4) to get the number of resident paragraphs:
;
                mov     dx,(EndDump-BeginDump+0Fh)/16
;Roy Silvernail discovered that the BeginDump and EndDump symbols
;were necessary to keep TASM 1.0 happy when computing # resident paragraphs
;in the above statement.
;
                mov     ah,31h                  ;DOS FCN 31h=TSR Call.
                int     21h                     ;Go Resident via DOS TSR call.
;
PseudoEnv:      DB      ' ',0,0,1,0,'SEARCHER',0
ENVLNGTH	EQU	$-PseudoEnv
;
BailOutMsg:
                db      0Dh,0Ah
                db      'Sorry. Searcher needs DOS v.2+. You have v.1.x'
                db      0Dh,0Ah,'$'
PriorInstMsg:
                db      0Dh,0Ah
                db      'SEARCHER IS *ALREADY* INSTALLED.'
InstallMsg:
                db      0Dh,0Ah
                db      'HotKey => Ctrl + Alt + S.'
                db      0Dh,0Ah
		db	'Use "+" and "-" to change characters. <Esc> quits.'
                db      0Dh,0Ah
                db      0Dh,0Ah
                db      'Searcher v1'
                db      0Dh,0Ah
                db      'Bushy ''95.'
                db      0Dh,0Ah,'$'

;
TSRinit         ENDP    ;v0.01

CodeSeg         ends
                end     Entry
;***********************************************************************
