
BounceBlockInit:
    lda.w #$0000
    sta.w ExtEntityData0,x
    lda.w #CoinSparkle
    sta.w ExtEntityPtr,x

BounceBlock:
    phk : plb
