.MODEL SMALL
.STACK 100H

.DATA
    ; -----------------------------------------------
    ; PARKING SLOT ARRAY (shared data)
    ; -----------------------------------------------
    slots         DB 10 DUP(0)       ; 10 parking slots
    totalCars     DB 0               ; total cars currently parked
    totalRevenue  DW 0               ; total revenue collected

    ; -----------------------------------------------
    ; PIN STORAGE
    ; Owner PIN: 1234 (stored as individual digits)
    ; -----------------------------------------------
    ownerPIN      DB '1','2','3','4'  ; correct PIN
    enteredPIN    DB 4 DUP(0)        ; buffer for entered PIN
    pinMatch      DB 0               ; 1 = match, 0 = no match

    ; -----------------------------------------------
    ; ROLE SELECTION MESSAGES
    ; -----------------------------------------------
    roleMenuMsg   DB 13,10
                  DB "========================================",13,10
                  DB "         SELECT YOUR ROLE              ",13,10
                  DB "========================================",13,10
                  DB " 1. Gate Operator                      ",13,10
                  DB " 2. Owner Mode                         ",13,10
                  DB " 0. Back to Main Menu                  ",13,10
                  DB "========================================",13,10
                  DB " Enter choice: $"

    ; -----------------------------------------------
    ; GATE OPERATOR MESSAGES
    ; -----------------------------------------------
    gateMenuMsg   DB 13,10
                  DB "========================================",13,10
                  DB "        GATE OPERATOR PANEL            ",13,10
                  DB "========================================",13,10
                  DB " 1. Check-In Vehicle                   ",13,10
                  DB " 2. Check-Out Vehicle                  ",13,10
                  DB " 3. Search Vehicle                     ",13,10
                  DB " 0. Back                               ",13,10
                  DB "========================================",13,10
                  DB " Enter choice: $"

    gateWelcome   DB 13,10,"Welcome, Gate Operator!",13,10,"$"
    gateCheckin   DB 13,10,"[CHECK-IN] Proceeding to check-in...",13,10,"$"
    gateCheckout  DB 13,10,"[CHECK-OUT] Proceeding to check-out...",13,10,"$"
    gateSearch    DB 13,10,"[SEARCH] Proceeding to search...",13,10,"$"

    ; -----------------------------------------------
    ; OWNER MODE MESSAGES
    ; -----------------------------------------------
    pinPrompt     DB 13,10,"Enter Owner PIN (4 digits): $"
    pinHidden     DB "*$"
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

    revMsg        DB 13,10,"Total Revenue: $"
    carsMsg       DB 13,10,"Total Cars Currently Parked: $"
    slotStatMsg   DB 13,10,"Slot Usage Statistics:",13,10,"$"
    slotLabel     DB 13,10," Slot  : $"
    slotEmpty     DB " [EMPTY]   $"
    slotOccupied  DB " [OCCUPIED]$"
    logoutMsg     DB 13,10,"Owner logged out.",13,10,"$"
    invalidMsg    DB 13,10,"Invalid choice!",13,10,"$"
    newline       DB 13,10,"$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Test owner mode directly
    CALL OWNER_MODE

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------
; PROCEDURE: GATE_OPERATOR
; Shows gate operator menu, handles options
; -----------------------------------------------
GATE_OPERATOR PROC
    LEA DX, gateWelcome
    MOV AH, 09H
    INT 21H

GATE_LOOP:
    LEA DX, gateMenuMsg
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H                        ; read choice into AL

    CMP AL, '1'
    JE  GATE_CHECKIN
    CMP AL, '2'
    JE  GATE_CHECKOUT
    CMP AL, '3'
    JE  GATE_SEARCH
    CMP AL, '0'
    JE  GATE_BACK

    LEA DX, invalidMsg
    MOV AH, 09H
    INT 21H
    JMP GATE_LOOP

GATE_CHECKIN:
    LEA DX, gateCheckin
    MOV AH, 09H
    INT 21H
    JMP GATE_LOOP

GATE_CHECKOUT:
    LEA DX, gateCheckout
    MOV AH, 09H
    INT 21H
    JMP GATE_LOOP

GATE_SEARCH:
    LEA DX, gateSearch
    MOV AH, 09H
    INT 21H
    JMP GATE_LOOP

GATE_BACK:
    RET

GATE_OPERATOR ENDP

; -----------------------------------------------
; PROCEDURE: OWNER_MODE
; Prompts for PIN, validates, shows owner dashboard
; -----------------------------------------------
OWNER_MODE PROC
    ; Show PIN prompt
    LEA DX, pinPrompt
    MOV AH, 09H
    INT 21H

    ; Read 4 digits, show * for each
    MOV CX, 4
    MOV SI, 0                      ; index into enteredPIN

READ_PIN:
    MOV AH, 08H                    ; read char WITHOUT echo
    INT 21H
    MOV enteredPIN[SI], AL         ; store digit

    ; Print * instead of digit
    MOV AH, 02H
    MOV DL, '*'
    INT 21H

    INC SI
    LOOP READ_PIN

    LEA DX, newline
    MOV AH, 09H
    INT 21H

    ; Validate PIN
    CALL VALIDATE_PIN
    CMP pinMatch, 1
    JNE PIN_WRONG

    ; PIN correct
    LEA DX, pinCorrect
    MOV AH, 09H
    INT 21H
    CALL OWNER_DASHBOARD
    RET

PIN_WRONG:
    LEA DX, pinWrong
    MOV AH, 09H
    INT 21H
    RET

OWNER_MODE ENDP

; -----------------------------------------------
; PROCEDURE: VALIDATE_PIN
; Compares enteredPIN with ownerPIN digit by digit
; Sets pinMatch = 1 if correct, 0 if wrong
; -----------------------------------------------
VALIDATE_PIN PROC
    MOV CX, 4
    MOV SI, 0
    MOV pinMatch, 1                ; assume correct

CHECK_DIGIT:
    MOV AL, enteredPIN[SI]
    CMP AL, ownerPIN[SI]
    JNE PIN_MISMATCH
    INC SI
    LOOP CHECK_DIGIT
    RET                            ; pinMatch stays 1

PIN_MISMATCH:
    MOV pinMatch, 0
    RET

VALIDATE_PIN ENDP

; -----------------------------------------------
; PROCEDURE: OWNER_DASHBOARD
; Shows owner stats menu
; -----------------------------------------------
OWNER_DASHBOARD PROC

OWNER_LOOP:
    LEA DX, ownerMenuMsg
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H                        ; read choice

    CMP AL, '1'
    JE  SHOW_REVENUE
    CMP AL, '2'
    JE  SHOW_CARS
    CMP AL, '3'
    JE  SHOW_SLOTS
    CMP AL, '0'
    JE  OWNER_LOGOUT

    LEA DX, invalidMsg
    MOV AH, 09H
    INT 21H
    JMP OWNER_LOOP

SHOW_REVENUE:
    LEA DX, revMsg
    MOV AH, 09H
    INT 21H
    ; Print totalRevenue as number
    MOV AX, totalRevenue
    CALL PRINT_NUMBER
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    JMP OWNER_LOOP

SHOW_CARS:
    LEA DX, carsMsg
    MOV AH, 09H
    INT 21H
    MOV AL, totalCars
    MOV AH, 0
    CALL PRINT_NUMBER
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    JMP OWNER_LOOP

SHOW_SLOTS:
    LEA DX, slotStatMsg
    MOV AH, 09H
    INT 21H
    ; Loop through all 10 slots and show status
    MOV CX, 10
    MOV SI, 0

SLOT_DISPLAY_LOOP:
    LEA DX, slotLabel
    MOV AH, 09H
    INT 21H

    ; Print slot number (SI is 16-bit, must use AX as bridge)
    MOV AX, SI
    ADD AL, '1'                    ; 1-based display
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    ; Print status
    MOV AL, slots[SI]
    CMP AL, 0
    JE  PRINT_EMPTY

    LEA DX, slotOccupied
    MOV AH, 09H
    INT 21H
    JMP NEXT_SLOT

PRINT_EMPTY:
    LEA DX, slotEmpty
    MOV AH, 09H
    INT 21H

NEXT_SLOT:
    INC SI
    LOOP SLOT_DISPLAY_LOOP
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    JMP OWNER_LOOP

OWNER_LOGOUT:
    LEA DX, logoutMsg
    MOV AH, 09H
    INT 21H
    RET

OWNER_DASHBOARD ENDP

; -----------------------------------------------
; PROCEDURE: PRINT_NUMBER
; Prints AX as decimal number to screen
; -----------------------------------------------
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10                     ; divisor
    MOV CX, 0                      ; digit counter

    CMP AX, 0
    JNE DIVIDE_LOOP
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP PRINT_DONE

DIVIDE_LOOP:
    CMP AX, 0
    JE  PRINT_DIGITS
    MOV DX, 0
    DIV BX                         ; AX = quotient, DX = remainder
    PUSH DX                        ; push digit onto stack
    INC CX
    JMP DIVIDE_LOOP

PRINT_DIGITS:
    CMP CX, 0
    JE  PRINT_DONE
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    DEC CX
    JMP PRINT_DIGITS

PRINT_DONE:
    POP DX
    POP CX
    POP BX
    POP AX
    RET

PRINT_NUMBER ENDP

END MAIN
