# Homework #3
# name: Daniel Garcia
# sbuid: 111157499

##################################
# Part 1 - String Functions
##################################

is_whitespace:

	beq $a0, '\0', is_whiteSpaceComplete	# If the character is a '\0', branch to is_whitespaceComplete
	beq $a0, '\n', is_whiteSpaceComplete	# If the character is a '\n', branch to is_whitespaceComplete
	beq $a0, ' ', is_whiteSpaceComplete	# If the character is a ' ', branch to is_whitespaceComplete
	j is_whitespaceError			# Otherwise, branch to is_whitespaceError

	is_whiteSpaceComplete:
	li $v0, 1				# Sets return value to 1 at return reg[$v0]
	j returnIs_whitespace			# Proceed to return value

	is_whitespaceError:
	li $v0, 0				# Sets return value to 0 at return reg[$v0]
	j returnIs_whitespace			# Proceed to return value
	
	returnIs_whitespace:
	jr $ra

cmp_whitespace:

	addi $sp, $sp, -8			# Add 8 bytes of memory allocation in the stack
    	sw $ra, 0($sp)				# Store the return address in the stack
    	sw $s0, 4($sp)				# Store reg[$s0] in the stack (Will be used later)
	
	move $s0, $a1				# Move the second char argument to reg[$s0]
	jal is_whitespace			# Call is_whitespace function
	beqz $v0, returnCmp_whitespace		# If the character is not a whitespace character, proceed to return function
	
	move $a0, $s0				# Move the saved second char argument to reg[$a0]
	jal is_whitespace			# Call is_whitespace function
	beqz $v0, returnCmp_whitespace		# If the character is not a whitespace character, proceed to return function
	
	returnCmp_whitespace:
	lw $ra, 0($sp)				# Restore return address from stack
	lw $s0, 4($sp)				# Restore reg[$s0] from stack
	addi $sp, $sp, 8			# Reset the stack pointer
	jr $ra

strcpy:
	
	ble $a0, $a1, returnStrcpy		# If the src address is less than or equal to the dest address, proceed to return function
	
	li $t0, 0				# Initialize byte counter to 0
	
	strcpyLoop:
		beq $t0, $a2, returnStrcpy	# If the byte counter reaches n, end loop
		lb $t1, 0($a0)			# Load the byte from the src address
		sb $t1, 0($a1)			# Copy this byte to the dest address
		addi $t0, $t0, 1		# Increment the byte counter
		addi $a0, $a0, 1		# Increment the src address
		addi $a1, $a1, 1		# Increment the dest address
		j strcpyLoop			# Jump back to the loop
	
	returnStrcpy:
	jr $ra

strlen:

	addi $sp, $sp, -12			# Add 12 bytes of memory allocation in the stack
    	sw $ra, 0($sp)				# Store the return address in the stack
    	sw $s0, 4($sp)				# Store reg[$s0] in the stack (Will be used later)
    	sw $s1, 8($sp)				# Store reg[$s1] in the stack (Will be used later)
    	
    	move $s0, $a0				# Move the string address into reg[$s0]
    	li $s1, 0				# Initialize length counter to zero
    	
    	strlenLoop:
    		lb $a0, 0($s0)			# Load the byte from the string address into argument reg[$a0]
    		jal is_whitespace		# Call is_whitespace function
    		li $t0, 1			# Initialize to check if byte is a whitespace
    		beq $v0, $t0, returnStrlen	# If the byte is a whitespace character, proceed to return length
    		addi $s0, $s0, 1		# Otherwise, increment the string address
    		addi $s1, $s1, 1		# And increment the length counter
    		j strlenLoop			# Jump back to the loop
    	
	returnStrlen:
	move $v0, $s1				# Move the length counter to the first return value
	lw $ra, 0($sp)				# Restore return address from stack
	lw $s0, 4($sp)				# Restore reg[$s0] from stack
	lw $s1, 8($sp)				# Restore reg[$s1] from stack
	addi $sp, $sp, 12			# Reset the stack pointer
	jr $ra

##################################
# Part 2 - vt100 MMIO Functions
##################################

set_state_color:
	
	# Category Check #
	beqz $a2, categoryZeroSelected		# If the category is 0, proceed to replace default colors
	li $t0, 1				# Initialize category check for 1 at reg[$t0]
	beq $a2, $t0, categoryOneSelected	# If the category is 1, proceed to replace highlight colors
	j returnSet_state_color			# Else, return function with struct unedited
	
	categoryZeroSelected:
	lb $t1, 0($a0)				# Load the default color byte
	move $t2, $a0				# Move struct address to a temp variable
	j modeCheck				# Proceed to mode check
	
	categoryOneSelected:
	addi $a0, $a0, 1			# Increment struct address to edit highlight color byte
	lb $t1, 0($a0)				# Load the highlight color byte
	move $t2, $a0				# Move struct address to a temp variable
	j modeCheck				# Proceed to mode check
	
	# Mode Check #
	modeCheck:
	beqz $a3, modeZeroSelected		# If the mode is 0, proceed to code with 0 input
	li $t0, 1				# Initialize mode check for 1 at reg[$t0]
	beq $a3, $t0, modeOneSelected		# If the mode is 1, proceed to code with 1 input
	li $t0, 2				# Initialize mode check for 2 at reg[$t0]
	beq $a3, $t0, modeTwoSelected		# If the mode is 2, proceed to code with 2 input
	j returnSet_state_color			# Else, return and do nothing
	
	modeZeroSelected:
	sb $a1, 0($t2)				# Replace the old color byte
	j returnSet_state_color			# Proceed to return function
	
	modeOneSelected:
	li $t0, 0xf				# Initialize mask for foreground [00001111]
	and $a1, $a1, $t0			# Mask color to obtain only foreground
	li $t0, 0xf0				# Initialize mask for old background [11110000]
	and $t1, $t1, $t0			# Mask color to keep old background
	add $t1, $t1, $a1			# Add bytes to obtain new color byte
	sb $t1, 0($t2)				# Replace old color byte
	j returnSet_state_color			# Proceed to return function
	
	modeTwoSelected:
	li $t0, 0xf0				# Initialize mask for new background [11110000]
	and $a1, $a1, $t0			# Mask color to obtain new background
	li $t0, 0xf				# Initialize mask for old foreground [00001111]
	and $t1, $t1, $t0			# Mask color to keep old foreground
	add $t1, $t1, $a1			# Add bytes to obtain new color byte
	sb $t1, 0($t2)				# Replace old color byte
	j returnSet_state_color			# Proceed to return function
		
	returnSet_state_color:
	jr $ra

save_char:
	
	lb $t0, 2($a0)			# Load x (row) position of cursor
	li $t1, 80			# Set temporary counter of number of columns
	mul $t0, $t0, $t1		# [i] * num of columns
	lb $t1, 3($a0)			# Load y (column) position of cursor
	add $t0, $t0, $t1		# ([i] * num of columns) + [j]
	sll $t0, $t0, 1			# Multiple by 2 (Number of bytes per cell) to obtain address increment
	li $t1, 0xffff0000		# Initialize base address of MMIO
	add $t0, $t0, $t1		# Add to base address to obtain cursor address
	sb $a1, 0($t0)			# Store the char at this cursor address
	
	jr $ra

reset:

	# color_only Check #
	beqz $a1, continueReset			# If color_only is set to 0, proceed to continueReset
	li $t0, 1				# Initialize mode check to 1
	beq $a1, $t0, continueReset		# If color_only is set to 1, proceed to continueReset
	j returnReset				# Else, return and do nothing
	
	continueReset:
	li $t0, 0xffff0000			# Initialize base address of first cell
	li $t1, 0xffff0fa0			# Initialize final address
	lb $t2, 0($a0)				# Load default color byte
	resetLoop:
		bge $t0, $t1, returnReset	# If every cell has been traversed, proceed to return function
		beqz $a1, colorAndAsciiMode	# If color_only is set to 0, proceed to colorAndAsciiMode
		j continueResetLoop		# Else, continue loop
			colorAndAsciiMode:
			li $t3, '\0'		# Initialize null character
			sb $t3, 0($t0)		# Set the ascii value at this cell address to null
		continueResetLoop:
		sb $t2, 1($t0)			# Set the color at this cell address to the default color
		addi $t0, $t0, 2		# Increment the base address to traverse to the next cell
		j resetLoop			# Jump back to the loop

	returnReset:
	jr $ra

clear_line:

	li $t0, 80				# Set temporary counter of number of columns
	mul $t0, $t0, $a0			# [i] * num of columns
	add $t0, $t0, $a1			# ([i] * num of columns) + [j]
	sll $t0, $t0, 1				# Multiple by 2 (Number of bytes per cell) to obtain address increment
	li $t1, 0xffff0000			# Initialize base address of MMIO
	add $t0, $t0, $t1			# Add to base address to obtain cursor address
	li $t1, '\0'				# Intialize null character
	li $t2, 80				# Initialize row end
	clear_lineLoop:
		beq $a1, $t2, returnClear_line	# If the end of the row is reached, proceed to return function
		sb $t1, 0($t0)			# Set the ascii value at this cell address to null
		sb $a2, 1($t0)			# Set the color at this cell address to the designated color
		addi $t0, $t0, 2		# Increment the base address to traverse to the next cell
		addi $a1, $a1, 1		# Increment y to move counter to the next cell
		j clear_lineLoop		# Jump back to the loop
	
	returnClear_line:
	jr $ra

set_cursor:

	# Initial check
	li $t0, 1				# Intialize check
	beq $a3, $t0, updateSet_cursor		# If the initial is set to 1, branch straight to updating the cursor

	# Clear cursor
	lb $t0, 2($a0)				# Load x (row) position of cursor
	li $t1, 80				# Set temporary counter of number of columns
	mul $t0, $t0, $t1			# [i] * num of columns
	lb $t1, 3($a0)				# Load y (column) position of cursor
	add $t0, $t0, $t1			# ([i] * num of columns) + [j]
	sll $t0, $t0, 1				# Multiple by 2 (Number of bytes per cell) to obtain address increment
	li $t1, 0xffff0000			# Initialize base address of MMIO
	add $t0, $t0, $t1			# Add to base address to obtain cursor address
	
	lb $t1, 1($t0)				# Load color byte of cursor
	li $t2, 0x88				# Create mask for bold attributes of foreground and background
	xor $t1, $t1, $t2			# Invert bold bits
	sb $t1, 1($t0)				# Set new color byte to cursor
	
	# Update cursor
	updateSet_cursor:
	sb $a1, 2($a0)				# Update x (row) position in struct
	sb $a2, 3($a0)				# Update y (row) position in struct
	
	li $t0, 80				# Set temporary counter of number of columns
	mul $t0, $t0, $a1			# [i] * num of columns
	add $t0, $t0, $a2			# ([i] * num of columns) + [j]
	sll $t0, $t0, 1				# Multiple by 2 (Number of bytes per cell) to obtain address increment
	li $t1, 0xffff0000			# Initialize base address of MMIO
	add $t0, $t0, $t1			# Add to base address to obtain cursor address
	
	lb $t1, 1($t0)				# Load color byte of cursor
	li $t2, 0x88				# Create mask for bold attributes of foreground and background
	xor $t1, $t1, $t2			# Invert bold bits
	sb $t1, 1($t0)				# Set new color byte to cursor
	
	jr $ra

move_cursor:

	addi $sp, $sp, -4			# Add 4 bytes of memory allocation in the stack
    	sw $ra, 0($sp)				# Store the return address in the stack
	
	beq $a1, 'h', move_cursorLeft		# If the character is a 'h', proceed to move left
	beq $a1, 'j', move_cursorDown		# If the character is a 'j', proceed to move down
	beq $a1, 'k', move_cursorUp		# If the character is a 'k', proceed to move up
	beq $a1, 'l', move_cursorRight		# If the character is a 'l', proceed to move right
	j returnMove_cursor			# Otherwise, return and do nothing
	
	move_cursorLeft:
	lb $a1, 2($a0)				# Load x (row) position of cursor into second argument
	lb $a2, 3($a0)				# Load y (column) position of cursor into third argument
	beqz $a2, returnMove_cursor		# If the y position is already at [0], return and do nothing
	addi $a2, $a2, -1			# Else, decrement the y position
	li $a3, 0				# And set initial to 0
	jal set_cursor				# Call set_cursor function
	j returnMove_cursor			# Proceed to return function
	
	move_cursorDown:
	lb $a1, 2($a0)				# Load x (row) position of cursor into second argument
	lb $a2, 3($a0)				# Load y (column) position of cursor into third argument
	li $t0, 24				# Initialize end of column
	beq $a1, $t0, returnMove_cursor		# If the x position is already at [24], return and do nothing
	addi $a1, $a1, 1			# Else, increment the x position
	li $a3, 0				# And set initial to 0
	jal set_cursor				# Call set_cursor function
	j returnMove_cursor			# Proceed to return function
	
	move_cursorUp:
	lb $a1, 2($a0)				# Load x (row) position of cursor into second argument
	lb $a2, 3($a0)				# Load y (column) position of cursor into third argument
	beqz $a1, returnMove_cursor		# If the x position is already at [0], return and do nothing
	addi $a1, $a1, -1			# Else, decrement the x position
	li $a3, 0				# And set initial to 0
	jal set_cursor				# Call set_cursor function
	j returnMove_cursor			# Proceed to return function
	
	move_cursorRight:
	lb $a1, 2($a0)				# Load x (row) position of cursor into second argument
	lb $a2, 3($a0)				# Load y (column) position of cursor into third argument
	li $t0, 79				# Initialize end of row
	beq $a2, $t0, returnMove_cursor		# If the y position is already at [79], return and do nothing
	addi $a2, $a2, 1			# Else, increment the y position
	li $a3, 0				# And set initial to 0
	jal set_cursor				# Call set_cursor function
	j returnMove_cursor			# Proceed to return function
	
	returnMove_cursor:
	lw $ra, 0($sp)				# Restore return address from stack
	addi $sp, $sp, 4			# Reset the stack pointer
	jr $ra

mmio_streq:
	
	addi $sp, $sp, -12					# Add 12 bytes of memory allocation in the stack
    	sw $ra, 0($sp)						# Store the return address in the stack
    	sw $s0, 4($sp)						# Store reg[$s0] in the stack (Will be used later)
    	sw $s1, 8($sp)						# Store reg[$s1] in the stack (Will be used later)
	
	move $s0, $a0						# Move mmio string address to a saved variable
	move $s1, $a1						# Move b string address to a saved variable
	mmio_streqLoop:
		lb $a0, 0($s0)					# Load the first character of the mmio string into the first argument
		lb $a1, 0($s1)					# Load the first character of the b string into the second argument
		jal cmp_whitespace				# Call cmp_whitespace
		beqz $v0, compareStringChars			# If the function returns 0, proceed to compare both characters
		j returnMmio_streq				# Else return function with return value $v0 = 1
		compareStringChars:
			lb $t0, 0($s0)				# Load the first character of the mmio string
			lb $t1, 0($s1)				# Load the first character of the b string
			beq $t0, $t1, continueMmio_streqLoop	# If both characters are equal, proceed to continue loop
			j returnMmio_streq			# Else, return function with return value $v0 = 0
		continueMmio_streqLoop:
		addi $s0, $s0, 2				# Increment the address of the mmio string to the next cell
		addi $s1, $s1, 1				# Increment the address of the b string
		j mmio_streqLoop				# Jump back to the loop
					
	returnMmio_streq:
	lw $ra, 0($sp)						# Restore return address from stack
	lw $s0, 4($sp)						# Restore reg[$s0] from stack
	lw $s1, 8($sp)						# Restore reg[$s1] from stack
	addi $sp, $sp, 12					# Reset the stack pointer
	jr $ra

##################################
# Part 3 - UI/UX Functions
##################################

handle_nl:
	
	addi $sp, $sp, -8		# Add 8 bytes of memory allocation in the stack
    	sw $ra, 0($sp)			# Store the return address in the stack
    	sw $s0, 4($sp)			# Store reg[$s0] in the stack (Will be used later)
    	
    	move $s0, $a0			# Move struct address to a saved variable
    	add $a0, $s0, $0		# Copy struct address to first argument
    	li $a1, '\n'			# Initialize newline character at second argument
    	jal save_char			# Call save_char to add newline character at cursor
    	
    	add $a0, $s0, $0		# Copy struct address to first argument
    	li $a1, 'l'			# Initialize "move right" command at second argument
    	jal move_cursor			# Call move_cursor to move cursor to the right
    	
    	lb $a0, 2($s0)			# Load x (row) position of cursor into first argument
    	lb $a1, 3($s0)			# Load y (column) position of cursor into second argument
    	lb $a2, 0($s0)			# Load default color byte into third argument
    	jal clear_line			# Call clean_line to clear the rest of the line
    	
    	move $a0, $s0			# Move struct address back to first argument
    	lb $a1, 2($a0)			# Load x (row) position of cursor into the second argument
    	li $a2, 0			# Set new y (column) position to 0 at third argument
    	li $a3, 1			# Set initial to 1 at fourth argument (Will not clear at current cursor)
    	addi $a1, $a1, 1		# Increment x position
    	li $t0, 25			# Initialize last row check counter
    	beq $a1, $t0, newlineToStart	# If the cursor is at the last row, proceed to move newline to start
    	j continueHandle_nl		# Else continue function
    		newlineToStart:
    		li $a1, 0		# Set new x position to 0 at second argument
    	continueHandle_nl:
    	jal set_cursor			# Call set_cursor to move cursor to new line
    	j returnHandle_nl		# Return function
    	
	returnHandle_nl:
	lw $ra, 0($sp)			# Restore return address from stack
	lw $s0, 4($sp)			# Restore reg[$s0] from stack
	addi $sp, $sp, 8		# Reset the stack pointer
	jr $ra

handle_backspace:
	
	addi $sp, $sp, -16		# Add 16 bytes of memory allocation in the stack
    	sw $ra, 0($sp)			# Store the return address in the stack
    	sw $s0, 4($sp)			# Store reg[$s0] in the stack (Will be used later)
    	sw $s1, 8($sp)			# Store reg[$s1] in the stack (Will be used later)
    	sw $s2, 12($sp)			# Store reg[$s2] in the stack (Will be used later)
    	
    	lb $t0, 2($a0)			# Load x (row) position of cursor
	li $t1, 80			# Set temporary counter of number of columns
	mul $t0, $t0, $t1		# [i] * num of columns
	lb $t1, 3($a0)			# Load y (column) position of cursor
	add $t0, $t0, $t1		# ([i] * num of columns) + [j]
	sll $t0, $t0, 1			# Multiple by 2 (Number of bytes per cell) to obtain address increment
	li $t1, 0xffff0000		# Initialize base address of MMIO
	add $s0, $t0, $t1		# Add to base address to obtain cursor address at a saved variable
    	
    	li $t0, '\0'			# Initialize null character
    	sb $t0, 0($s0)			# Clear character at cursor
    	lb $t0, 0($a0)			# Load the default color
    	sb $t0, 1($s0)			# Set color at cursor to default
    	
    	move $s2, $a0			# Move the struct address to a saved variable
    	addi $s1, $s0, 2		# Set the next cell address into a saved variable
    	add $a0, $s1, $0		# Copy source to first argument
    	add $a1, $s0, $0		# Copy destination address to second argument
    	li $t0, 79			# Intialize end of row counter
    	lb $t1, 3($s2)			# Load y (column) position of cursor
    	sub $a2, $t0, $t1		# Subtract to obtain int n as third argument
    	sll $a2, $a2, 1			# Multiply by 2 to obtain n cells
    	jal strcpy			# Call strcpy ("strings" will be cells)
    	
    	lb $t0, 2($s2)			# Load x (row) position of cursor
	li $t1, 80			# Set temporary counter of number of columns
	mul $t0, $t0, $t1		# [i] * num of columns
	li $t1, 79			# Load column 79 (end of row)
	add $t0, $t0, $t1		# ([i] * num of columns) + [j]
	sll $t0, $t0, 1			# Multiple by 2 (Number of bytes per cell) to obtain address increment
	li $t1, 0xffff0000		# Initialize base address of MMIO
	add $t1, $t0, $t1		# Add to base address to obtain address of last cell at (x, 79)
	
    	li $t0, '\0'			# Initialize null character
    	sb $t0, 0($t1)			# Clear character at (x, 79)
    	lb $t0, 0($s2)			# Load the default color
    	sb $t0, 1($t1)			# Set color at (x, 79) to default
	
	returnHandle_backspace:
	lw $ra, 0($sp)			# Restore return address from stack
	lw $s0, 4($sp)			# Restore reg[$s0] from stack
	lw $s1, 8($sp)			# Restore reg[$s1] from stack
	lw $s2, 12($sp)			# Restore reg[$s2] from stack
	addi $sp, $sp, 16		# Reset the stack pointer
	jr $ra

highlight:
	
	li $t0, 80				# Set temporary counter of number of columns
	mul $t0, $t0, $a0			# [i] * num of columns
	add $t0, $t0, $a1			# ([i] * num of columns) + [j]
	sll $t0, $t0, 1				# Multiple by 2 (Number of bytes per cell) to obtain address increment
	li $t1, 0xffff0000			# Initialize base address of MMIO
	add $t0, $t0, $t1			# Add to base address to obtain (x,y) address
	
	li $t1, 0				# Initialize n counter
	highlightLoop:
		beq $t1, $a3, returnHighlight	# If all specified number of cells have been highlighted, proceed to return function
		sb $a2, 1($t0)			# Highlight this cell with the specified color
		addi $t0, $t0, 2		# Increment to the next cell
		addi $t1, $t1, 1		# Increment counter
		j highlightLoop			# Jump back to the loop
	
	returnHighlight:
	jr $ra

highlight_all:

	addi $sp, $sp, -28		# Add 20 bytes of memory allocation in the stack
    	sw $ra, 0($sp)			# Store the return address in the stack
    	sw $s0, 4($sp)			# Store reg[$s0] in the stack (Will be used later)
    	sw $s1, 8($sp)			# Store reg[$s1] in the stack (Will be used later)
    	sw $s2, 12($sp)			# Store reg[$s2] in the stack (Will be used later)
    	sw $s3, 16($sp)			# Store reg[$s3] in the stack (Will be used later)
    	sw $s4, 20($sp)			# Store reg[$s4] in the stack (Will be used later)
    	sw $s5, 24($sp)			# Store reg[$s5] in the stack (Will be used later)
	
	move $s0, $a0				# Move the highlight color byte to a saved variable
	move $s1, $a1				# Move the string array address to a saved variable
	li $s2, 0xffff0000			# Initialize base address of MMIO to a saved variable
	li $s3, 0xffff0fa0			# Initialize final address to a saved variable
	li $s4, 0				# Initialize x (row) position to 0 at a saved variable
	li $s5, 0				# Initialize y (column) position to 0 at a saved variable
	
	whileNotEndOfDisplayLoop:
	
		beq $s2, $s3, returnHighlight_all	# If every cell has been traversed, proceed to return function
		
		whileIsWhitespaceLoop:
		
			lb $a0, 0($s2)				# Load character byte of this cell
			jal is_whitespace			# Call is_whitespace function
			beqz $v0, preForEachWordLoop		# If the character is not a whitespace, proceed to continue function
			addi $s2, $s2, 2			# Else, traverse to the next cell
			addi $s5, $s5, 1			# Increment y position
			li $t0, 80				# Initialize end of row counter
			beq $t0, $s5, moveToNextRowCounterStart	# If the cell has reached the end of the row, proceed to the next row
			j whileIsWhitespaceLoop			# Else, jump back to whileIsWhitespaceLoop
			
			moveToNextRowCounterStart:
				addi $s4, $s4, 1			# Increment x position
				li $t0, 25				# Initialize end of column counter
				beq $t0, $s4, whileNotEndOfDisplayLoop	# If the cell has reached the end of the column, proceed to end super loop
				li $s5, 0				# Initialize y position back to 0
			j whileIsWhitespaceLoop				# Jump back to whileIsWhitespaceLoop
			
		preForEachWordLoop:
		addi $sp, $sp, -8				# Add 8 bytes of memory allocation in the stack
		sw $s1, 0($sp)					# Save the string array address in the stack
		sw $s2, 4($sp)					# Save the current cell address in the stack
		
		forEachWordLoop:
		
			move $a0, $s2				# Move current cell address into the first argument
			lw $a1, 0($s1)				# Load address from dictionary at this array index into the second argument
			li $t0, 0x00				# Initialize null entry
			beq $t0, $a1, postForEachWordLoop	# If the array index is null, proceed to continue function
			jal mmio_streq				# Call mmio_streq to compare both strings
			beqz $v0, moveToNextWord		# If both strings are not equal, proceed to move to the next word
			
			lw $a0, 0($s1)				# Else, load address again from dictionary at this array index into the first argument
			jal strlen				# Call strlen to calculate string length
			
			add $a0, $0, $s4			# Copy x position to the first argument
			add $a1, $0, $s5			# Copy y position to the second argument
			add $a2, $0, $s0			# Copy color byte to the third argument
			move $a3, $v0				# Move the result of n to the fourth argument
			jal highlight				# Call highlight function
			
			moveToNextWord:
			addi $s1, $s1, 4			# Increment to the next array index
			lw $s2, 4($sp)				# Load current cell address from stack
			
			j forEachWordLoop		# Jump back to forEachWordLoop
			
		postForEachWordLoop:
		lw $s1, 0($sp)				# Restore original string array address from stack
		lw $s2, 4($sp)				# Restore current cell address from stack
		addi $sp, $sp, 8			# Reset the stack pointer
		
		whileIsNotWhitespaceLoop:
			
			lb $a0, 0($s2)					# Load character byte of this cell
			jal is_whitespace				# Call is_whitespace function
			beqz $v0, continueWhileIsNotWhitespaceLoop	# If the character is not a whitespace, proceed to continue function
			j whileNotEndOfDisplayLoop			# Else, jump back to the super loop
			
			continueWhileIsNotWhitespaceLoop:
			addi $s2, $s2, 2				# Traverse to the next cell
			addi $s5, $s5, 1				# Increment y position
			li $t0, 80					# Initialize end of row counter
			beq $t0, $s5, moveToNextRowCounterEnd		# If the cell has reached the end of the row, proceed to the next row
			j whileIsNotWhitespaceLoop			# Else, jump back to whileIsNotWhitespaceLoop
			
			moveToNextRowCounterEnd:
				addi $s4, $s4, 1			# Increment x position
				li $t0, 25				# Initialize end of column counter
				beq $t0, $s4, whileNotEndOfDisplayLoop	# If the cell has reached the end of the column, proceed to end super loop
				li $s5, 0				# Else, initialize y position back to 0
			j whileIsNotWhitespaceLoop			# Jump back to whileIsNotWhitespaceLoop
			
		j whileNotEndOfDisplayLoop				# Jump back to the loop
			
	returnHighlight_all:
	lw $ra, 0($sp)			# Restore return address from stack
	lw $s0, 4($sp)			# Restore reg[$s0] from stack
	lw $s1, 8($sp)			# Restore reg[$s1] from stack
	lw $s2, 12($sp)			# Restore reg[$s2] from stack
	lw $s3, 16($sp)			# Restore reg[$s3] from stack
	lw $s4, 20($sp)			# Restore reg[$s4] from stack
	lw $s5, 24($sp)			# Restore reg[$s5] from stack
	addi $sp, $sp, 28		# Reset the stack pointer
	jr $ra
