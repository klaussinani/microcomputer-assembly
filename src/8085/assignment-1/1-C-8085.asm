IN 10H
LXI B,0064H ;; SET B-C = 100
;; FOR DELB
MVI A,0DH ;; INTERUPTS MASK
MVI L,00H ;; INTERUPTS COUNTER
MVI E ;; LOOPS COUNTER
SIM
BEGIN:
EI ;; ENABLE INTERUPTS
LOOP_A:
MVI A,00H ;; INITIALISE A
MOV A,L ;; STORE INTERUPTS
;; IN ACCUMULATOR
CMA ;; COMPLEMENT
;; ACCUMULATOR
RLC ;; RO
RLC ;; TA
RLC ;; TE!
RLC ;; LSBs ARE NOW MSBs
ANI F0H ;; A && 1111 0000
;; AKA TRAP THE MSBs
ADD E ;; ADD THE LSBs TO A
STA 3000H ;; SENDS TO LEDS
DI ;; DISABLE INTERRUPTS
CALL DELB ;; IMPLEMENT DELAY
EI ;; OK ENABLE INTERRUPTS
LOOP_B:
MOV A,E ;; TAKE NUMBER OF LOOPS
INR A ;; INCREMENT A
MOV E,A ;; STORE TO E
CPI 0FH ;; COMPARE WITH 16
JNZ BEGIN ;; IF NOT EQUAL
;; TO 16 GO TO BEGIN
MVI E,00H ;; ELSE RESET
JMP BEGIN ;; THEN START OVER
INTR_ROUTINE:
DI ;; DISABLE INTERUPTS
PUSH PSW ;; SAVE ACCUMULATOR
;; & FLAGS
PUSH B ;; SAVE B REGISTER
PUSH D ;; SAVE D REGISTER
;; IN ORDER TO SERVE
;; THE INTERRUPT
LOOP_C:
LDA 2000H ;; READ INPUT FROM INPUT
ADI 80H ;; ADD 1000 0000 TO A
CPI 00H ;; COMPARE WITH 0
JNZ SHUTDOWN ;; IF NOT EQUAL WITH 0
;; END LOOP_C
;; IN OTHER WORDS
;; CHECK IF MSB OF
;; SWITCHES IS ON
RIM
ANI 20H ;; ISOLATE 6TH BIT
CPI 20H
JZ LOOP_C ;; IF A EQUAL TO
;; TO 0010 0000
;; START AGAIN
;; LOOP_C
MVI C,32H ;; ELSE
MVI B,00H ;; RESET B
CALL DELB
RIM
ANI 20H ;; ISOLATE 6TH BIT
CPI 20H ;; AGAIN COMPARE
;; TO 0100 0000
JZ LOOP_C ;; START AGAIN
;; IF EQUAL
INR L ;; INCREMENT INTERRUPTS
;; COUNTER
MOV A,L ;; SAVE TO A
ANI 0FH ;; ISOLATE LSBs
MOV L,A ;; RESTORE TO COUNTER
SHUTDOWN:
POP D ;; RESTORE
POP B ;; REGISTERS
POP PSW ;; AND FLAGS
EI
RET
HLT
END
