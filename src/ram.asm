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

print "DP usage: $", hex(+) : +

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
OamFlipMask: skip $02       ; Mask to XOR each property byte with (for sprite flipping)

; level data stuff

LevelWidth: skip $02        ; In blocks
LevelHeight: skip $02

CamBoundaryLeft: skip $02   ; In pixels
CamBoundaryRight: skip $02
CamBoundaryTop: skip $02
CamBoundaryBottom: skip $02

; Extended camera controls

CamPivot: skip $02          ; The center of the 24px stable area around the player
CamPivotOffset: skip $02    ; Where the pivot is in screen coords
CamShouldScrollUp: skip $02 ; Should the camera catch up upwards?

HorizontalSeam: skip $02
VerticalSeam: skip $02

DmaQueueOffset: skip $02    ; Current offset into the DMA queue
GfxBufferPtr: skip $02      ; Pointer to the gfx decompression buffer
CurrentEntity: skip $02     ; ID of the entity currently being processed.

; Dynamic block updates

UpdateBlockX: skip $02      ; Set these variables to update the block on screen
UpdateBlockY: skip $02

; Extended entities

ExtEntitySlot: skip $02


base $0E00
DmaQueue: skip $100         ; Dma queue data (see dma_queue.asm)
DmaQueueMode = DmaQueue
DmaQueueAddr = DmaQueue+1
DmaQueueDest = DmaQueue+4
DmaQueueSize = DmaQueue+6
LevelRows: skip $100        ; Offsets to the start of each row (max 128 blocks high)

; Sprites

base $1000
!EntityCount = 16*2                 ; Amount of bytes in sprite slots

EntityPtr: skip !EntityCount
EntityPtrBank: skip !EntityCount
EntityState = EntityPtrBank+1       ; SMW-like interaction state
EntityPosX: skip !EntityCount
EntityPosY: skip !EntityCount
EntitySubPos: skip !EntityCount
EntitySubPosX = EntitySubPos
EntitySubPosY = EntitySubPos+1
EntityLastPos: skip !EntityCount    ; Used in collision to determine your last position on either axis
EntityVelX: skip !EntityCount
EntityVelY: skip !EntityCount
EntitySize: skip !EntityCount
EntityWidth = EntitySize
EntityHeight = EntitySize+1
EntityRender: skip !EntityCount     ; flip flags
EntityCollide: skip !EntityCount    ; bitfield of which blocks the entity is touching (udlr)
EntityAnimTimer: skip !EntityCount
EntityData0: skip !EntityCount
EntityData1: skip !EntityCount
EntityData2: skip !EntityCount
EntityData3: skip !EntityCount


!ExtEntityCount = 16*2
ExtEntityPtr: skip !EntityCount
ExtEntityPosX: skip !EntityCount
ExtEntityPosY: skip !EntityCount
ExtEntityData0: skip !EntityCount
ExtEntityData1: skip !EntityCount
ExtEntityData2: skip !EntityCount
ExtEntityData3: skip !EntityCount



print "Entity usage: $", hex(+) : +



LevelData    = $7F0000      ; Level data (word buffer)
GfxBuffer    = $7F8000      ; Generic decompression buffer


base off
pullpc
