
BounceBlockInit:
    lda.w #$FFFF
    sta.w ExtEntityData0,x
    lda.w #BounceBlock
    sta.w ExtEntityPtr,x

BounceBlock:
    phk : plb

    lda.w ExtEntityData0,x
    inc
    sta.w ExtEntityData0,x
    cmp.w #$0008
    bmi +
    lda.w #$0000
    sta.w ExtEntityPtr,x
    ; Change block
    lda.w ExtEntityPosX,x
    lsr #3
    sta.w UpdateBlockX
    lda.w ExtEntityPosY,x
    lsr #3
    sta.w UpdateBlockY
    lda.w #$007F
    sta.w Scratch+2
    lda.w ExtEntityData1,x
    sta.b Scratch
    lda.w ExtEntityData3,x
    sta.b [Scratch]
    wdm
    jsl UpdateTilemapBlock
    rtl
+

    lda.w ExtEntityPosX,x
    sec : sbc.w CamX
    sta.w OamOffsetX
    ldy.w ExtEntityData0,x
    lda.w BounceBlockOffsets,y
    ora.w #$FF00
    clc : adc.w ExtEntityPosY,x
    sec : sbc.w CamY
    ;clc : adc.w #$0004
    sta.w OamOffsetY
    lda.w ExtEntityData2,x
    jsl DrawLargeTile
    ldx.w CurrentEntity
    rtl

BounceBlockOffsets:
    db $FC, $F9, $F7, $F6, $F6, $F7, $F9, $FC
