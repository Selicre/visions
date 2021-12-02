GamemodeLoad:

    lda.w #NmiMain
    sta.b NmiPtr
    ; Setup level stuff

    lda.w #LevelData
    sta.w Scratch
    lda.w #$007F
    sta.w Scratch+2

    ldx.w #$0000
    ldy.w #$0000
-
    lda.l TestLevelData,x
    and.w #$00FF
    sta.b [Scratch],y
    iny #2
    inx
    cpx.w #64*64
    bne -

    lda.w #$0400-$100
    sta.w CamBoundaryRight

    lda.w #$0080
    sta.w LevelWidth

    lda.w #$0000
    sta.w HorizontalSeam

    lda.w #$0000
    sta.w VerticalSeam


    ; Upload graphics
    sep #$20
    %cgram_dma(0, TestPal, $0000, $0200)
    lda #$01
    sta.w MDMAEN

    %vram_dma(0, $80, TestGfx, $0000, $4000)
    lda #$01
    sta.w MDMAEN

    %vram_dma(0, $80, SprGfx, $6000, $4000)
    lda #$01
    sta.w MDMAEN

    ; setup level modes
    lda.b #$01
    sta.w BGMODE
    lda.b #$11
    sta.w TM
    lda.b #$A1
    sta.w BG1SC
    lda.b #$B1
    sta.w BG2SC

    lda.b #%00000111
    sta.w OBSEL

    rep #$20

    jsr SetupRowPtrs
    lda #$0000
-
    pha
    jsr RenderTilemapRow
    sep #$20
    jsr DmaQueueExec
    rep #$20
    pla
    inc #2
    cmp #$0020
    bne -

    sep #$20

    lda #$0F
    sta.w INIDISP       ; end f-blank
    rep #$20

    ; Switch gamemode
    lda.w #GamemodeMain
    sta.w GamemodePtr
    rts


CoolTilemap:
    db $00, $00, $00, $00, $01
    db $00, $10, $02, $00, $01

GamemodeMain:
    lda.w Joypad1Held
    bit.w #JOY_Left
    beq +
    lda.b CamX
    sec : sbc.w #$0010
    sta.b CamX
    bpl +
    stz.b CamX
+
    lda.w Joypad1Held
    bit.w #JOY_Right
    beq +
    lda.b CamX
    clc : adc.w #$0010
    cmp.w CamBoundaryRight
    bmi ++
    lda.w CamBoundaryRight
++
    sta.b CamX
+
    lda.w Joypad1Held
    bit.w #JOY_Up
    beq +
    lda.b CamY
    sec : sbc.w #$0010
    sta.b CamY
    bpl +
    stz.b CamY
+
    lda.w Joypad1Held
    bit.w #JOY_Down
    beq +
    lda.b CamY
    clc : adc.w #$0010
    sta.b CamY
+
    ;       vhoopppc
    lda.w #%0011000000000000
    sta.w OamPropMask
    lda.w #$0080
    sec : sbc.b CamX
    sta.w OamOffsetX

    lda.w #$0080
    sec : sbc.b CamY
    sta.w OamOffsetY

    ldx.w #CoolTilemap
    ldy.w #$0002
    jsl DrawSpriteTilemap

    ; Scrolling Y
    lda.b CamY
    lsr #3
    and.w #$FFFE
    cmp.w VerticalSeam
    beq .skipY
    bmi +
    inc.w VerticalSeam
    inc.w VerticalSeam
    clc : adc.w #$1E
    bra ++
+
    dec.w VerticalSeam
    dec.w VerticalSeam
    lda.w VerticalSeam
++
    jsr RenderTilemapRow
.skipY:
    ; Scrolling X
    lda.b CamX
    lsr #3
    and.w #$FFFE
    cmp.w HorizontalSeam
    beq .skipX
    bmi +
    inc.w HorizontalSeam
    inc.w HorizontalSeam
    clc : adc.w #$3E
    bra ++
+
    dec.w HorizontalSeam
    dec.w HorizontalSeam
    lda.w HorizontalSeam
++
    jsr RenderTilemapColumn
.skipX:

    rts


NmiMain:
    lda.b CamX
    sta.w Layer1X
    sep #$20
    sta.w BG1HOFS
    xba
    sta.w BG1HOFS
    rep #$20
    lda.b CamY
    sta.w Layer1Y
    sep #$20
    sta.w BG1VOFS
    xba
    sta.w BG1VOFS
    rep #$20

    sep #$20

    lda #$80
    sta.w INIDISP       ; start f-blank

    jsr DmaQueueExec

    lda #$0F
    sta.w INIDISP       ; end f-blank
    rep #$20
    rts
