macro signext()
    and #$00FF
    bit #$0080
    beq ?pos
    ora #$FF00
?pos:
endmacro

; State: a8, x16
macro setup_dma(channel, source, size)
    ; source
    lda.b #<source>>>16
    sta.w A1B(<channel>)
    ldy.w #<source>
    sty.w A1T(<channel>)
    ; size
    ldy.w #<size>
    sty.w DAS(<channel>)
endmacro

; State: a8, x16
macro vram_dma(channel, mode, source, dest, size)
    lda.b #<mode>
    sta.w VMAINC
    ldy.w #$1801
    sty.w DMAP(<channel>)
    ldy.w #<dest>
    sty.w VMADD
    %setup_dma(<channel>, <source>, <size>)
endmacro

; State: a8, x16
macro vram_dma_vdest(channel, mode, source, dest, size)
    lda.b #<mode>
    sta.w VMAINC
    ldy.w #$1801
    sty.w DMAP(<channel>)
    ldy.w <dest>
    sty.w VMADD
    %setup_dma(<channel>, <source>, <size>)
endmacro

; State: a8, x16
macro cgram_dma(channel, source, dest, size)
    ldy.w #$2200
    sty.w DMAP(<channel>)
    lda.b #<dest>
    sta.w CGADD
    %setup_dma(<channel>, <source>, <size>)
endmacro

; State: a8, x16
macro oam_dma(channel, source, dest, size)
    ldy.w #$0400
    sty.w DMAP(<channel>)
    ldy.w #<dest>
    sty.w OAMADD
    %setup_dma(<channel>, <source>, <size>)
endmacro


macro offset(name)
    !offset_base_<name> = !offset_base - ?here
?here:
endmacro

macro ext_entity_slot()
    ldx.w ExtEntitySlot
    cpx.w #!ExtEntityCount
    bmi ?next
    ldx.w #$0000
    stx.w ExtEntitySlot
?next:
    inc.w ExtEntitySlot
    inc.w ExtEntitySlot
endmacro
