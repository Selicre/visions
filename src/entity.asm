; Entity manager & helper methods

RunEntities:
    stz.w CurrentEntity
    ldx.w CurrentEntity
.loop:
    lda.w EntityPtr,x
    bpl .return         ; If less than $8000, skip over this sprite
    sta.b Scratch+$00
    lda.w EntityPtrBank,x
    sta.b Scratch+$02
    ; Make sure you can rtl here
    phk : pea .return-1
    jml [$0000]
.return:
    phk : plb
    ldx.w CurrentEntity
    inx #2
    stx.w CurrentEntity
    cpx.w #!EntityCount
    bne .loop
    rts

DoCollision:
    phb : phk : plb

    stz.w EntityCollide
    ; do X first
    jsr ApplySpeedX
    jsr DoLayerCollisionX

    ; then Y
    jsr ApplySpeedY
    jsr DoLayerCollisionY

    plb
    rtl

; Scratch stuff
LayerCollPtr = Scratch
LayerCollPtrEnd = Scratch+3
LayerCollClampPos = Scratch+5
LayerCollDirection = Scratch+7

DoLayerCollisionX:
    ; set up longptr to block
    lda.w #$007F
    sta.b LayerCollPtr+2
    ; Obtain row pointer
    lda.w EntityVelX,x
    sta.b LayerCollDirection    ; stash initial speed
    php                         ; keep the N flag
    lda.w EntityWidth,x
    and.w #$00FF
    plp
    bpl +
    eor #$FFFF : inc
+
    sta.b Scratch+9
    clc : adc.w EntityPosX,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    sta.b LayerCollClampPos
    sta.w UpdateBlockX

    ; check if we need to collide to begin with (TODO: unfuck this)
    lda.w Scratch+9
    clc : adc.w EntityLastPos,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    cmp.b LayerCollClampPos
    beq .exit


    ; Figure out the end block
    lda.w EntityHeight,x
    and.w #$00FF
    clc : adc.w EntityPosY,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    tay
    lda.w LevelRows,y
    clc : adc.b LayerCollClampPos
    sta.b LayerCollPtrEnd

    ; Figure out the start block
    lda.w EntityHeight,x
    and.w #$00FF
    eor #$FFFF : inc
    clc : adc.w EntityPosY,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    sta.w UpdateBlockY
    tay
    lda.w LevelRows,y
    clc : adc.b LayerCollClampPos
    sta.b LayerCollPtr
.loop:
    lda.b [LayerCollPtr]
    asl
    tax
    jsr (BlockXRoutine,x)
    ldx.w CurrentEntity
    lda.b LayerCollPtr
    cmp.b LayerCollPtrEnd
    php
    clc : adc.w LevelWidth
    rep 2 : inc.w UpdateBlockY
    sta.b LayerCollPtr
    plp
    bne .loop
.exit:
    rts

DoLayerCollisionY:
    ; set up longptr to block
    lda.w #$007F
    sta.b LayerCollPtr+2
    ; Obtain row pointer
    lda.w EntityVelY,x
    sta.b LayerCollDirection
    php                     ; keep the N flag
    lda.w EntityHeight,x
    and.w #$00FF
    plp
    bpl +
    eor #$FFFF : inc
+
    sta.b Scratch+9
    clc : adc.w EntityPosY,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    sta.b LayerCollClampPos
    sta.w UpdateBlockY

    ; check if we need to collide to begin with (TODO: unfuck this)
    lda.b Scratch+9
    clc : adc.w EntityLastPos,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    cmp.b LayerCollClampPos
    beq .exit

    ldy.b LayerCollClampPos
    lda.w LevelRows,y
    sta.b Scratch+9
    ; Figure out the end block
    lda.w EntityWidth,x
    and.w #$00FF
    clc : adc.w EntityPosX,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    clc : adc.b Scratch+9
    sta.b LayerCollPtrEnd
    ; Figure out the start block
    lda.w EntityWidth,x
    and.w #$00FF
    eor #$FFFF : inc
    clc : adc.w EntityPosX,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    sta.w UpdateBlockX
    clc : adc.b Scratch+9
    sta.b LayerCollPtr
.loop:
    lda.b [LayerCollPtr]
    asl
    tax
    jsr (BlockYRoutine,x)
    ldx.w CurrentEntity
    lda.b LayerCollPtr
    cmp.b LayerCollPtrEnd
    php
    inc #2
    rep 2 : inc.w UpdateBlockX
    sta.b LayerCollPtr
    plp
    bne .loop
.exit:
    rts

ApplySpeedX:
    lda.w EntityPosX,x
    sta.w EntityLastPos,x
    sep #$20
    clc

    lda.w EntitySubPosX,x
    adc.w EntityVelX,x
    sta.w EntitySubPosX,x

    lda.w EntityPosX,x
    adc.w EntityVelX+1,x
    sta.w EntityPosX,x

    lda.w EntityVelX+1,x
    bmi .belowZero

    lda.w EntityPosX+1,x
    adc.b #$00
    sta.w EntityPosX+1,x
    rep #$20
    rts
.belowZero:
    lda.w EntityPosX+1,x
    adc.b #$FF
    sta.w EntityPosX+1,x
    rep #$20
    rts

ApplySpeedY:
    lda.w EntityPosY,x
    sta.w EntityLastPos,x
    sep #$20
    clc

    lda.w EntitySubPosY,x
    adc.w EntityVelY,x
    sta.w EntitySubPosY,x

    lda.w EntityPosY,x
    adc.w EntityVelY+1,x
    sta.w EntityPosY,x

    lda.w EntityVelY+1,x
    bmi .belowZero

    lda.w EntityPosY+1,x
    adc.b #$00
    sta.w EntityPosY+1,x
    rep #$20
    rts
.belowZero:
    lda.w EntityPosY+1,x
    adc.b #$FF
    sta.w EntityPosY+1,x
    rep #$20
    rts

DrawEntity:
    phx
    ldx.w CurrentEntity
    lda.w EntityPosX,x
    sec : sbc.b CamX
    sta.w OamOffsetX
    lda.w EntityPosY,x
    sec : sbc.b CamY
    sta.w OamOffsetY
    lda.w EntityRender,x
    sta.w OamFlipMask
    plx
    jmp DrawSpriteTilemap
