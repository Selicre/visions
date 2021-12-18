; Entity manager & helper methods

!uhhh = 0
macro entity_loop()
    stz.w CurrentEntity
    ldx.w CurrentEntity
.label!uhhh
endmacro

macro entity_loop_end()
    ldx.w CurrentEntity
    inx #2
    stx.w CurrentEntity
    cpx.w #!EntityCount
    bne .label!uhhh
    !uhhh += 1
endmacro

RunEntities:
%entity_loop()
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
%entity_loop_end()
    rts

CollideEntities:
    ; inline these loops in the future for performance
    ; maybe codegen this and run code from SRAM? That would resolve N-M collision perf
%entity_loop()
    lda.w EntityPtr,x
    bpl .skip           ; If less than $8000, skip over this sprite
    stz.w EntityCollide,x
    stz.w EntitySurfaceVel,x
    jsr ApplySpeedY     ; Calculate next position
.skip:
%entity_loop_end()
%entity_loop()
    lda.w EntityPtr,x
    bpl +               ; If less than $8000, skip over this sprite
    lda.w EntityPhysics,x
    bit.w #$0001
    beq +               ; If physics not set, skip over this sprite
    jsr DoEntityCollisionY
    jsr DoLayerCollisionY
+
%entity_loop_end()
%entity_loop()
    lda.w EntityPtr,x
    bpl +               ; If less than $8000, skip over this sprite
    jsr ApplySpeedX     ; Calculate next position
+
%entity_loop_end()
%entity_loop()
    lda.w EntityPtr,x
    bpl +               ; If less than $8000, skip over this sprite
    lda.w EntityPhysics,x
    bit.w #$0001
    beq +               ; If physics not set, skip over this sprite
    jsr DoLayerCollisionX
+
%entity_loop_end()

    rts

RenderEntities:
    stz.w CurrentEntity
    ldx.w CurrentEntity
.loop:
    lda.w EntityRenderPtr,x
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


ApplySpeedX:
    lda.w EntityVelX,x
    clc : adc.w EntitySurfaceVel,x
    sta.b Scratch
    lda.w EntityPosX,x
    sta.w EntityLastPos,x
    sep #$20
    clc

    lda.w EntitySubPosX,x
    adc.b Scratch
    sta.w EntitySubPosX,x

    lda.w EntityPosX,x
    adc.b Scratch+1
    sta.w EntityPosX,x

    lda.b Scratch+1
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
