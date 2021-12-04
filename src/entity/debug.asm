;; Debug controller, to test collision and stuff

EntityDebugTilemap:
    ;db $00, $F0, $C6, $06, $01
    ;db $F8, $E8, $82, $04, $01
    ;db $F8, $F8, $A2, $04, $01
    db $F8, $F6, $A8, $04, $01

EntityDebugInit:
    lda.w #EntityDebug
    sta.w EntityPtr,x
    lda.w #$0606
    sta.w EntitySize,x


EntityDebug:
    phk : plb
    ;lda.w #$0100
    ;sta.w EntityVelY,x

    ldy.w #$0000
    lda.w Joypad1Held
    bit.w #JOY_Left
    beq +
    ldy.w #$FE01
+
    bit.w #JOY_Right
    beq +
    ldy.w #$0201
+
    tya
    sta.w EntityVelX,x

    lda.w Joypad1Held
    ldy.w #$0000
    bit.w #JOY_Up
    beq +
    ldy.w #$FE01
+
    bit.w #JOY_Down
    beq +
    ldy.w #$0201
+
    tya
    sta.w EntityVelY,x

    ;jsl ApplySpeed
    jsl DoCollision

    ldx.w #EntityDebugTilemap
    ldy.w #$0001
    jsl DrawEntity
    rtl
