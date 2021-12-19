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
    cpx.w #512*32
    bne -

    lda.w #$2000-$100
    sta.w CamBoundaryRight
    lda.w #$0200-$E0
    sta.w CamBoundaryBottom

    lda.w #$0400
    sta.w LevelWidth

    lda.w #$0040
    sta.w LevelHeight

    lda.w #$0000
    sta.w HorizontalSeam

    lda.w #$0000
    sta.w VerticalSeam

    lda.w #EntityPlayerInit
    sta.w EntityPtr
    ;sta.w EntityPtr+2

    lda.w #EntityPlayerInit>>16
    sta.w EntityPtrBank
    ;sta.w EntityPtrBank+2
    lda.w #$0020
    sta.w EntityPosX
    sta.w EntityPosY

    lda.w #$0040
    ;sta.w EntityPosX+2
    ;sta.w EntityPosY+2

    ;lda.w #$0001
    ;sta.w EntityData1+2

    lda.w #EntityGaloombaInit
    sta.w EntityPtr+8
    sta.w EntityPtr+10
    
    lda.w #EntityGaloombaInit>>16
    sta.w EntityPtrBank+8
    sta.w EntityPtrBank+10

    lda.w #$00F0
    sta.w EntityPosX+8
    lda.w #$00A0
    sta.w EntityPosY+8

    lda.w #$00C0
    sta.w EntityPosX+10
    lda.w #$00A0
    sta.w EntityPosY+10

    lda.w #EntityPlatformInit
    sta.w EntityPtr+12
    sta.w EntityPtr+14
    
    lda.w #EntityPlatformInit>>16
    sta.w EntityPtrBank+12
    sta.w EntityPtrBank+14
    lda.w #$00C0

    sta.w EntityPosX+12
    sta.w EntityPosY+12

    sta.w EntityPosY+14
    lda.w #$00C0-0050

    sta.w EntityPosX+14

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

    ; Upload BG tilemap
    %vram_dma(0, $80, BgTilemap, $B000/2, $1000)
    lda #$01
    sta.w MDMAEN

    ; setup level modes
    lda.b #$01
    sta.w BGMODE
    lda.b #$13
    sta.w TM
    lda.b #$D1
    sta.w BG1SC
    lda.b #$D9
    sta.w BG2SC

    lda.b #%00000111
    sta.w OBSEL

    ; Fadein stuff
    lda.b #$BF
    sta.w CGADSUB
    lda #$FF
    sta.w COLDATA
    sta.w ScreenBrightness

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

if 0
    lda.w Joypad1Held
    bit.w #JOY_Left
    beq +
    lda.b CamX
    sec : sbc.w #$0010
    sta.b CamX
    bpl +
    stz.b CamX
+
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

endif
    jsr RunEntities
    jsr CollideEntities

    ldx #$0000
    jsr FollowCameraDynamic

    jsr RunExtEntities
    jsr RenderEntities
    jsr AnimateGfx

    ; Scrolling Y
    lda.b CamY
    lsr #3
    and.w #$FFFE
    cmp.w VerticalSeam
    beq .skipY
    bmi +
    inc.w VerticalSeam
    inc.w VerticalSeam
    lda.w VerticalSeam
    clc : adc.w #$1E
    bra ++
+
    dec.w VerticalSeam
    dec.w VerticalSeam
    lda.w VerticalSeam
++
    jsr RenderTilemapRow
.skipY:
;.tryAgain:
    ; Scrolling X
    lda.b CamX
    lsr #3
    and.w #$FFFE
    cmp.w HorizontalSeam
    beq .skipX
    bmi +
    inc.w HorizontalSeam
    inc.w HorizontalSeam
    lda.w HorizontalSeam
    clc : adc.w #$3E
    bra ++
+
    dec.w HorizontalSeam
    dec.w HorizontalSeam
    lda.w HorizontalSeam
++
    jsr RenderTilemapColumn
    ;bra .tryAgain

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
    dec
    sep #$20
    sta.w BG1VOFS
    xba
    sta.w BG1VOFS
    rep #$20
    lda.b BGX
    sta.w Layer2X
    sep #$20
    sta.w BG2HOFS
    xba
    sta.w BG2HOFS
    rep #$20
    lda.b BGY
    sta.w Layer2Y
    dec
    sep #$20
    sta.w BG2VOFS
    xba
    sta.w BG2VOFS
    rep #$20

    sep #$20

    lda.w ScreenBrightness
    cmp.b #$E0
    beq +
    dec
    sta.w COLDATA
    sta.w ScreenBrightness
+

    lda #$80
    sta.w INIDISP       ; start f-blank

    jsr DmaQueueExec

    lda #$0F
    sta.w INIDISP       ; end f-blank
    rep #$20
    rts

FollowCameraDynamic:
    lda.w EntityPosX,x
    sec : sbc.w CamPivot
    cmp.w #-$000C+1
    bpl .right
.left:
    ; Scroll to the left
    ; Move the camera pivot
    lda.w EntityPosX,x
    clc : adc.w #$000C
    sta.w CamPivot
    lda.w CamPivotOffset
    inc #2
    cmp.w #$0098
    bmi +
    lda.w #$0098
+
    sta.w CamPivotOffset
    bra .exit
.right:
    cmp.w #$000C
    bmi .exit
    ; Scroll to the left
    ; Move the camera pivot
    lda.w EntityPosX,x
    sec : sbc.w #$000C
    sta.w CamPivot
    lda.w CamPivotOffset
    dec #2
    cmp.w #$0066
    bpl +
    lda.w #$0066
+
    sta.w CamPivotOffset
.exit:
    lda.w CamPivot
    sec : sbc.w CamPivotOffset

    ; clamp
    cmp.w CamBoundaryLeft
    bpl +
    lda.w CamBoundaryLeft
+
    cmp.w CamBoundaryRight
    bmi +
    lda.w CamBoundaryRight
+
    sec : sbc.b CamX
    cmp.w #$0010
    bmi +
    lda.w #$0010
+
    cmp.w #$FFF0
    bpl +
    lda.w #$FFF0
+
    clc : adc.b CamX
    sta.b CamX

    lda.w EntityCollide,x
    and.w #%1000
    ora.w CamShouldScrollUp
    php
    ldy.w #$0001
    lda.w EntityPosY,x
    sec : sbc.w CamY
    cmp.w #$0020
    bpl +
    plp
    bra .forceScroll
+
    plp
    beq +
    cmp.w #$007E
    bpl +
.forceScroll:
    clc : adc #$0003
    cmp.w #$007E
    bmi +
    lda.w #$007E
+
    sty.w CamShouldScrollUp
    bra ++
+
    stz.w CamShouldScrollUp
++
    cmp.w #$0096
    bmi +
    lda.w #$0096
+
    eor #$FFFF : inc
    clc : adc.w EntityPosY,x

    cmp.w CamBoundaryTop
    bpl +
    lda.w CamBoundaryTop
+
    cmp.w CamBoundaryBottom
    bmi +
    lda.w CamBoundaryBottom
+
    sec : sbc.b CamY
    cmp.w #$0010
    bmi +
    lda.w #$0010
+
    cmp.w #$FFF0
    bpl +
    lda.w #$FFF0
+
    clc : adc.b CamY
    sta.b CamY

    lda.b CamX
    lsr #2
    sta.b BGX
    lda.b CamY
    lsr #3
    sta.b BGY


    rts
