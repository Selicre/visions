BlockMappings:
    dw $00F8, $00F8, $00F8, $00F8   ; 0 Air
    dw $1806, $1807, $1816, $1817   ; 1 Turn block
    dw $1C06, $1C07, $1C16, $1C17   ; 2 Throw block
    dw $1860, $1861, $1862, $1863   ; 3 Question block
    dw $0982, $0983, $0992, $0993   ; 4 Grass
    dw $0994, $0995, $0992, $0993   ; 5 Dirt
    dw $1030, $1031, $1032, $1033   ; 6 Cement
    dw $186C, $186D, $186E, $186F   ; 7 Coin
    dw $182D, $582D, $982D, $D82D   ; 8 Outlined air
    dw $1858, $1859, $185A, $185B   ; 9 Used block
    dw $1C2C, $5C2C, $1C3C, $5C3C   ; A Cloud
    dw $00F8, $00F8, $00F8, $00F8   ; B Block placeholder

BlockXRoutine:
    dw BlockNone
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockCoin
    dw BlockNone
    dw BlockSolidX
    dw BlockNone
    dw BlockSolidX
    dw BlockSolidX

BlockYRoutine:
    dw BlockNone
    dw BlockTurnBlock
    dw BlockTreadmill
    dw BlockQuestion
    dw BlockSolidY
    dw BlockSolidY
    dw BlockSolidY
    dw BlockCoin
    dw BlockNone
    dw BlockSolidY
    dw BlockTopSolid
    dw BlockSolidY
    dw BlockSolidY

BlockNone:
    rts

BlockCoin:
    ldx.w CurrentEntity     ; check for player entity
    cpx #$0000
    bne +
    lda.w #$0000
    sta.b [LayerCollPtr]
    jsl UpdateTilemapBlock

    %ext_entity_slot()
    lda.w UpdateBlockX
    asl #3
    sta.w ExtEntityPosX,x
    lda.w UpdateBlockY
    asl #3
    sta.w ExtEntityPosY,x
    lda.w #CoinSparkleInit
    sta.w ExtEntityPtr,x

    ldx.w CurrentEntity
+
    rts

BlockQuestion:
    lda.b LayerCollDirection
    bpl +
    lda.w #$000B
    sta.b [LayerCollPtr]
    jsl UpdateTilemapBlock

    %ext_entity_slot()
    lda.w UpdateBlockX
    asl #3
    sta.w ExtEntityPosX,x
    lda.w UpdateBlockY
    asl #3
    sta.w ExtEntityPosY,x
    lda.w #BounceBlockInit
    sta.w ExtEntityPtr,x
    lda.b LayerCollPtr
    sta.w ExtEntityData1,x
    lda.w #$202A
    sta.w ExtEntityData2,x
    lda.w #$0009
    sta.w ExtEntityData3,x

    ldx.w CurrentEntity
+
    jmp BlockSolidY

BlockTurnBlock:
    lda.b LayerCollDirection
    bpl +
    lda.w #$000B
    sta.b [LayerCollPtr]
    jsl UpdateTilemapBlock

    %ext_entity_slot()
    lda.w UpdateBlockX
    asl #3
    sta.w ExtEntityPosX,x
    lda.w UpdateBlockY
    asl #3
    sta.w ExtEntityPosY,x
    lda.w #BounceBlockInit
    sta.w ExtEntityPtr,x
    lda.b LayerCollPtr
    sta.w ExtEntityData1,x
    lda.w #$2040
    sta.w ExtEntityData2,x
    lda.w #$0001
    sta.w ExtEntityData3,x

    ldx.w CurrentEntity
+
    jmp BlockSolidY

BlockTopSolid:
    lda.b LayerCollDirection
    bmi +
    jmp BlockSolidY
+
    rts

BlockTreadmill:
    ldx.w CurrentEntity
    lda.w #$0200
    sta.w EntitySurfaceVel,x
    jmp BlockSolidY

BlockSolidX:
    ldx.w CurrentEntity
    ; if not, clamp position
    lda.b LayerCollDirection
    bpl +
    ; if speed is negative, then push out to the right
    ; calculate the target position
    lda.b LayerCollClampPos
    inc #2
    asl #3
    sta.b Scratch+9
    lda.w EntityWidth,x
    and.w #$00FF
    clc : adc.b Scratch+9
    sta.w EntityPosX,x
    sep #$20 : stz.w EntitySubPosX,x : rep #$20
    stz.w EntityVelX,x
    lda.w EntityCollide,x
    ora.w #$0002
    sta.w EntityCollide,x
    rts
+
    ; do the same but to the right
    lda.b LayerCollClampPos
    asl #3
    dec
    sta.b Scratch+9
    lda.w EntityWidth,x
    and.w #$00FF
    eor.w #$FFFF : inc
    clc : adc.b Scratch+9
    sta.w EntityPosX,x
    sep #$20 : lda.b #$F0 : sta.w EntitySubPosX,x : rep #$20
    stz.w EntityVelX,x
    lda.w EntityCollide,x
    ora.w #$0001
    sta.w EntityCollide,x
    rts

BlockSolidY:
    ldx.w CurrentEntity
    ; if not, clamp position
    lda.w LayerCollDirection
    bpl +
    ; if speed is negative, then push out to the bottom
    ; calculate the target position
    lda.b LayerCollClampPos
    inc #2
    asl #3
    sta.b Scratch+9
    lda.w EntityHeight,x
    and.w #$00FF
    clc : adc.b Scratch+9
    sta.w EntityPosY,x
    sep #$20 : stz.w EntitySubPosY,x : rep #$20
    stz.w EntityVelY,x
    lda.w EntityCollide,x
    ora.w #$0004
    sta.w EntityCollide,x
    rts
+
    ; do the same but to the top
    lda.b LayerCollClampPos
    asl #3
    dec
    sta.b Scratch+9
    lda.w EntityHeight,x
    and.w #$00FF
    eor.w #$FFFF : inc
    clc : adc.b Scratch+9
    sta.w EntityPosY,x
    sep #$20 : lda.b #$F0 : sta.w EntitySubPosY,x : rep #$20
    stz.w EntityVelY,x
    lda.w EntityCollide,x
    ora.w #$0008
    sta.w EntityCollide,x
    rts
