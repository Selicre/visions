
EntityGaloombaInit:
    lda.w #EntityGaloomba
    sta.w EntityPtr,x
    lda.w #EntityGaloombaRender
    sta.w EntityRenderPtr,x
    lda.w #$0606
    sta.w EntitySize,x
    lda.w #$0001
    sta.w EntityPhysics,x
EntityGaloomba:
    phk : plb
    lda.w #$0100
    sta.w EntityVelX,x
    lda.w EntityVelY,x
    cmp.w #$0400
    bmi +
    lda.w #$0400
+
    clc : adc.w #$0030
    sta.w EntityVelY,x
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
    lda.w #$26A8
    jsl DrawLargeTile
    rtl
