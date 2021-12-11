; DMA queue entry format

; mm aa aa aa bb bb ss ss
; a: A bus address
; b: B bus address
; s: transfer size
; m: mode switch
; 00: vram
; 02: vram columns
; 04: cgram

; State: a8, x16
DmaQueueExec:
    lda #$00            ; clean up top byte
    xba
    ldx #$0000
.loop:
    cpx.w DmaQueueOffset
    beq .exit
    ; source
    lda.w DmaQueue+3,x
    sta.w A1B(0)
    ldy.w DmaQueue+1,x
    sty.w A1T(0)
    ; size
    ldy.w DmaQueue+6,x
    sty.w DAS(0)
    lda.w DmaQueue,x
    cmp #$00
    beq .vram
    cmp #$02
    beq .vramcol
    ;cmp #$04
    ;beq .cgram
.vram:
    lda.b #$80
    sta.w VMAINC
    ldy.w #$1801
    sty.w DMAP(0)
    ldy.w DmaQueue+4,x
    sty.w VMADD
    bra .next
.vramcol:
    lda.b #$81
    sta.w VMAINC
    ldy.w #$1801
    sty.w DMAP(0)
    ldy.w DmaQueue+4,x
    sty.w VMADD
    ;bra .next
.next:
    lda.b #$01
    sta.w MDMAEN
    ; todo: do this better?
    ; (doesn't matter that a is 8-bit, the queue size is 256 bytes)
    txa
    clc : adc #$08
    tax
    bra .loop
.exit:
    stz.w DmaQueueOffset
    stz.w DmaQueueOffset+1
    ldy.w #GfxBuffer
    sty.w GfxBufferPtr
    rts
