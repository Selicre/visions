CoinSparkleInit:
    lda.w #$0000
    sta.w ExtEntityData0,x
    lda.w #CoinSparkle
    sta.w ExtEntityPtr,x

CoinSparkle:
    phk : plb

    lda.w ExtEntityData0,x
    lsr #2
    clc : adc.w #$0004
    tay

    lda.w ExtEntityPosX,x
    sec : sbc.w CamX
    sta.w OamOffsetX
    lda.w ExtEntityPosY,x
    sec : sbc.w CamY
    clc : adc.w #$0004
    sta.w OamOffsetY
    lda.w CoinSparkleTiles,y
    and.w #$00FF
    beq +
    jsl DrawSmallTile
+
    dey

    lda.w #$0004
    clc : adc.w OamOffsetX
    sta.w OamOffsetX
    lda.w #$0008
    clc : adc.w OamOffsetY
    sta.w OamOffsetY
    lda.w CoinSparkleTiles,y
    and.w #$00FF
    beq +
    jsl DrawSmallTile
+
    dey

    lda.w #$0004
    clc : adc.w OamOffsetX
    sta.w OamOffsetX
    lda.w #-$0008
    clc : adc.w OamOffsetY
    sta.w OamOffsetY
    lda.w CoinSparkleTiles,y
    and.w #$00FF
    beq +
    jsl DrawSmallTile
+
    dey

    lda.w #-$0004
    clc : adc.w OamOffsetX
    sta.w OamOffsetX
    lda.w #-$0008
    clc : adc.w OamOffsetY
    sta.w OamOffsetY
    lda.w CoinSparkleTiles,y
    and.w #$00FF
    beq +
    jsl DrawSmallTile
+
    ldx.w CurrentEntity

.end:
    lda.w ExtEntityData0,x
    inc
    sta.w ExtEntityData0,x
    cmp.w #$0024
    bmi +
    lda.w #$0000
    sta.w ExtEntityPtr,x
+
    rtl

CoinSparkleTiles:
    db $00, $00, $00, $00, $FF, $FF, $6E, $6E, $66, $66, $00, $00, $00, $00
