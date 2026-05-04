.MODEL SMALL
.STACK 100H

.DATA
    ; -----------------------------------------------
    ; PLATE STORAGE ARRAY
    ; 10 slots x 11 bytes each (10 chars + '$')
    ; -----------------------------------------------
    plateBuffer   DB 110 DUP('$')  ; all initialized with '$'
    plateLen      EQU 11           ; max plate length + delimiter

    ; -----------------------------------------------
    ; MESSAGES
    ; -----------------------------------------------
    enterPlate    DB 13,10,"Enter Vehicle Plate Number (max 10 chars): $"
    plateStored   DB 13,10,"Plate registered successfully!",13,10,"$"
    plateDisplay  DB 13,10,"Plate for Slot #$"
    plateIs       DB ": $"
    noPlate       DB 13,10,"No plate registered for this slot.",13,10,"$"
    searchPrompt  DB 13,10,"Enter Plate to Search: $"
    searchFound   DB 13,10,"Vehicle FOUND in Slot #$"
    searchNotFound DB 13,10,"Vehicle NOT FOUND in parking.",13,10,"$"
    newline       DB 13,10,"$"

    ; Temp buffers
    inputBuf      DB 11 DUP('$')   ; input buffer
    inputLen      DB 0             ; length of entered plate
    searchBuf     DB 11 DUP('$')   ; search buffer
    searchLen     DB 0             ; length of search input

    ; Stack temp storage
    stackTemp     DB 11 DUP(0)     ; temp array to hold popped stack content

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Test: register plate in slot 0
    MOV BX, 0
    CALL REGISTER_PLATE

    ; Test: display plate of slot 0
    MOV BX, 0
    CALL DISPLAY_PLATE

    ; Test: search for a plate
    CALL SEARCH_PLATE

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------
; PROCEDURE: REGISTER_PLATE
; Reads plate chars, pushes to stack, pops in
; reverse to get correct order, stores in plateBuffer
; Input: BX = slot index (0-9)
; -----------------------------------------------
REGISTER_PLATE PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI

    ; Clear inputBuf first
    MOV SI, 0
CLEAR_INPUT:
    CMP SI, 11
    JE  CLEAR_DONE
    MOV inputBuf[SI], '$'
    INC SI
    JMP CLEAR_INPUT

CLEAR_DONE:
    LEA DX, enterPlate
    MOV AH, 09H
    INT 21H

    ; --- STEP 1: Read chars and PUSH onto stack ---
    MOV CX, 0                      ; character counter

READ_CHAR:
    MOV AH, 08H                    ; read without echo
    INT 21H

    CMP AL, 13                     ; Enter key?
    JE  DONE_READING
    CMP AL, 8                      ; Backspace? ignore
    JE  READ_CHAR
    CMP CX, 10                     ; max 10 chars?
    JE  DONE_READING

    ; Echo the character
    MOV AH, 02H
    MOV DL, AL
    INT 21H

    ; PUSH character onto stack (zero-extend AL to AX)
    MOV AH, 0
    PUSH AX
    INC CX
    JMP READ_CHAR

DONE_READING:
    MOV inputLen, CL
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    ; --- STEP 2: POP chars into stackTemp ---
    ; Stack is LIFO so stackTemp will have REVERSED order
    MOV SI, 0
    MOV DI, CX                     ; save count

POP_TO_TEMP:
    CMP CX, 0
    JE  POP_DONE
    POP AX
    MOV stackTemp[SI], AL
    INC SI
    DEC CX
    JMP POP_TO_TEMP

POP_DONE:
    ; --- STEP 3: Copy stackTemp in REVERSE into inputBuf ---
    ; Reversing the reversed = correct original order
    MOV CL, inputLen
    MOV CH, 0
    MOV SI, 0                      ; destination index in inputBuf
    MOV DI, CX
    DEC DI                         ; start from last char in stackTemp

REVERSE_TO_INPUT:
    CMP CX, 0
    JE  REVERSE_DONE
    MOV AL, stackTemp[DI]
    MOV inputBuf[SI], AL
    INC SI
    DEC DI
    DEC CX
    JMP REVERSE_TO_INPUT

REVERSE_DONE:
    ; Add '$' delimiter at end
    MOV inputBuf[SI], '$'

    ; --- STEP 4: Copy inputBuf into plateBuffer at slot BX ---
    ; Offset = BX * 11
    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV DI, AX                     ; DI = offset in plateBuffer
    MOV SI, 0                      ; SI = index in inputBuf

STORE_PLATE:
    MOV AL, inputBuf[SI]
    MOV plateBuffer[DI], AL
    CMP AL, '$'
    JE  STORE_DONE
    INC SI
    INC DI
    JMP STORE_PLATE

STORE_DONE:
    LEA DX, plateStored
    MOV AH, 09H
    INT 21H

    POP DI
    POP SI
    POP CX
    POP AX
    RET
REGISTER_PLATE ENDP

; -----------------------------------------------
; PROCEDURE: DISPLAY_PLATE
; Displays stored plate for given slot
; Input: BX = slot index (0-9)
; -----------------------------------------------
DISPLAY_PLATE PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    LEA DX, plateDisplay
    MOV AH, 09H
    INT 21H

    ; Print slot number (1-based)
    MOV AX, BX
    ADD AL, '1'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    LEA DX, plateIs
    MOV AH, 09H
    INT 21H

    ; Calculate offset: BX * 11
    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV SI, AX

    ; Check if slot is empty (first char = '$')
    MOV AL, plateBuffer[SI]
    CMP AL, '$'
    JE  NO_PLATE_FOUND

PRINT_PLATE:
    MOV AL, plateBuffer[SI]
    CMP AL, '$'
    JE  DISPLAY_DONE
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    INC SI
    JMP PRINT_PLATE

NO_PLATE_FOUND:
    LEA DX, noPlate
    MOV AH, 09H
    INT 21H
    JMP DISPLAY_EXIT

DISPLAY_DONE:
    LEA DX, newline
    MOV AH, 09H
    INT 21H

DISPLAY_EXIT:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
DISPLAY_PLATE ENDP

; -----------------------------------------------
; PROCEDURE: SEARCH_PLATE
; Reads search input using stack, searches all slots
; -----------------------------------------------
SEARCH_PLATE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    ; Clear searchBuf
    MOV SI, 0
CLEAR_SEARCH:
    CMP SI, 11
    JE  CLEAR_SEARCH_DONE
    MOV searchBuf[SI], '$'
    INC SI
    JMP CLEAR_SEARCH

CLEAR_SEARCH_DONE:
    LEA DX, searchPrompt
    MOV AH, 09H
    INT 21H

    ; Read search input using STACK
    MOV CX, 0

READ_SEARCH:
    MOV AH, 08H
    INT 21H
    CMP AL, 13
    JE  DONE_SEARCH_READ
    CMP AL, 8
    JE  READ_SEARCH
    CMP CX, 10
    JE  DONE_SEARCH_READ

    MOV AH, 02H
    MOV DL, AL
    INT 21H

    MOV AH, 0
    PUSH AX
    INC CX
    JMP READ_SEARCH

DONE_SEARCH_READ:
    MOV searchLen, CL
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    ; POP into stackTemp
    MOV SI, 0

POP_SEARCH:
    CMP CX, 0
    JE  POP_SEARCH_DONE
    POP AX
    MOV stackTemp[SI], AL
    INC SI
    DEC CX
    JMP POP_SEARCH

POP_SEARCH_DONE:
    ; Reverse stackTemp into searchBuf
    MOV CL, searchLen
    MOV CH, 0
    MOV SI, 0
    MOV DI, CX
    DEC DI

REVERSE_SEARCH:
    CMP CX, 0
    JE  REVERSE_SEARCH_DONE
    MOV AL, stackTemp[DI]
    MOV searchBuf[SI], AL
    INC SI
    DEC DI
    DEC CX
    JMP REVERSE_SEARCH

REVERSE_SEARCH_DONE:
    MOV searchBuf[SI], '$'

    ; Search all 10 slots
    MOV BX, 0

SEARCH_SLOTS:
    CMP BX, 10
    JE  NOT_FOUND

    ; Offset = BX * 11
    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV SI, AX                    ; SI = start of slot in plateBuffer
    MOV DI, 0                     ; DI = index into searchBuf
    MOV CL, searchLen
    MOV CH, 0

COMPARE_LOOP:
    CMP CX, 0
    JE  MATCH_FOUND               ; all chars matched!

    MOV AL, plateBuffer[SI]
    CMP AL, searchBuf[DI]
    JNE NEXT_SLOT_SEARCH

    INC SI
    INC DI
    DEC CX
    JMP COMPARE_LOOP

NEXT_SLOT_SEARCH:
    INC BX
    JMP SEARCH_SLOTS

MATCH_FOUND:
    LEA DX, searchFound
    MOV AH, 09H
    INT 21H

    MOV AX, BX
    ADD AL, '1'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    LEA DX, newline
    MOV AH, 09H
    INT 21H
    JMP SEARCH_EXIT

NOT_FOUND:
    LEA DX, searchNotFound
    MOV AH, 09H
    INT 21H

SEARCH_EXIT:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
SEARCH_PLATE ENDP

END MAIN
