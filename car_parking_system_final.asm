.MODEL SMALL
.STACK 200H

.DATA
    ; ===============================================
    ; FEATURE 1 - SLOT ARRAY
    ; ===============================================
    slots         DB 10 DUP(0)       ; 0=Empty, 1=Occupied
    totalSlots    DB 10

    ; ===============================================
    ; FEATURE 2 - PIN & ROLE DATA
    ; ===============================================
    ownerPIN      DB '1','2','3','4'
    enteredPIN    DB 4 DUP(0)
    pinMatch      DB 0
    totalCars     DB 0
    totalRevenue  DW 0

    ; ===============================================
    ; FEATURE 3 - PLATE BUFFER
    ; 10 slots x 11 bytes (10 chars + '$')
    ; ===============================================
    plateBuffer   DB 110 DUP('$')
    inputBuf      DB 11 DUP('$')
    inputLen      DB 0
    searchBuf     DB 11 DUP('$')
    searchLen     DB 0
    stackTemp     DB 11 DUP(0)

    ; ===============================================
    ; FEATURE 4 - FEE & TIER DATA
    ; ===============================================
    tierRates     DW 20, 40, 80      ; Regular=20, Premium=40, VIP=80 Taka/hr
    tierNames     DB "Regular $"
                  DB "Premium $"
                  DB "VIP     $"
    entryTick     DW 0
    exitTick      DW 0
    selectedTier  DB 0
    duration      DW 0
    totalFee      DW 0

    ; ===============================================
    ; SHARED VARIABLES
    ; ===============================================
    currentSlot   DB 0              ; slot assigned during check-in

    ; ===============================================
    ; MAIN MENU MESSAGES
    ; ===============================================
    mainMenuMsg   DB 13,10
                  DB "========================================",13,10
                  DB "   ADVANCED CAR PARKING SYSTEM         ",13,10
                  DB "========================================",13,10
                  DB " 1. Gate Operator Login                ",13,10
                  DB " 2. Owner Mode Login                   ",13,10
                  DB " 3. Exit                               ",13,10
                  DB "========================================",13,10
                  DB " Enter choice: $"

    ; ===============================================
    ; FEATURE 1 MESSAGES
    ; ===============================================
    slotFoundMsg  DB 13,10,"Slot Allocated : #$"
    fullMsg       DB 13,10,"*** PARKING FULL! No slots available. ***",13,10,"$"

    ; ===============================================
    ; FEATURE 2 MESSAGES
    ; ===============================================
    gateMenuMsg   DB 13,10
                  DB "========================================",13,10
                  DB "        GATE OPERATOR PANEL            ",13,10
                  DB "========================================",13,10
                  DB " 1. Check-In Vehicle                   ",13,10
                  DB " 2. Check-Out Vehicle                  ",13,10
                  DB " 3. Search Vehicle                     ",13,10
                  DB " 0. Back to Main Menu                  ",13,10
                  DB "========================================",13,10
                  DB " Enter choice: $"

    gateWelcome   DB 13,10,"Welcome, Gate Operator!",13,10,"$"

    pinPrompt     DB 13,10,"Enter Owner PIN (4 digits): $"
    pinWrong      DB 13,10,"*** Wrong PIN! Access Denied. ***",13,10,"$"
    pinCorrect    DB 13,10,"PIN Correct! Welcome, Owner!",13,10,"$"

    ownerMenuMsg  DB 13,10
                  DB "========================================",13,10
                  DB "          OWNER DASHBOARD              ",13,10
                  DB "========================================",13,10
                  DB " 1. View Total Revenue                 ",13,10
                  DB " 2. View Total Cars Parked             ",13,10
                  DB " 3. View Slot Usage Statistics         ",13,10
                  DB " 0. Logout                             ",13,10
                  DB "========================================",13,10
                  DB " Enter choice: $"

    revMsg        DB 13,10,"Total Revenue        : $"
    takaMsg2      DB " Taka",13,10,"$"
    carsMsg       DB 13,10,"Total Cars Parked    : $"
    slotStatMsg   DB 13,10,"Slot Usage Statistics:",13,10,"$"
    slotLabel     DB 13,10," Slot  #$"
    slotEmpty     DB " : [EMPTY]   $"
    slotOccupied  DB " : [OCCUPIED]$"
    logoutMsg     DB 13,10,"Owner logged out successfully.",13,10,"$"

    ; ===============================================
    ; FEATURE 3 MESSAGES
    ; ===============================================
    enterPlate    DB 13,10,"Enter Vehicle Plate (max 10 chars): $"
    plateStored   DB 13,10,"Plate registered successfully!",13,10,"$"
    plateDisplay  DB 13,10,"Plate for Slot #$"
    plateIs       DB ": $"
    noPlate       DB 13,10,"No plate registered for this slot.",13,10,"$"
    searchPrompt  DB 13,10,"Enter Plate to Search: $"
    searchFound   DB 13,10,"Vehicle FOUND in Slot #$"
    searchNotFound DB 13,10,"Vehicle NOT FOUND in parking.",13,10,"$"

    ; ===============================================
    ; FEATURE 4 MESSAGES
    ; ===============================================
    tierMenuMsg   DB 13,10
                  DB "========================================",13,10
                  DB "       SELECT PARKING TYPE             ",13,10
                  DB "========================================",13,10
                  DB " 1. Regular  - 20 Taka/hour            ",13,10
                  DB " 2. Premium  - 40 Taka/hour            ",13,10
                  DB " 3. VIP      - 80 Taka/hour            ",13,10
                  DB "========================================",13,10
                  DB " Enter choice: $"

    entryMsg      DB 13,10,"Vehicle checked in! Timer started.",13,10,"$"
    checkoutPrompt DB 13,10,"Press any key to complete Check-Out...$"
    exitMsg       DB 13,10,"Vehicle checked out!",13,10,"$"
    receiptMsg    DB 13,10,"======== PARKING RECEIPT ========",13,10,"$"
    durationMsg   DB 13,10,"Parking Duration : $"
    secondsMsg    DB " seconds",13,10,"$"
    tierMsg       DB 13,10,"Parking Type     : $"
    feeMsg        DB 13,10,"Total Fee        : $"
    takaMsg       DB " Taka",13,10,"$"
    dividerMsg    DB "=================================",13,10,"$"
    thankMsg      DB 13,10,"  Thank you! Drive safely!",13,10,"$"
    minFeeMsg     DB 13,10,"(Minimum 1 hour charge applied)",13,10,"$"

    ; ===============================================
    ; SHARED MESSAGES
    ; ===============================================
    invalidMsg    DB 13,10,"Invalid choice! Try again.",13,10,"$"
    newline       DB 13,10,"$"
    exitSysMsg    DB 13,10,"Thank you for using Car Parking System! Goodbye!",13,10,"$"

    ; Checkout - slot number prompt
    checkoutSlotMsg DB 13,10,"Enter slot number to Check-Out (1-9): $"
    slotClearedMsg  DB 13,10,"Slot cleared successfully!",13,10,"$"
    slotEmptyErrMsg DB 13,10,"That slot is already empty!",13,10,"$"

.CODE

; ===============================================
; MACRO: PRINT_STRING
; Prints a string at address in DX
; ===============================================
PRINT_STRING MACRO msg
    LEA DX, msg
    MOV AH, 09H
    INT 21H
ENDM

; ===============================================
; MAIN PROCEDURE
; ===============================================
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MAIN_LOOP:
    PRINT_STRING mainMenuMsg

    MOV AH, 01H
    INT 21H

    CMP AL, '1'
    JE  GOTO_GATE
    CMP AL, '2'
    JE  GOTO_OWNER
    CMP AL, '3'
    JE  GOTO_EXIT

    PRINT_STRING invalidMsg
    JMP MAIN_LOOP

GOTO_GATE:
    CALL GATE_OPERATOR
    JMP MAIN_LOOP

GOTO_OWNER:
    CALL OWNER_MODE
    JMP MAIN_LOOP

GOTO_EXIT:
    PRINT_STRING exitSysMsg
    MOV AH, 4CH
    INT 21H

MAIN ENDP

; ===============================================
; FEATURE 2 - GATE OPERATOR
; ===============================================
GATE_OPERATOR PROC
    PRINT_STRING gateWelcome

GATE_LOOP:
    PRINT_STRING gateMenuMsg

    MOV AH, 01H
    INT 21H

    CMP AL, '1'
    JE  GATE_CHECKIN
    CMP AL, '2'
    JE  GATE_CHECKOUT
    CMP AL, '3'
    JE  GATE_SEARCH
    CMP AL, '0'
    JE  GATE_BACK

    PRINT_STRING invalidMsg
    JMP GATE_LOOP

GATE_CHECKIN:
    ; FEATURE 1 - Find available slot
    CALL FIND_SLOT
    CMP BX, 0FFH
    JE  GATE_FULL

    ; Save slot number
    MOV AL, BL
    MOV currentSlot, AL

    ; Mark slot occupied
    MOV SI, BX
    MOV slots[SI], 1

    ; Increment total cars
    INC totalCars

    ; Show allocated slot
    PRINT_STRING slotFoundMsg
    MOV DL, BL
    ADD DL, '1'
    MOV AH, 02H
    INT 21H
    PRINT_STRING newline

    ; FEATURE 3 - Register plate
    MOV BX, 0
    MOV BL, currentSlot
    CALL REGISTER_PLATE

    ; FEATURE 4 - Select tier and start timer
    CALL SELECT_TIER
    CALL CHECKIN_TIMER

    JMP GATE_LOOP

GATE_FULL:
    PRINT_STRING fullMsg
    JMP GATE_LOOP

GATE_CHECKOUT:
    ; Ask which slot to check out
    PRINT_STRING checkoutSlotMsg
    MOV AH, 01H
    INT 21H

    SUB AL, '1'                    ; convert to 0-based index
    MOV BL, AL
    MOV BH, 0

    ; Check if slot is valid
    CMP BX, 10
    JAE GATE_INVALID_SLOT

    ; Check if slot is occupied
    MOV SI, BX
    CMP slots[SI], 0
    JE  GATE_SLOT_EMPTY

    ; Clear slot
    MOV slots[SI], 0
    DEC totalCars

    ; Display plate before clearing
    CALL DISPLAY_PLATE

    ; Clear plate from buffer
    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV SI, AX
    MOV CX, 11
CLEAR_PLATE_LOOP:
    MOV plateBuffer[SI], '$'
    INC SI
    LOOP CLEAR_PLATE_LOOP

    ; FEATURE 4 - Calculate fee and print receipt
    CALL CHECKOUT_TIMER
    CALL CALCULATE_FEE
    CALL PRINT_RECEIPT

    ; Add fee to total revenue
    MOV AX, totalRevenue
    ADD AX, totalFee
    MOV totalRevenue, AX

    PRINT_STRING slotClearedMsg
    JMP GATE_LOOP

GATE_INVALID_SLOT:
    PRINT_STRING invalidMsg
    JMP GATE_LOOP

GATE_SLOT_EMPTY:
    PRINT_STRING slotEmptyErrMsg
    JMP GATE_LOOP

GATE_SEARCH:
    CALL SEARCH_PLATE
    JMP GATE_LOOP

GATE_BACK:
    RET

GATE_OPERATOR ENDP

; ===============================================
; FEATURE 2 - OWNER MODE
; ===============================================
OWNER_MODE PROC
    PRINT_STRING pinPrompt

    MOV CX, 4
    MOV SI, 0

READ_PIN:
    MOV AH, 08H
    INT 21H
    MOV enteredPIN[SI], AL
    MOV AH, 02H
    MOV DL, '*'
    INT 21H
    INC SI
    LOOP READ_PIN

    PRINT_STRING newline

    CALL VALIDATE_PIN
    CMP pinMatch, 1
    JNE PIN_WRONG

    PRINT_STRING pinCorrect
    CALL OWNER_DASHBOARD
    RET

PIN_WRONG:
    PRINT_STRING pinWrong
    RET

OWNER_MODE ENDP

; ===============================================
; FEATURE 2 - VALIDATE PIN
; ===============================================
VALIDATE_PIN PROC
    MOV CX, 4
    MOV SI, 0
    MOV pinMatch, 1

CHECK_DIGIT:
    MOV AL, enteredPIN[SI]
    CMP AL, ownerPIN[SI]
    JNE PIN_MISMATCH
    INC SI
    LOOP CHECK_DIGIT
    RET

PIN_MISMATCH:
    MOV pinMatch, 0
    RET

VALIDATE_PIN ENDP

; ===============================================
; FEATURE 2 - OWNER DASHBOARD
; ===============================================
OWNER_DASHBOARD PROC

OWNER_LOOP:
    PRINT_STRING ownerMenuMsg

    MOV AH, 01H
    INT 21H

    CMP AL, '1'
    JE  SHOW_REVENUE
    CMP AL, '2'
    JE  SHOW_CARS
    CMP AL, '3'
    JE  SHOW_SLOTS
    CMP AL, '0'
    JE  OWNER_LOGOUT

    PRINT_STRING invalidMsg
    JMP OWNER_LOOP

SHOW_REVENUE:
    PRINT_STRING revMsg
    MOV AX, totalRevenue
    CALL PRINT_NUMBER
    PRINT_STRING takaMsg2
    JMP OWNER_LOOP

SHOW_CARS:
    PRINT_STRING carsMsg
    MOV AL, totalCars
    MOV AH, 0
    CALL PRINT_NUMBER
    PRINT_STRING newline
    JMP OWNER_LOOP

SHOW_SLOTS:
    PRINT_STRING slotStatMsg
    MOV CX, 10
    MOV SI, 0

SLOT_DISPLAY_LOOP:
    PRINT_STRING slotLabel
    MOV AX, SI
    ADD AL, '1'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    MOV AL, slots[SI]
    CMP AL, 0
    JE  PRINT_EMPTY_SLOT

    PRINT_STRING slotOccupied
    JMP NEXT_SLOT

PRINT_EMPTY_SLOT:
    PRINT_STRING slotEmpty

NEXT_SLOT:
    INC SI
    LOOP SLOT_DISPLAY_LOOP
    PRINT_STRING newline
    JMP OWNER_LOOP

OWNER_LOGOUT:
    PRINT_STRING logoutMsg
    RET

OWNER_DASHBOARD ENDP

; ===============================================
; FEATURE 1 - FIND SLOT
; Returns: BX = slot index or 0FFH if full
; ===============================================
FIND_SLOT PROC
    MOV CX, 0
    MOV BX, 0

SCAN_LOOP:
    CMP CX, 10
    JE  ALL_FULL
    MOV AL, slots[BX]
    CMP AL, 0
    JE  SLOT_FOUND
    INC BX
    INC CX
    JMP SCAN_LOOP

SLOT_FOUND:
    RET

ALL_FULL:
    MOV BX, 0FFH
    RET

FIND_SLOT ENDP

; ===============================================
; FEATURE 3 - REGISTER PLATE
; Input: BX = slot index (0-9)
; ===============================================
REGISTER_PLATE PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI

    ; Clear inputBuf
    MOV SI, 0
REG_CLEAR:
    CMP SI, 11
    JE  REG_CLEAR_DONE
    MOV inputBuf[SI], '$'
    INC SI
    JMP REG_CLEAR

REG_CLEAR_DONE:
    PRINT_STRING enterPlate

    MOV CX, 0

REG_READ:
    MOV AH, 08H
    INT 21H
    CMP AL, 13
    JE  REG_DONE
    CMP AL, 8
    JE  REG_READ
    CMP CX, 10
    JE  REG_DONE

    MOV AH, 02H
    MOV DL, AL
    INT 21H

    MOV AH, 0
    PUSH AX
    INC CX
    JMP REG_READ

REG_DONE:
    MOV inputLen, CL
    PRINT_STRING newline

    ; POP into stackTemp
    MOV SI, 0
REG_POP:
    CMP CX, 0
    JE  REG_POP_DONE
    POP AX
    MOV stackTemp[SI], AL
    INC SI
    DEC CX
    JMP REG_POP

REG_POP_DONE:
    ; Reverse stackTemp into inputBuf
    MOV CL, inputLen
    MOV CH, 0
    MOV SI, 0
    MOV DI, CX
    DEC DI

REG_REVERSE:
    CMP CX, 0
    JE  REG_REVERSE_DONE
    MOV AL, stackTemp[DI]
    MOV inputBuf[SI], AL
    INC SI
    DEC DI
    DEC CX
    JMP REG_REVERSE

REG_REVERSE_DONE:
    MOV inputBuf[SI], '$'

    ; Store in plateBuffer at slot BX
    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV DI, AX
    MOV SI, 0

REG_STORE:
    MOV AL, inputBuf[SI]
    MOV plateBuffer[DI], AL
    CMP AL, '$'
    JE  REG_STORE_DONE
    INC SI
    INC DI
    JMP REG_STORE

REG_STORE_DONE:
    PRINT_STRING plateStored

    POP DI
    POP SI
    POP CX
    POP AX
    RET

REGISTER_PLATE ENDP

; ===============================================
; FEATURE 3 - DISPLAY PLATE
; Input: BX = slot index (0-9)
; ===============================================
DISPLAY_PLATE PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    PRINT_STRING plateDisplay

    MOV AX, BX
    ADD AL, '1'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    PRINT_STRING plateIs

    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV SI, AX

    MOV AL, plateBuffer[SI]
    CMP AL, '$'
    JE  DISP_NO_PLATE

DISP_PRINT:
    MOV AL, plateBuffer[SI]
    CMP AL, '$'
    JE  DISP_DONE
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    INC SI
    JMP DISP_PRINT

DISP_NO_PLATE:
    PRINT_STRING noPlate
    JMP DISP_EXIT

DISP_DONE:
    PRINT_STRING newline

DISP_EXIT:
    POP SI
    POP DX
    POP CX
    POP AX
    RET

DISPLAY_PLATE ENDP

; ===============================================
; FEATURE 3 - SEARCH PLATE
; ===============================================
SEARCH_PLATE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    ; Clear searchBuf
    MOV SI, 0
SRCH_CLEAR:
    CMP SI, 11
    JE  SRCH_CLEAR_DONE
    MOV searchBuf[SI], '$'
    INC SI
    JMP SRCH_CLEAR

SRCH_CLEAR_DONE:
    PRINT_STRING searchPrompt

    MOV CX, 0

SRCH_READ:
    MOV AH, 08H
    INT 21H
    CMP AL, 13
    JE  SRCH_READ_DONE
    CMP AL, 8
    JE  SRCH_READ
    CMP CX, 10
    JE  SRCH_READ_DONE

    MOV AH, 02H
    MOV DL, AL
    INT 21H

    MOV AH, 0
    PUSH AX
    INC CX
    JMP SRCH_READ

SRCH_READ_DONE:
    MOV searchLen, CL
    PRINT_STRING newline

    ; POP into stackTemp
    MOV SI, 0
SRCH_POP:
    CMP CX, 0
    JE  SRCH_POP_DONE
    POP AX
    MOV stackTemp[SI], AL
    INC SI
    DEC CX
    JMP SRCH_POP

SRCH_POP_DONE:
    ; Reverse into searchBuf
    MOV CL, searchLen
    MOV CH, 0
    MOV SI, 0
    MOV DI, CX
    DEC DI

SRCH_REVERSE:
    CMP CX, 0
    JE  SRCH_REVERSE_DONE
    MOV AL, stackTemp[DI]
    MOV searchBuf[SI], AL
    INC SI
    DEC DI
    DEC CX
    JMP SRCH_REVERSE

SRCH_REVERSE_DONE:
    MOV searchBuf[SI], '$'

    ; Search all slots
    MOV BX, 0

SRCH_SLOTS:
    CMP BX, 10
    JE  SRCH_NOT_FOUND

    MOV AX, BX
    MOV CX, 11
    MUL CX
    MOV SI, AX
    MOV DI, 0
    MOV CL, searchLen
    MOV CH, 0

SRCH_COMPARE:
    CMP CX, 0
    JE  SRCH_MATCH

    MOV AL, plateBuffer[SI]
    CMP AL, searchBuf[DI]
    JNE SRCH_NEXT_SLOT

    INC SI
    INC DI
    DEC CX
    JMP SRCH_COMPARE

SRCH_NEXT_SLOT:
    INC BX
    JMP SRCH_SLOTS

SRCH_MATCH:
    PRINT_STRING searchFound
    MOV AX, BX
    ADD AL, '1'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    PRINT_STRING newline
    JMP SRCH_EXIT

SRCH_NOT_FOUND:
    PRINT_STRING searchNotFound

SRCH_EXIT:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET

SEARCH_PLATE ENDP

; ===============================================
; FEATURE 4 - SELECT TIER
; ===============================================
SELECT_TIER PROC
    PUSH AX
    PUSH DX

TIER_LOOP:
    PRINT_STRING tierMenuMsg

    MOV AH, 01H
    INT 21H

    CMP AL, '1'
    JE  TIER_REG
    CMP AL, '2'
    JE  TIER_PREM
    CMP AL, '3'
    JE  TIER_VIP

    PRINT_STRING invalidMsg
    JMP TIER_LOOP

TIER_REG:
    MOV selectedTier, 0
    JMP TIER_DONE
TIER_PREM:
    MOV selectedTier, 1
    JMP TIER_DONE
TIER_VIP:
    MOV selectedTier, 2

TIER_DONE:
    PRINT_STRING newline
    POP DX
    POP AX
    RET

SELECT_TIER ENDP

; ===============================================
; FEATURE 4 - CHECKIN TIMER
; ===============================================
CHECKIN_TIMER PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV AH, 00H
    INT 1AH
    MOV entryTick, DX

    PRINT_STRING entryMsg

    POP DX
    POP CX
    POP AX
    RET

CHECKIN_TIMER ENDP

; ===============================================
; FEATURE 4 - CHECKOUT TIMER
; ===============================================
CHECKOUT_TIMER PROC
    PUSH AX
    PUSH CX
    PUSH DX

    PRINT_STRING checkoutPrompt
    MOV AH, 08H
    INT 21H

    MOV AH, 00H
    INT 1AH
    MOV exitTick, DX

    PRINT_STRING exitMsg

    ; Calculate duration in ticks then convert to seconds
    MOV AX, exitTick
    SUB AX, entryTick
    MOV BX, 18
    MOV DX, 0
    DIV BX
    MOV duration, AX

    POP DX
    POP CX
    POP AX
    RET

CHECKOUT_TIMER ENDP

; ===============================================
; FEATURE 4 - CALCULATE FEE
; ===============================================
CALCULATE_FEE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; Convert seconds to hours
    MOV AX, duration
    MOV BX, 3600
    MOV DX, 0
    DIV BX                         ; AX = hours, DX = remainder

    ; If less than 1 hour, use 1 hour minimum
    CMP AX, 0
    JNE SAVE_HOURS
    MOV AX, 1                      ; minimum 1 hour

SAVE_HOURS:
    MOV CX, AX                     ; CX = hours (save BEFORE any PRINT)

    ; Now safe to print minimum fee message if needed
    CMP CX, 1
    JNE DO_CALC
    ; Check if original duration was less than 3600 seconds
    MOV AX, duration
    CMP AX, 3600
    JAE DO_CALC
    PRINT_STRING minFeeMsg         ; print only if truly minimum applied

DO_CALC:
    ; Get tier rate from array
    MOV BL, selectedTier
    MOV BH, 0
    SHL BX, 1                      ; word offset (each DW = 2 bytes)
    MOV AX, tierRates[BX]          ; AX = rate per hour

    ; Multiply rate * hours (both small numbers)
    MOV DX, 0
    MUL CX                         ; AX = total fee
    MOV totalFee, AX               ; store result

    POP DX
    POP CX
    POP BX
    POP AX
    RET

CALCULATE_FEE ENDP

; ===============================================
; FEATURE 4 - PRINT RECEIPT
; ===============================================
PRINT_RECEIPT PROC
    PUSH AX
    PUSH BX
    PUSH DX

    PRINT_STRING receiptMsg
    PRINT_STRING dividerMsg

    PRINT_STRING durationMsg
    MOV AX, duration
    CALL PRINT_NUMBER
    PRINT_STRING secondsMsg

    PRINT_STRING tierMsg
    ; Calculate offset into tierNames: selectedTier * 9
    MOV AL, selectedTier
    MOV AH, 0
    MOV BX, 9
    MUL BX                         ; AX = selectedTier * 9
    LEA DX, tierNames
    ADD DX, AX                     ; DX points to correct tier name
    MOV AH, 09H
    INT 21H

    PRINT_STRING feeMsg
    MOV AX, totalFee
    CALL PRINT_NUMBER
    PRINT_STRING takaMsg

    PRINT_STRING dividerMsg
    PRINT_STRING thankMsg

    POP DX
    POP BX
    POP AX
    RET

PRINT_RECEIPT ENDP

; ===============================================
; UTILITY - PRINT NUMBER
; Input: AX = number to print
; ===============================================
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10
    MOV CX, 0

    CMP AX, 0
    JNE PN_DIVIDE
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP PN_DONE

PN_DIVIDE:
    CMP AX, 0
    JE  PN_PRINT
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    JMP PN_DIVIDE

PN_PRINT:
    CMP CX, 0
    JE  PN_DONE
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    DEC CX
    JMP PN_PRINT

PN_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET

PRINT_NUMBER ENDP

END MAIN
