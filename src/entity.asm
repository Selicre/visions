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

; Scratch stuff
LayerCollPtr = Scratch
LayerCollPtrEnd = Scratch+3
LayerCollClampPos = Scratch+5
LayerCollDirection = Scratch+7

DoEntityCollisionY:
;    lda.w EntityVelY,x
;    bpl +
;    rts
;+
    ldy.w #$0000
.loop:
    lda.w EntityPtr,y
    bne +
    jmp .next
+
    ; Check Y velocity
    lda.w EntityVelY,x
    sec : sbc EntityVelY,y
    bpl +
    jmp .next
+
    ; Check X
    lda.w EntityPosX,x
    sec : sbc.w EntityPosX,y
    bpl +
    eor #$FFFF : inc
+
    sta.b Scratch
    lda.w #$0000
    sep #$20
    lda.w EntityWidth,x
    clc : adc.w EntityWidth,y
    rep #$20
    cmp.w Scratch
    bmi .next


    ; Get height
    lda.w #$0000
    sep #$20
    lda.w EntityHeight,y
    clc : adc.w EntityHeight,x
    rep #$20
    sta.w Scratch

    wdm

    ; Check if our last pos < their pos
    lda.w EntityPosY,y
    sec : sbc.w Scratch

    inc : inc

    cmp.w EntityLastPos,x
    bmi .next

    lda.w EntityLastPos,y
    sec : sbc.w Scratch

    dec : dec

    cmp.w EntityPosY,x
    bpl .next


    lda.w EntityPosY,y
    sec : sbc.w Scratch
    sta.w EntityPosY,x
    sep #$20 : lda.w EntitySubPosY,y : sta.w EntitySubPosY,x : rep #$20
    lda.w EntityVelY,y
    clc : adc.w #$0100
    sta.w EntityVelY,x
    lda.w EntityCollide,x
    ora.w #$0008
    sta.w EntityCollide,x

    ; Make sure you also move along
    lda.w EntityVelX,y
    sta.w EntitySurfaceVel,x


.next:
    iny #2
    cpy.w #!EntityCount
    bpl +
    jmp .loop
+
    rts

DoCollision:
    phb : phk : plb

    stz.w EntityCollide
    ; do Y first
    jsr ApplySpeedY
    jsr DoLayerCollisionY
    ; then X
    jsr ApplySpeedX
    jsr DoLayerCollisionX

    plb
    rtl

DoLayerCollisionX:
    ; set up longptr to block
    lda.w #$007F
    sta.b LayerCollPtr+2
    ; Obtain row pointer
    lda.w EntityVelX,x
    clc : adc.w EntitySurfaceVel,x
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

if 0
    ; check if we need to collide to begin with (TODO: unfuck this)
    lda.w Scratch+9
    clc : adc.w EntityLastPos,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    cmp.b LayerCollClampPos
    beq .exit
    endif


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
    inc
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
    sta.b Scratch+$0B
    clc : adc.w EntityPosY,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    sta.b LayerCollClampPos
    sta.w UpdateBlockY

;if 0
    ; check if we need to collide to begin with (TODO: unfuck this)
    lda.b Scratch+$0B
    clc : adc.w EntityLastPos,x
    bpl +
    lda #$0000
+
    lsr #4 : asl
    cmp.b LayerCollClampPos
    beq .exit
;endif

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
