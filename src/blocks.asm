BlockMappings:
    dw $00F8, $00F8, $00F8, $00F8   ; Air
    dw $1868, $1869, $186A, $186B   ; Turnblock
    dw $1C68, $1C69, $1C6A, $1C6B   ; Throw block
    dw $1848, $1849, $184A, $184B   ; Turnblock
    dw $0982, $0983, $0992, $0993   ; Grass
    dw $0994, $0995, $0992, $0993   ; Dirt
    dw $1030, $1031, $1032, $1033   ; Cement
    dw $186C, $186D, $186E, $186F   ; Coin
    dw $182D, $582D, $982D, $D82D   ; Outlined air
    dw $1858, $1859, $185A, $185B   ; Used block

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

BlockYRoutine:
    dw BlockNone
    dw BlockSolidY
    dw BlockSolidY
    dw BlockQuestion
    dw BlockSolidY
    dw BlockSolidY
    dw BlockSolidY
    dw BlockCoin
    dw BlockNone
    dw BlockSolidY

BlockNone:
    rts

BlockCoin:
    ldx.w CurrentEntity     ; check for player entity
    cpx #$0000
    bne +
    lda.w #$0000
    sta.b [LayerCollPtr]
    jsr UpdateTilemapBlock
    ldx.w CurrentEntity
+
    rts

BlockQuestion:
    lda.b LayerCollDirection
    bpl +
    lda.w #$0009
    sta.b [LayerCollPtr]
    jsr UpdateTilemapBlock
+
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
