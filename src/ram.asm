; Allocated memory

org $8000   ; quasar bug?
pushpc
org $8000
base $0000
Scratch: skip $20
NmiPtr: skip $02
IrqPtr: skip $02
GamemodePtr: skip $02
MainRunning: skip $01

; "Painted frame" x/y mirrors

Layer1X: skip $02
Layer1Y: skip $02
Layer2X: skip $02
Layer2Y: skip $02
Layer3X: skip $02
Layer3Y: skip $02
Layer4X: skip $02
Layer4Y: skip $02

; "Processed frame" x/y mirrors

CamX: skip $02
CamY: skip $02
BGX: skip $02
BGY: skip $02

Joypad1Held: skip $02
Joypad1Edge: skip $02
Joypad2Held: skip $02
Joypad2Edge: skip $02

OamPtr: skip $02            ; Pointer to the current OAM tile
HiOamPtr: skip $02          ; Pointer to the high OAM table
CachedRowPtr: skip $02      ; Pointer to the current cached row

print "DP usage: "
print hex(+) : +

AsyncScratch = $0200
AsyncStack = $02EF
base $02F0
AsyncSavedStatus: skip $01
AsyncSavedIP: skip $03
AsyncSavedSP: skip $02
AsyncSavedA: skip $02
AsyncSavedX: skip $02
AsyncSavedY: skip $02
AsyncRunning: skip $01


base $0300
OamBuffer: skip $200
HiOamBuffer: skip $20
HiOamIndex: skip $02        ; Index into the hioam bits
OamPtrLast: skip $02        ; Pointer to last frame's OAM pointer (to fill garbage)
OamOffsetX: skip $02        ; Offset X for draw routine
OamOffsetY: skip $02        ; Offset Y for draw routine
OamPropMask: skip $02       ; Mask to OR each property byte with

; level data stuff

LevelWidth: skip $02        ; In blocks
LevelHeight: skip $02

CamBoundaryLeft: skip $02   ; In pixels
CamBoundaryRight: skip $02
CamBoundaryTop: skip $02
CamBoundaryBottom: skip $02

HorizontalSeam: skip $02
VerticalSeam: skip $02
DmaQueueOffset: skip $02    ; Current offset into the DMA queue
GfxBufferPtr: skip $02


base $0E00
DmaQueue: skip $100         ; Dma queue data (see dma_queue.asm)
LevelRows: skip $100        ; Offsets to the start of each row (max 128 blocks high)

; Sprites

base $1000
!SpriteAmt = 16*2           ; Amount of bytes in sprite slots

SpritePtr: skip !SpriteAmt
SpritePtrBank: skip !SpriteAmt
SpritePtrMode = SpritePtrBank+1     ; 
SpritePosX: skip !SpriteAmt
SpritePosY: skip !SpriteAmt
SpriteSubPosX: skip !SpriteAmt
SpriteSubPosY = SpriteSubPos+1



GfxBuffer    = $7F0000      ; Generic decompression buffer
LevelData    = $7F8000      ; Level data (word buffer)


base off
pullpc
