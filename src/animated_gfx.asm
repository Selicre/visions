
AnimateGfx:
    lda.w GlobalAnimTimer
    bit.w #$0007    ; is it divisible by 8?
    bne +
    lsr #3          ; divide by 8
    and.w #$0003    ; mod 4
    xba             ; * 100
    asl             ; * 2
    ; build DMA queue entries
    ldx.w DmaQueueOffset
    clc : adc.w #AnimatedGfx+$1800
    sta.w DmaQueueAddr,x
    lda.w #$0C00/2
    sta.w DmaQueueDest,x
    lda.w #$0200
    sta.w DmaQueueSize,x

    sep #$20
    lda.b #AnimatedGfx>>16
    sta.w DmaQueueAddr+2,x
    stz.w DmaQueueMode,x
    rep #$20

    txa
    clc : adc.w #$0008
    sta.w DmaQueueOffset
+
    inc.w GlobalAnimTimer
    rts
