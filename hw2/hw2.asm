# Homework #2
# name: Daniel Garcia
# sbuid: 111157499

# There should be no .data section in your homework!

.text

###############################
# Part 1 functions
###############################
recitationCount:

    #Define your code here
    
    	#___TEST FOR RNUM___
    	blt $a2, 8, recitationCountError		# If recitation number is less than 8, proceed to error
    	bgt $a2, 14, recitationCountError		# If recitation number is greater than 14, proceed to error
    	beq $a2, 11, recitationCountError		# If recitation number is equal to 11, proceed to error
    	
    	#___TEST FOR CLASS SIZE___
    	ble $a1, 0, recitationCountError		# If the class size is less than or equal to 0, proceed to error
    	
    	#___TEST FOR VALID ARGUMENTS___
    	addi $t0, $a0, 0				# Load the address of the class into a temporary reg[$t0]
    	li $v0, 0					# Initialize the return value to 0
    	li $t1, 0					# Initialize a student counter at reg[$t1]
    	recitationCountLoop:				# Loop to check each student's recitation number
    		beq $a1, $t1, returnRecitationCount	# If every student within the class size has been checked, proceed to return value
    		lb $t2, 14($t0)				# Load the byte containing the recitation number at reg[$t2]
		sll $t2, $t2, 28			# Shift leftmost bits in the byte by 28 to isolate rightmost bits (recitation value)
    		srl $t2, $t2, 28			# Shift right to reset original leftmost bits to 0 and obtain bit value of recitation
    		beq $a2, $t2, addStudentInRecitation	# If the recitation number of this student is equal to the argument, proceed to increment the return value
    		j continueRecitationCountLoop		# Else, continue the loop
    		addStudentInRecitation:
    			addi $v0, $v0, 1		# Increment the return value
    		continueRecitationCountLoop:
    			addi $t1, $t1, 1		# Increment the student counter
    			addi $t0, $t0, 16		# Increment by 16 to the class address to move on to the next student
    			j recitationCountLoop		# Jump back to the loop
	
	recitationCountError:
	li $v0, -1					# Set return value to -1 at reg[$v0]
	j returnRecitationCount				# Proceed to return value
	
	returnRecitationCount:
	jr $ra
	
aveGradePercentage:

    #Define your code here
    	
    	addi $t0, $a0, 0				# Load the address of the histogram into a temporary reg[$t0]
    	addi $t1, $a1, 0				# Load the address of the grades into a temporary reg[$t1]
    	li $v0, 0					# Initialize the return value to 0
    	li $t2, 0					# Initialize the total histogram count to 0 at reg[$t2]
    	li $t3, 0					# Initialize the entry counter to 0 at reg[$t3]
    	mtc1 $0, $f0 					# Initialize the total grade to 0 at floating point reg[$f0]
    	cvt.s.w $f0, $f0				# Convert this grade to a floating point value 0.0
    	mtc1 $0, $f9					# Initialize a 0 as a zero register at floating point reg[$f9]
    	cvt.s.w $f9, $f9				# Convert this 0 to a floating point value 0.0
    	aveGradePercentageLoop:
    		beq $t3, 12, evalAveGradePercentage	# If every entry has been checked, proceed to evaluate average
    		lw $t4, 0($t0)				# Load the integer of the histogram at this entry at reg[$t4]
    		bltz $t4, aveGradePercentageError	# If this integer is a negative value, proceed to error
    		addu $t2, $t2, $t4			# Else, add this integer to the total histogram count
    		lwc1 $f1, 0($t1)			# Load the grade float at this entry at floating point reg[$f1]
    		c.lt.s $f1, $f9 			# If this float is a negative value, set condition flag 0 to true
    		bc1t aveGradePercentageError		# If the condition  flag is true, proceed to error
    		mtc1 $t4, $f2				# Else, move the histogram integer to a floating point reg[$f2]
    		cvt.s.w $f2, $f2			# Convert this integer to a single-precision float
    		mul.s $f1, $f1, $f2			# Multiply the grade float and histogram integer
    		add.s $f0, $f0, $f1			# Add this float to the total grade
    		addi $t0, $t0, 4			# Increment the address of the historgram
    		addi $t1, $t1, 4			# Increment the address of the grades
    		addi $t3, $t3, 1			# Increment the entry counter
    		j aveGradePercentageLoop		# Continue the loop
    		
    	evalAveGradePercentage:
    		beqz $t2, aveGradePercentageError	# If the total grade count is 0, proceed to error
    		mtc1 $t2, $f3				# Move the total grade count integer to floating point reg[$f3]
    		cvt.s.w $f3, $f3			# Convert this integer into a floating point
    		div.s $f0, $f0, $f3			# Divide the total grades by the total grade count
    		mfc1 $v0, $f0				# Move this average into the the return value
    		j returnAveGradePercentage		# Proceed to return value
	
	aveGradePercentageError:
	li $v0, -1					# Set return value to -1 at reg[$v0]
	mtc1 $v0, $f0					# Move the return value to a floating point reg[$t1]
	cvt.s.w $f0, $f0				# Convert this to a floating point value -1.0
	mfc1 $v0, $f0					# Move the floating point back to the return value
	j returnAveGradePercentage			# Proceed to return value
	
	returnAveGradePercentage:
	jr $ra

favtopicPercentage:

    #Define your code here
	
	#___TEST FOR CLASS SIZE___
    	ble $a1, 0, favtopicPercentageError		# If the class size is less than or equal to 0, proceed to error
    	
    	#___TEST FOR TOPIC RANGE___
    	blt $a2, 1, favtopicPercentageError		# If the topic range is less than 1, proceed to error
    	bgt $a2, 15, favtopicPercentageError		# If the topic range is greater than 15, proceed to error
    	
    	#___TEST FOR VALID ARGUMENTS___
    	addi $t0, $a0, 0				# Load the address of the class into a temporary reg[$t0]
    	li $v0, 0					# Initialize the return value to 0
    	li $t1, 0					# Initialize a student counter at reg[$t1]
    	favtopicPercentageLoop:				# Loop to check each student's recitation number
    		beq $a1, $t1, evalFavtopicPercentage	# If every student within the class size has been checked, proceed to evaluate average
    		lb $t2, 14($t0)				# Load the byte containing the topics at reg[$t2]
		sll $t2, $t2, 24			# Shift leftmost bits in the byte by 24 to isolate the 8 rightmost bits
    		srl $t2, $t2, 28			# Shift right 28 bits to isolate and obtain the bit value of topics
    		and $t2, $t2, $a2			# Determine if the student likes any of the topics within the argument
    		bgtz $t2, addStudentInPercentage	# If the student likes any of the topics, proceed to add student in the percentage
    		j continuefavtopicPercentageLoop	# Else, continue the loop
    		addStudentInPercentage:
    			addi $v0, $v0, 1		# Increment the return value
    		continuefavtopicPercentageLoop:
    			addi $t1, $t1, 1		# Increment the student counter
    			addi $t0, $t0, 16		# Increment by 16 to the class address to move on to the next student
    			j favtopicPercentageLoop	# Jump back to the loop
    	
    	evalFavtopicPercentage:
    		mtc1 $v0, $f0				# Move to the total number of students into a floating point reg[$f0]
    		cvt.s.w $f0, $f0			# Convert this number into a floating point
    		mtc1 $t1, $f1				# Move the class size into a floating point reg[$t1]
    		cvt.s.w $f1, $f1			# Convert this size into a floating point
    		div.s $f0, $f0, $f1			# Divide the floating points and find the percentage
    		mfc1 $v0, $f0				# Move the resulting float back into the return value
    		j returnFavtopicPercentage		# Proceed to return value
	
	favtopicPercentageError:
	li $v0, -1					# Set return value to -1 at reg[$v0]
	mtc1 $v0, $f0					# Move the return value to a floating point reg[$t1]
	cvt.s.w $f0, $f0				# Convert this to a floating point value -1.0
	mfc1 $v0, $f0					# Move the floating point back to the return value
	j returnAveGradePercentage			# Proceed to return value
	
	returnFavtopicPercentage:
	jr $ra

findFavtopic:

    #Define your code here

	#___TEST FOR CLASS SIZE___
    	ble $a1, 0, findFavtopicError		# If the class size is less than or equal to 0, proceed to error
    	
    	#___TEST FOR TOPIC RANGE___
    	blt $a2, 1, findFavtopicError		# If the topic range is less than 1, proceed to error
    	bgt $a2, 15, findFavtopicError		# If the topic range is greater than 15, proceed to error
    	
    	#___TEST FOR VALID ARGUMENTS___#
    	addi $t0, $a0, 0				# Load the address of the class into a temporary reg[$t0]
    	li $v0, 0					# Initialize the return value to 0
    	li $t1, 0					# Initialize a student counter at reg[$t1]
    	li $t3, 0					# Initialize counter for "Data-Paths" at reg [$t3]
    	li $t4, 0					# Initialize counter for "Digital Logic" at reg[$t4]
    	li $t5, 0					# Initialize counter for "Boolean Logic" at reg[$t5]
    	li $t6, 0					# Initialize counter for "MIPS" at reg[$t6]
    	li $t7, 0					# Initialize placeholder for modified nibble at reg[$t7]
    	li $t9, 1					# Constant to check if topic at the rightmost bit for the student is 1
    	findFavtopicLoop:				# Loop to check each student's recitation number
    		beq $a1, $t1, evalFindFavtopic		# If every student within the class size has been checked, proceed to evaluate the favorite topic
    		lb $t2, 14($t0)				# Load the byte containing the topics at reg[$t2]
		sll $t2, $t2, 24			# Shift leftmost bits in the byte by 24 to isolate the 8 rightmost bits
    		srl $t2, $t2, 28			# Shift right 28 bits to isolate and obtain the bit value of topics
    		and $t2, $t2, $a2			# Determine the topics that the student likes within the argument
    		li $t8, 0				# Initialize counter for total topics at reg[$t8]
    		findFavtopicBitLoop:
    			beq $t8, 4, continueFindFavtopicLoop		# End loop to check each bit and continue to check each student
    			and $t7, $t2, $t9				# Check if the rightmost bit is 1
    			beq $t7, 1, addToTopic				# If it is 1, proceed to increment the specified topic
    			j continueFindFavtopicBitLoop			# Else, continue to the next bit
    			addToTopic:
    				beq $t8, 0, incrementData			# If this is the first bit, increment the Data counter
    				beq $t8, 1, incrementDigital			# If this is the second bit, increment the Digital counter
    				beq $t8, 2, incrementBoolean			# If this is the third bit, increment the Boolean counter
    				beq $t8, 3, incrementMIPS			# If this is the fourth bit, increment the MIPS counter
    				incrementData:
    					addi $t3, $t3, 1
    					j continueFindFavtopicBitLoop
    				incrementDigital:
    					addi $t4, $t4, 1
    					j continueFindFavtopicBitLoop
    				incrementBoolean:
    					addi $t5, $t5, 1
    					j continueFindFavtopicBitLoop
    				incrementMIPS:
    					addi $t6, $t6, 1
    					j continueFindFavtopicBitLoop
    			continueFindFavtopicBitLoop:
    			addi $t8, $t8, 1				# Increment total topics counter
    			srl $t2, $t2, 1					# Move to the next bit
    			j findFavtopicBitLoop				# Jump back to the loop
    		continueFindFavtopicLoop:
    		addi $t0, $t0, 16			# Increment by 16 to the class address to move on to the next student
    		addi $t1, $t1, 1			# Increment student counter
    		j findFavtopicLoop			# Jump back to the loop
    	
    	evalFindFavtopic:
    		add $t7, $t3, $t4					# Re-initialize reg[$t7] as total favorite topics
    		add $t7, $t7, $t5					# Add all the topic counters
    		add $t7, $t7, $t6					#	"	
    		beqz $t7, findFavtopicError				# If there are no favorite topics, proceed to error
    		bge $t4, $t3, winDigital				# | x | x | 1 | 0 |
    		j winData						# | x | x | 0 | 1 |
    		winDigital:
    			bge $t6, $t5, winDigitalAndMIPS			# | 1 | 0 | 1 | 0 |
    			j winDigitalAndBoolean				# | 0 | 1 | 1 | 0 |
    			winDigitalAndMIPS:
    				bge $t6, $t4, winMIPSFinal		# | 1 | 0 | 0 | 0 |
    				j winDigitalFinal			# | 0 | 0 | 1 | 0 |
    			winDigitalAndBoolean:
    				bge $t5, $t4, winBooleanFinal		# | 0 | 1 | 0 | 0 |
    				j winDigitalFinal			# | 0 | 0 | 1 | 0 |
    		winData:
    			bge $t6, $t5, winDataAndMIPS			# | 1 | 0 | 0 | 1 |
    			j winDataAndBoolean				# | 0 | 1 | 0 | 1 |
    			winDataAndMIPS:
    				bge $t6, $t3, winMIPSFinal		# | 1 | 0 | 0 | 0 |
    				j winDataFinal				# | 0 | 0 | 0 | 1 |
    			winDataAndBoolean:
    				bge $t5, $t3, winBooleanFinal		# | 0 | 1 | 0 | 0 |
    				j winDataFinal				# | 0 | 0 | 0 | 1 |
    		winDataFinal:
    			li $v0, 1			# 0 0 0 1
    			j returnFindFavtopic		# Proceed to return value
    		winDigitalFinal:
    			li $v0, 2			# 0 0 1 0
    			j returnFindFavtopic		# Proceed to return value
    		winBooleanFinal:
    			li $v0, 4			# 0 1 0 0
    			j returnFindFavtopic		# Proceed to return value
    		winMIPSFinal:
    			li $v0, 8			# 1 0 0 0
    			j returnFindFavtopic		# Proceed to return value
	
	findFavtopicError:
	li $v0, -1					# Set return valie to -1 at reg[$v0]
	j returnFindFavtopic				# Proceed to return value
	
	returnFindFavtopic:
	jr $ra

###############################
# Part 2 functions
###############################

twoFavtopics:

    #Define your code here
    	
    	# Place items in stack
    	addi $sp, $sp, -12			# Add 12 bytes of memory allocation in the stack
    	sw $ra, 0($sp)				# Store the return address in the stack
    	sw $s0, 4($sp)				# Store reg[$s0] in the stack (Will be used later)
    	sw $a2, 8($sp)				# Store reg[$a2] in the stack (Will be used later)
    	
    	li, $a2, 15				# Set the nibble to 1111 (Consider all topics)
    	jal findFavtopic			# Call findFavtopic
    	
    	beq $v0, 1, removeData			# If the favorite is "Data-Paths", proceed to not consider
    	beq $v0, 2, removeDigital		# If the favorite is "Digital Logic", proceed to not consider
    	beq $v0, 4, removeBoolean		# If the favorite is "Boolean Logic", proceed to not consider
    	beq $v0, 8, removeMIPS			# If the favorite is "MIPS", proceed to not consider
    	j twoFavtopicsError			# Else, proceed to return error for both outputs
    	
    	removeData:
    		li $a2, 14			# Set the nibble to 1110 (Don't consider Data-Paths)
    		j secondCallFindFavtopic	# Proceed to find the second favorite topic
    	
    	removeDigital:
    		li $a2, 13			# Set the nibble to 1101 (Don't consider Digital Logic)
    		j secondCallFindFavtopic	# Proceed to find the second favorite topic
    		
    	removeBoolean:
    		li $a2, 11			# Set the nibble to 1011 (Don't consider Boolean Logic)
    		j secondCallFindFavtopic	# Proceed to find the second favorite topic
    		
    	removeMIPS:
    		li $a2, 7			# Set the nibble ot 0111 (Don't consider MIPS)
    		j secondCallFindFavtopic	# Proceed to find the second favorite topic
    		
    	secondCallFindFavtopic:
    		move $s0, $v0			# Move the previous return value to a saved variable in reg[$s0]
    		jal findFavtopic		# Call findFavtopic
    		move $v1, $v0			# Move the return value to this function's second return value
    		move $v0, $s0			# Move the original return value back to this function's first return value
    		j returnTwoFavtopics		# Proceed to return values
    	
    	twoFavtopicsError:
    		li $v1, -1			# Set the second return value to -1
    		j returnTwoFavtopics		# Proceed to return values
    	
    	returnTwoFavtopics:
	lw $ra, 0($sp)				# Restore return address from stack
	lw $s0, 4($sp)				# Restore reg[$s0] from stack
	lw $a2, 8($sp)				# Restore reg[$a2] in the stack (Will be used later)
	addi $sp, $sp, 12			# Reset the stack pointer
	jr $ra

calcAveClassGrade:

    #Define your code here
	
	addi $sp, $sp, -24			# Add 24 bytes of memory allocation in the stack
	sw $ra, 0($sp)				# Store the return address in the stack
	sw $a0, 4($sp)				# Store the class argument in the stack
	sw $a1, 8($sp)				# Store the class size argument in the stack
	sw $s0, 12($sp)				# Store reg[$s0] in the stack (Will be used later)
	sw $s1, 16($sp)				# Store reg[$s1] in the stack (Will be used later)
	sw $s2, 20($sp)				# Store reg[$s2] in the stack (Will be used later)
	
	#___TEST FOR CLASS SIZE___
    	ble $a1, 0, calcAveClassGradeError	# If the class size is less than or equal to 0, proceed to error
	
	#___RESET HISTOGRAM___
	addi $s0, $a0, 0			# Place the address of the class into reg[$s0]
	addi $s1, $a2, 0			# Place the address of the histogram into a temporary reg[$t0]
	li $s2, 0				# Initialize counter for each student
	li $t0, 0				# Initialize counter for each histogram index
	
	resetHistogramLoop:
		beq $t0, 12, createHistogramLoop	# If the counter reaches the total array index, proceed to create class histogram
		sw $0, 0($s1)				# Reset the histogram count to 0 at this index
		addi $s1, $s1, 4			# Increment the address
		addi $t0, $t0, 1			# Increment the index counter
		j resetHistogramLoop			# Jump back to the loop
		
	createHistogramLoop:
		beq $a1, $s2, callAveGradePercentage	# If every student in the class size has been checked, proceed to calculate aveGradePercentage
		addi $s1, $a2, 0			# Reset address at reg[$s1]
		#addi $sp, $sp, -4			# Allocate 4 more bytes before calling getGradeIndex
		#sw $a0, 0($sp)				# Store $a0 in the stack
		lh $a0, 12($s0)				# Load the short into the first argument reg[$a0] at this class index
		jal getGradeIndex			# Call getGradeIndex
		beq $v0, -1, calcAveClassGradeError	# If it returns an invalid grade, proceed to error
		sll $v0, $v0, 2				# Multiply the index by 4
		add $s1, $s1, $v0			# Move to the index of the grade
		lw $t0, 0($s1)				# Load the current integer at this index
		addi $t0, $t0, 1			# Increment the integer
		sw $t0, 0($s1)				# Store the integer back into memory
		addi $s0, $s0, 16			# Move to the next student
		addi $s2, $s2, 1			# Increment the student counter
		j createHistogramLoop			# Jump back to the loop
	
	callAveGradePercentage:
		move $a0, $a2				# Move the histogram argument to the first argument
		move $a1, $a3				# Move the gradepoints argument to the second argument
		jal aveGradePercentage			# Call aveGradePercentage
		move $a2, $a2				# Restore the original argument
		move $a3, $a1				# Restore the original argument
		j returnCalcAveClassGrade
	
	calcAveClassGradeError:
		li $v0, -1					# Set return value to -1 at reg[$v0]
		mtc1 $v0, $f0					# Move the return value to a floating point reg[$t1]
		cvt.s.w $f0, $f0				# Convert this to a floating point value -1.0
		mfc1 $v0, $f0					# Move the floating point back to the return value
		j returnCalcAveClassGrade			# Proceed to return value
	
	returnCalcAveClassGrade:
	lw $ra, 0($sp)				# Restore return address from stack
	lw $a0, 4($sp)				# Restore the class argument from stack
	lw $a1, 8($sp)				# Restore the classSize argument from stack
	lw $s0, 12($sp)				# Restore reg[$s0] from stack
	lw $s1, 16($sp)				# Restore reg[$s1] from stack
	lw $s2, 20($sp)				# Restore reg[$s2] from stack
	addi $sp, $sp, 24			# Reset stack pointer
	jr $ra


updateGrades:

    #Define your code here

	addi $sp, $sp, -16				# Add 16 bytes of memory allocation in the stack
	sw $ra, 0($sp)					# Store the return address in the stack
	sw $a0, 4($sp)					# Store the class argument in the stack
	sw $s0, 8($sp)					# Store reg[$s0] in the stack (Will be used later)
	sw $s1, 12($sp)					# Store reg[$s1] in the stack (Will be used later)
	
	#___TEST FOR CLASS SIZE___
    	ble $a1, 0, updateGradesError			# If the class size is less than or equal to 0, proceed to error
    	
    	#___TEST FOR CUTOFFS___
    	li $t0, 0					# Initialize index pointer at reg[$t0]
    	addi $t1, $a2, 0				# Load the address of the float array into reg[$t1]
    	startCutoffCheckLoop:
    		beq $t0, 11, lastCutoffCheck		# If it has traversed through every cutoff, proceed to check the last cutoff
    		lwc1 $f0, 0($t1)			# Load cutoff[i] at floating point reg[$f0]
    		lwc1 $f1, 4($t1)			# Load cutoff[i+1] at floating point reg[$f1]
    		c.lt.s $f0, $f1				# If cutoff[i] is less than cutoff[i+1], set condition flag to true
    		bc1t updateGradesError			# If the condition flag is true, proceed to error
    		addi $t1, $t1, 4			# Else, move to the next cutoff pair
    		addi $t0, $t0, 1			# Increment the index pointer
    		j startCutoffCheckLoop			# Jump back to the loop
    		
    	lastCutoffCheck:
    		lwc1 $f0, 0($t1)			# Load cutoff[11] at floating point reg[$f0]
    		mtc1 $0, $f1				# Initialize a 0 as a zero register at floating point reg[$f1]
    		cvt.s.w $f1, $f1			# Convert this 0 to a floating point value 0.0
    		c.eq.s $f0, $f1				# If cutoff[11] is 0.0, set condition flag to true
    		bc1f updateGradesError			# If the condition flag is false, proceed to error
    		
    	#___UPDATE GRADES___
    	addi $s0, $a0, 0				# Load the address of the class into reg[$s0]
    	li $s1, 0					# Initialize a student index pointer at reg[$s1]
    	updateGradesLoop:
    		beq $a1, $s1, returnUpdateGrades	# If every student has been checked, proceed to return value
    		lwc1 $f0, 8($s0)			# Load the percentile of the student at this student index pointer
    		addi $t0, $a2, 0			# Load the address of the float array into reg[$t0]
    		li $a0, 0				# Initialize cutoff index pointer at reg[$0]
    		updateGradesCutoffLoop:
    			lwc1 $f1, 0($t0)		# Load the cutoff into floating point reg[$f1]
    			c.le.s $f1, $f0			# If the cutoff is less than the grade, set the condition flag to true
    			bc1t continueUpdateGradesLoop	# If it is true, proceed to get the grade
    			addi $t0, $t0, 4		# Else, move to the next cutoff
    			addi $a0, $a0, 1		# Increment the cutoff index
    			j updateGradesCutoffLoop	# Jump back to the cutoff loop
    		continueUpdateGradesLoop:
    		jal getGrade				# Get the grade of the index
    		sh $v0, 12($s0)				# Replace the grade in the current struct with the new grade
    		addi $s0, $s0, 16			# Go to the next student
    		addi $s1, $s1, 1			# Increment the student index pointer
    		li $v0, 0				# Set the return value to 0
    		j updateGradesLoop			# Jump back to the loop
	
	updateGradesError:
		li $v0, -1				# Set return value to -1 at reg[$v0]
		j returnUpdateGrades			# Proceed to return value

	returnUpdateGrades:
	lw $ra, 0($sp)					# Restore return address from stack
	lw $a0, 4($sp)					# Restore the class argument from stack
	lw $s0, 8($sp)					# Restore reg[$s0] from stack
	lw $s1, 12($sp)					# Restore reg[$s1] from stack
	addi $sp, $sp, 16				# Reset stack pointer
	jr $ra

###############################
# Part 3 functions
###############################

find_cheaters:

    #Define your code here
    
	addi $sp, $sp, -24				# # Add 16 bytes of memory allocation in the stack
	sw $s0, 0($sp)					# Store reg[$s0] in the stack (Will be used later)
	sw $s1, 4($sp)					# Store reg[$s1] in the stack (Will be used later)
	sw $s2, 8($sp)					# Store reg[$s2] in the stack (Will be used later)
	sw $s3, 12($sp)					# Store reg[$s3] in the stack (Will be used later)
	sw $s4, 16($sp)					# Store reg[$s4] in the stack (Will be used later)
	sw $s5, 20($sp)					# Store reg[$s5] in the stack (Will be used later)

	#___TEST FOR ROWS___
	ble $a1, 0, find_cheatersError			# If the rows is less than or equal to 0, proceed to error
	
	#___TEST FOR COLUMNS___
	ble $a2, 0, find_cheatersError			# If the columns is less than or equal to 0, proceed to error
	
	add $s0, $s0, $a0				# Load the address of the 2D array into reg[$s0]
	li $s1, 0					# Initialize row pointer at reg[$s1]
	li $s2, 0					# Initialize column pointer at reg[$s2]
	add $s3, $s3, $a3				# Load the address of the string array into reg[$s3]
	mul $s4, $a1, $a2				# Load the total number of seats into reg[$s4]
	li $s5, 0					# Initiaze student counter at reg[$s5]
	li $v0, 0					# Initialize first return value
	li $v1, 0					# Initialize second return value
	find_cheatersStudentLoop:
		beq $s4, $s5, returnFind_cheaters		# If every seat has been checked, proceed to return
		lw $t0, 4($s0)					# Load the address of the student at this index
		beqz $t0, continueFind_cheatersStudentLoop	# If there is no student at this index, move on to the next student
		addi $v1, $v1, 1				# Else, increment the second return value (Seat is not empty)
		lw $t0, 4($t0)					# Load the address of the student's netID at this index at reg[$t0]
		lw $t1, 0($s0)					# Load the grade of the student's exam at this index at reg[$t1]
		li $t8, -1					# Set initial index mover of rows to -1
		li $t9, -1					# Set initial index mover of columns to -1
		checkSurroundingRowNested:
			beq $t8, 2, continueFind_cheatersStudentLoop	# Once all adjacent rows have been checked, end nested loop
			add $t3, $s1, $t8				# Set temporary row pointer to [row of student + $t8]
			bltz $t3, moveToNextAdjacentRow			# If this row does not exist, proceed to move to the next adjacent row
			checkSurroundingColumnNested:			# Else, proceed to check surrounding columns
				beq $t9, 2, moveToNextAdjacentRow	# Once all adjacent columns have been checked, proceed to move to the next row
				add $t4, $s2, $t9			# Set temporary column pointer to [column of student + $t9]
				bltz $t4, moveToNextAdjacentColumn	# If this column does not exist, proceed to move to the next adjacent column
				or $t5, $t8, $t9			# ->
				beqz $t5, moveToNextAdjacentColumn	# If we are checking the current student's index, move to the next adjacent column
				# IF ALL CONDITIONS ARE MET, BEGIN CHECKING GRADE
				sll $t6, $a2,  3			# "
				mul $t6, $t6, $t3			# "
				sll $t7, $t4, 3				# "
				add $t6, $t6, $t7			# ($t3)($a2 * 8) + ($t4 * 8) = $t6 = Address of grade being checked
				add $t6, $t6, $a0			# $t6 = Final address of grade being checked
				lw $t6, 0($t6)				# Load the word(grade) into reg[$t6]
				beq $t6, $t1, foundCheater		# If grade is the same, end nested loop and proceed to code of founding cheater
				moveToNextAdjacentColumn:
				addi $t9, $t9, 1			# Increment index mover of columns
				j checkSurroundingColumnNested		# Jump back to column loop
			moveToNextAdjacentRow:
			addi $t8, $t8, 1				# Increment index mover of rows
			li $t9, -1					# Reset index mover of columns
			j checkSurroundingRowNested			# Jump back to row loop
		foundCheater:
			sw $t0, 0($s3)				# Add address of student netID to the string array
			addi $s3, $s3, 4			# Move the pointer of the string array to the next word
			addi $v0, $v0, 1			# Increment the first return value
			j continueFind_cheatersStudentLoop
			
		continueFind_cheatersStudentLoop:
		addi $s2, $s2, 1				# Increment the column pointer
		beq $s2, $a2, incRowResCol			# If the max column size is reached, move to the next row and reset the column pointer
		j finishFind_cheatersStudentLoop		# Else, just finish the loop and move on to the next student
			
		incRowResCol:
			addi $s1, $s1, 1		# Increment the row pointer
			li $s2, 0			# Reset column pointer
			j finishFind_cheatersStudentLoop		
		
		finishFind_cheatersStudentLoop:
		addi $s5, $s5, 1			# Increment the total seats counter
		addi $s0, $s0, 8			# Point to the address of the next student
		j find_cheatersStudentLoop		# Jump back to the loop
	
	find_cheatersError:
		li $v0, -1				# Set first return value to -1 at reg[$v0]
		li $v1, -1				# Set second return value to -1 at reg[$v1]
		j returnFind_cheaters			# Proceed to return values
		
	returnFind_cheaters:
	lw $s0, 0($sp)					# Restore reg[$s0] from stack
	lw $s1, 4($sp)					# Restore reg[$s1] from stack
	lw $s2, 8($sp)					# Restore reg[$s2] from stack
	lw $s3, 12($sp)					# Restore reg[$s3] from stack
	lw $s4, 16($sp)					# Restore reg[$s4] from stack
	lw $s5, 20($sp)					# Restore reg[$s5] from stack
	addi $sp, $sp, 24				# Reset stack pointer
	jr $ra

