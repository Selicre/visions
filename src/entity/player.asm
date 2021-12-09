;; Player controller, to test collision and stuff


; %yxppccct

EntityPlayerTilemap:
    ;db $00, $F0, $C6, $06, $01
    ;db $F8, $E8, $82, $04, $01
    ;db $F8, $F8, $A2, $04, $01
    ;db $F8, $F6, $A8, $04, $01
    db $F8, $F9, $02, $20, $01
    db $F8, $E9, $00, $20, $01

EntityPlayerTilemapRaised:
    ;db $00, $F0, $C6, $06, $01
    ;db $F8, $E8, $82, $04, $01
    ;db $F8, $F8, $A2, $04, $01
    ;db $F8, $F6, $A8, $04, $01
    db $F8, $F8, $02, $20, $01
    db $F8, $E8, $00, $20, $01

EntityPlayerTilePtrs:
    dw $9400, $9C40     ; 00 Standing
    dw $9400, $9800     ; 04 Walking
    dw $C8C0, $CCC0     ; 08 Jumping up
    dw $C900, $CD00     ; 0C Falling down
    dw $9400, $A500     ; 10 Dashing stand
    dw $9400, $A580     ; 14 Dashing
    dw $9400, $AD00     ; 18 Dash jump

EntityPlayerAnimPeriod:
    db $0A,$08,$06,$04,$03,$02,$01,$01

EntityPlayerInit:
    lda.w #EntityPlayer
    sta.w EntityPtr,x
    lda.w #$0806
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
    lda.w Joypad1Held
    bit.w #JOY_X|JOY_Y
    bne +
    ; walk
    lda #$0028
    bra ++
+
    ; run
    lda #$0050
    ; Deceleration
++
    sta.b Scratch

    lda.w Joypad1Held
    bit.w #JOY_Down
    bne ..exit
    ; Accelerate
    lda.w Joypad1Held
    bit.w #JOY_Left
    beq +
    lda.w EntityVelX,x
    sec : sbc.b Scratch
    sta.w EntityVelX,x
    ; set flip
    lda.w EntityRender,x
    and.w #~$4000
    sta.w EntityRender,x
+

    lda.w Joypad1Held
    bit.w #JOY_Right
    beq +
    lda.w EntityVelX,x
    clc : adc.b Scratch
    sta.w EntityVelX,x
    ; set flip
    lda.w EntityRender,x
    ora.w #$4000
    sta.w EntityRender,x
+
..exit:

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
    cmp.w #$0170
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
    lda.w .p_meter,x
    cmp.b #$70
    bmi ..no_pspeed
    lda.b #$01
    sta.w .p_speed,x
    bra ++
..no_pspeed:
    stz.w .p_speed,x
++
    rep #$20
+

    ; Handle gravity
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

.jump:
    lda.w Joypad1Edge
    bit.w #JOY_A|JOY_B
    beq ..exit
    ; check if on ground
    lda.w EntityCollide,x
    bit.w #%1000
    beq ..exit
    lda.w EntityVelX,x
    bpl +
    eor #$FFFF : inc
+
    ; / 8 * 5
    lsr #4
    sta.b Scratch
    asl #2
    adc.b Scratch
    adc.w #$04D0
    eor #$FFFF : inc
    sta.w EntityVelY,x
..exit:

if 0
.incr_anim_timer:
    ; increase timer
    lda.w EntityVelX,x
    bne ++
    lda.w #$07FF
    bra +++
++
    bpl +
    eor #$FFFF : inc
+
    clc : adc.w EntityAnimTimer,x
+++
    sta.w EntityAnimTimer,x
    and.w #$0800
    sta.b Scratch
else
.incr_anim_timer:
    lda.w EntityVelX,x
    bne +
    stz.w EntityAnimTimer,x
    bra ..exit
+
    bpl +
    eor #$FFFF : inc
+
    lsr #7
    tay
    sep #$20
    dec.w EntityAnimTimer,x
    bpl +
    lda.w EntityPlayerAnimPeriod,y
    sta.w EntityAnimTimer,x
    lda.w EntityAnimTimer+1,x
    eor.b #$01
    sta.w EntityAnimTimer+1,x
+
    rep #$20
    lda.w EntityAnimTimer,x
    and.w #$0100
    sta.b Scratch
..exit:
endif
    wdm
    ; Use raised tilemap
    stz.b Scratch+8

    ; PLAYER GRAPHICS DMA STUFF
.do_animation:
    lda.w EntityCollide,x
    bit.w #%1000
    beq ..off_ground
..on_ground:

    lda.w .p_speed,x
    bit.w #$0001
    bne ..dash
    lda.b Scratch
    beq +
    ldy #$0000      ; stand
    bra ..exit
+
    ldy #$0004      ; walk
    inc.b Scratch+8
    bra ..exit
..dash:
    lda.b Scratch
    beq +
    ldy #$0010      ; dash stand
    bra ..exit
+
    ldy #$0014      ; dash walk
    inc.b Scratch+8
    bra ..exit

..off_ground:
    ; check for p-speed
    lda.w .p_speed,x
    bit.w #$0001
    bne ..dash_jump
    lda.w EntityVelY,x
    bpl ..fall
..rise:
    ldy #$0008      ; rise
    bra ..exit
..fall:
    ldy #$000C      ; fall
    bra ..exit
..dash_jump:
    ldy #$0018      ; dash jump
..exit:

    ldx.w DmaQueueOffset
    lda.w EntityPlayerTilePtrs,y
    sta.w DmaQueueAddr+$00,x
    clc : adc.w #$0200
    sta.w DmaQueueAddr+$08,x
    lda.w EntityPlayerTilePtrs+2,y
    sta.w DmaQueueAddr+$10,x
    clc : adc.w #$0200
    sta.w DmaQueueAddr+$18,x
    lda.w #$C000/2
    sta.w DmaQueueDest+$00,x
    lda.w #$C200/2
    sta.w DmaQueueDest+$08,x
    lda.w #$C040/2
    sta.w DmaQueueDest+$10,x
    lda.w #$C240/2
    sta.w DmaQueueDest+$18,x
    lda.w #$0040
    sta.w DmaQueueSize+$00,x
    sta.w DmaQueueSize+$08,x
    sta.w DmaQueueSize+$10,x
    sta.w DmaQueueSize+$18,x
    sep #$20
    stz.w DmaQueueMode+$00,x
    stz.w DmaQueueMode+$08,x
    stz.w DmaQueueMode+$10,x
    stz.w DmaQueueMode+$18,x
    lda.b #PlayerGfx>>16
    sta.w DmaQueueAddr+2+$00,x
    sta.w DmaQueueAddr+2+$08,x
    sta.w DmaQueueAddr+2+$10,x
    sta.w DmaQueueAddr+2+$18,x
    rep #$20
    lda.w DmaQueueOffset
    clc : adc.w #$0020
    sta.w DmaQueueOffset

    jsl DoCollision

    jsr FollowCameraDynamic

    lda.b Scratch+8
    bne +
    ldx.w #EntityPlayerTilemap
    bra ++
+
    ldx.w #EntityPlayerTilemapRaised
++
    ldy.w #$0002
    jsl DrawEntity
    rtl


FollowCameraSimple:
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
    rts

FollowCameraDynamic:
    lda.w EntityPosX,x
    sec : sbc.w CamPivot
    cmp.w #-$000C+1
    bpl .right
.left:
    ; Scroll to the left
    ; Move the camera pivot (todo: do this smoothly)
    lda.w EntityPosX,x
    clc : adc.w #$000C
    sta.w CamPivot
    lda.w CamPivotOffset
    inc #2
    cmp.w #$0098
    bmi +
    lda.w #$0098
+
    sta.w CamPivotOffset
    bra .exit
.right:
    cmp.w #$000C
    bmi .exit
    ; Scroll to the left
    ; Move the camera pivot (todo: do this smoothly)
    lda.w EntityPosX,x
    sec : sbc.w #$000C
    sta.w CamPivot
    lda.w CamPivotOffset
    dec #2
    cmp.w #$0066
    bpl +
    lda.w #$0066
+
    sta.w CamPivotOffset
.exit:
    lda.w CamPivot
    sec : sbc.w CamPivotOffset

    ; clamp
    cmp.w CamBoundaryLeft
    bpl +
    lda.w CamBoundaryLeft
+
    cmp.w CamBoundaryRight
    bmi +
    lda.w CamBoundaryRight
+
    sta.b CamX

    wdm

    lda.w EntityCollide,x
    and.w #%1000
    ora.w CamShouldScrollUp
    php

    ldy.w #$0001
    lda.w EntityPosY,x
    sec : sbc.w CamY
    plp
    beq +
    cmp.w #$007E
    bpl +
    clc : adc #$0003
    sty.w CamShouldScrollUp
    bra ++
+
    stz.w CamShouldScrollUp
++
    cmp.w #$0096
    bmi +
    lda.w #$0096
+
    eor #$FFFF : inc
    clc : adc.w EntityPosY,x

    cmp.w CamBoundaryTop
    bpl +
    lda.w CamBoundaryTop
+
    cmp.w CamBoundaryBottom
    bmi +
    lda.w CamBoundaryBottom
+
    sta.b CamY
    rts
