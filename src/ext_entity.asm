; Extended entities (particles, etc.)


RunExtEntities:
    stz.w CurrentEntity
    ldx.w CurrentEntity
.loop:
    lda.w ExtEntityPtr,x
    bpl .return         ; If less than $8000, skip over this sprite
    sta.b Scratch+$00
    lda.w #$0002        ; Always in bank $02
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
