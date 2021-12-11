
SetupRowPtrs:
    ldx #$0000
    lda #$0000
-
    sta.w LevelRows,x
    clc : adc.w LevelWidth
    inx #2
    cpx #$0100
    bne -
    rts

RenderTilemapColumn:
    tay
    ; Calculate vram destination:
    and.w #$003F            ; wrap around
    cmp.w #$0020            ; is it on the second page?
    bmi +
    clc : adc.w #$400-$20   ; if it is, put it there
+
    clc : adc.w #$5000      ; nametable location in VRAM
    sta.b Scratch+$0A

    ; Set up seam
    ; This calculates a pointer when the tiles start being fetched
    ; from the current page rather than the next one.
    lda.w VerticalSeam
    clc : adc.w #$0020      ; next page
    tax
    lda.w LevelRows,x       ; get level offset
    clc : adc.w #LevelData  ; turn into a pointer
    sta.b Scratch+$0C

    ; Calculate how much to shift the level pointer once the seam is reached
    lda.w LevelWidth
    asl #4
    sta.b Scratch+$10

    ; Calculate when to stop drawing (and where to start from, as well)
    lda.w VerticalSeam
    and.w #$FFE0
    clc : adc.w #$0020
    tax
    lda.w LevelRows,x
    clc : adc.w #LevelData
    sta.b Scratch+$0E       ; stop value

    sta.b Scratch           ; and also the start value, too
    lda.w #$007F            ; turn into longptr
    sta.b Scratch+2

    lda.w GfxBufferPtr      ; set up gfx buffer target
    sta.b Scratch+3
    clc : adc.w #$0040
    sta.b Scratch+6

    sep #$20
    lda.b #$7F              ; write top byte as well
    sta.b Scratch+5
    sta.b Scratch+8
    rep #$20

.loop:
    ; Set up seam
    lda.b Scratch
    cmp.b Scratch+$0C
    bne +
    sec : sbc.w Scratch+$10
    sta.b Scratch
+

    lda.b [Scratch],y
    asl #3
    tax

    lda.w BlockMappings,x
    sta.b [Scratch+3]
    inc.b Scratch+3
    inc.b Scratch+3
    lda.w BlockMappings+4,x
    sta.b [Scratch+3]
    inc.b Scratch+3
    inc.b Scratch+3

    lda.w BlockMappings+2,x
    sta.b [Scratch+6]
    inc.b Scratch+6
    inc.b Scratch+6
    lda.w BlockMappings+6,x
    sta.b [Scratch+6]
    inc.b Scratch+6
    inc.b Scratch+6

    lda.b Scratch
    clc : adc.w LevelWidth
    sta.b Scratch
    cmp.b Scratch+$0E
    bne .loop

    ; Push to the DMA queue
    ldx.w DmaQueueOffset
    lda.w GfxBufferPtr
    sta.w DmaQueue+1,x
    clc : adc.w #$0040
    sta.w DmaQueue+1+8,x
    clc : adc.w #$0040
    sta.w GfxBufferPtr
    sep #$20
    lda.b #$02  ; column mode
    sta.w DmaQueue,x
    sta.w DmaQueue+8,x
    lda.b #$7F  ; bank byte
    sta.w DmaQueue+3,x
    sta.w DmaQueue+3+8,x
    rep #$20
    lda.b Scratch+$0A
    sta.w DmaQueue+4,x
    inc
    sta.w DmaQueue+4+8,x
    lda.w #$0040
    sta.w DmaQueue+6,x
    sta.w DmaQueue+6+8,x

    txa
    clc : adc.w #$0010
    sta.w DmaQueueOffset

    rts


RenderTilemapRow:
    tay
    ; calculate vram destination
    asl #5
    and.w #$03FF
    clc : adc.w #$5000  ; TODO: pull from elsewhere?
    sta.b Scratch+$0A

    ; Set up seam
    lda.w HorizontalSeam
    and.w #$003F
    sta.b Scratch+$0C

    ; Set up pointers
    lda.w HorizontalSeam
    and.w #$FFC0
    clc : adc.w #$0040          ; get horizontal position
    clc : adc.w LevelRows,y     ; get vertical position
    clc : adc.w #LevelData
    sta.b Scratch
    lda.w #$007F
    sta.b Scratch+2

    lda.w #GfxBuffer
    sta.b Scratch+3
    lda.w #$007F
    sta.b Scratch+5

    lda.w #GfxBuffer+$40
    sta.b Scratch+6
    lda.w #$007F
    sta.b Scratch+8

    ldy #$0000
.loop:
    ; Set up seam skip
    cpy.b Scratch+$0C
    bne +
    lda.b Scratch
    sec : sbc.w #$40
    sta.b Scratch
+

    lda.b [Scratch],y
    asl #3
    tax

    lda.w BlockMappings,x
    sta.b [Scratch+3]
    inc.b Scratch+3
    inc.b Scratch+3
    lda.w BlockMappings+2,x
    sta.b [Scratch+3]
    inc.b Scratch+3
    inc.b Scratch+3

    lda.w BlockMappings+4,x
    sta.b [Scratch+6]
    inc.b Scratch+6
    inc.b Scratch+6
    lda.w BlockMappings+6,x
    sta.b [Scratch+6]
    inc.b Scratch+6
    inc.b Scratch+6


    iny #2
    cpy #$0020          ; Tilemap seam
    bne +
    lda.b Scratch+3
    clc : adc.w #$0040
    sta.b Scratch+3
    lda.b Scratch+6
    clc : adc.w #$0040
    sta.b Scratch+6
+
    cpy #$0040
    bne .loop

    ; Push to the DMA queue
    ldx.w DmaQueueOffset
    lda.w GfxBufferPtr
    sta.w DmaQueue+1,x
    clc : adc.w #$0080
    sta.w DmaQueue+1+8,x
    clc : adc.w #$0080
    sta.w GfxBufferPtr
    sep #$20
    lda.b #$00  ; row mode
    sta.w DmaQueue,x
    sta.w DmaQueue+8,x
    lda.b #$7F  ; bank byte
    sta.w DmaQueue+3,x
    sta.w DmaQueue+3+8,x
    rep #$20
    lda.b Scratch+$0A
    sta.w DmaQueue+4,x
    clc : adc #$0400
    sta.w DmaQueue+4+8,x
    lda.w #$0080
    sta.w DmaQueue+6,x
    sta.w DmaQueue+6+8,x

    txa
    clc : adc.w #$0010
    sta.w DmaQueueOffset
    rts
