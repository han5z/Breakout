######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       16
# - Unit height in pixels:      16
# - Display width in pixels:    512
# - Display height in pixels:   512
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
display_address:    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
keyboard_address:    .word 0xffff0000

# Start values
bg_colour:		.word 0xFFF9F0		# set background colour to floral white
wall_colour:		.word 0xE8D4BE		# set wall colour to dutch white
pb_colour:		.word 0x7e7773		# set paddle and ball colour to dark grey
paddle_height:		.word 29		# set paddle height
ball_height:		.word 27		# set ball height
paddle_width:		.word 7			# set width of paddle

exit_prompt_msg:	.asciiz "Type '!' to quit the game"

# Location data
paddle_location:	.word 0			# storage of paddle location (to be initialized)
paddle_shift:		.word 0			# 0 for static, 1 for shift left, 2 for shift right
ball_location:		.word 0		# set ball location to middle of 30th row
ball_travel_x:		.word 1		# Set initial ball travel x direction
ball_travel_y:		.word -1			# Set initial ball travel y direction

# Bricks:
brick_1_colour:		.word 0xff949b		# Set to pink
brick_2_colour:		.word 0xffcba4		# Set to peach
brick_3_colour:		.word 0xfadeb2		# Set to peach-yellow
brick_4_colour:		.word 0xf0edd1		# Set to eggshell
brick_5_colour:		.word 0x8bbf7c		# Set to pistachio
brick_6_colour:		.word 0xf6e4ad		# Set to medium champagne
brick_hard_colour:	.word 0x8c88ba		# Set to lavender purple

# Hearts:
heart_colour:		.word 0xff949b		# Set $t4 to pink
heart_location:		.word 304		# Position of rightmost heart
lives_total:		.word 3			# 3 lives total

# Score
score_message:		.asciiz "Your most recent score was: "
score:			.word 0			# Initialize player score to 0
highscore_message:	.asciiz "Your highest score is: "
highest_score:		.word 0
newline:		.asciiz "\n"

# Sleep time
#sleep_time:		.word 133

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
lw $t1, score
sw $t1, highest_score
add $t1, $zero, $zero
sw $t1, score
lw $t1, heart_location
addi $t1, $zero, 304
sw $t1, heart_location
lw $t1, lives_total
addi $t1, $zero, 3
sw $t1, lives_total 
#lw $t1, sleep_time
#addi $t1, $zero, 133
#sw $t1, sleep_time


#
# Draw background
#
lw $t0, display_address		# Set up function parameters
la $a0, ($t0)
addi $a1, $zero, 32
addi $a2, $zero, 64
lw $a3, bg_colour
lw $t0, display_address
jal draw_rect

#
# Drawing three walls
#

# Draw top wall
lw $t0, display_address
la $a0, 768($t0)
addi $a1, $zero, 32		# Set width to 32
addi $a2, $zero, 3		# Set height to 3
lw $a3, wall_colour		# t4 stores the white-grey hex color code
jal draw_rect

# Draw left side wall
addi $a0, $a0, 384		# Start drawing 9 lines down
addi $a1, $zero, 1		# Set width to 1
addi $a2, $zero, 55		# Set height to 55
lw $a3, wall_colour 
jal draw_rect

# Draw right side wall
addi $a0, $a0, 124
addi $a1, $zero, 1		# Set width to 2 to allow bricks positioned symmetrically
# $a2 remains the same
# $a3 remains the same
jal draw_rect

#
# Draw bricks
#
#
lw $t0, display_address
addi $a0, $t0, 1412
addi $a1, $zero, 30
addi $a2, $zero, 1
# First row
lw $a3, brick_1_colour		# Set $t4 to pink
jal draw_rect
addi $t0, $t0, 8
# Second row
addi $a0, $a0, 128
lw $a3, brick_2_colour		# Set $t4 to peach
jal draw_rect
addi $t0, $t0, 8
# Third row
addi $a0, $a0, 128
lw $a3, brick_3_colour		# Set $t4 to peach-yellow
jal draw_rect
addi $t0, $t0, 8
# Fourth row
addi $a0, $a0, 128
lw $a3, brick_4_colour		# Set $t4 to eggshell
jal draw_rect
addi $t0, $t0, 8
# Fifth row
addi $a0, $a0, 128
lw $a3, brick_5_colour		# Set $t4 to pistachio
jal draw_rect
addi $t0, $t0, 8
# Sixth row
addi $a0, $a0, 128
lw $a3, brick_6_colour		# Set $t4 to medium champagne
jal draw_rect


#
# Draw paddle
#
lw $a0, display_address
# Begin to draw
lw $t2, paddle_height
sll $t2, $t2, 7			# Set row to appropriate value by multiplying 128
addi $t2, $t2, 64		# Set pixel to middle of the row
# Find paddle start location by moving floor of half the paddle width pixels left of the 
# center on row specified by paddle height
lw $t3, paddle_width		# Load paddle width into $t3
addi $t4, $zero, 2		# Load 2 into $t4
div $t3, $t4			# Divide paddle width by 2
mflo $t3			# Load quotient into $t3
sll $t3, $t3, 2			# Multiply $t3 by 4
sub $t2, $t2, $t3		# Calculate starting value of paddle draw
# Update paddle location
sw $t2, paddle_location

lw $t3, paddle_width
add $a0, $a0, $t2		# Set starting position of paddle draw
add $a1, $zero, $t3		# Set width of paddle to 5
addi $a2, $zero, 1		# Set height of paddle to 1
lw $a3, pb_colour		# Set colour of paddle
jal draw_rect

# Draw ball
lw $a3, pb_colour		# Set colour of the ball
jal draw_ball

# Draw hearts
lw $a0, display_address
addi $a0, $a0, 256
lw $a1, heart_colour
jal draw_heart
addi $a0, $a0, 24
jal draw_heart
addi $a0, $a0, 24
jal draw_heart

# Print exit game prompt message
#la $a0, exit_prompt_msg
#li $v0, 4
#syscall


game_loop:
	# 1a. Check if key has been pressed
    	# 1b. Check which key has been pressed
    	# 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
    	#5. Go back to 1
    #lw $t1, score
    #bne $t1, 15, before_key
    #lw $t2, sleep_time
    #sra $t2, $t2, 2
    #sw $t2, sleep_time  
    
    before_key:
    lw $t9, keyboard_address
    lw $t8, 0($t9)
    beq $t8, 1, keypress_happened
    
    after_key:
    jal update_ball_location
    
    # Update ball on screen
    lw $t0, ball_location	# Load ball location into $t0
    add $t1, $t0, $zero		# Save initial location into $t1
    lw $t2, ball_travel_x	
    sll $t2, $t2, 2
    lw $t3, ball_travel_y
    sll $t3, $t3, 7
    add $t1, $t1, $t2
    add $t1, $t1, $t3		# Update $t1 to the new location
    sw $t1, ball_location	# Update ball location in memory
    # Erase old ball
    lw $t6, display_address
    lw $t8, bg_colour
    add $t6, $t6, $t0
    sw $t8, 0($t6)
    # Draw new ball
    lw $t6, display_address
    add $t6, $t6, $t1		# Go to the new location stored in $t1
    lw $t7, pb_colour		# Load ball colour into $t7
    sw $t7, 0($t6)    		# Draw pixel with colour of ball
    
    # Draw new paddle
    lw $t0, paddle_shift	# Determine which way to draw paddle
    beq $t0, 0, refresh_paddle	# Do not shift paddle if value is 0
    beq $t0, 1, paddle_l	# Shift paddle left if value is 1
    jal paddle_right_draw	# Shift paddle right if value is 2
    j paddle_draw_end
    paddle_l:
    jal paddle_left_draw
    j paddle_draw_end
    refresh_paddle:		# Redraw paddle if none of the other cases (in edge case where ball overwrites paddle)
    lw $a0, display_address
    lw $t1, paddle_location
    add $a0, $a0, $t1
    lw $a1, paddle_width
    addi $a2, $zero, 1
    lw $a3, pb_colour
    jal draw_rect
    
    paddle_draw_end:
    add $t1, $zero, $zero
    sw $t1, paddle_shift
    
    # Sleep
    li $v0, 32
    li $a0, 166
    syscall
    b game_loop

# Determine what function to perform based on key pressed
keypress_happened:
lw $t1, 4($t9)			# Load key that was pressed into $t1
beq $t1, 0x21, respond_to_exl
beq $t1, 0x61, respond_to_a
beq $t1, 0x64, respond_to_d
beq $t1, 0x70, respond_to_p
j after_key

respond_to_exl:		# Exit the program
j end

respond_to_p:
lw $t9, keyboard_address
lw $t8, 0($t9)
beq $t8, 1, pause_keypress_happened
li $v0, 32
li $a0, 133
syscall
b respond_to_p

pause_keypress_happened:
# Add sound effect
    addi $a0, $zero, 67		#(0-127) pitch
    addi $a1, $zero, 66		# 66 milliseconds duration
    addi $a2, $zero, 80	# instrument
    addi $a3, $zero, 80		# (0-127) volume
    li $v0, 33
    syscall
    
lw $t1, 4($t9)
beq $t1, 0x70, after_key
j respond_to_p

respond_to_a:		# Check for collision, if none update location and draw new paddle
lw $t0, paddle_height
lw $t1, paddle_location
sll $t0, $t0, 7		# Find left border on the screen
addi $t0, $t0, 4	# Check if next pixel over is the paddle
beq $t1, $t0, a_col	# Do not update and draw if paddle is on border
addi $t1, $t1, -4	# Update location of paddle
sw $t1, paddle_location	# Store new location back into paddle_location
addi $t2, $zero, 1
sw $t2, paddle_shift	# Set paddle shift to 1 (left shift)
a_col:
j after_key

respond_to_d:		# Check for collision, if none update location and draw new paddle
lw $t0, paddle_height
lw $t1, paddle_location
sll $t0, $t0, 7		
addi $t0, $t0, 124	# Find right border on the screen
lw $t5, paddle_width
sll $t5, $t5, 2		# Multiply paddle width by 4
sub $t0, $t0, $t5
beq $t0, $t1, d_col	# Do not update and draw if paddle is on right border
addi $t1, $t1, 4	# Update location of paddle
sw $t1, paddle_location	# Store new location back into paddle_location
addi $t2, $zero, 2
sw $t2, paddle_shift	# Set paddle shift to 2 (right shift)
d_col:
j after_key

paddle_left_draw:
lw $t1, paddle_location
lw $t2, display_address	# Load display address into $a0
lw $a3, pb_colour	# Load paddle colour into $a3
add $a0, $t2, $t1	# Set display address to new paddle location on the display
lw $a1, paddle_width
addi $a2, $zero, 1
addi $sp, $sp, -4
sw $ra, ($sp)
jal draw_rect		# Draw new pixel left of the old paddle
lw $ra, ($sp)
addi $sp, $sp, 4
sll $a1, $a1, 2
add $a0, $a0, $a1
lw $t3, bg_colour	# Load background colour into $t3
sw $t3, 0($a0)		# Erase pixel on the rightmost of the paddle
jr $ra

paddle_right_draw:
lw $t1, paddle_location
lw $a0, display_address	# Load display address into $a0
lw $t3, bg_colour	# Load background colour into $t3
lw $a3, pb_colour	# Load paddle colour into $a3
add $a0, $a0, $t1	# Set display address to new paddle location on the display
sw $t3, -4($a0)		# Erase pixel on the leftmost of the paddle
lw $a1, paddle_width	# Load paddle width into $a1
addi $a2, $zero, 1
addi $sp, $sp, -4	# Store $ra in stack and draw paddle
sw $ra, ($sp)
jal draw_rect		# Draw new paddle right of the old paddle
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

lose_life:
lw $t1, lives_total
addi $t1, $t1, -1
sw $t1, lives_total
lw $t2, heart_location
lw $a0, display_address
add $a0, $a0, $t2
lw $a1, bg_colour
jal draw_heart
lw $t1, lives_total
blez $t1, go_to_end
blez $t1, go_to_end
addi $t2, $t2, -24
sw $t2, heart_location

# Add sound effect
    addi $a0, $zero, 63		#(0-127) pitch
    addi $a1, $zero, 300	# 66 milliseconds duration
    addi $a2, $zero, 87		# instrument
    addi $a3, $zero, 80		# (0-127) volume
    li $v0, 33
    syscall

# Draw ball
lw $a3, pb_colour		# Set colour of the ball
jal draw_ball
addi $t0, $zero, 1
addi $t1, $zero, -1
sw $t0, ball_travel_x
sw $t1, ball_travel_y
li $v0, 32
li $a0, 500
syscall
j game_loop
go_to_end:
j end

update_ball_location:
    # Fetch ball location
    lw $t0, ball_location	# $t0 holds the current location of the ball
    lw $t2, ball_travel_x	# load x travel direction into $t2
    lw $t3, ball_travel_y	# load y travel direction into $t3
    
    # Calculate new location
    add $t1, $t0, $zero		# Store new location in $t1
    sll $t2, $t2, 2		# Multiply x by 4
    sll $t3, $t3, 7		# Multiply y by 128
    add $t1, $t1, $t2		# Add x travel into $t1
    add $t1, $t1, $t3		# Add y travel into $t1
    
    # Check if off screen
    ble $t1, 4220, continue_walls	# If ball outside of 4220 end the game
    j lose_life
    
    continue_walls:
    # Check for collision with walls
    lw $t4, display_address
    add $t4, $t4, $t1
    lw $t5, wall_colour
    lw $t6, 0($t4)
    bne $t5, $t6, end_wall_check	# Move to next check if new location is not a wall
    # Check for collision with top wall
    bge $t1, 1152, continue_side	# Reverse y-direction if coming into contact with top wall
    # Reverse ball y-direction
    lw $t3, ball_travel_y
    neg $t3, $t3		# Negate y-direction
    sw $t3, ball_travel_y	# Store back into address
    # check collision with corners
    beq $t1, 1024, continue_side
    bne $t1, 1148, check_paddle
    continue_side:
    # Reverse ball x-direction
    lw $t3, ball_travel_x
    neg $t3, $t3		# Negate x-direction
    sw $t3, ball_travel_x	# Store back into address
    end_wall_check:
    
    # Check collisions for bricks in all scenarios
    # Scenario 1: brick to the top/bottom of the ball (takes precedence)
    sub $t1, $t1, $t2
    addi $sp, $sp, -4
    sw $ra, ($sp)
    jal check_bricks
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    # Scenario 2: brick to the left/right of the ball
    lw $t1, ball_location
    lw $t2, ball_travel_x
    sll $t2, $t2, 2
    add $t1, $t1, $t2
    addi $t9, $zero, 1
    addi $sp, $sp, -4
    sw $ra, ($sp)
    jal check_bricks
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    # Scenario 3: brick neither to the top/bottom but diagonal in the direction of the ball
    # Only break this brick if scenario 1 and 2 do not occur
    lw $t0, ball_location	# $t0 holds the current location of the ball
    lw $t2, ball_travel_x	# load x travel direction into $t2
    lw $t3, ball_travel_y	# load y travel direction into $t3
    lw $t4, bg_colour
    lw $t5, display_address
    add $t1, $t0, $zero		# Store new location in $t1
    sll $t2, $t2, 2		# Multiply x by 4
    sll $t3, $t3, 7		# Multiply y by 128
    add $t1, $t1, $t2		# Add x travel into $t1
    add $t5, $t5, $t1		# Check if there is no bricks to the left/right
    lw $t6, 0($t5)
    bne $t6, $t4, end_scenario
    sub $t5, $t5, $t1
    sub $t1, $t1, $t2
    add $t1, $t1, $t3		# Add y travel into $t1
    add $t5, $t5, $t1		# Check if there is no bricks to the top/bottom
    lw $t6, 0($t5)
    bne $t6, $t4, end_scenario
    add $t1, $t1, $t2		# Add back left/right movement
    addi $t9, $zero, 2		# Give the erase_brick function special instructions
    addi $sp, $sp, -4
    sw $ra, ($sp)
    jal check_bricks
    lw $ra, ($sp)
    addi $sp, $sp, 4
    
    end_scenario:
    
    check_paddle:
    # Check for collision with paddle
    # Reload information
    lw $t0, ball_location	# $t0 holds the current location of the ball
    lw $t3, ball_travel_y	# load y travel direction into $t3
    # Calculate new location
    add $t1, $t0, $zero		# Store new location in $t1
    sll $t3, $t3, 7		# Multiply y by 128
    add $t1, $t1, $t3		# Add y travel into $t1
    lw $t4, paddle_location	# Check for collision with paddle
    sub $t6, $t1, $t4		# Obtain difference between paddle location and new ball location
    lw $t8, paddle_width	# Load paddle width into $t8
    sll $t8, $t8, 2		# Find the range of acceptable values $t2 can fall in
    subi $t8, $t8, 4		# Adjust range
    bgt $t6, $t8, continue	# Check if $t2 is to the right side the paddle range
    blt $t6, $zero, continue	# Check if $t2 is to the left side of the paddle range
    # Reverse ball y-direction if paddle hit
    lw $t3, ball_travel_y
    neg $t3, $t3		# Negate y-direction
    sw $t3, ball_travel_y	# Store back into address
    
    continue:
jr $ra


check_bricks:
    lw $t0, display_address	# Load display address into $t0
    add $t0, $t0, $t1		# Set display address to new calculated shift
    lw $t2, 0($t0)		# Grab the pixel colour from location and store into $t2
    
    lw $t3, brick_1_colour	# store the colour brick is supposed to be in $t3
    add $a2, $t1, $zero		# store new location into $a2
    addi $a1, $zero, 20		# Number to divide brick by
    bne $t2, $t3, finish_check_1	# Check if colours are equal, if so remove the brick
    addi $a3, $zero, 1412	# Row number of the first row of bricks
    addi $sp, $sp, -4
    sw $ra, ($sp)		# Store $ra in stack
    jal erase_brick
    lw $ra, ($sp)
    addi $sp, $sp, 4
    finish_check_1:
    
    lw $t3, brick_2_colour
    bne $t2, $t3, finish_check_2	# Check if colours are equal, if so remove the brick
    addi $a3, $zero, 1540	# Row number of the first row of bricks
    addi $sp, $sp, -4
    sw $ra, ($sp)		# Store $ra in stack
    jal erase_brick
    lw $ra, ($sp)
    addi $sp, $sp, 4
    finish_check_2:
    
    lw $t3, brick_3_colour
    bne $t2, $t3, finish_check_3	# Check if colours are equal, if so remove the brick
    addi $a3, $zero, 1668	# Row number of the first row of bricks
    addi $sp, $sp, -4
    sw $ra, ($sp)		# Store $ra in stack
    jal change_brick
    lw $ra, ($sp)
    addi $sp, $sp, 4
    finish_check_3:
    
    lw $t3, brick_4_colour
    bne $t2, $t3, finish_check_4	# Check if colours are equal, if so remove the brick
    addi $a3, $zero, 1796	# Row number of the first row of bricks
    addi $sp, $sp, -4
    sw $ra, ($sp)		# Store $ra in stack
    jal erase_brick
    lw $ra, ($sp)
    addi $sp, $sp, 4
    finish_check_4:
    
    lw $t3, brick_5_colour
    bne $t2, $t3, finish_check_5	# Check if colours are equal, if so remove the brick
    addi $a3, $zero, 1924	# Row number of the first row of bricks
    addi $sp, $sp, -4
    sw $ra, ($sp)		# Store $ra in stack
    jal erase_brick
    lw $ra, ($sp)
    addi $sp, $sp, 4
    finish_check_5:
    
    lw $t3, brick_6_colour
    bne $t2, $t3, finish_check_6	# Check if colours are equal, if so remove the brick
    addi $a3, $zero, 2052	# Row number of the first row of bricks
    addi $sp, $sp, -4
    sw $ra, ($sp)		# Store $ra in stack
    jal erase_brick
    lw $ra, ($sp)
    addi $sp, $sp, 4
    finish_check_6:
    
    
    # Turns peach-yellow into lavender purple
    lw $t3, brick_hard_colour
    bne $t2, $t3, finish_check_hard	# Check if colours are equal, if so remove the brick
    addi $a3, $zero, 1668	# Row number of the first row of bricks
    addi $sp, $sp, -4
    sw $ra, ($sp)		# Store $ra in stack
    jal erase_brick
    lw $ra, ($sp)
    addi $sp, $sp, 4
    finish_check_hard:
jr $ra

# 
# $a0: address of brick row in memory
# $a1: width of brick (to divide by)
# $a2: calculated new position of ball
# $a3: starting point of the brick row
erase_brick:
    sub $a2, $a2, $a3		# Get current position relatiev to start position of row
    div $a2, $a1		# Divide by 20 (5 pixels)
    mflo $t3			# Get quotient to find which brick corresponds with the location
    lw $t0, display_address
    add $t0, $t0, $a3
    addi $t2, $zero, 20
    mult $t2, $t3
    mflo $t2
    add $t0, $t0, $t2
    lw $t3, bg_colour
    sw $t3, 0($t0)
    sw $t3, 4($t0)
    sw $t3, 8($t0)
    sw $t3, 12($t0)
    sw $t3, 16($t0)
    beq $t9, 1, reverse_ball_x
    lw $t3, ball_travel_y	# Reverse ball y-direction if brick hit
    neg $t3, $t3		# Negate y-direction
    sw $t3, ball_travel_y	# Store back into address
    beq $t9, 2, reverse_ball_x
    j erase_brick_end
    reverse_ball_x:
    lw $t3, ball_travel_x	# Reverse ball y-direction if brick hit
    neg $t3, $t3		# Negate y-direction
    sw $t3, ball_travel_x	# Store back into address
    erase_brick_end:	
    lw $t1, score		# Update score
    addi $t1, $t1, 1
    sw $t1, score
    # Add sound effect
    addi $a0, $zero, 62		#(0-127) pitch
    addi $a1, $zero, 66		# 66 milliseconds duration
    addi $a2, $zero, 120	# instrument
    addi $a3, $zero, 80		# (0-127) volume
    li $v0, 33
    syscall
jr $ra

# 
# $a0: address of brick row in memory
# $a1: width of brick (to divide by)
# $a2: calculated new position of ball
# $a3: starting point of the brick row
change_brick:
    sub $a2, $a2, $a3		# Get current position relatiev to start position of row
    div $a2, $a1		# Divide by 20 (5 pixels)
    mflo $t3			# Get quotient to find which brick corresponds with the location
    lw $t0, display_address
    add $t0, $t0, $a3
    addi $t2, $zero, 20
    mult $t2, $t3
    mflo $t2
    add $t0, $t0, $t2
    lw $t3, brick_hard_colour
    sw $t3, 0($t0)
    sw $t3, 4($t0)
    sw $t3, 8($t0)
    sw $t3, 12($t0)
    sw $t3, 16($t0)
    beq $t9, 1, reverse_ball_x_h
    lw $t3, ball_travel_y	# Reverse ball y-direction if brick hit
    neg $t3, $t3		# Negate y-direction
    sw $t3, ball_travel_y	# Store back into address
    beq $t9, 2, reverse_ball_x_h
    j erase_brick_end_h
    reverse_ball_x_h:
    lw $t3, ball_travel_x	# Reverse ball y-direction if brick hit
    neg $t3, $t3		# Negate y-direction
    sw $t3, ball_travel_x	# Store back into address
    erase_brick_end_h:	
    lw $t1, score		# Update score
    addi $t1, $t1, 1
    sw $t1, score
    # Add sound effect
    addi $a0, $zero, 62		#(0-127) pitch
    addi $a1, $zero, 66		# 66 milliseconds duration
    addi $a2, $zero, 120	# instrument
    addi $a3, $zero, 80		# (0-127) volume
    li $v0, 33
    syscall
jr $ra

# The rectangle drawing function
# Takes in the following:
# - $a0 : Starting location for drawing the rectangle
# - $a1 : The width of the rectangle
# - $a2 : The height of the rectangle
# - $a3 : The colour of the rectangle
draw_rect:
add $t0, $zero, $a0		# Put drawing location into $t0
add $t1, $zero, $a2		# Put the height into $t1
add $t2, $zero, $a1		# Put the width into $t2
add $t3, $zero, $a3		# Put the colour into $t3

outer_loop:
beq $t1, $zero, end_outer_loop	# if the height variable is zero, then jump to the end.

# draw a line
inner_loop:
beq $t2, $zero, end_inner_loop	# if the width variable is zero, jump to the end of the inner loop
sw $t3, 0($t0)			# draw a pixel at the current location.
addi $t0, $t0, 4		# move the current drawing location to the right.
addi $t2, $t2, -1		# decrement the width variable
j inner_loop			# repeat the inner loop
end_inner_loop:

addi $t1, $t1, -1		# decrement the height variable
add $t2, $zero, $a1		# reset the width variable to $a1
# reset the current drawing location to the first pixel of the next line.
addi $t0, $t0, 128		# move $t0 to the next line
sll $t4, $t2, 2			# calculate rectangle width in pixels
sub $t0, $t0, $t4		# move $t0 to the first pixel to draw in this line.
j outer_loop			# jump to the beginning of the outer loop

end_outer_loop:			# the end of the rectangle drawing
jr $ra			# return to the calling program

#
# Draw heart
# $a0: starting position of heart
# $a1: colour of heart
draw_heart:
add $t0, $zero, $a0
add $t1, $zero, $a1
sw $t1, 4($t0)
sw $t1, 12($t0)
sw $t1, 128($t0)
sw $t1, 132($t0)
sw $t1, 136($t0)
sw $t1, 140($t0)
sw $t1, 144($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 268($t0)
sw $t1, 392($t0)
jr $ra

#
# Draw ball
#
draw_ball:
lw $t0, display_address
lw $t2, ball_height
sll $t2, $t2, 7			# Multiply height by 128
add $t3, $zero, $a0
sll $t3, $t3, 2
addi $t2, $t2, 64		# Ball offset from center
sw $t2, ball_location
add $t0, $t0, $t2		# Begin to draw ball on the 30th row
sw $a3, 0($t0)
jr $ra

####################################################################

end:

# Add sound effect
    addi $a0, $zero, 36		#(0-127) pitch
    addi $a1, $zero, 500	# 66 milliseconds duration
    addi $a2, $zero, 16	# instrument
    addi $a3, $zero, 80		# (0-127) volume
    li $v0, 33
    syscall

lw $a0, display_address
addi $a1, $zero, 32
addi $a2, $zero, 32
li $a3, 0xffffff
jal draw_rect
li $t1, 0x272b2b
addi $a0, $a0, 2108
sw $t1, -128($a0)
sw $t1, 0($a0)
sw $t1, 4($a0)
sw $t1, 8($a0)
sw $t1, 128($a0)
sw $t1, 140($a0)
sw $t1, 256($a0)
sw $t1, 384($a0)

la $a0, score_message
li $v0, 4
syscall
lw $a0, score
li $v0, 1
syscall
li $v0, 4
la $a0, newline
syscall

lw $a0, highest_score
blez $a0, end_loop
la $a0, highscore_message
li $v0, 4
syscall
lw $a0, highest_score
li $v0, 1
syscall
li $v0, 4
la $a0, newline
syscall

li $v0, 32

end_loop:
lw $t9, keyboard_address
lw $t8, 0($t9)
beq $t8, 1, end_keypress
    li $v0, 32
    li $a0, 500
    syscall
b end_loop

end_keypress:
lw $t1, 4($t9)
beq $t1, 0x72, restart
beq $t1, 0x65, exit
j end_loop
restart:
j main

exit:
li $v0, 10
syscall
