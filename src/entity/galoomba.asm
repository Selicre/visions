
EntityGaloombaInit:
    lda.w #EntityGaloomba
    sta.w EntityPtr,x
    lda.w #EntityGaloombaRender
    sta.w EntityRenderPtr,x
    lda.w #$0606
    sta.w EntitySize,x
    lda.w #$0001
    sta.w EntityPhysics,x
    lda.w #$0080
    sta.w EntityVelX,x
    lda.w #$4000
    sta.w EntityRender,x
    lda.w #$0002
    sta.w EntityInteract,x
EntityGaloomba:
    phk : plb
    lda.w EntityCollide,x
    bit.w #$0002
    beq +
    lda.w #$0080
    sta.w EntityVelX,x
    lda.w #$4000
    sta.w EntityRender,x
+
    lda.w EntityCollide,x
    bit.w #$0001
    beq +
    lda.w #-$0080
    sta.w EntityVelX,x
    lda.w #$0000
    sta.w EntityRender,x
+
    lda.w EntityVelY,x
    cmp.w #$0400
    bmi +
    lda.w #$0400
+
    clc : adc.w #$0030
    sta.w EntityVelY,x
    inc.w EntityAnimTimer,x

    ;wdm
    ; run e2e shit
    ldy.w #$0000
.e2eloop:
    jsl FindEntityIntersect
    bcs .exit
    lda.w EntityInteract,y
    bit.w #$0001
    beq .notplayer
    lda.w EntityVelY,x
    sec : sbc.w EntityVelY,y
    bcc .hurtplayer
    lda.w #EntityGaloombaStunned
    sta.w EntityPtr,x
    lda.w #-$500
    sta.w EntityVelY,y
    stz.w EntityVelX,x
    bra +
.hurtplayer:
    lda.w EntityCollide,y
    ora.w #$0010
    sta.w EntityCollide,y
    ; TODO: flip
+
.notplayer:
    lda.w EntityInteract,y
    bit.w #$0002
    beq .nobounce
    wdm
    lda.w EntityPosX,x
    sec : sbc.w EntityPosX,y
    bmi +
    lda.w #$0080
    sta.w EntityVelX,x
    lda.w #$4000
    sta.w EntityRender,x
    bra ++
+
    lda.w #-$0080
    sta.w EntityVelX,x
    lda.w #$0000
    sta.w EntityRender,x
++
.nobounce:
    iny #2
    bra .e2eloop
.exit:
    rtl

EntityGaloombaStunned:
    lda.w #$8000
    sta.w EntityRender,x
    inc.w EntityAnimTimer,x
    rtl

EntityGaloombaRender:
    lda.w EntityPosX,x
    sec : sbc.w CamX
    sec : sbc.w #$0008
    sta.w OamOffsetX

    lda.w EntityPosY,x
    sec : sbc.w CamY
    sec : sbc.w #$0008
    sta.w OamOffsetY
    ; todo: maybe not like this
    lda.w EntityAnimTimer,x
    lsr #3
    and.w #$0001
    asl
    eor.w #$24A8
    eor.w EntityRender,x
    jsl DrawLargeTile
    rtl
