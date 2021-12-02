;; VISIONS
;; Entry point & interrupts

incsrc "lib/registers.asm"
incsrc "lib/header.asm"
incsrc "ram.asm"
incsrc "macros.asm"

;; BANK 0

org $808000
Boot:
    jml + : +           ; jump to fastrom bank
    sei
    clc : xce
    sep #$30
    lda #$01
    sta.w MEMSEL        ; Fastrom
    stz.w HDMAEN        ; Disable HDMA, if any
    stz.w NMITIMEN      ; Disable joypad, NMI and v/h count
    lda #$80
    sta.w INIDISP       ; Activate f-blank
    rep #$30
    lda #$01FF
    tcs                 ; Init system stack

    ; Clean up memory
    stz.w WMADDL
    stz.w WMADDH
    lda #$8008
.zero:
    sta.w DMAP(0)
    lda.w #.zero+1
    sta.w A1T(0)
    lda.w #(.zero+1)>>8
    sta.w A1T(0)+1
    stz.w DAS(0)
    sep #$10
    ldy #$01
    sty.w MDMAEN
    sty.w MDMAEN

    sep #$30
    lda #%10000001
    sta.w NMITIMEN      ; enable NMI & joypad
    rep #$30

InitFrame:
    lda.w #GamemodeLoad
    sta.b GamemodePtr
    lda.w #NoNmi
    sta.b NmiPtr
    lda.w #NoIrq
    sta.b IrqPtr

RunFrame:
    inc.b MainRunning
    jsr ResetSprites
    jsr UpdateJoypad
    ldx #$0000
    jsr (GamemodePtr,x)
    jsr FillSprites
    stz.b MainRunning
    lda.w AsyncRunning
    beq WaitForNmi
    jmp AsyncResume     ; Resume async task if necessary

WaitForNmi:
    wai
    bra WaitForNmi


NmiHandler:
    jml + : +           ; jump to fastrom bank
    rep #$30
    pha                 ; save A in case of lag frame
    lda.l MainRunning   ; check if the main task is running (lag frame)
    beq +
    ; Do nothing if the current frame is a lag frame.
    pla
    rti
+
    lda.l AsyncRunning  ; check if an async task is running
    beq +
    pla
    jsr AsyncSave
+
    jsr UploadSprites
    ldx #$0000
    jsr (NmiPtr,x)

    lda #$01FF          ; reset stack
    tcs
    jmp RunFrame

IrqHandler:
    bit TIMEUP          ; dummy read
    jmp (IrqPtr)

Brk:
    stp                 ; todo: add a real crash handler

NoIrq:
    rti

NoNmi:
    rts

incsrc "async.asm"
incsrc "sprites.asm"
incsrc "joypad.asm"
incsrc "dma_queue.asm"

incsrc "gamemode.asm"
incsrc "render.asm"
incsrc "mappings.asm"

TestPal:
    incbin "../testpal.bin"
TestLevelData:
    incbin "../level.data"

print "Bank 0 usage: "
print hex((+) - $808000) : +

;; BANK 8 (Graphics)
org $818000

TestGfx:
    incbin "../testgfx.bin"
SprGfx:
    incbin "../sprgfx.bin"

