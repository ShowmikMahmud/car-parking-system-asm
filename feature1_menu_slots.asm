.MODEL SMALL
.STACK 100H

.DATA
    ; -----------------------------------------------
    ; PARKING SLOT ARRAY (0 = Empty, 1 = Occupied)
    ; -----------------------------------------------
    slots         DB 10 DUP(0)       ; 10 parking slots, all empty at start
    totalSlots    DB 10              ; total number of slots

    ; -----------------------------------------------
    ; MESSAGES
    ; -----------------------------------------------
    menuMsg       DB 13,10
                  DB "========================================",13,10
                  DB "   ADVANCED CAR PARKING SYSTEM         ",13,10
                  DB "========================================",13,10
                  DB " 1. Check-In  (Gate Operator)          ",13,10
                  DB " 2. Check-Out (Gate Operator)          ",13,10
                  DB " 3. Search Vehicle                     ",13,10
                  DB " 4. Owner Mode                         ",13,10
                  DB " 5. Exit                               ",13,10
                  DB "========================================",13,10
                  DB " Enter your choice: $"

    choiceMsg     DB 13,10,"Invalid choice! Please try again.",13,10,"$"
    fullMsg       DB 13,10,"*** PARKING FULL! No slots available. ***",13,10,"$"
    slotMsg       DB 13,10,"Slot allocated: #$"
    exitMsg       DB 13,10,"Thank you for using Car Parking System!",13,10,"$"
    newline       DB 13,10,"$"

    ; Placeholder messages for features 2,3,4
    checkinMsg    DB 13,10,"[CHECK-IN] Feature loading...",13,10,"$"
    checkoutMsg   DB 13,10,"[CHECK-OUT] Feature loading...",13,10,"$"
    searchMsg     DB 13,10,"[SEARCH] Feature loading...",13,10,"$"
    ownerMsg      DB 13,10,"[OWNER MODE] Feature loading...",13,10,"$"

    allocSlot     DB 0              ; stores the allocated slot number

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; -----------------------------------------------
    ; MAIN MENU LOOP
    ; -----------------------------------------------
MENU_LOOP:
    CALL DISPLAY_MENU              ; display menu
    CALL GET_CHOICE                ; get user input

    CMP AL, '1'
    JE  CHECKIN_OPTION

    CMP AL, '2'
    JE  CHECKOUT_OPTION

    CMP AL, '3'
    JE  SEARCH_OPTION

    CMP AL, '4'
    JE  OWNER_OPTION

    CMP AL, '5'
    JE  EXIT_OPTION

    ; Invalid choice
    LEA DX, choiceMsg
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

CHECKIN_OPTION:
    CALL FIND_SLOT                 ; find available slot
    CMP BX, 0FFH                  ; 0FFH means parking full
    JE  PARKING_FULL
    ; slot found, print slot number
    LEA DX, slotMsg
    MOV AH, 09H
    INT 21H
    MOV DL, BL
    ADD DL, '1'                   ; convert to 1-based display (1-10)
    MOV AH, 02H
    INT 21H
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    ; Mark slot as occupied
    MOV SI, BX
    MOV slots[SI], 1
    JMP MENU_LOOP

PARKING_FULL:
    LEA DX, fullMsg
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

CHECKOUT_OPTION:
    LEA DX, checkoutMsg
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

SEARCH_OPTION:
    LEA DX, searchMsg
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

OWNER_OPTION:
    LEA DX, ownerMsg
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

EXIT_OPTION:
    LEA DX, exitMsg
    MOV AH, 09H
    INT 21H
    MOV AH, 4CH
    INT 21H

MAIN ENDP

; -----------------------------------------------
; PROCEDURE: DISPLAY_MENU
; Prints the main menu to screen
; -----------------------------------------------
DISPLAY_MENU PROC
    LEA DX, menuMsg
    MOV AH, 09H
    INT 21H
    RET
DISPLAY_MENU ENDP

; -----------------------------------------------
; PROCEDURE: GET_CHOICE
; Reads a single key from user, returns in AL
; -----------------------------------------------
GET_CHOICE PROC
    MOV AH, 01H                   ; read character with echo
    INT 21H
    RET
GET_CHOICE ENDP

; -----------------------------------------------
; PROCEDURE: FIND_SLOT
; Scans slots array for first empty slot (0)
; Returns: BX = slot index, or 0FFH if full
; -----------------------------------------------
FIND_SLOT PROC
    MOV CX, 0                     ; counter
    MOV BX, 0                     ; index

SCAN_LOOP:
    CMP CX, 10                    ; checked all 10 slots?
    JE  ALL_FULL
    MOV AL, slots[BX]             ; load slot status
    CMP AL, 0                     ; is it empty?
    JE  SLOT_FOUND
    INC BX
    INC CX
    JMP SCAN_LOOP

SLOT_FOUND:
    RET                           ; BX has the free slot index

ALL_FULL:
    MOV BX, 0FFH                  ; signal: parking full
    RET

FIND_SLOT ENDP

END MAIN
