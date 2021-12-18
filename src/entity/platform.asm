; Regular brown platform
; mostly for testing

EntityPlatformTilemap:
    ;db $00, $F0, $C6, $06, $01
    ;db $F8, $E8, $82, $04, $01
    ;db $F8, $F8, $A2, $04, $01
    ;db $F8, $F6, $A8, $04, $01
    db $E8, $FC, $60, $21, $01
    db $F8, $FC, $61, $21, $01
    db $08, $FC, $62, $21, $01

EntityPlatformInit:
    lda.w #EntityPlatform
    sta.w EntityPtr,x
    lda.w #EntityPlatformRender
    sta.w EntityRenderPtr,x
    lda.w #$0518
    sta.w EntitySize,x
    lda.w #$0000
    sta.w EntityData0,x
    lda.w #$0002
    sta.w EntityPhysics,x
EntityPlatform:
    phk : plb
    ;jsl ApplySpeed

    ;lda.w #$0100
    ;sta.w EntityVelX,x

    inc.w EntityData0,x
    lda.w EntityData0,x
    lsr #2
    and.w #$003E
    tay
    lda.w EntityPlatformVelData,y
    sta.w EntityVelY,x


    lda.w EntityData0,x
    clc : adc.w #$0008
    lsr
    and.w #$003E
    tay
    lda.w EntityPlatformVelData,y
    sta.w EntityVelX,x

    rtl

EntityPlatformRender:
    phk : plb
    ldx.w #EntityPlatformTilemap
    ldy.w #$0003
    jsl DrawEntity
    rtl

EntityPlatformVelData:
    dw 0, 99, 195, 284, 362, 425, 473, 502, 512, 502, 473, 425, 362, 284, 195, 99
    dw 0, -99, -195, -284, -362, -425, -473, -502, -512, -502, -473, -425, -362, -284, -195, -99
