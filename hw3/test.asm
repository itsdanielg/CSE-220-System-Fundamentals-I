.include "hw3.asm"

.data
newline: .asciiz "\n"
whitespaceTestOne: .byte 'a'
whitespaceTestTwo: .byte 'B'
whitespaceTestThree: .byte '\0'
whitespaceTestFour: .byte '\n'
whitespaceTestFive: .byte '%'
whitespaceTestSix: .byte ' '
test1: .asciiz "Hello World"
test2: .asciiz "abcdefghijklmnopqrstuvwxyz"
test3: .asciiz "THIS SENTENCE IS COMPLETE!"
test4: .asciiz "Hellow orld"
test5: .asciiz "Hellowo\0rld"
test6: .asciiz "Hellowor\nld"

.text
.globl main
main:

	### WHITESPACE CHECK ###
	### EXPECTED RESULTS: 001101
	lb $a0, whitespaceTestOne
	jal is_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall

	lb $a0, whitespaceTestTwo
	jal is_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestThree
	jal is_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestFour
	jal is_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestFive
	jal is_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestSix
	jal is_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	la $a0, newline
   	li $v0, 4
   	syscall
    	
    	### WHITESPACE  DOUBLE CHECK ###
	### EXPECTED RESULTS: 011101###
	
	lb $a0, whitespaceTestOne
	lb $a1, whitespaceTestThree
	jal cmp_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestThree
	lb $a1, whitespaceTestFour
	jal cmp_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestFour
	lb $a1, whitespaceTestSix
	jal cmp_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestThree
	lb $a1, whitespaceTestSix
	jal cmp_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestThree
	lb $a1, whitespaceTestFive
	jal cmp_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	lb $a0, whitespaceTestFour
	lb $a1, whitespaceTestFour
	jal cmp_whitespace
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	la $a0, newline
   	li $v0, 4
   	syscall
   	
   	### STRCPY CHECK ###
	### EXPECTED RESULTS: THIS fghijklmnopqrstuvwxyz ###
	
	la $a0, test3
	la $a1, test2
	li $a2, 5
	jal strcpy
	la $a0, test2
    	li $v0, 4
    	syscall
    	
    	la $a0, newline
   	li $v0, 4
   	syscall
   	
	
	### STRLEN CHECK ###
	### EXPECTED RESULTS: 52626678 ###
	
	la $a0, test1
	jal strlen
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	la $a0, test2
	jal strlen
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	la $a0, test3
	jal strlen
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	la $a0, test4
	jal strlen
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	la $a0, test5
	jal strlen
	move $a0, $v0
    	li $v0, 1
    	syscall
    	
    	la $a0, test6
	jal strlen
	move $a0, $v0
    	li $v0, 1
    	syscall