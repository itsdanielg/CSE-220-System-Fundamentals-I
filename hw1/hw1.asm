# Homework 1
# Name: Daniel Garcia
# Net ID: dmgarcia
# SBU ID: 111157499

.data
# include the file with the test case information
.include "Struct1.asm"  
# Float values to be compared
floatZero: .float 0.0
floatHundred: .float 100.0

.align 2  # word alignment 

numargs: .word 0
AddressOfNetId: .word 0
AddressOfId: .word 0
AddressOfGrade: .word 0
AddressOfRecitation: .word 0
AddressOfFavTopics: .word 0
AddressOfPercentile: .word 0

err_string: .asciiz "ERROR\n"

newline: .asciiz "\n"

updated_NetId: .asciiz "Updated NetId\n"
updated_Id: .asciiz "Updated Id\n"
updated_Grade: .asciiz "Updated Grade\n"
updated_Recitation: .asciiz "Updated Recitation\n"
updated_FavTopics: .asciiz "Updated FavTopics\n"
updated_Percentile: .asciiz "Updated Percentile\n"
unchanged_Percentile: .asciiz "Unchanged Percentile\n"
unchanged_NetId: .asciiz "Unchanged NetId\n"
unchanged_Id: .asciiz "Unchanged Id\n"
unchanged_Grade: .asciiz "Unchanged Grade\n"
unchanged_Recitation: .asciiz "Unchanged Recitation\n"
unchanged_FavTopics:  .asciiz "Unchanged FavTopics\n"

# Any new labels in the .data section should go below this 

# Helper macro for accessing command line arguments via Label
.macro load_args
    sw $a0, numargs
    lw $t0, 0($a1)
    sw $t0, AddressOfNetId
    lw $t0, 4($a1)
    sw $t0, AddressOfId
    lw $t0, 8($a1)
    sw $t0, AddressOfGrade
    lw $t0, 12($a1)
    sw $t0, AddressOfRecitation
    lw $t0, 16($a1)
    sw $t0, AddressOfFavTopics
    lw $t0, 20($a1)
    sw $t0, AddressOfPercentile
.end_macro

.globl main
.text
main:
    load_args()     # Only do this once
    # Your .text code goes below here
    
    # ____________________PART 1____________________
    
    # Arguments Check
    la $a0, numargs				# Load the address of numargs into reg[$a0]
    lw $s0, 0($a0)				# Load number of arguments into reg[$s0]
    bne $s0, 6, argumentError			# If it is not 6, branch to argumentError
    
    # ID Check				
    la $t0, AddressOfId				# Load the address of ID into reg[$t0]
    lw $a0, 0($t0)				# Load the word into reg[$a0]
    li $v0, 84					# Load immediate command to convert string into a 32-bit integer
    syscall					# Convert the string
    bnez $v1, argumentError			# If the string cannot be converted, branch to argumentError
    bltz $v0, argumentError			# If the number is less than 0, branch to argumentError
    addi $t0, $0, 999999999			# Set the limit of 999999999 to reg[$t0]
    bgt $v0, $t0, argumentError			# If the number is greater than 999999999, branch to argumentError
    move $s1, $v0				# Load the integer into reg[$s1]
    
    # NetID Check
    la $t0, AddressOfNetId			# Load the address of netID into reg[$t0]
    lw $s2, 0($t0)				# Load the string into reg[$s2]
    					
    # Percentile Check
    la $t0, AddressOfPercentile			# Load the address of percentile into reg[$t0]
    lw $a0, 0($t0)				# Load the word into reg[$a0]
    li $v0, 85					# Load the immediate command to convert string into a 32-bit float
    syscall					# Convert the string
    bnez $v1, argumentError			# If the string cannot be converted, branch to argumentError
    la $t0, floatZero				# Load the float value address of 0.0 into reg[$t0]
    lw $t1, 0($t0)				# Load the float value of 0.0 into reg[$t1]
    blt $v0, $t1, argumentError			# If the float is less than 0.0, branch to argumentError
    la $t0, floatHundred			# Load the float value address of 100.0 into reg[$t0]
    lw $t1, 0($t0)				# Load the float value of 100.0 into reg[$t1]
    bgt $v0, $t1, argumentError			# If the float is greater than 100, branch to argumentError
    move $s3, $v0				# Load the float into reg[$s3]
    
    # Grade Check
    la $t0, AddressOfGrade			# Load the address of grade into reg[$t0]
    lw $t0, 0($t0)				# Load the word intor reg[$t0]
    lb $s4, ($t0)				# Load the first byte of the word into reg[$s4]
    blt $s4, 'A', argumentError			# If the character is less than 'A', branch to argumentError
    bgt $s4, 'F', argumentError			# If the character is greater than 'F', branch to argumentError
    # Start second character check
    lb $s5, 1($t0)				# Load the next byte of the word into reg[$t1]
    beqz $s5, addSpaceToNull			# If the grade only has one character, finish grade check and continue code
    beq $s5, '+', gradeCheckContinue		# If the second character is '-', continue to check the grade
    beq $s5, '-', gradeCheckContinue		# If the second character is '+', continue to check the grade
    j argumentError				# Jump to argumentError if none of the conditions are met
    # Continue grade check
    gradeCheckContinue:
    lb $t1, 2($t0)				# Load the next byte of the word into reg[$t1]
    bnez $t1, argumentError			# If there are more characters to the grade, branch to argumentError
    j continueCode				# Else, continue to Recitation Check
    addSpaceToNull:
    addi $s5, $0, ' '				# Add space character to the null space
    
    # Recitation Check
    continueCode:
    la $t0, AddressOfRecitation			# Load the address of recitation into reg[$t0]
    lw $a0, 0($t0)				# Load the word into reg[$a0]
    li $v0, 84					# Load the immediate command to convert string into a 32-bit integer
    syscall					# Convert the string
    bnez $v1, argumentError			# If the string cannot be converted, branch to argumentError
    blt $v0, 8, argumentError			# If the integer is less than 8, branch to argumentError
    bgt $v0, 14, argumentError			# If the integer is greater than 14, branch to argumentError
    beq $v0, 11, argumentError			# If the integer is 11, branch to argumentError
    move $s6, $v0				# Load the integer into regjwong 123 C+ 9 1010 3.45[$s6]
    
    # FavTopics Check
    la $t0, AddressOfFavTopics			# Load the address of favTopics into reg[$t0]
    lw $t0, 0($t0)				# Load the word into reg[$t0]
    add $s7, $0, $0				# Nullify reg[$s7] to store current bits
    add $t2, $0, $0				# Initialize a pointer at index 0 to reg[$t2]
    bitCheckLoop:
    	beq $t2, 4, favTopicsContinue		# If the pointer is at index 4, end loop
    	lb $t1, 0($t0)				# Load the byte at this index of the string into reg[$t1]
    	beq $t1, '0', zeroBitUpdate		# If this byte is '0', branch to update next bit with zero
    	beq $t1, '1', oneBitUpdate		# If this byte is '1', branch to update next bit with one
    	j argumentError				# If none of the conditions are met, branch to argumentError
    	zeroBitUpdate:
    		sll $s7, $s7, 1			# Add zero to the rightmost bit by shifting the byte to the left by one bit
    		j continueBitCheckLoop		# Jump to continue loop
    	oneBitUpdate:
    		sll $s7, $s7, 1			# Add one to the rightmost bit by shifting the byte to the left by one bit
    		addi $s7, $s7, 1		# And then adding one to the byte
    		j continueBitCheckLoop		# Jump to continue loop
    	continueBitCheckLoop:
    		addi $t0, $t0, 1		# Increment the string address of the word
    		addi $t2, $t2, 1		# Increment the pointer
    		j bitCheckLoop
    favTopicsContinue:
    lb $t1, 0($t0)				# Load the fifth byte of the word into reg[$t1]
    bnez $t1, argumentError			# If this byte is not null, branch to argumentError
    
    # ____________________PART 2____________________
    
    la $t0, Student_Data			# Set and load the address of student data to reg[$t0]
    
    lw $t1, 0($t0)				# Load the first word of the student data (ID) at reg[$t1]
    bne $t1, $s1, idNotEqual			# If the data and argument are not equal, jump to update ID
    la $a0, unchanged_Id			# Else, load the address of the unchanged string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    j netIdCompare				# Go to the next argument
    idNotEqual:
    sw $s1, 0($t0)				# Set the value of the new ID into the old ID memory address of Student_Data
    la $a0, updated_Id				# Load the address of the updated string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    
    netIdCompare:
    lw $t1, 4($t0)				# Load the next word of the student data (netID) at reg [$t1]
    startCharacterLoop:
    	lb $t2, 0($t1)				# Load the character at this byte of the netID
    	lb $t3, 0($s2)				# Load the character at this byte of the argument
    	beqz $t2, endStringCheck		# If the byte of the netID is null, jump to check if argument byte is also null
    	bne $t2, $t3, netIdNotEqual		# If both characters are not equal, branch to update netID
    	addi $t1, $t1, 1			# Else, increment the string address of netID
    	addi $s2, $s2, 1			# And also increment the string of the argument
    	j startCharacterLoop			# Repeat the loop
    	endStringCheck:
    	beqz $t3, endCharacterLoop		# If the argument byte is also null, end the loop
    	j  netIdNotEqual			# Else end loop and update netID
    endCharacterLoop:
    la $a0, unchanged_NetId			# Else, load the addess of the unchanged string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    j percentileCompare				# Go to the next argument
    netIdNotEqual:
    la $a0, updated_NetId			# Load the address of the updated string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    la $s2, AddressOfNetId			# Reload the address of the argument netID
    lw $s2, 0($s2)				# Reload the word at reg[$s2]
    sw $s2, 4($t0)				# Set the value of the new netID into the old netID memory address of Student_Data
    
    percentileCompare:
    lw $t1, 8($t0)				# Load the next word of the student data (Percentile) at reg [$t1]
    bne $t1, $s3, percentileNotEqual		# If the data and argument are not equal, jump to update percentile
    la $a0, unchanged_Percentile		# Else, load the address of the unchanged string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    j gradeCompare				# Go to the next argument
    percentileNotEqual:
    sw $s3, 8($t0)				# Set the value of the new percentile into the old percentile memory address of Student_Data
    la $a0, updated_Percentile			# Load the address of the updated string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    
    gradeCompare:
    lb $t1, 12($t0)				# Load the first byte of the grade at reg[$t1]
    lb $t2, 13($t0)				# Load the second byte of the grade at reg[$t2]
    bne $t1, $s4, gradeNotEqual			# If the first byte of the grade data and argument are not equal, jump to update grade
    bne $t2, $s5, gradeNotEqual			# If the second byte of the grade data and argument are not equal, jump to update grade
    la $a0, unchanged_Grade			# Else, load the address of the unchanged string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    j recitationCompare				# Go to the next argument
    gradeNotEqual:
    sb $s4, 12($t0)				# Set the value of the new grade's first byte into the old first byte memory address of Student_Data
    sb $s5, 13($t0)				# Set the value of the new grade's second byte into the old second byte memory address of Student_Data
    la $a0, updated_Grade			# Load the address of the updated string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    
    recitationCompare:
    lb $t1, 14($t0)				# Load the last byte of the struct
    # Initial integer check
    blt $t1, 0, setRegToNeg			# If the integer is negative, mark it
    j continueRecitationCompare
    setRegToNeg:
    	addi $t5, $0, -1			# Mark this register to see if the integer is negative (Come back after favTopics check)
    continueRecitationCompare:
    sll $t1, $t1, 28				# Shift leftmost bits in the byte by 28 to isolate rightmost bits (recitation value)
    srl $t1, $t1, 28				# Shift right to reset original leftmost bits to 0 and obtain bit value of recitation
    bne $t1, $s6, recitationNotEqual		# If the data and argument are not equal, jump to update recitation
    la $a0, unchanged_Recitation		# Else, load the address of the unchanged string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    j favTopicsCompare				# Go to the next argument
    recitationNotEqual:
    la $a0, updated_Recitation			# Load the address of the updated string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    
    favTopicsCompare:
    lb $t1, 14($t0)				# Reload the last byte of the struct
    sll $t1, $t1, 24				# Shift leftmost bits in the byte by 24 to isolate the 8 rightmost bits
    srl $t1, $t1, 28				# Shift right 28 bits to isolate and obtain the bit value of favTopics
    bne $t1, $s7, favTopicsNotEqual		# If the data and argument are not equal, jump to update favTopics
    la $a0, unchanged_FavTopics			# Else, load the address of the unchanged string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    j updateLastByte				# Jump to updating the entire byte
    favTopicsNotEqual:
    la $a0, updated_FavTopics			# Load the address of the updated string into reg[$a0]
    li $v0, 4					# Load the immediate command to print the string
    syscall					# Print the string
    updateLastByte:
    sll $s7, $s7, 4				# Shift the bits to the left to obtain 4 0's for the right most bits
    add $t6, $s7, $s6				# Add the recitation and favTopics bits into reg[$t6]
    beq $t5, -1, updateToNeg			# If the previous byte was marked negative, update the new byte to negative
    sb $t6, 14($t0)				# Else, set the value of the new final byte into the old final byte memory address of Student_Data
    j printHexBytes				# Jump to printing the bytes
    updateToNeg:
    	sll $t6, $t6, 24			# Shift the bits to the left by 24 to reset the leftmost bits
    	sra $t6, $t6, 24			# Shift the bits to the right by arithmetic to change the sign of the bits
    	sb $t6, 14($t0)				# Set the value of the new final byte into the old final byte memory address of Student_Data
    
    printHexBytes:
    beq $t7, 15, terminateProgram		# If we have reached the last null byte of the struct, end the program
    lbu $a0, 0($t0)				# Load the unsigned byte at this memory address
    li $v0, 34					# Load the immediate command to print the hex
    syscall					# Print the hex
    la $a0, newline				# Load the newline address into reg[$a0]
    li $v0, 4					# Load the immediate command to print the newline
    syscall					# Print the newline
    addi $t0, $t0, 1				# Increment the address of the struct
    addi $t7, $t7, 1				# Increment the pointer
    j printHexBytes				# Jump back to the loop

argumentError:
	la $a0, err_string		# Load the address of err_string into reg[$a0]
	li $v0, 4			# Load immediate command of printing reg[$a0] string into reg[$v0]
	syscall				# Print the string
	j terminateProgram		# Jump to terminateProgram
    
terminateProgram:
    li $v0, 10
    syscall 				# Exit the program
