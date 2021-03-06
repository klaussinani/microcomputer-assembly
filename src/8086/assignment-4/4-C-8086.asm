READ MACRO
;; READING MACRO
MOV AH,8
INT 21H
ENDM
PRINT MACRO CHAR
;; PRINT CHAR MACRO
PUSH AX
PUSH DX
MOV DL,CHAR
MOV AH,02H
INT 21H
POP DX
POP AX
ENDM
PRINT_STRING MACRO STRING
;; PRINT STRING MACRO
PUSH AX
PUSH DX
MOV DX,OFFSET STRING
MOV AH,09H
INT 21H
POP DX
POP AX
ENDM
PRINT_NUM MACRO CHAR
;; PRINT NUMBER MACRO
MOV DL,CHAR
ADD DL,30H
MOV AH,2
INT 21H
ENDM
PAUSE MACRO
;; STANDING BY MACRO
PUSH AX
PUSH DX
LEA DX,PKEY ;;<=>MOV DX & OFFSET PKEY
;; TRADE THE OFFSET OF PKEY TO DX
MOV AH,9
INT 21H ;; OUTPUT STRING AT DS:DX
MOV AH,8 ;; WAIT FOR PRESSING OF A KEY
INT 21H ;; WITHOUT ECHO => 8
PRINT 0AH
PRINT 0DH
POP DX
POP AX
ENDM
EXIT MACRO
;; EXIT MACRO
MOV AH,4CH
INT 21H
ENDM
STACK_SEG SEGMENT STACK
DW 128 DUP(?)
ENDS
DATA_SEG SEGMENT
ENTAILMENT DB 0AH,0DH, "$"
LINE DB 0AH,0DH,"$"
INPUT_MSG DB "USE ONLY AS INPUT NUMBERS \
OR LETTERS. USE * TO EXIT! \(^_^)/",0AH,0DH,"$"
GIVE_MSG DB "(HIT ENTER AFTER YOUR INPUT):$"
NUM_TABLE DB 20 DUP(?)
NUM_ASC_TABLE DB 20 DUP(?)
LOWER_TABLE DB 20 DUP(?)
UPPER_TABLE DB 20 DUP(?)
NUM_COUNTER DW 0
INDEX_FIRST_SMALLEST DB 0
INDEX_SECOND_SMALLEST DB 0
LOWER_COUNTER DW 0
UPPER_COUNTER DW 0
INDEX DW 0
ENDS
CODE_SEG SEGMENT
ASSUME CS:CODE_SEG,SS:STACK_SEG,DS:DATA_SEG,ES:DATA_SEG
MAIN PROC FAR
;; INITIALIZING SEGMENT REGISTERS
MOV AX,DATA_SEG
MOV DS,AX
MOV ES,AX
;; CODING PART
START:
PRINT_STRING INPUT_MSG
PRINT_STRING GIVE_MSG
CALL INPUT_ROUTINE
CALL OUTPUT_ROUTINE
PRINT_STRING LINE
MOV LOWER_COUNTER,0 ;; RESETING VITAL
;; VARIABLES/COUNTER
MOV UPPER_COUNTER,0
MOV NUM_COUNTER,0
MOV INDEX_FIRST_SMALLEST,0
MOV INDEX_SECOND_SMALLEST,0
JMP START
ENDIT:
EXIT
MAIN ENDP
;; FUNCTIONS/ROUTINES PART
OUTPUT_ROUTINE PROC NEAR
UPPER_START:
MOV CX,UPPER_COUNTER
CMP CX,0
JE LOWER_START
MOV BX,OFFSET UPPER_TABLE
UPPER_PRINT:
MOV AL,DS:[BX]
PRINT AL
INC BX
LOOP UPPER_PRINT
PRINT '-'
LOWER_START: ;; REPEAT FOR OTHERS
MOV CX,LOWER_COUNTER
CMP CX,0
JE NUM_START
MOV BX,OFFSET LOWER_TABLE
LOWER_PRINT:
MOV AL,DS:[BX]
PRINT AL
INC BX
LOOP LOWER_PRINT
PRINT '-'
NUM_START:
MOV CX,NUM_COUNTER
CMP CX,0
JE PRINT_EJECT ;; IN CASE THE TABLE IS
;; THERE IS NOTHING
;; TO PRING
MOV BX,OFFSET NUM_TABLE;; THE STARING ADDRESS
;; OF TABLE NUM_TABLE
;; IS DOMINATED BY
;; OUR FIRST ELEMENT
NUM_PRINT:
MOV AL,DS:[BX]
PRINT AL
INC BX ;; MOVE ON TO THE NEXT
;; PIECE OF DATA/ELEMENT
LOOP NUM_PRINT ;; REPEAT AS MANY TIMES
;; AS THE COUNTER
;; NUM_COUNTER INDICATES
PRINT_STRING ENTAILMENT
NUM_ASC:
;; HERE WE DEFINE THE PRINTING ORDER OF THE FIRST
;; AND SECOND SMALLEST ELEMENTS
MOV CX,NUM_COUNTER ;; LOAD COUNTER = NUMBER OF
;; ARITHMETIC CHARACTERS
MOV BX,OFFSET NUM_TABLE;; LOAD JUST OUR NUMBERS
MOV AL,DS:[BX] ;; GET THE FIRST
DEC CX ;; WE GOT ONE CANDIDATE NUM
;; DECREMENT COUNTER BY ONE
CMP CX,0 ;; CHECK IF WE USED
;; ALL NUMBERS
JE DONE ;; IF SO WE ARE DONE
KEEP_UP:
DEC CX ;; DECREMENT AGAIN
CMP CX,0 ;; RE-CHECK FOR END
JL DONE
INC BX ;; SMALLEST ELEM CANDIDATE
;; INDEX INCREMENTED
MOV AH,DS:[BX] ;; LOAD NEXT CANDIDATE
CMP AL,AH ;; COMPARE THEM
JLE KEEP_UP ;; THE FIST IS LESS
;; GET NEXT CANDIDATE
MOV AL,AH ;; SECOND IS LESS
;; KEEP IT AS POSSIBLE
;; SMALLEST CANDIDATE
INC INDEX_FIRST_SMALLEST
JMP KEEP_UP ;; KEEP UP
DONE: ;; GOT THE 1ST SMALLEST
;; LEST FIND THE 2ND
MOV BX,OFFSET NUM_ASC_TABLE;; LOAD SMALLEST NUMS
MOV [BX],AL ;; SAVE 1ST SMALLEST
MOV DH,AL ;; SET IT ALSO AS LANDMARK
JMP CONT
CONT:
MOV CX,00H ;; CLEAR COUNTERS/INDEXES
MOV BX,00H
MOV CX,NUM_COUNTER ;; RELOAD COUNTER
MOV BX,OFFSET NUM_TABLE;; ALSO THE TABLE
MOV AL,DS:[BX] ;; GEST FIRST CANDIDATE
DEC CX ;; DECREMENT COUNTER
CMP CX,0 ;; CHECK IF DONE
JE DOONE
KEEEP_UP:
DEC CX ;; DECREMENT AGAIN
CMP CX,0
JL DOONE
INC BX ;; 1ST CANDIDATE INDX++
MOV AH,DS:[BX] ;; NEXT CANDIDATE
CMP AL,DH ;; 1ST CANDID ==? LANDMARK
JE SWIITCH ;; CANDIDATE WAS LANDMARK
CMP AL,AH ;; IT WAS NOT SO
;; COMPARE 2 CANDS
JLE KEEEP_UP ;; 1ST WAS LESS
;; GO GET A NEW CAND
CMP AH,DH ;; 2ND WAS LESS BUT
;; IT COULD BE THE LANDMARK
JE KEEEP_UP ;; IT WAS SO GET A NEW
MOV AL,AH ;; NONE IS LANDMAR
;; SO JUST COMPARE
INC INDEX_SECOND_SMALLEST
JMP KEEEP_UP
SWIITCH:
MOV AL,AH ;; THE SECOND IS LESS
;; AND IT'S NOT LANDMARK
INC INDEX_SECOND_SMALLEST
JMP KEEEP_UP
DOONE: ;; GOT MY 2ND SMALLEST
MOV BX,00H ;; SAVE IT AFTER THE 1ST
MOV BX,OFFSET NUM_ASC_TABLE
INC BX
MOV [BX],AL ;; SAVING DONE
TABLE:
;; APPEARING OREDER IS ESSENTIAL
;; SO FIND WHICH APPREARED FIRST
ADD INDEX_FIRST_SMALLEST,30H
ADD INDEX_SECOND_SMALLEST,30H
MOV DL,INDEX_FIRST_SMALLEST
MOV DH,INDEX_SECOND_SMALLEST
CMP DL,DH ;; COMPARE THE 2 INDXES
;; IT IS REALLY EASY
;; FROM NOW ON
JG SECOND_SMALLEST_FIRST
MOV BX,OFFSET NUM_ASC_TABLE
MOV AL,DS:[BX] ;; 1ST SMALLEST APPREARED 1ST
PRINT AL ;; PRINT APPROPRIATELY
INC BX
MOV AL,DS:[BX]
PRINT AL
JMP PRINT_EJECT
SECOND_SMALLEST_FIRST: ;; 2ND SMALLEST
;; APPEARED 1ST
MOV BX,OFFSET NUM_ASC_TABLE
INC BX ;; PRINT APPROPRIATELY
MOV AL,DS:[BX]
PRINT AL
DEC BX
MOV AL,DS:[BX]
PRINT AL
JMP PRINT_EJECT
PRINT_EJECT:
RET
OUTPUT_ROUTINE ENDP
INPUT_ROUTINE PROC NEAR
MOV CX,16H ;; LIMIT INPUT COUNTER
INPUT_LOOP:
READ
CMP AL,0DH ;; [ENTER] PRESSED
JE INPUT_END
CMP AL,20H ;; [SPACE] PRESSED
JE SPACE_LOOP
CMP AL,2AH ;; [*] PRESSED
JE ENDIT
CMP AL,30H
JL INPUT_LOOP
CMP AL,39H
JG UPPER_CHECK ;; 0 TO 9 CHECK
PRINT AL
NUM_INPUT:
MOV BX,OFFSET NUM_TABLE
ADD BX,NUM_COUNTER
MOV [BX],AL ;; CHAR @ NUMBERS TABLE
INC NUM_COUNTER;; NUMBERS COUNTER
;; INCREMENTED
JMP ENDING_LOOP
UPPER_CHECK:
CMP AL,41H
JL INPUT_LOOP
CMP AL,5AH
JG LOWER_CHECK ;; A TO Z CHECK
PRINT AL
UPPER_INPUT:
MOV BX,OFFSET UPPER_TABLE
ADD BX,UPPER_COUNTER
MOV [BX],AL ;; PLACE CHARACTER
;; IN UPPERS TABLE
INC UPPER_COUNTER ;; INCEREMENT
;; UPPERS COUNTER
JMP ENDING_LOOP
LOWER_CHECK:
CMP AL,61H
JL INPUT_LOOP
CMP AL,7AH
JG INPUT_LOOP ;; a TO z CHECK
PRINT AL
LOWER_INPUT:
MOV BX,OFFSET LOWER_TABLE
ADD BX,LOWER_COUNTER
MOV [BX],AL ;; STORE TO
;; LOWERS TABLE
INC LOWER_COUNTER ;; INCREMENT
;; COUNTER OF LOWERS
ENDING_LOOP:
LOOP INPUT_LOOP
ENTER_LOOP:
READ
CMP AL,0DH ;; CHECK IF ENTER
;; WAS PRESSED
JNE ENTER_LOOP
INPUT_END:
PRINT_STRING ENTAILMENT
RET
SPACE_LOOP:
PRINT ' '
JMP ENDING_LOOP
INPUT_ROUTINE ENDP
CODE_SEG ENDS
END MAIN
