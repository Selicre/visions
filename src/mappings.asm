BlockMappings:
    dw $00F8, $00F8, $00F8, $00F8   ; Air
    dw $1868, $1869, $186A, $186B   ; Turnblock
    dw $1C68, $1C69, $1C6A, $1C6B   ; Throw block
    dw $1848, $1849, $184A, $184B   ; Turnblock
    dw $0982, $0983, $0992, $0993   ; Grass
    dw $0994, $0995, $0992, $0993   ; Dirt
    dw $1030, $1031, $1032, $1033   ; Cement
    dw $186C, $186D, $186E, $186F   ; Coin
    dw $182D, $582D, $982D, $D82D   ; Cement air
    dw $1858, $1859, $185A, $185B   ; Used block

BlockXRoutine:
    dw BlockNone
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockSolidX
    dw BlockCoin
    dw BlockNone
    dw BlockSolidX

BlockYRoutine:
    dw BlockNone
    dw BlockSolidY
    dw BlockSolidY
    dw BlockQuestion
    dw BlockSolidY
    dw BlockSolidY
    dw BlockSolidY
    dw BlockCoin
    dw BlockNone
    dw BlockSolidY

BlockNone:
    rts

BlockCoin:
    lda.w #$0008
    sta.b [LayerCollPtr]
    jsr UpdateTilemapBlock
    ldx.w CurrentEntity
    rts

BlockQuestion:
    wdm
    lda.b LayerCollDirection
    bpl +
    lda.w #$0009
    sta.b [LayerCollPtr]
    jsr UpdateTilemapBlock
+
    jmp BlockSolidY
