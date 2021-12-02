UpdateJoypad:
    ; Wait until joypad poll is finished
    sep #$30
    lda #$01
-
    bit $4212
    bne -
    rep #$30

    ; Update joypad
    lda.w Joypad1Held
    eor.w #$FFFF
    and.w JOY1
    sta.w Joypad1Edge
    lda.w JOY1
    sta.w Joypad1Held

    lda.w Joypad2Held
    eor.w #$FFFF
    and.w JOY2
    sta.w Joypad2Edge
    lda.w JOY2
    sta.w Joypad2Held

    rts

