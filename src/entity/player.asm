;; Player controller, to test collision and stuff

EntityPlayerTilemap:
    ;db $00, $F0, $C6, $06, $01
    ;db $F8, $E8, $82, $04, $01
    ;db $F8, $F8, $A2, $04, $01
    db $F8, $F6, $A8, $04, $01

EntityPlayerInit:
    lda.w #EntityPlayer
    sta.w EntityPtr,x
    lda.w #$0606
    sta.w EntitySize,x

; A counter that counts up when you have more than $240 speed.
EntityPlayer_p_meter = EntityData0
; Flag that determines whether the player has P-speed.
; Set when jumping off ground with p-speed, unset when on ground.
EntityPlayer_p_speed = EntityData0+1
EntityPlayer:
    phk : plb
.handle_p_speed:
    ; if !(on_ground || p_speed) then decrement
    lda.w EntityCollide,x
    and.w #%1000
    ora.w .p_speed,x
    and.w #$00FF
    beq ..decrement

    ; then check speed
    lda.w EntityVelX,x
    cmp.w #$0240
    bcc ..decrement   ; <=
    cmp.w #-$0240+1
    bcs ..decrement   ; >=
..increment:
    sep #$20
    lda.w .p_meter,x
    inc #2
    cmp.b #$70
    bmi ..not_max
    lda.b #$01
    sta.b .p_speed,x
    lda.b #$70
..not_max:
    sta.w .p_meter,x
    bra ..exit
..decrement:
    sep #$20
    lda.w .p_meter,x    ; if zero, then do not decrement it again
    beq ..exit
    dec.w .p_meter,x
..exit:
    rep #$20


.accelerate:
    ; Prepare acceleration
    lda.w Joypad1Held
    bit.w #JOY_Left
    php
    lda.w EntityVelX,x
    plp
    beq +
    eor #$FFFF : inc
+
    cmp #$0000
    bmi +
    ; Acceleration
    lda #$0018
    bra ++
+
    lda #$0050
    ; Deceleration
++
    sta.b Scratch

    ; Accelerate
    lda.w Joypad1Held
    bit.w #JOY_Left
    beq +
    lda.w EntityVelX,x
    sec : sbc.b Scratch
    sta.w EntityVelX,x
+

    lda.w Joypad1Held
    bit.w #JOY_Right
    beq +
    lda.w EntityVelX,x
    clc : adc.b Scratch
    sta.w EntityVelX,x
+

.decelerate:
    lda.w EntityCollide,x
    bit.w #%1000
    beq ..skip
    lda.w Joypad1Held
    bit.w #JOY_Left|JOY_Right
    bne ..skip
    lda.w EntityVelX,x
    cmp #$0010
    bpl ..positive
    cmp #$FFF0
    bmi ..negative
..neutral:
    lda.w #$0000
    bpl +
..positive:
    sec : sbc.w #$0010
    bpl +
..negative:
    clc : adc.w #$0010
+
    sta.w EntityVelX,x
..skip:

    ; Prepare top speed
    lda.w Joypad1Held
    bit.w #JOY_X|JOY_Y
    beq .no_run
    lda.w .p_meter,x    ; check p-meter
    cmp.w #$0070
    bne .no_pspeed
    lda #$0300
    bra +
.no_pspeed:
    lda #$0240
    bra +
.no_run:
    lda #$0140
+
    sta.b Scratch
    eor #$FFFF : inc
    sta.b Scratch+2

    ; Clamp top speed
    lda.w EntityVelX,x
    bmi +
    cmp.b Scratch
    bmi ++
    lda.b Scratch
    bra ++
+
    cmp.b Scratch+2
    bpl ++
    lda.b Scratch+2
    bra ++
++
    sta.w EntityVelX,x

.reset_p_speed:
    lda.w EntityCollide,x
    bit.w #%1000
    beq +
    sep #$20
    stz.w .p_speed,x
    rep #$20
+


.jump:
    lda.w Joypad1Edge
    bit.w #JOY_A|JOY_B
    beq ..exit
    ; check if on ground
    lda.w EntityCollide,x
    bit.w #%1000
    beq ..exit
    ; apply p-speed flag and jump
    sep #$20
    lda.w .p_meter,x
    cmp.b #$70
    bmi ..no_pspeed
    lda.b #$01
    sta.w .p_speed,x
..no_pspeed:
    rep #$20

    lda.w #$FB00
    sta.w EntityVelY,x
..exit:

    lda.w Joypad1Held
    bit.w #JOY_A|JOY_B
    php                 ; preserve N

    lda.w EntityVelY,x
    cmp.w #$0400
    bmi +
    lda.w #$0400
+
    plp
    bne +
    clc : adc.w #$0030
+
    clc : adc.w #$0030
    sta.w EntityVelY,x

    ; TODO: maybe fix this
    jsl DoCollision


if 0
    lda.w EntityPosX
    sec : sbc.w #$0080
    bpl +
    lda #$0000
+
    cmp.w CamBoundaryRight
    bmi +
    lda.w CamBoundaryRight
+
    sta.b CamX

    lda.w EntityPosY
    sec : sbc.w #$0070
    bpl +
    lda #$0000
+
    cmp.w CamBoundaryBottom
    bmi +
    lda.w CamBoundaryBottom
+
    sta.b CamY

endif


    ldx.w #EntityPlayerTilemap
    ldy.w #$0001
    jsl DrawEntity
    rtl
