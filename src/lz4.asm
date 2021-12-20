; Ported from http://www.brutaldeluxe.fr/products/crossdevtools/lz4/index.html
; Needs to be uploaded to SRAM to run properly.

; A: banks
; X: compressed data offset
; Y: compressed data end
; Scratch: target ptr

Lz4DecompressData:
base $F10000
Lz4Decompress:
    phk : plb
    sta.w .literal_3+1
    sep #$20
    sta.w .match_5+1
    sta.w .match_5+2
    xba
    sta.w .read_token+3
    sta.w .match_1+3
    sta.w .get_length_1+3
    rep #$30
    sty.w .limit+1

    ldy.b Scratch       ; Init target data offset
.read_token:
    lda.l $AA0000,x     ; Read token
    inx
    sta.w .match_2+1
.literal:
    and.w #$00F0
    beq .limit          ; no literal
    cmp.w #$00F0
    bne +
    jsr .get_length_lit
    bra ++
+
    lsr #4
++
    dec
..3:
    mvn $AA,$BB
    phk : plb
.limit:
    cpx #$AAAA           ; end of stream?
    beq .end
    bpl .end
.match:
    tya
    sec
..1:
    sbc.l $AA0000,x
    inx #2
    sta.w .match_4+1
..2:
    lda.w #$AAAA        ; current token value
    and.w #$000F
    cmp.w #$000F
    bne +
    jsr .get_length_mat
+
    clc : adc.w #$0003

    phx
..4:
    ldx.w #$AAAA
..5:
    mvn $BB,$BB
    phk : plb
    plx
    bra .read_token
.end:
    tya
    rtl

.get_length:
..lit:
    lda.w #$000F
..mat:
    sta.w .get_length_2+1
..1:
    lda.l $AA0000,x
    inx
    and.w #$00FF
    cmp.w #$00FF
    bne .get_length_3
    clc
..2:
    adc.w #$000F
    sta.w .get_length_2+1
    bra .get_length_1
..3:
    adc.w .get_length_2+1
    rts
base off
Lz4DecompressEnd:

Lz4UploadRt:
    ; Can't DMA to SRAM, so use MVN
    %mvn(Lz4DecompressData, Lz4Decompress, Lz4DecompressEnd-Lz4DecompressData)
    rts
