;;
;;  sysdef.asm: This file contains definitions to simplify assembler programming
;;              and for accessing the various hardware registers via MMIO
;;

;
;***************************************************************************************
;*  Assembler macros which make life much easier:
;***************************************************************************************
;
#define RET     MOVE    @R13++, R15
#define INCRB   ADD     0x0100, R14
#define DECRB   SUB     0x0100, R14
#define NOP     ABRA    R15, 1

#define SYSCALL(x,y)    ASUB    x, y

;
;  Some register short names:
;
#define PC  R15
#define SR  R14
#define SP  R13

;
;***************************************************************************************
;* Constant definitions
;***************************************************************************************
;

; ========== VGA ==========

VGA$MAX_X               .EQU    79                      ; Max. X-coordinate in decimal!
VGA$MAX_Y               .EQU    39                      ; Max. Y-coordinate in decimal!
VGA$MAX_CHARS           .EQU    3200                    ; VGA$MAX_X * VGA$MAX_Y
VGA$CHARS_PER_LINE      .EQU    80  

VGA$EN_HW_CURSOR        .EQU    0x0040                  ; Show hardware cursor
VGA$EN_HW_SCRL          .EQU    0x0C00                  ; Hardware scrolling enable
VGA$CLR_SCRN            .EQU    0x0100                  ; Clear screen
VGA$BUSY                .EQU    0x0200                  ; VGA is currently performing a task

VGA$COLOR_RED           .EQU    0x0004
VGA$COLOR_GREEN         .EQU    0x0002
VGA$COLOR_BLUE          .EQU    0x0001
VGA$COLOR_WHITE         .EQU    0x0007

; ========== CYCLE COUNTER ==========

CYC$RESET               .EQU    0x0001                  ; Reset cycle counter
CYC$RUN                 .EQU    0x0002                  ; Start/stop counter

; ========== EAE ==========

EAE$MULU                .EQU    0x0000                  ; Unsigned 16 bit multiplication
EAE$MULS                .EQU    0x0001                  ; Signed 16 bit multiplication
EAE$DIVU                .EQU    0x0002                  ; Unsigned 16 bit division with remainder
EAE$DIVS                .EQU    0x0003                  ; Signed 16 bit division with remainder

; ========== KEYBOARD ==========

; STATUS REGISTER

KBD$NEW_ASCII           .EQU    0x0001                  ; new ascii character available
KBD$NEW_SPECIAL         .EQU    0x0002                  ; new special key available
KBD$NEW_ANY             .EQU    0x0003                  ; any new key available 

KBD$ASCII               .EQU    0x00FF                  ; mask the special keys
KBD$SPECIAL             .EQU    0xFF00                  ; mask the ascii keys

KBD$LOCALE              .EQU    0x001C                  ; bit mask for checking locales
KBD$LOCALE_US           .EQU    0x0000                  ; default: US keyboard layout
KBD$LOCALE_DE           .EQU    0x0004                  ; DE: German keyboard layout

KBD$MODIFIERS           .EQU    0x00E0                  ; bit mask for checking modifiers
KBD$SHIFT               .EQU    0x0020                  ; modifier "SHIFT" pressed
KBD$ALT                 .EQU    0x0040                  ; modifier "ALT" pressed
KBD$CTRL                .EQU    0x0080                  ; modifier "CTRL" pressed

; READ REGISTER: COMMON ASCII CODES
KBD$SPACE               .EQU    0x0020
KBD$ENTER               .EQU    0x000D
KBD$ESC                 .EQU    0x001B
KBD$TAB                 .EQU    0x0009
KBD$BACKSPACE           .EQU    0x0008

; READ REGISTER: SPECIAL KEYS

KBD$F1                  .EQU    0x0100
KBD$F2                  .EQU    0x0200
KBD$F3                  .EQU    0x0300
KBD$F4                  .EQU    0x0400
KBD$F5                  .EQU    0x0500
KBD$F6                  .EQU    0x0600
KBD$F7                  .EQU    0x0700
KBD$F8                  .EQU    0x0800
KBD$F9                  .EQU    0x0900
KBD$F10                 .EQU    0x0A00
KBD$F11                 .EQU    0x0B00
KBD$F12                 .EQU    0x0C00

KBD$CUR_UP              .EQU    0x1000
KBD$CUR_DOWN            .EQU    0x1100
KBD$CUR_LEFT            .EQU    0x1200
KBD$CUR_RIGHT           .EQU    0x1300
KBD$PG_UP               .EQU    0x1400
KBD$PG_DOWN             .EQU    0x1500
KBD$HOME                .EQU    0x1600
KBD$END                 .EQU    0x1700
KBD$INS                 .EQU    0x1800
KBD$DEL                 .EQU    0x1900

; READ REGISTER: CTRL + character is also mapped to an ASCII code

KBD$CTRL_A              .EQU    0x0001 
KBD$CTRL_B              .EQU    0x0002 
KBD$CTRL_C              .EQU    0x0003 
KBD$CTRL_D              .EQU    0x0004 
KBD$CTRL_E              .EQU    0x0005 
KBD$CTRL_F              .EQU    0x0006 
KBD$CTRL_G              .EQU    0x0007 
KBD$CTRL_H              .EQU    0x0008 
KBD$CTRL_I              .EQU    0x0009 
KBD$CTRL_J              .EQU    0x000A 
KBD$CTRL_K              .EQU    0x000B 
KBD$CTRL_L              .EQU    0x000C 
KBD$CTRL_M              .EQU    0x000D 
KBD$CTRL_N              .EQU    0x000E 
KBD$CTRL_O              .EQU    0x000F 
KBD$CTRL_P              .EQU    0x0010 
KBD$CTRL_Q              .EQU    0x0011 
KBD$CTRL_R              .EQU    0x0012 
KBD$CTRL_S              .EQU    0x0013 
KBD$CTRL_T              .EQU    0x0014 
KBD$CTRL_U              .EQU    0x0015 
KBD$CTRL_V              .EQU    0x0016 
KBD$CTRL_W              .EQU    0x0017 
KBD$CTRL_X              .EQU    0x0018 
KBD$CTRL_Y              .EQU    0x0019 
KBD$CTRL_Z              .EQU    0x001A 

;
;  Useful ASCII constants:
;
CHR$BELL        .EQU 0x0007 ; ASCII-BELL character
CHR$TAB         .EQU 0x0009 ; ASCII-TAB character
CHR$SPACE       .EQU 0x0020 ; ASCII-Space
CHR$CR          .EQU 0x000d ; Carriage return
CHR$LF          .EQU 0x000a ; Line feed

;
;***************************************************************************************
;*  IO-page addresses:
;***************************************************************************************
;
IO$BASE             .EQU 0xFF00
;
;  VGA-registers:
;
VGA$STATE           .EQU 0xFF00 ; VGA status register
    ; Bits 11-10: Hardware scrolling / offset enable: Bit #10 enables the use
    ;             of the offset register #4 (display offset) and bit #11
    ;             enables the use of register #5 (read/write offset).
    ; Bit      9: Busy: VGA is currently busy, e.g. clearing the screen,
    ;             printing, etc. While busy, commands will be ignored, but
    ;             they can still be written into the registers, though
    ; Bit      8: Set bit to clear screen. Read bit to find out, if clear
    ;             screen is still active
    ; Bit      7: VGA enable (1 = on; 0: no VGA signal is generated)
    ; Bit      6: Hardware cursor enable
    ; Bit      5: Hardware cursor blink enable
    ; Bit      4: Hardware cursor mode: 1 - small
    ;                              0 - large
    ; Bits   2-0: Output color for the whole screen, bits (2, 1, 0) = RGB
VGA$CR_X            .EQU 0xFF01 ; VGA cursor X position
VGA$CR_Y            .EQU 0xFF02 ; VGA cursor Y position
VGA$CHAR            .EQU 0xFF03 ; write: VGA character to be displayed
                                ; read: character "under" the cursor
VGA$OFFS_DISPLAY    .EQU 0xFF04 ; Offset in bytes that is used when displaying
                                ; the video RAM. Scrolling forward one line
                                ; means adding 0x50 to this register.
                                ; Only works, if bit #10 in VGA$STATE is set.
VGA$OFFS_RW         .EQU 0xFF05 ; Offset in bytes that is used, when you read
                                ; or write to the video RAM using VGA$CHAR.
                                ; Works independently from VGA$OFFS_DISPLAY.
                                ; Active, when bit #11 in VGA$STATE is set.

;
;  Registers for TIL-display:
;
IO$TIL_DISPLAY  .EQU 0xFF10 ; Address of TIL-display
IO$TIL_MASK     .EQU 0xFF11 ; Mask register of TIL display
;
;  Switch-register:
;
IO$SWITCH_REG   .EQU 0xFF12 ; 16 binary keys
;
;  USB-keyboard-registers:
;
IO$KBD_STATE    .EQU 0xFF13 ; Status register of USB keyboard
;    Bit  0 (read only):      New ASCII character avaiable for reading
;                             (bits 7 downto 0 of Read register)
;    Bit  1 (read only):      New special key available for reading
;                             (bits 15 downto 8 of Read register)
;    Bits 2..4 (read/write):  Locales: 000 = US English keyboard layout,
;                             001 = German layout, others: reserved for more locales
;    Bits 5..7 (read only):   Modifiers: 5 = shift, 6 = alt, 7 = ctrl
;                             Only valid, when bits 0 and/or 1 are '1'
;
IO$KBD_DATA     .EQU 0xFF14 ; Data register of USB keyboard
;    Contains the ASCII character in bits 7 downto 0  or the special key code
;    in 15 downto 0. The "or" is meant exclusive, i.e. it cannot happen that
;    one transmission contains an ASCII character PLUS a special character.
;
;  CYCLE-COUNT-registers       
;
IO$CYC_LO       .EQU 0xFF17     ; low word of 48-bit counter
IO$CYC_MID      .EQU 0xFF18     ; middle word of 48-bit counter
IO$CYC_HI       .EQU 0xFF19     ; high word of 48-bit counter
IO$CYC_STATE    .EQU 0xFF1A     ; status register
;    Bit  0 (write only):     Reset counter to zero and start counting, i.e.
;                             bit 1 is automatically set to 1 when resetting
;    Bit  1 (read/write):     Start/stop counter
;
;  EAE (Extended Arithmetic Element):
;
IO$EAE_OPERAND_0    .EQU    0xFF1B
IO$EAE_OPERAND_1    .EQU    0xFF1C
IO$EAE_RESULT_LO    .EQU    0xFF1D
IO$EAE_RESULT_HI    .EQU    0xFF1E
IO$EAE_CSR          .EQU    0xFF1F ; Command and Status Register
;
; EAE-Opcodes:      0x0000  MULU
;                   0x0001  MULS
;                   0x0002  DIVU
;                   0x0003  DIVS
;
;
;  UART-registers:
;
IO$UART_SRA     .EQU 0xFF21 ; Status register (relative to base address)
IO$UART_RHRA    .EQU 0xFF22 ; Receiving register (relative to base address)
IO$UART_THRA    .EQU 0xFF23 ; Transmitting register (relative to base address)

