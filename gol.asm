.ORG 0x0000 # START

LDA 0
LD R3,RD

CALL CLEARSCR

START:
#CALL HOME
CALL DRAWBOARD
CALL CALCULATE
INC RD
JMPI START

CLEARSCR:
LDA T_CLRSCR
LD R3,R4
CALL PRINTTXT
LDA T_HOME
LD R3,R4
CALL PRINTTXT
RET

HOME:
LDA T_HOME
LD R3,R4
CALL PRINTTXT
RET

# Draw the entire board
# Regs used locally: R3, RF (global pointer to board cell), R6, R7
DRAWBOARD:
CALL DRAW_BORDER
LDA D_BOARD_DATA
LD R3,RF # global pointer to current board data cell
LDA D_BOARD_H
LD M3,R6 # board height (counter)
LDA DRAW_ROW_LOOP # loop address
LD R3,R7
DRAW_ROW_LOOP:
CALL DRAW_ROW
DEC R6
JMPNZ R7 # DRAW_ROW_LOOP
CALL DRAW_BORDER
RET

# Draw upper and lower border
# Regs used locally: R3, R4, R5
DRAW_BORDER:
LDA D_BOARD_W
LD M3,R4 # board width
INC R4
INC R4  # board width
LDA DRAW_B_LOOP
LD R3,R5 # loop address
LDA 0x0040 # board character @
DRAW_B_LOOP:
OUT R3,P0
DEC R4
JMPNZ R5 # DRAW_B_LOOP
LDA 0x000D # CR LF
OUT R3,P0
LDA 0x000A
OUT R3,P0
RET


# Draw a single row of a board, use RF as global pointer to current board cell
# Regs used locally: R3, R4, R5, R8, R9, RA, RB 
DRAW_ROW:
LDA 0x0040 # board character @
OUT R3,P0

LDA D_BOARD_W
LD M3,R4 # board width
LDA DRAW_I_LOOP
LD R3,R5 # loop address
LDA 0x0001
LD R3,RE # value to check (bit 0)
LDA 0x002E # empty character .
LD R3,R9
LDA 0x0023 # full character #
LD R3,RA
LDA DRAW_CELL_CHAR # jump location
LD R3,RB
DRAW_I_LOOP:
LD R9,R3 # init R3 with empty character
LD MF,R8 # load current cell
AND R8,RE # check if cell is empty
JMPZ RB # DRAW_CELL_CHAR
LD RA,R3 # load R3 with full charactwr
DRAW_CELL_CHAR:
OUT R3,P0
INC RF
DEC R4
JMPNZ R5 #DRAW_I_LOOP

LDA 0x0040 # board character @
OUT R3,P0
LDA 0x000D # CR LF
OUT R3,P0
LDA 0x000A
OUT R3,P0
RET

# Calculate neighbourhood
# Regs used locally: R3, RF (global pointer to board cell), R6, R7
CALCULATE:
LDA D_BOARD_DATA
LD R3,RF # global pointer to current board data cell
LDA D_BOARD_H
LD M3,R6 # board height (counter)
LDA CALC_ROW_LOOP # loop address
LD R3,R7
CALC_ROW_LOOP:

DEC R6
JMPNZ R7 # CALC_ROW_LOOP
RET



# Print text pointed by R4
# Regs used locally: R3, R5, R6, R7
PRINTTXT: # R4 contains text start address (i.e. counter)
LD M4,R5 # counter
LDA END_PRINTTXT
LD R3,R6
LDA PRINT_LOOP
LD R3,R7

PRINT_LOOP:
DEC R5
JMPZ R6 # END_PRINTTXT
INC R4
LD M4,R3
OUT R3,P0
JMP R7 # PRINT_LOOP

END_PRINTTXT:
RET

#.ORG 0x1000
T_CLRSCR:
.DATA 5 # counter+1
.DATA 0x001B, 0x005B, 0x0032, 0x004A # ESC [2J (clear screen)
T_HOME:
.DATA 4 # counter+1
.DATA 0x001B, 0x005B, 0x0048 # ESC [H (home)
T_WELCOME: 
.DATA 8 # counter+1
.DATA 0x0048, 0x0065, 0x006C, 0x006C, 0x006F, 0x000D, 0x000A # Hello \n

D_BOARD_W:
.DATA 40
D_BOARD_H:
.DATA 10

.ORG 0x1000
D_BOARD_DATA:
# assume there's enough space here
# data format: bits 12-15 - neighbours count, bit 0 - current state, bit 1 - next state
.DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.DATA 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0
.DATA 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0
.DATA 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0
.DATA 0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0
.DATA 0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0
.DATA 0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0
.DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0