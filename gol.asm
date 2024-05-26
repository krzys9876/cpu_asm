.ORG 0x0000 # START

# Global regs:
# RD - main loop counter
LDA 0
LD R3,RD

CALL CLEARSCR

# Main loop
START:
CALL HOME # cursor - go home
CALL DRAWBOARD # redraw entire board
CALL CALCULATE # calculate g.o.l. rules
CALL UPDATE # update cell state
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
# Regs used locally: 
# R3 - scratch
# RF - global pointer to board cell
# R6 - vertical position (desc)
# R7 - loop address
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
# Regs used locally: 
# R3 - scratch
# R4 - horizontal position (desc)
# R5 - loop address
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
# Regs used locally: 
# R3 - scratch
# R4 - horizontal position (desc)
# R5 - loop address
# R8, R9, RA, RB - scratches
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
# Regs used locally: 
# R3 - scratch
# RF - global pointer to board cell
# R5, R7 - jump addresses
# R4 - horizontal position (desc)
# R6 - vertical position (desc)
# RE - current cell value
# RC - scratch
# RB - pointer to neighbour

CALCULATE:
LDA D_BOARD_DATA
LD R3,RF # global pointer to current board data cell
LDA D_BOARD_H
LD M3,R6 # board height (counter)
LDA CALC_ROW_LOOP # loop address
LD R3,R7

CALC_ROW_LOOP:
LDA D_BOARD_W
LD M3,R4 # board width (counter)
LDA CALC_CELL_LOOP
LD R3,R5 # loop address

CALC_CELL_LOOP:
LD MF,RE # initial cell value
LDA 0x000F
AND RE,R3 # reset neighbours counter and next state

# 8 positions (clock-wise starting with right)
# Right neighbour
LDA 1 # check if not right border
CMP R4,R3
JMPIZ CONT_RIGHT 
LD RF, RB
INC RB # move right
CALL CALC_ONE_NEIGHBOUR
CONT_RIGHT:

#Lower right neighbour
LDA 1 # check if not right border
CMP R4,R3
JMPIZ CONT_LOWER_RIGHT
LDA 1 # check if lower border
CMP R6,R3
JMPIZ CONT_LOWER_RIGHT
LD RF, RB
INC RB # move right
LDA D_BOARD_W # move down one row
LD M3,RC
ADD RB,RC
CALL CALC_ONE_NEIGHBOUR
CONT_LOWER_RIGHT:

#Lower neighbour
LDA 1 # check if lower border
CMP R6,R3
JMPIZ CONT_LOWER
LDA D_BOARD_W # move down one row
LD M3,RC
LD RF, RB
ADD RB,RC
CALL CALC_ONE_NEIGHBOUR
CONT_LOWER:

#Lower left neighbour
LDA D_BOARD_W # check if left border
LD M3,RC
CMP R4,RC
JMPIZ CONT_LOWER_LEFT
LDA 1 # check if lower border
CMP R6,R3
JMPIZ CONT_LOWER_LEFT
LD RF, RB
DEC RB # move left
LDA D_BOARD_W # move down one row
LD M3,RC
ADD RB,RC
CALL CALC_ONE_NEIGHBOUR
CONT_LOWER_LEFT:

#Left neighbour
LDA D_BOARD_W # check if left border
LD M3,RC
CMP R4,RC
JMPIZ CONT_LEFT
LD RF, RB
DEC RB # move left
CALL CALC_ONE_NEIGHBOUR
CONT_LEFT:

#Upper left neighbour
LDA D_BOARD_W # check if left border
LD M3,RC
CMP R4,RC
JMPIZ CONT_UPPER_LEFT
LDA D_BOARD_H # check if upper border
LD M3,RC
CMP R6,RC
JMPIZ CONT_UPPER_LEFT
LD RF, RB
DEC RB # move left
LDA D_BOARD_W # move up one row
LD M3,RC
SUB RB,RC
CALL CALC_ONE_NEIGHBOUR
CONT_UPPER_LEFT:

#Upper neighbour
LDA D_BOARD_H # check if upper border
LD M3,RC
CMP R6,RC
JMPIZ CONT_UPPER
LDA D_BOARD_W # move up one row
LD M3,RC
LD RF, RB
SUB RB,RC
CALL CALC_ONE_NEIGHBOUR
CONT_UPPER:

#Upper right neighbour
LDA 1 # check if not right border
CMP R4,R3
JMPIZ CONT_UPPER_RIGHT
LDA D_BOARD_H # check if upper border
LD M3,RC
CMP R6,RC
JMPIZ CONT_UPPER_RIGHT
LD RF, RB
INC RB # move right
LDA D_BOARD_W # move up one row
LD M3,RC
SUB RB,RC
CALL CALC_ONE_NEIGHBOUR
CONT_UPPER_RIGHT:

LD RE,MF # load calculated neighbours back to memory

CALL CALC_NEXT_STATE

INC RF
DEC R4
JMPNZ R5 #CALC_CELL_LOOP
DEC R6
JMPNZ R7 # CALC_ROW_LOOP
RET


# check if neighbour cell is alive
# Regs used locally:
# RB - pointer to neighbour
# RE - currennt cell value - to be increased if neighbour is alive
# RC - scratch
CALC_ONE_NEIGHBOUR:
LD MB,RC # check if neighbour is alive (1 bit)
LDA 0x0001
AND RC,R3
JMPIZ CALC_ONE_NEIGHBOUR_END
LDA 0x1000 # Add 1 to neighbours counter
ADD RE,R3
CALC_ONE_NEIGHBOUR_END:
RET

# Calculate next state using previously calculated number of alive neighbours
# Regs used locally:
# RF - global pointer to board cell
# R3 - scratch
# RC - scratch
# Rules:
# 1. Any live cell with fewer than two live neighbors dies, as if by underpopulation.
# 2. Any live cell with two or three live neighbors lives on to the next generation.
# 3. Any live cell with more than three live neighbors dies, as if by overpopulation.
# 4. Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.
CALC_NEXT_STATE:
LD MF,RC # start with current state, NOTE: next state is reset at the beginning of calculation

# Rule 1. 0 or 1 member - alive cell dies
LDA 0x0001
CMP RC,R3
JMPIZ NEXT_DEAD
LDA 0x1001
CMP RC,R3
JMPIZ NEXT_DEAD

# Rule 2. 2 or 3 members - alive cell remains alive
LDA 0x2001
CMP RC,R3
JMPIZ NEXT_ALIVE
LDA 0x3001
CMP RC,R3
JMPIZ NEXT_ALIVE

# Rule 4. dead cell with 3 neighbours becomes alive
LDA 0x3000
CMP RC,R3
JMPIZ NEXT_ALIVE

# Rule 3. and all other cases - cell becomes / remains dead

NEXT_DEAD: 
LDA 0xFFEF # reset bit 4
AND RC,R3
LD RC,MF # load next state back to memory
RET

NEXT_ALIVE:
LDA 0x0010 # set bit 4
OR RC,R3
LD RC,MF # load next state back to memory
RET

# Update board - copy next state to current state
# Regs used locally: 
# R3 - scratch
# RF - global pointer to board cell
# R5, R7, R8, R9 - jump addresses
# R4 - horizontal position (desc)
# R6 - vertical position (desc)
# RE, RC - scratches

UPDATE:
LDA D_BOARD_DATA
LD R3,RF # global pointer to current board data cell
LDA D_BOARD_H
LD M3,R6 # board height (counter)
LDA UPDATE_ROW_LOOP # loop address
LD R3,R7
LDA UPDATE_DEAD # loop address
LD R3,R8
LDA UPDATE_CELL_LOOP_END # loop address
LD R3,R9

UPDATE_ROW_LOOP:
LDA D_BOARD_W
LD M3,R4 # board width (counter)
LDA UPDATE_CELL_LOOP
LD R3,R5 # loop address

UPDATE_CELL_LOOP:
LD MF,RE # initial cell value
LD RE,RC # copy value for comparison
LDA 0x0010
AND RC,R3 # check next state
JMPZ R8 # UPDATE_DEAD

LDA 0x0001
OR RE,R3
LD RE,MF
JMP R9 # UPDATE_CELL_LOOP_END

UPDATE_DEAD:
LDA 0xFFFE
AND RE,R3
LD RE,MF

UPDATE_CELL_LOOP_END:
INC RF
DEC R4
JMPNZ R5 #CALC_CELL_LOOP
DEC R6
JMPNZ R7 # CALC_ROW_LOOP
RET


# Print text pointed by R4
# Regs used locally: 
# R3 - scratch
# R4 - parameter - start address
# R5 - counter
# R6, R7 - loop addresses
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
# data format: bits 12-15 - neighbours count, bit 0 - current state, bit 4 - next state
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