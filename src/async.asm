;; Async queue support
; Run a task (e.g. decompression) in the background after all game logic, in a non-blocking fashion

; Args
; A - P . PC low
; X - PC high . PC bank

AsyncStart:
;    lda.w AsyncRunning
;    beq +
    ; TODO: push into a queue if necessary
;+
    sta.w AsyncSavedStatus
    stx.w AsyncSavedStatus+2
    lda.w #AsyncStack
    sta.w AsyncSavedSP
    rtl

AsyncResume:
    lda.w AsyncSavedStatus
    pha
    lda.w AsyncSavedStatus+2
    pha
    lda.w AsyncSavedSP
    tcs
    lda.w AsyncSavedA
    ldx.w AsyncSavedX
    ldy.w AsyncSavedY
    rti

AsyncSave:
    sta.w AsyncSavedA
    stx.w AsyncSavedX
    sty.w AsyncSavedY
    lda 3,s
    sta.w AsyncSavedStatus
    lda 5,s
    sta.w AsyncSavedStatus+2
    rts

AsyncFinish:
    ; TODO: check if there are other entries in a queue
    stz.w AsyncRunning
    jmp WaitForNmi
