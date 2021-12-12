;; OAM manager

; Tilemap format:
; xx yy cc cc ss
; xx: signed 8-bit X offset
; yy: signed 8-bit Y offset
; cccc: tile properties
; ss: size (0 - 8x8, 1 - 16x16)
; Drawn first to last.

; 16-bit AX
; Inputs:
; X: address of tilemap
; Y: length of tilemap
; OamOffsetX: screen space x coord
; OamOffsetY: screen space y coord
; OamPropMask: mask to OR each property word with
; Outputs:
; A,Y: clobber
; X: pointer at the end
; Clobbers 4 bytes of scratch space

DrawSpriteXPos = Scratch+2
DrawSpriteXOffset = Scratch+4
DrawSpriteSize = Scratch+6

DrawSpriteTilemap:
.loop:
    stz.b DrawSpriteXOffset
    lda.w OamFlipMask   ; get sprite flip
    bit.w #$4000        ; horizontal flip?
    beq +
    lda $0004,x         ; load size
    and #$00FF
    asl #3              ; 0px if not flipped, 8px if flipped small, 16px if flipped large
    adc #$0008
    sta.w DrawSpriteXOffset
+
    lda $0001,x         ; load y
    %signext()
    clc : adc.w OamOffsetY
    cmp #$FFF0
    bmi .next
    cmp #$00E0
    bpl .next
    sta.b Scratch

    lda $0000,x         ; load x
    %signext()
    pha
    lda DrawSpriteXOffset
    beq +
    lda 1,s
    eor.w #$FFFF : inc
    sta 1,s
+
    pla
    clc : adc.w OamOffsetX
    sec : sbc.w DrawSpriteXOffset
    cmp #$FFF0
    bmi .next
    cmp #$0100
    bpl .next

    sta.b DrawSpriteXPos
    sta.b (OamPtr)
    inc.b OamPtr
    lda.b Scratch
    sta.b (OamPtr)
    inc.b OamPtr

    lda $0002,x         ; load props
    ora.w OamPropMask
    eor.w OamFlipMask
    sta.b (OamPtr)
    inc.b OamPtr
    inc.b OamPtr

    lda.w $0004,x       ; load size
    sta.b DrawSpriteSize
    jsr HandleHiOam
.next:
    inx #5
    dey
    bne +
    rtl
+
    jmp .loop

HandleHiOam:
    ; handle hioam (TODO; this kinda sucks)
    sep #$20            ; 8-bit mode
    lda.b (HiOamPtr)
    sta.b Scratch
    phx

    lda.b DrawSpriteSize    ; load size
    beq +
    ldx.w HiOamIndex
    lda.l DrawSpriteSFlag,x
    tsb.b Scratch
+
    lda.b DrawSpriteXPos+1  ; load high byte of x
    beq +                   ; if non-zero, assume the x bit is set
    ldx.w HiOamIndex
    lda.l DrawSpriteXFlag,x
    tsb.b Scratch
+
    lda.b Scratch
    sta.b (HiOamPtr)

    plx

    rep #$20            ; 16-bit mode

    inc.w HiOamIndex    ; increment index and pointer, if necessary
    lda.w HiOamIndex
    cmp.w #$0004
    bne +
    stz.w HiOamIndex
    inc.b HiOamPtr
    sep #$20            ; TODO: better way to do this?
    lda.b #$00
    sta.b (HiOamPtr)
    rep #$20
+
    rts
DrawSpriteXFlag:
    db $01, $04, $10, $40
DrawSpriteSFlag:
    db $02, $08, $20, $80

; uses OamOffsetX & OamOffsetY for position, A as tile
DrawSmallTile:
    pha
    lda.w OamOffsetY
    cmp #$FFF0
    bmi .exit
    cmp #$00E0
    bpl .exit
    lda.w OamOffsetX
    cmp #$FFF0
    bmi .exit
    cmp #$0100
    bpl .exit
    sta.b (OamPtr)
    inc.b OamPtr
    lda.w OamOffsetY
    sta.b (OamPtr)
    inc.b OamPtr
    pla
    sta.b (OamPtr)
    inc.b OamPtr
    inc.b OamPtr

    sep #$20            ; 8-bit mode
    lda.b (HiOamPtr)
    sta.b Scratch

    lda.w OamOffsetX+1      ; load high byte of x
    beq +                   ; if non-zero, assume the x bit is set
    ldx.w HiOamIndex
    lda.l DrawSpriteXFlag,x
    tsb.b Scratch
+
    lda.b Scratch
    sta.b (HiOamPtr)
    rep #$20            ; 16-bit mode

    inc.w HiOamIndex    ; increment index and pointer, if necessary
    lda.w HiOamIndex
    cmp.w #$0004
    bne +
    stz.w HiOamIndex
    inc.b HiOamPtr
    sep #$20
    lda.b #$00
    sta.b (HiOamPtr)
    rep #$20
+
    rtl
.exit:
    pla
    rtl

; TODO: deduplicate maybe
; uses OamOffsetX & OamOffsetY for position, A as tile
DrawLargeTile:
    pha
    lda.w OamOffsetY
    cmp #$FFF0
    bmi .exit
    cmp #$00E0
    bpl .exit
    lda.w OamOffsetX
    cmp #$FFF0
    bmi .exit
    cmp #$0100
    bpl .exit
    sta.b (OamPtr)
    inc.b OamPtr
    lda.w OamOffsetY
    sta.b (OamPtr)
    inc.b OamPtr
    pla
    sta.b (OamPtr)
    inc.b OamPtr
    inc.b OamPtr

    sep #$20            ; 8-bit mode
    lda.b (HiOamPtr)
    sta.b Scratch

    ldx.w HiOamIndex
    lda.l DrawSpriteSFlag,x
    tsb.b Scratch

    lda.w OamOffsetX+1      ; load high byte of x
    beq +                   ; if non-zero, assume the x bit is set
    ldx.w HiOamIndex
    lda.l DrawSpriteXFlag,x
    tsb.b Scratch
+
    lda.b Scratch
    sta.b (HiOamPtr)
    rep #$20            ; 16-bit mode

    inc.w HiOamIndex    ; increment index and pointer, if necessary
    lda.w HiOamIndex
    cmp.w #$0004
    bne +
    stz.w HiOamIndex
    inc.b HiOamPtr
    sep #$20
    lda.b #$00
    sta.b (HiOamPtr)
    rep #$20
+
    rtl
.exit:
    pla
    rtl


ResetSprites:
    lda.w #OamBuffer
    sta.b OamPtr
    lda.w #HiOamBuffer
    sta.b HiOamPtr
    stz.w HiOamIndex
    stz.w HiOamBuffer
    rts

FillSprites:
    lda.w #$E0E0
    ldx.b OamPtr
-
    sta.w $0000,x
    inx #2
    cpx.w #OamBuffer+$200
    bmi -
    rts

UploadSprites:
    sep #$20
    %oam_dma(0, OamBuffer, $0000, $0220)
    lda #$01
    sta.w MDMAEN
    rep #$20
    rts
