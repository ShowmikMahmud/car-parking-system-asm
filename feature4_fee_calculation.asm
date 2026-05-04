.MODEL SMALL
.STACK 100H

.DATA
    ; -----------------------------------------------
    ; PRICE TIER ARRAY (rates per hour in Taka)
    ; Index 0 = Regular, 1 = Premium, 2 = VIP
    ; -----------------------------------------------
    tierRates     DW 20, 40, 80    ; Regular=20, Premium=40, VIP=80
    tierNames     DB "Regular $"
                  DB "Premium $"
                  DB "VIP     $"

    ; -----------------------------------------------
    ; ENTRY/EXIT TIME STORAGE (system ticks)
    ; One tick = ~55ms, 18.2 ticks = 1 second
    ; -----------------------------------------------
    entryTick     DW 0             ; entry time (low word of tick count)
    exitTick      DW 0             ; exit time
    selectedTier  DB 0             ; 0=Regular, 1=Premium, 2=VIP
    duration      DW 0             ; duration in seconds
    totalFee      DW 0             ; calculated fee

    ; -----------------------------------------------
    ; MESSAGES
    ; -----------------------------------------------
    tierMenuMsg   DB 13,10
                  DB "========================================",13,10
                  DB "       SELECT PARKING TYPE             ",13,10
                  DB "========================================",13,10
                  DB " 1. Regular  - 20 Taka/hour            ",13,10
                  DB " 2. Premium  - 40 Taka/hour            ",13,10
                  DB " 3. VIP      - 80 Taka/hour            ",13,10
                  DB "========================================",13,10
                  DB " Enter choice: $"

    entryMsg      DB 13,10,"Vehicle checked in. Timer started!",13,10,"$"
    exitPrompt    DB 13,10,"Press any key to simulate Check-Out...$"
    exitMsg       DB 13,10,"Vehicle checked out. Calculating fee...",13,10,"$"

    durationMsg   DB 13,10,"Parking Duration : $"
    secondsMsg    DB " seconds",13,10,"$"
    tierMsg       DB "Parking Type     : $"
    feeMsg        DB "Total Fee        : $"
    takaMsg       DB " Taka",13,10,"$"
    dividerMsg    DB "----------------------------------------",13,10,"$"
    receiptMsg    DB 13,10,"======== PARKING RECEIPT ===============",13,10,"$"
    thankMsg      DB "========================================",13,10
                  DB "   Thank you! Drive safely!            ",13,10
                  DB "========================================",13,10,"$"
    invalidMsg    DB 13,10,"Invalid choice! Please try again.",13,10,"$"
    newline       DB 13,10,"$"

    ; Minimum fee message (if parked less than 1 hour)
    minFeeMsg     DB 13,10,"(Minimum 1 hour charge applied)",13,10,"$"

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Test Feature 4 directly
    CALL SELECT_TIER
    CALL CHECKIN_TIMER
    CALL CHECKOUT_TIMER
    CALL CALCULATE_FEE
    CALL PRINT_RECEIPT

    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -----------------------------------------------
; PROCEDURE: SELECT_TIER
; Shows tier menu, stores selected tier in selectedTier
; -----------------------------------------------
SELECT_TIER PROC
    PUSH AX
    PUSH DX

TIER_MENU_LOOP:
    LEA DX, tierMenuMsg
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H                        ; read choice into AL

    CMP AL, '1'
    JE  TIER_REGULAR
    CMP AL, '2'
    JE  TIER_PREMIUM
    CMP AL, '3'
    JE  TIER_VIP

    LEA DX, invalidMsg
    MOV AH, 09H
    INT 21H
    JMP TIER_MENU_LOOP

TIER_REGULAR:
    MOV selectedTier, 0
    JMP TIER_DONE

TIER_PREMIUM:
    MOV selectedTier, 1
    JMP TIER_DONE

TIER_VIP:
    MOV selectedTier, 2

TIER_DONE:
    LEA DX, newline
    MOV AH, 09H
    INT 21H

    POP DX
    POP AX
    RET
SELECT_TIER ENDP

; -----------------------------------------------
; PROCEDURE: CHECKIN_TIMER
; Captures system ticks at check-in using INT 1Ah
; Stores in entryTick
; -----------------------------------------------
CHECKIN_TIMER PROC
    PUSH AX
    PUSH CX
    PUSH DX

    ; Read system timer ticks (INT 1Ah, AH=00H)
    ; Returns: CX:DX = tick count (we use DX = low word)
    MOV AH, 00H
    INT 1AH
    MOV entryTick, DX              ; store low word of tick count

    LEA DX, entryMsg
    MOV AH, 09H
    INT 21H

    POP DX
    POP CX
    POP AX
    RET
CHECKIN_TIMER ENDP

; -----------------------------------------------
; PROCEDURE: CHECKOUT_TIMER
; Waits for keypress then captures exit tick
; Calculates duration in seconds
; -----------------------------------------------
CHECKOUT_TIMER PROC
    PUSH AX
    PUSH CX
    PUSH DX

    ; Wait for user to press a key (simulates time passing)
    LEA DX, exitPrompt
    MOV AH, 09H
    INT 21H

    MOV AH, 08H                    ; wait for keypress
    INT 21H

    ; Capture exit tick
    MOV AH, 00H
    INT 1AH
    MOV exitTick, DX               ; store low word

    LEA DX, exitMsg
    MOV AH, 09H
    INT 21H

    ; Calculate duration in ticks
    MOV AX, exitTick
    SUB AX, entryTick              ; AX = tick difference

    ; Convert ticks to seconds
    ; 1 second = ~18 ticks (18.2 rounded down for simplicity)
    MOV BX, 18
    MOV DX, 0
    DIV BX                         ; AX = seconds, DX = remainder
    MOV duration, AX               ; store duration in seconds

    POP DX
    POP CX
    POP AX
    RET
CHECKOUT_TIMER ENDP

; -----------------------------------------------
; PROCEDURE: CALCULATE_FEE
; Calculates fee based on duration and selected tier
; Fee = (duration in hours) * tier rate
; Minimum charge = 1 hour rate
; -----------------------------------------------
CALCULATE_FEE PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; Convert duration (seconds) to hours
    ; 1 hour = 3600 seconds
    MOV AX, duration
    MOV BX, 3600
    MOV DX, 0
    DIV BX                         ; AX = hours, DX = remaining seconds

    ; If less than 1 hour, charge minimum 1 hour
    CMP AX, 0
    JNE  CALC_FEE
    MOV AX, 1                      ; minimum 1 hour

    ; Print minimum fee notice
    PUSH AX
    LEA DX, minFeeMsg
    MOV AH, 09H
    INT 21H
    POP AX

CALC_FEE:
    ; Get rate from tierRates array
    ; Index = selectedTier * 2 (DW = 2 bytes each)
    MOV BL, selectedTier
    MOV BH, 0
    SHL BX, 1                      ; BX = BX * 2 (word index)
    MOV CX, tierRates[BX]          ; CX = rate per hour

    ; Fee = hours * rate
    MUL CX                         ; AX = hours * rate
    MOV totalFee, AX               ; store total fee

    POP DX
    POP CX
    POP BX
    POP AX
    RET
CALCULATE_FEE ENDP

; -----------------------------------------------
; PROCEDURE: PRINT_RECEIPT
; Prints a formatted receipt with duration, tier, fee
; -----------------------------------------------
PRINT_RECEIPT PROC
    PUSH AX
    PUSH BX
    PUSH DX

    LEA DX, receiptMsg
    MOV AH, 09H
    INT 21H

    LEA DX, dividerMsg
    MOV AH, 09H
    INT 21H

    ; Print duration in seconds
    LEA DX, durationMsg
    MOV AH, 09H
    INT 21H
    MOV AX, duration
    CALL PRINT_NUMBER
    LEA DX, secondsMsg
    MOV AH, 09H
    INT 21H

    ; Print tier name
    LEA DX, tierMsg
    MOV AH, 09H
    INT 21H

    ; Print tier name from tierNames array
    ; Each tier name = 9 bytes (8 chars + '$')
    MOV BL, selectedTier
    MOV BH, 0
    MOV AX, 9
    MUL BL                         ; AX = offset into tierNames
    LEA DX, tierNames
    ADD DX, AX                     ; DX points to correct tier name
    MOV AH, 09H
    INT 21H

    ; Print fee
    LEA DX, feeMsg
    MOV AH, 09H
    INT 21H
    MOV AX, totalFee
    CALL PRINT_NUMBER
    LEA DX, takaMsg
    MOV AH, 09H
    INT 21H

    LEA DX, dividerMsg
    MOV AH, 09H
    INT 21H

    LEA DX, thankMsg
    MOV AH, 09H
    INT 21H

    POP DX
    POP BX
    POP AX
    RET
PRINT_RECEIPT ENDP

; -----------------------------------------------
; PROCEDURE: PRINT_NUMBER
; Prints value in AX as decimal to screen
; -----------------------------------------------
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10
    MOV CX, 0

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
    DIV BX
    PUSH DX
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
