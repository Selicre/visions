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
    stz.w EntityCollide
    ; do X first
    jsr ApplySpeedX
    jsr DoLayerCollisionX

    ; then Y
    jsr ApplySpeedY
    jsr DoLayerCollisionY
    rtl

DoLayerCollisionX:
    stz.b Scratch+6         ; Collided flag
    ; Obtain row pointer
    lda.w EntityVelX,x
    php                     ; keep the N flag
    lda.w EntityWidth,x
    and.w #$00FF
    plp
    bpl +
    eor #$FFFF : inc
+
    clc : adc.w EntityPosX,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    sta.b Scratch
    sta.b Scratch+2

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
    clc : adc.b Scratch
    sta.b Scratch+$10
    ; Figure out the start block
    lda.w EntityHeight,x
    and.w #$00FF
    eor #$FFFF : inc
    clc : adc.w EntityPosY,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    tay
    lda.w LevelRows,y
    clc : adc.b Scratch
    tax
.loop:
    lda.l LevelData,x
    phx
    ldx.w CurrentEntity
    jsr ResolveHCollision
    plx
    cpx.b Scratch+$10
    php
    txa
    clc : adc.w LevelWidth
    tax
    plp
    bne .loop
    ldx.w CurrentEntity
    lda.b Scratch+6
    beq +
    stz.w EntityVelX,x
+
    rts


; massive TODO. this only handles solid collision
ResolveHCollision:
    cmp #$0000
    beq +   ; if air, do nothing
    ; if not, clamp position
    lda.w EntityVelX,x
    bpl ++
    ; if speed is negative, then push out to the right
    ; calculate the target position
    lda.b Scratch
    inc #2
    asl #3
    sta.b Scratch+4
    lda.w EntityWidth,x
    and.w #$00FF
    clc : adc.b Scratch+4
    sta.w EntityPosX,x
    sep #$20 : stz.w EntitySubPosX,x : rep #$20
    inc.b Scratch+6
    lda.w EntityCollide,x
    ora.w #$0002
    sta.w EntityCollide,x
    rts
++
    ; do the same but to the right
    lda.b Scratch
    asl #3
    dec
    sta.b Scratch+4
    lda.w EntityWidth,x
    and.w #$00FF
    eor.w #$FFFF : inc
    clc : adc.b Scratch+4
    sta.w EntityPosX,x
    sep #$20 : stz.w EntitySubPosX,x : rep #$20
    inc.b Scratch+6
    lda.w EntityCollide,x
    ora.w #$0001
    sta.w EntityCollide,x
+
    rts

DoLayerCollisionY:
    stz.b Scratch+6         ; Collided flag
    ; Obtain row pointer
    lda.w EntityVelY,x
    php                     ; keep the N flag
    lda.w EntityHeight,x
    and.w #$00FF
    plp
    bpl +
    eor #$FFFF : inc
+
    clc : adc.w EntityPosY,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    sta.b Scratch+2
    tay
    lda.w LevelRows,y
    sta.b Scratch
    ; Figure out the end block
    lda.w EntityWidth,x
    and.w #$00FF
    clc : adc.w EntityPosX,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    clc : adc.b Scratch
    sta.b Scratch+$10
    ; Figure out the start block
    lda.w EntityWidth,x
    and.w #$00FF
    eor #$FFFF : inc
    clc : adc.w EntityPosX,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    clc : adc.b Scratch
    tax
.loop:
    lda.l LevelData,x
    phx
    ldx.w CurrentEntity
    jsr ResolveVCollision
    plx
    cpx.b Scratch+$10
    php
    inx #2
    plp
    bne .loop
    ldx.w CurrentEntity
    lda.b Scratch+6
    beq +
    stz.w EntityVelY,x
+
    rts

; massive TODO. this only handles solid collision
ResolveVCollision:
    cmp #$0000
    beq +   ; if air, do nothing
    ; if not, clamp position
    lda.w EntityVelY,x
    bpl ++
    ; if speed is negative, then push out to the bottom
    ; calculate the target position
    lda.b Scratch+2
    inc #2
    asl #3
    sta.b Scratch+4
    lda.w EntityHeight,x
    and.w #$00FF
    clc : adc.b Scratch+4
    sta.w EntityPosY,x
    sep #$20 : stz.w EntitySubPosY,x : rep #$20
    inc.b Scratch+6
    lda.w EntityCollide,x
    ora.w #$0004
    sta.w EntityCollide,x
    rts
++
    ; do the same but to the top
    lda.b Scratch+2
    asl #3
    dec
    sta.b Scratch+4
    lda.w EntityHeight,x
    and.w #$00FF
    eor.w #$FFFF : inc
    clc : adc.b Scratch+4
    sta.w EntityPosY,x
    sep #$20 : lda.b #$F0 : sta.w EntitySubPosY,x : rep #$20
    inc.b Scratch+6
    lda.w EntityCollide,x
    ora.w #$0008
    sta.w EntityCollide,x
+
    rts

ApplySpeedX:
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
