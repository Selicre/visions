;; SNES header

org $80FFC0
    db $20,$20,$20,$20,$20,$20,$20,$20  ;\ Blank title since it is unneeded.
    db $20,$20,$20,$20,$20,$20,$20,$20  ; |
    db $20,$20,$20,$20,$20          ;/
    db $30                  ; Rom type: LoROM
    db $02                  ; ROM+SRAM
    db $0A                  ; ROM size: 1MB
    db $07                  ; RAM size: 8KB
    db $01                  ; Country code: NTSC        
    db $00                  ; License code: N/A
    db $00                  ; Version: zero
    dw $0000                ; Checksum complement. (uncalculated)
    dw $0000                ; Checksum (uncalculated)
    db $FF,$FF,$FF,$FF      ;

    ; Table of interrupt vectors for native mode:
    dw Brk, Brk, Brk, NmiHandler, Brk, IrqHandler
    db $FF,$FF,$FF,$FF          ; Free space

    ; Same for emulated mode:
    dw Brk, Brk, Brk, Brk, Boot, Brk
