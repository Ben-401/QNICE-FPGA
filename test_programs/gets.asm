; New gets library function for the monitor: development testbed
; Works together with c/test_programs/gets_test.c and therefore
; starts at 0xE000. Load this program first, before executing gets_test.c
;
; gets_test.c expects the following 4 words as a "magic" at 0xE000:
; 0xFF90, 0x0016, 0x2309, 0x1976
; It further expects the entry point of GETS to be 0xE004
;
; done by sy2002 in October 2016

#include "../dist_kit/sysdef.asm"
#include "../dist_kit/monitor.def"

                .ORG 0xE000

                SYSCALL(exit, 1)        ; 0xE000: 0xFF90 0x0016
                .DW 0x2309, 0x1976      ; 0xE002: 0x2309 0x1976
                                        ; 0xE004: GETS entry for gets_test.c

;===================== REUSABLE CODE FOR MONITOR STARTS HERE =================
;
;***************************************************************************************
;* IO$GETS reads a zero terminated string from STDIN and echos typing on STDOUT
;*
;* It accepts CR, LF and CR/LF as input terminator, so it directly works with various
;* terminal settings on UART and also with keyboards on PS/2 ("USB"). Furtheron, it
;* accepts BACKSPACE for editing the string.
;*
;* R8 has to point to a preallocated memory area to store the input line
;***************************************************************************************
;
GETS            INCRB

                MOVE    R8, R0              ; save original R8
                MOVE    R8, R1              ; R1 = working pointer
GETS_LOOP       RSUB    IO$GETCHAR, 1       ; get char from STDIN
                CMP     R8, 0x000D          ; accept CR as line end
                RBRA    GETS_CR, Z
                CMP     R8, 0x000A          ; accept LF as line end
                RBRA    GETS_LF, Z
                CMP     R8, 0x0008          ; use BACKSPACE for editing
                RBRA    GETS_BS, Z          
GETS_ADDBUF     MOVE    R8, @R1++           ; store char to buffer
GETS_ECHO       RSUB    IO$PUTCHAR, 1       ; echo char on STDOUT
                RBRA    GETS_LOOP, 1        ; next character

GETS_LF         MOVE    0, @R1              ; add zero terminator
                MOVE    R0, R8              ; restore original R8

                DECRB
                RET

                ; For also accepting CR/LF, we need to do a non-blocking
                ; check on STDIN, if there is another character waiting.
                ; IO$GETCHAR is a blocking call, so we cannot use it here.
                ; STDIN = UART, if bit #0 of IO$SWITCH_REG = 0, otherwise
                ; STDIN = PS/2 ("USB") keyboard
                ;
                ; At a terminal speed of 115200 baud = 14.400 chars/sec
                ; (for being save, let us assume only 5.000 chars/sec)
                ; and a CPU frequency of 50 MHz we need to wait about
                ; 10.000 CPU cycles until we check, if the terminal program
                ; did send one other character. The loop at GETS_CR_WAIT
                ; costs about 7 cycles per iteration, so we loop (rounded up)
                ; 2.000 times.
                ; As a simplification, we assume the same waiting time
                ; for a PS/2 ("USB") keyboard

GETS_CR         MOVE    2000, R3            ; CPU speed vs. transmit speed
GETS_CR_WAIT    SUB     1, R3
                RBRA    GETS_CR_WAIT, !Z

                MOVE    IO$SWITCH_REG, R2   ; read the switch register
                MOVE    @R2, R2
                AND     0x0001, R2          ; lowest bit set?
                RBRA    GETS_CR_UART, Z     ; no: read from UART

                MOVE    IO$KBD_STATE, R2    ; read the keyboard status reg.
                MOVE    @R2, R2
                AND     0x0001, R2          ; char waiting/lowest bit set?
                RBRA    GETS_LF, Z          ; no: then add zero term. and ret.

                MOVE    IO$KBD_DATA, R2     ; yes: read waiting character
                MOVE    @R2, R2
                RBRA    GETS_CR_LF, 1       ; check for LF


GETS_CR_UART    MOVE    IO$UART_SRA, R2     ; read UART status register
                MOVE    @R2, R2
                AND     0x0001, R2          ; is there a character waiting?
                RBRA    GETS_LF, Z          ; no: then add zero term. and ret.

                MOVE    IO$UART_RHRA, R2    ; yes: read waiting character
                MOVE    @R2, R2

GETS_CR_LF      CMP     R2, 0x000A          ; is it a LF (so we have CR/LF)?
                RBRA    GETS_LF, Z          ; yes: then add zero trm. and ret.

                ; it is CR/SOMETHING, so add both: CR and "something" to
                ; the string and go on waiting for input
                MOVE    0x000D, @R1++
                MOVE    R2, R8
                RBRA    GETS_ADDBUF, 1      ; no: add it to buffer and go on

                ; handle BACKSPACE for editing
                ;
                ; For STDOUT = UART it is kind of trivial, because you "just"
                ; need to rely on the fact, that the terminal settings are
                ; correct and then the terminal program takes care of the
                ; nitty gritty details like moving the cursor and scrolling.
                ;
                ; For STDOUT = VGA, this needs to be done manually by this
                ; routine.

GETS_BS         CMP     R0, R1              ; beginning of string?
                RBRA    GETS_LOOP, Z        ; yes: ignore BACKSPACE key

                SUB     1, R1               ; delete last char in memory                

                MOVE    IO$SWITCH_REG, R2   ; read the switch register
                MOVE    @R2, R2
                AND     0x0002, R2          ; bit #1 set?
                RBRA    GETS_ECHO, Z        ; no: STDOUT = UART: just echo

                MOVE    VGA$CR_X, R2        ; R2: HW X-register
                MOVE    VGA$CR_Y, R3        ; R3: HW Y-register
                MOVE    VGA$CHAR, R4        ; R4: HW put/get character reg.
                MOVE    _VGA$X, R5          ; R5: SW X-register
                MOVE    _VGA$Y, R6          ; R6: SW Y-register

                CMP     @R2, 0              ; cursor already at leftmost pos.?
                RBRA    GETS_BSLUP, Z       ; yes: scroll one line up

                SUB     1, @R2              ; cursor one position to the left
                SUB     1, @R5
GETS_BSX        MOVE    0x0020, @R4         ; delete char on the screen
                RBRA    GETS_LOOP, 1        ; next char/key

GETS_BSLUP      CMP     @R3, VGA$MAX_Y      ; cursor already bottom line?
                RBRA    GETS_BSSUP, Z       ; yes: scroll screen up

                SUB     1, @R3              ; cursor one line up
                SUB     1, @R6
GETS_BSXLU      MOVE    VGA$MAX_X, @R2      ; cursor to the rightpost pos.
                MOVE    VGA$MAX_X, @R5
                RBRA    GETS_BSX, 1         ; delete char on screen and go on

GETS_BSSUP      MOVE    VGA$OFFS_DISPLAY, R7        ; if RW > DISP then do not
                MOVE    VGA$OFFS_RW, R8             ; scroll up the screen
                CMP     @R8, @R7                    ; see VGA$SCROLL_UP_1 for
                RBRA    GETS_BSUPSKP, N             ; an explanation

                SUB     VGA$CHARS_PER_LINE, @R7     ; do the visual scrolling
GETS_BSUPSKP    SUB     VGA$CHARS_PER_LINE, @R8     ; scroll the RW window

                CMP     @R7, @R8                    ; if after the scrolling
                RBRA    GETS_NOCRS, !Z              ; RW = DISP then show
                MOVE    VGA$STATE, R8               ; the cursor
                OR      VGA$EN_HW_CURSOR, @R8

GETS_NOCRS      MOVE    VGA$MAX_Y, @R3              ; cursor to bottom
                MOVE    VGA$MAX_Y, @R6
                RBRA    GETS_BSXLU, 1               ; cursor to rightmost pos.

;===================== REUSABLE CODE FOR MONITOR ENDS HERE ===================

#include "../monitor/io_library.asm"
#include "../monitor/uart_library.asm"
#include "../monitor/usb_keyboard_library.asm"
#include "../monitor/vga_library.asm"
#include "../monitor/string_library.asm"

QMON$WARMSTART  SYSCALL(exit, 1)
QMON$LAST_ADDR  HALT

#include "../monitor/variables.asm"
